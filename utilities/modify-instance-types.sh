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
#This script changes the EC2 instance type for a cluster.
#This script depends on the cluster being deployed with the Qumulo Cloud Q Quick Start CloudFormation or aws-terraform-cloud-q Terraform scripts.
#This script is designed to run on an AWS Linux 2 AMI with the AWS CLI configured OR the following IAM privileges configured on the EC2 instance:
#	ssm:get-parameter
#	ec2:describe-instances
#	ec2:stop-instances
#	ec2:modify-instance-attribute
#	ec2:start-instances
#The AWS Linux EC2 instance must have connectivity to the cluster on port 8000 and 443.
#Stackname required here is the top-level stackname from CloudFormation or the deployment_unique_name from Terraform
#The Cluster Instances must all be running or all be stopped.
#The Cluster Instances must all have the same instance type.
#At completion the cluster will be left in the original state, running or stopped.
#There are three scenarios:
#1. All nodes running, inservice=yes:
#   In this case each instance is modified one at a time so the cluster remains operational
#2. All nodes running, inserive=no:
#   In this case all instances are shutdown, modifed, and restarted
#3. All nodes stopped, inservice=(not applicable)
#   In this case the instance types are modified and left in the stopped state

#Get Inputs and validate
#-----------------------
POSITIONAL=()

while [[ $# -gt 0 ]]; do
key="$1"

	case $key in
		-r|--region)
	    region="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -t|--qstackname)
	    QStackName="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -n|--newtype)
	    iNewType="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -c|--nodecount)
	    nodeCount="$2"
	    shift # past argument
	    shift # past value
	    ;;
	    -r|--inservice)
	    inService="$2"
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
echo "    **Input Echo"

if [ -z "$region" ]; then
	echo "	MISSING Parameter: Region is required, like us-west-2"
	fail="true"
else
	echo "	*AWS Region = $region"
fi

if [ -z "$QStackName" ]; then
	echo "	MISSING Parameter: CloudFormation= Top-level Stack Name is required, cut and paste from CloudFormation. For example TestVA" 
	echo "	                   Terraform= Terraform Deployment Unique Name available in outputs.  For example TestVA-GN6MF5H0SXA"
	echo "	                   Cluster must be built with Qumulo Cloud Q Quick Start Cloudformation or aws-terraform-cloud-q Terraform scripts"
	fail="true"
else
	echo "	*Nested Stack Name (CFN) or Deployment Unique Name (TFN) = $QStackName"
fi

if [ -z "$iNewType" ]; then
	echo "	MISSING Parameter: New Instance Type is required: m5.[xlarge-24xlarge], c5n.[4xlarge-18xlarge]"
	fail="true"
else
	echo "	*New Instance Type = $iNewType"
fi

if [ -z "$nodeCount" ]; then
	echo "	MISSING Parameter: Cluster Total Node Count is required: 4 to 10 nodes"
	fail="true"
else
	echo "	*Node Count = $nodeCount"
fi

if [ -z "$inService" ]; then
	echo "	MISSING Parameter: In Service is required: yes or no"
	echo "	                   yes= nodes stopped, modified, restarted one at a time"
	echo "	                   no= all instances stopped, modified, restarted"
	echo "	                   Note: For large cluster placement groups in service upgrades may fail to place upon restart"
	fail="true"
else
	echo "	*In Service = $inService"
fi

echo ""
echo "    **Parameter, Cluster, and Instance Verification"

case $iNewType in
	m5.xlarge)
 		echo "	--New instance type $iNewType confirmed"
 		;;
	m5.2xlarge)
 		echo "	--New instance type $iNewType confirmed"
 		;;
 	m5.4xlarge)
 		echo "	--New instance type $iNewType confirmed"
 		;;
 	m5.8xlarge)
 		echo "	--New instance type $iNewType confirmed"
 		;;
 	m5.12xlarge)
 		echo "	--New instance type $iNewType confirmed"
 		;;
 	m5.16xlarge)
 		echo "	--New instance type $iNewType confirmed"
 		;;
 	m5.24xlarge)
 		echo "	--New instance type $iNewType confirmed"
 		;;
 	c5n.4xlarge)
 		echo "	--New instance type $iNewType confirmed"
 		;;
 	c5n.9xlarge)
 		echo "	--New instance type $iNewType confirmed"
 		;;
 	c5n.18xlarge)
 		echo "	--New instance type $iNewType confirmed"
 		;;
 	*)
 		echo "  !!Invalid instance type $iNewType.  Use lower case and verify instance type."
 		fail="true"
 		;;
esac

case $inService in
	[yY] | [yY][Ee][Ss] )
    	echo "	--In Service modification confirmed as yes, one instance at a time will be modified"
    	inService="yes"
        ;;
    [nN] | [nN][Oo] )
    	echo "	--In Service modification confirmed as no, will stop all instances and modify"
    	inService="no"
        ;; 
 	*)
 		echo "  !!Invalid In Service parameter= $inService.  yes or no."
 		fail="true"
 		;;
esac

if [ -z "$fail" ]; then
	echo "	--Finding EC2 Instance Types With QSTACK Nested Stack Name= $QStackName"
else
	echo "  ***COMMAND Structure: modify-instance-types.sh --region <aws region> --qstackname <nested stack name> --newtype <ec2 instance type> --nodecount <number of nodes in cluster> --inservice <yes/no>"
	echo "  ***This script is designed to work with the Qumulo Cloud Q Quick Start CloudFormation or aws-terraform-cloud-q Terraform provisioning scripts that provisioned the cluster AND any node additions"
	exit
fi

#Grab instance IDs out of Parameter Store, validate count, and then get the IPs, types, and states for each
#----------------------------------------------------------------------------------------------------------
IFS=', ' read -r -a instanceIDs <<< $(aws ssm get-parameter --region "$region" --name "/qumulo/$QStackName/instance-ids" --query "Parameter.Value" --output "text")

if [ ${#instanceIDs[@]} = 0 ]; then
	echo "  !!No EC2 Instances found with QSTACK Nested Stack Name= $QStackName"
	exit
elif [ ${#instanceIDs[@]} = $nodeCount ]; then 
	echo "	--$nodeCount Instances found as expected"
else
	echo "  !!Instance count found not expected.  Found ${#instanceIDs[@]} instances, Expected $nodeCount instances"
	exit
fi

echo "	--Getting instance types, IPs, and operational state"
echo -n "	  "
for m in "${!instanceIDs[@]}"; do 
	nodeIPs+=($(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].PrivateIpAddress" --out "text"))
	echo -n "*"
	instanceTypes+=($(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].InstanceType" --out "text"))
	echo -n "*"	
	instanceStates+=($(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].State.Name" --out "text"))	
	echo -n "*"	
done

echo " "

#Check that all instances are running on the same instance type and that the new type is different than the current type
#-----------------------------------------------------------------------------------------------------------------------
old_match=0
old_mismatch=0
for m in "${!instanceTypes[@]}"; do 
	if [ "${instanceTypes[m]}" = "${instanceTypes[0]}" ]; then
		(( old_match = old_match + 1 ))
	else
		(( old_mismatch = old_mismatch + 1 ))
	fi
done

if [ ${#instanceTypes[@]} = $old_match ]; then 
	echo "	--$old_match EC2 Instances currently using ${instanceTypes[0]} instance type"
else
	echo "  !!$old_mismatch instances not using the same instance type.  Rectify and rerun script. Exiting."
	echo "  !!${instanceTypes[@]}"
	exit
fi

if [ "$iNewType" = "${instanceTypes[0]}" ]; then
	echo "  !!Current cluster using the same instance type as requested $iNewType.  Exiting."
	exit
fi

#Grab QQ from the cluster
#------------------------
if [[ -e "qq" ]]; then
  	echo "	--qq installed already"
else
  	wget --no-check-certificate https://${nodeIPs[0]}/static/qq
  	chmod 777 ./qq                
fi

#Check for either a fully running cluster or a fully stopped cluster and validate quorum
#---------------------------------------------------------------------------------------

stopped=0;
for m in "${!instanceStates[@]}"; do
	if [ "${instanceStates[m]}" = "stopped" ]; then
		(( stopped = stopped + 1 ))
		echo "	--Instance ${instanceIDs[m]} not running"
	fi
done

if [ $stopped = 0 ]; then
	echo "	--Cluster instances all running"
elif [ $stopped != $nodeCount ]; then
	echo "  !!Cluster instances are in a mixed operational state. All instances must be running or stopped. Rectify and rerun script."
	echo "  !!${instanceStates[@]}"
	exit	
else
	echo "	--Cluster instances all stopped. Modifying ${#instanceIDs[@]} Instances to $iNewType"
fi

if [ $stopped = 0 ]; then
	out_quorum=0
	in_quorum=0
	for m in "${!instanceIDs[@]}"; do
		quorum=$(./qq --host ${nodeIPs[m]} node_state_get)
		if [[ "$quorum" != *"ACTIVE"* ]]; then
			(( out_quorum = out_quorum + 1 ))
		else
			(( in_quorum = in_quorum + 1 ))
		fi
	done   

	if [ ${#instanceIDs[@]} = $in_quorum ]; then 
		echo "	--$in_quorum Nodes in quorum as expected. Modifying ${#instanceIDs[@]} Instances to $iNewType"
	else
		echo "  !!One or more nodes out of quorum.  $out_quorum instances out of quorum."
		exit
	fi
fi

echo ""
echo "    **Cluster Instance Type Modification"

#All instances running and inservice=yes, one instance at a time modification
#----------------------------------------------------------------------------
if [ "$inService" = "yes" ] && [ $stopped = 0 ]; then
	for m in "${!instanceIDs[@]}"; do
		(( n = m + 1 ))

		echo "      *Node$n - Instance ID ${instanceIDs[m]}"

		if [ "$inService" = "yes" ] && [ $stopped = 0 ]; then
			echo "	--Stopping"
			aws ec2 stop-instances --region "$region" --instance-ids "${instanceIDs[m]}" > /dev/null	

	 		echo "	  ..Waiting for instance to stop"

			state=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].State.Name" --out "text")
			while [ "$state" != "stopped" ]; do
				sleep 10
	    		echo "	  ..Waiting for instance to stop"
				state=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].State.Name" --out "text")
			done
			echo "	--Stopped"		
		fi

	  	echo "	--Changing instance type to $iNewType"
		aws ec2 modify-instance-attribute --region "$region" --instance-id "${instanceIDs[m]}" --instance-type "{\"Value\": \"$iNewType\"}" > /dev/null	

		type=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].InstanceType" --out "text")
		while [ "$type" != "$iNewType" ]; do
			sleep 10
			type=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].InstanceType" --out "text")
		done
	  	echo "	--Instance type changed"

		echo "	--Starting instance"
		aws ec2 start-instances --region "$region" --instance-ids "${instanceIDs[m]}" > /dev/null

	    echo "	  ..Waiting for instance to start"

		state=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].State.Name" --out "text")
		while [ "$state" != "running" ]; do
			sleep 10
			state=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].State.Name" --out "text")
	    	echo "	  ..Waiting for instance to start"
		done

		echo "	--Instance started"
		echo "	--Checking quorum"
	    echo "	  ..Waiting for node to join quorum"

	    until ./qq --host ${nodeIPs[m]} node_state_get | grep -q "ACTIVE"; do
	      sleep 5
	      echo "	  ..Waiting for node to join quorum"
	    done	
	    
	    echo "	--Node joined quorum"
	    echo "	--Waiting 30 seconds for cluster to settle"
	    sleep 30
	done
fi

#All instances running but in-service=no, Stop all instances, change type, restart and validate quorum
#-----------------------------------------------------------------------------------------------------

if [ "$inService" = "no" ] && [ $stopped = 0 ]; then

	echo ""
	echo "      *Stopping Instances"

	for m in "${!instanceIDs[@]}"; do
		(( n = m + 1 ))
		echo "	--Stopping Node$n - Instance ID ${instanceIDs[m]}"		
		aws ec2 stop-instances --region "$region" --instance-ids "${instanceIDs[m]}" > /dev/null	
	done

    echo "	  ..Waiting for Node1 to stop"

	for m in "${!instanceIDs[@]}"; do
		(( n = m + 1 ))		
		state=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].State.Name" --out "text")
		while [ "$state" != "stopped" ]; do
			sleep 10
			state=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].State.Name" --out "text")
	    	echo "	  ..Waiting for Node$n to stop"
		done		
		echo "	--Node$n stopped"
	done	

	echo ""
	echo "      *Changing Instance Types"
	echo "	--Changing instance types to $iNewType"
	
	for m in "${!instanceIDs[@]}"; do
		(( n = m + 1 ))		
		aws ec2 modify-instance-attribute --region "$region" --instance-id "${instanceIDs[m]}" --instance-type "{\"Value\": \"$iNewType\"}" > /dev/null	

		type=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].InstanceType" --out "text")
		while [ "$type" != "$iNewType" ]; do
			sleep 10
			type=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].InstanceType" --out "text")
		done
	  	echo "	--Node$n instance type changed"
	done

	echo ""
	echo "      *Starting Cluster and Checking Quorum"

	for m in "${!instanceIDs[@]}"; do
		(( n = m + 1 ))
		echo "	--Starting Node$n - Instance ID ${instanceIDs[m]}"		
		aws ec2 start-instances --region "$region" --instance-ids "${instanceIDs[m]}" > /dev/null	
	done

    echo "	  ..Waiting for Node1 to start"

	for m in "${!instanceIDs[@]}"; do
		(( n = m + 1 ))		
		state=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].State.Name" --out "text")
		while [ "$state" != "running" ]; do
			sleep 10
			state=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].State.Name" --out "text")
	    	echo "	  ..Waiting for Node$n to start"
		done		
		echo "	--Node$n started"
	done

    echo "	--Checking quorum"
    echo "	  ..Waiting for Node1 to join quorum"
	
	for m in "${!instanceIDs[@]}"; do
		(( n = m + 1 ))		
	    until ./qq --host ${nodeIPs[m]} node_state_get | grep -q "ACTIVE"; do
    	 	sleep 5
      		echo "	  ..Waiting for Node$n to join quorum"
    	done
    	echo "	--Node$n joined quorum"
    done			
fi

#All instances stopped
#---------------------

if [ $stopped != 0 ]; then

	echo "      *Changing Instance Types"
	echo "	--Changing instance types to $iNewType"
	
	for m in "${!instanceIDs[@]}"; do
		(( n = m + 1 ))		
		aws ec2 modify-instance-attribute --region "$region" --instance-id "${instanceIDs[m]}" --instance-type "{\"Value\": \"$iNewType\"}" > /dev/null	

		type=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].InstanceType" --out "text")
		while [ "$type" != "$iNewType" ]; do
			sleep 10
			type=$(aws ec2 describe-instances --region "$region" --filter "Name=instance-id, Values=${instanceIDs[m]}" --query "Reservations[].Instances[].InstanceType" --out "text")
		done
	  	echo "	--Node$n instance type changed"
	done
fi

if [ $stopped = 0 ]; then
  	echo "  ******* ${#instanceIDs[@]} Instances changed to $iNewType, started, and in quorum"		
else
	echo "  ******* ${#instanceIDs[@]} Instances changed to $iNewType.  Cluster remains stopped."		
fi

