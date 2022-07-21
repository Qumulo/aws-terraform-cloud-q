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
#This script changes the EC2 EBS volume types
#This script depends on the cluster being deployed with the Qumulo Cloud Q Quick Start CloudFormation or aws-terraform-cloud-q Terraform scripts.
#This script is designed to run on a Mac/Linux machine with the AWS CLI configured.  
#If running it on an EC2 instance on AWS without the AWS CLI configured the following IAM permissions are required:
#	ec2:describe-instances
#	ec2:modify-volume
#	ec2:create-tags
#There are three scenarios:
#1. Change from st1->sc1 or sc1->st1
#2. Change from gp2->gp3 or gp3->gp2
#3. Modify gp3 throughput and iops which is a gp3->gp3 use case

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
	    vName="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -o|--oldtype)
	    vOldType="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -n|--newtype)
	    vNewType="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -i|--iops)
	    vIops="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -t|--throughput)
	    vThroughput="$2"
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

if [ -z "$vName" ]; then
	echo "	MISSING Parameter: Tag Name is required, cut and paste from AWS EC2 Volumes Console View"
	fail="true"
else
	echo "	*Volume Tag Name = $vName"
fi

if [ -z "$vOldType" ]; then
	echo "	MISSING Parameter: Current Volume Type is required: gp2, gp3, sc1, st1"
	fail="true"
else
	echo "	*Old Volume Type = $vOldType"
fi

if [ -z "$vNewType" ]; then
	echo "	MISSING Parameter: New Volume Type is required: gp2, gp3, sc1, st1"
	fail="true"
else
	echo "	*New Volume Type = $vNewType"
fi

if [ -z "$vIops" ] && [ "$vNewType" = "gp3" ]; then
	echo "	   - gp3 IOPS = 3000"
	vIops="3000"
elif ((( 10#$vIops > 16000 )) || (( 10#$vIops < 3000 ))) && [ "$vNewType" = "gp3" ]; then
	echo "	INVALID Parameter: gp3 IOPS must be between 3000-16000"
	fail="true"
elif [ -z "$fail" ]; then
	echo "	   - gp3 IOPS = $vIops"	
fi

if [ -z "$vThroughput" ] && [ "$vNewType" = "gp3" ]; then
	echo "	   - gp3 Throughput = 250 MB/s"
	vThroughput="250"
elif ((( 10#$vThroughput > 1000 )) || (( 10#$vThroughput < 125 ))) && [ "$vNewType" = "gp3" ]; then
	echo "	INVALID Parameter: gp3 Throughput must be between 125-1000 MB/s"
	fail="true"	
elif [ -z "$fail" ]; then
	echo "	   - gp3 Throughput = $vThroughput"
fi

echo ""
vUpdate="false"

if [ -z "$fail" ]; then
	if [ "$vOldType" = "gp2" ] && [ "$vNewType" = "gp3" ]; then
		echo "	--Changing gp2 -> gp3"
	elif [ "$vOldType" = "gp3" ] && [ "$vNewType" = "gp2" ]; then
		echo "	--Changing gp3 -> gp2"
	elif [ "$vOldType" = "sc1" ] && [ "$vNewType" = "st1" ]; then
		echo "	--Changing sc1 -> st1"
	elif [ "$vOldType" = "st1" ] && [ "$vNewType" = "sc1" ]; then
		echo "	--Changing st1 -> sc1"
	elif [ "$vOldType" = "gp3" ] && [ "$vNewType" = "gp3" ]; then
		echo "	--Changing gp3 IOPS & Throughput"	
		vUpdate="true"
	else
		echo "	**Can Only change between gp2 and gp3, sc1 and st1, or update gp3 IOPS and Throughput. Review inputs."
		fail="true"
	fi
fi

if [ -z "$fail" ]; then
	echo "	--Finding $vOldType EBS Volumes With Tag Name= $vName"
else
	echo "	***This script is designed to work with the Qumulo Cloud Q Quick Start CloudFormation or aws-terraform-cloud-q Terraform provisioning scripts that generated EBS Volume Tags"
	echo "	***COMMAND Structure: modify-vol-types.sh --region <aws region> --tagname <name> --oldtype <ebs vol type> --newtype <ebs vol type> [--iops <gp3 iops> --throughput <gp3 throughput>]"
	exit
fi

volIds+=($(aws ec2 describe-volumes --region "$region" --filter "Name=tag:Name, Values=$vName" "Name=volume-type, Values=$vOldType" --query "Volumes[].VolumeId" --out "text"))

if [ "$vUpdate" = "true" ]; then
	volIops+=($(aws ec2 describe-volumes --region "$region" --filter "Name=tag:Name, Values=$vName" "Name=volume-type, Values=$vOldType" --query "Volumes[].Iops" --out "text"))
	volTput+=($(aws ec2 describe-volumes --region "$region" --filter "Name=tag:Name, Values=$vName" "Name=volume-type, Values=$vOldType" --query "Volumes[].Throughput" --out "text"))
fi

if [ ${#volIds} -eq 0 ]; then
	echo "	**No $vOldType EBS Volumes found with Tag Name= $vName"
	exit
else
	if [ "$vUpdate" = "false" ]; then
		echo "	--Modifying ${#volIds[@]} Volumes from $vOldType to $vNewType"
		if [ "$vNewType" = "gp3" ] && [ "$vUpdate" = "false" ]; then
			echo "	  - gp3 IOPS = $vIops"	
			echo "	  - gp3 Throughput = $vThroughput"
		fi
	else
		echo "	--Modifying Throughput and IOPS for ${#volIds[@]} $vNewType Volumes"	
		for m in "${!volIds[@]}"; do
			echo "    - ${volIds[m]} modifying IOPS from ${volIops[m]} to $vIops, Throughput from ${volTput[m]} to $vThroughput"
		done
	fi
fi

subTag=${vName%???}
boot=${vName: -4}

for m in "${!volIds[@]}"; do
	if [ "$vNewType" = "gp3" ]; then
		aws ec2 modify-volume --region "$region" --volume-type "$vNewType" --volume-id "${volIds[m]}" --iops "$vIops" --throughput "$vThroughput"
	else
		aws ec2 modify-volume --region "$region" --volume-type "$vNewType" --volume-id "${volIds[m]}"
	fi

	if [ "$vUpdate" = "false" ] && [ "$boot" != "boot" ]; then
		aws ec2 create-tags --region "$region" --resources "${volIds[m]}" --tags "Key=Name,Value=$subTag$vNewType"
	fi
done 

