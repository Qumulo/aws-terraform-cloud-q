Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#User data runs every boot cycle

if [ $(curl -sI -w "%%{http_code}\\n" "s3.${bucket_region}.amazonaws.com" -o /dev/null --connect-timeout 10 --retry 10 --retry-delay 5 --max-time 200) == "405" ]; then
  echo "S3 Reachable"
else
  echo "S3 Unreachable"
  exit 1
fi

cd /root
if [[ ! -e "provision.sh" ]]; then
  aws s3 cp --region ${bucket_region} s3://"${bucket_name}/${scripts_s3_prefix}provision.sh" ./provision.sh
fi

sed "" provision.sh > provision-sub.sh
sed -i.rep "s|\$${bucket_name}|${bucket_name}|g" provision-sub.sh
sed -i.rep "s|\$${bucket_region}|${bucket_region}|g" provision-sub.sh
sed -i.rep "s|\$${cluster_name}|${cluster_name}|g" provision-sub.sh
sed -i.rep "s|\$${cluster_secrets_arn}|${cluster_secrets_arn}|g" provision-sub.sh
sed -i.rep "s|\$${deployment_unique_name}|${deployment_unique_name}|g" provision-sub.sh
sed -i.rep "s|\$${flash_iops}|${flash_iops}|g" provision-sub.sh
sed -i.rep "s|\$${flash_tput}|${flash_tput}|g" provision-sub.sh
sed -i.rep "s|\$${floating_ips}|${floating_ips}|g" provision-sub.sh
sed -i.rep "s|\$${functions_s3_prefix}|${functions_s3_prefix}|g" provision-sub.sh
sed -i.rep "s|\$${instance_ids}|${instance_ids}|g" provision-sub.sh
sed -i.rep "s|\$${kms_key_id}|${kms_key_id}|g" provision-sub.sh
sed -i.rep "s|\$${max_nodes_down}|${max_nodes_down}|g" provision-sub.sh
sed -i.rep "s|\$${mod_overness}|${mod_overness}|g" provision-sub.sh
sed -i.rep "s|\$${node1_ip}|${node1_ip}|g" provision-sub.sh
sed -i.rep "s|\$${number_azs}|${number_azs}|g" provision-sub.sh
sed -i.rep "s|\$${primary_ips}|${primary_ips}|g" provision-sub.sh
sed -i.rep "s|\$${region}|${region}|g" provision-sub.sh
sed -i.rep "s|\$${scripts_path}|${scripts_path}|g" provision-sub.sh
sed -i.rep "s|\$${sidecar_provision}|${sidecar_provision}|g" provision-sub.sh
sed -i.rep "s|\$${sidecar_secrets_arn}|${sidecar_secrets_arn}|g" provision-sub.sh
sed -i.rep "s|\$${software_secrets_arn}|${software_secrets_arn}|g" provision-sub.sh
sed -i.rep "s|\$${temporary_password}|${temporary_password}|g" provision-sub.sh
sed -i.rep "s|\$${upgrade_s3_prefix}|${upgrade_s3_prefix}|g" provision-sub.sh
sed -i.rep "s|\$${version}|${version}|g" provision-sub.sh
  

/bin/bash -xe provision-sub.sh

poweroff