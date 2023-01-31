#!/bin/bash -e

# MIT License
#
# Copyright (c) 2021 Qumulo, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal 
#  in the Software without restriction, including without limitation the rights 
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
#  copies of the Software, and to permit persons to whom the Software is 
#  furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
# SOFTWARE.

#README********README*********README********************************************************
#This script tags the EBS volumes, by type, associated with one or more EC2 instances
#This script is designed to run on a Mac/Linux machine with the AWS CLI configured.  
#If running it on an EC2 instance on AWS without the AWS CLI configured the following IAM permissions are required:
#	ec2:describe-instances
#	ec2:modify-volume
#	ec2:create-tags
#If you are creating resource group with this script, you require the following additional IAM permissions. 
#   resource-groups:CreateGroup
#   ec2:DescribeTags

POSITIONAL=()

while [[ $# -gt 0 ]]; do
key="$1"

	case $key in
		-r|--region)
	    region="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -t|--tagname)
	    vname="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -c|--cloudwatch)
	    cw_rg="$2"
	    shift # past argument
	    shift # past value
	    ;;		
	    -i|--ec2-idlist)
	    instance_ids="$2"
	    shift # past argument
	    shift # past value
	    ;;			
	    *)    # unknown option
	    POSITIONAL+=("$1") # save it in an array for later
	    shift # past argument
	    ;;
	esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo ""

if [ -z "$region" ]; then
	echo "	MISSING Parameter: Region is required, like us-west-2"
	fail="true"
else
	echo "	*AWS Region = $region"
fi

if [ -z "$vname" ]; then
	echo "	MISSING Parameter: EBS Tag Name is required"
	fail="true"
else
	echo "	*EBS Volume Tag Name = $vname"
fi

if [ -z "$instance_ids" ]; then
	echo "	MISSING Parameter: One or more EC2 Instance IDs is required.  Comma delimited in one set of quotes."
	fail="true"
else
	echo "	*EC2 Instance IDs = $instance_ids"
fi

if [ -z "$cw_rg" ]; then
	echo "	*NOT creating Cloudwatch resource groups"
	cw_rg="false"
elif [ "$cw_rg" == "true" ]; then
	echo "	*Creating Cloudwatch resource groups (SSD/HDD) for EBS Volumes"
else
	echo "	*NOT creating Cloudwatch resource groups"
	cw_rg="false"	
fi

echo ""

if [ -z "$fail" ]; then
	echo "	--Finding EBS Volumes for EC2 Instance ID(s)"
	echo ""
else
	echo "	***COMMAND Structure: tag-vols.sh --region <aws region> [--cloudwatch true] --tagname <name> --ec2-idlist <\"i-0123456789abcdefa, i-0123456789abcdefa, ...\">"
	exit
fi

IFS=', ' read -r -a id_list <<< "$instance_ids"
numVols=0
af="true"

for m in "${!id_list[@]}"; do 
	ec2Name=$(aws ec2 describe-tags --region us-west-2  --filter "Name=resource-id, Values=${id_list[m]}" --query "Tags[].Value" --out "text")
	echo "	--EC2 Instance = ${id_list[m]}, $ec2Name"
	bootIDs+=($(aws ec2 describe-volumes --region $region --filter "Name=attachment.instance-id, Values=${id_list[m]}" "Name=attachment.device, Values=/dev/sda*" --query "Volumes[].VolumeId" --out "text"))  

	gp2IDs=($(aws ec2 describe-volumes --region $region --filter "Name=attachment.instance-id, Values=${id_list[m]}" "Name=attachment.device, Values=/dev/x*" "Name=volume-type, Values=gp2" --query "Volumes[].VolumeId" --out "text"))
	if [ ${#gp2IDs[@]} -gt 0 ]; then
	  numVols=$(($numVols+${#gp2IDs[@]}))
	  echo "	    - Applying tag Name = $vname-gp2"		  
	  echo "	    - Tagging gp2 volumes: ${gp2IDs[@]}"		
	  aws ec2 create-tags --region $region --resources ${gp2IDs[@]} --tags "Key=Name,Value=$vname-gp2" 
	  echo ""	  
	fi    

	gp3IDs=($(aws ec2 describe-volumes --region $region --filter "Name=attachment.instance-id, Values=${id_list[m]}" "Name=attachment.device, Values=/dev/x*" "Name=volume-type, Values=gp3" --query "Volumes[].VolumeId" --out "text"))
	if [ ${#gp3IDs[@]} -gt 0 ]; then
	  numVols=$(($numVols+${#gp3IDs[@]}))
	  echo "	    - Applying tag Name = $vname-gp3"		  
	  echo "	    - Tagging gp3 volumes: ${gp3IDs[@]}"
	  aws ec2 create-tags --region $region --resources ${gp3IDs[@]} --tags "Key=Name,Value=$vname-gp3" 
	  echo ""	 	  
	fi   

	st1IDs=($(aws ec2 describe-volumes --region $region --filter "Name=attachment.instance-id, Values=${id_list[m]}" "Name=attachment.device, Values=/dev/x*" "Name=volume-type, Values=st1" --query "Volumes[].VolumeId" --out "text"))
	if [ ${#st1IDs[@]} -gt 0 ]; then
	  af="false"
	  numVols=$(($numVols+${#st1IDs[@]}))
	  echo "	    - Applying tag Name = $vname-st1"		  
	  echo "	    - Tagging st1 volumes: ${st1IDs[@]}"	
	  aws ec2 create-tags --region $region --resources ${st1IDs[@]} --tags "Key=Name,Value=$vname-st1"
	  echo ""	 	  
	fi   

	sc1IDs=($(aws ec2 describe-volumes --region $region --filter "Name=attachment.instance-id, Values=${id_list[m]}" "Name=attachment.device, Values=/dev/x*" "Name=volume-type, Values=sc1" --query "Volumes[].VolumeId" --out "text"))                           
	if [ ${#sc1IDs[@]} -gt 0 ]; then
	  af="false"	
	  numVols=$(($numVols+${#sc1IDs[@]}))		
	  echo "	    - Applying tag Name = $vname-sc1"		  
	  echo "	    - Tagging sc1 volumes: ${sc1IDs[@]}"	
	  aws ec2 create-tags --region $region --resources ${sc1IDs[@]} --tags "Key=Name,Value=$vname-sc1"
	  echo ""	 	  
	fi   
done

if [ ${#bootIDs[@]} -gt 0 ]; then
	numVols=$(($numVols+${#bootIDs[@]}))	
	echo "	--EC2 Boot Volumes"	
	echo "	    - Applying tag Name = $vname-boot"		
	echo "	    - Tagging EC2 boot volumes: ${bootIDs[@]}"	
	aws ec2 create-tags --region $region --resources ${bootIDs[@]} --tags "Key=Name,Value=$vname-boot"	
	echo ""
fi

if [ "$cw_rg" == "true" ]; then
	echo "	--Creating Cloudwatch Resource Groups"	
	rg_ssd=$(aws resource-groups create-group --region $region --name "Qumulo-Cluster-SSD-$vname" --resource-query '{ "Type": "TAG_FILTERS_1_0", "Query": "{\"ResourceTypeFilters\":[\"AWS::AllSupported\"],\"TagFilters\":[{\"Key\":\"Name\",\"Values\":[\"'$vname'-gp2\",\"'$vname'-gp3\"]}]}"}' --query Group.Name --output text)
	echo "	    - Created resource group = $rg_ssd"		
	if [ "$af" == "false" ]; then
		rg_hdd=$(aws resource-groups create-group --region $region --name "Qumulo-Cluster-HDD-$vname" --resource-query '{ "Type": "TAG_FILTERS_1_0", "Query": "{\"ResourceTypeFilters\":[\"AWS::AllSupported\"],\"TagFilters\":[{\"Key\":\"Name\",\"Values\":[\"'$vname'-st1\",\"'$vname'-sc1\"]}]}"}' --query Group.Name --output text)
		echo "	    - Created resource group = $rg_hdd"			
	fi
	echo ""
fi

echo "	**Completed - Tagged $numVols Volumes**"
