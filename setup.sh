#!/bin/bash

echo "##################################################################"
echo "# Downloading source code.... ####################################"
echo "##################################################################"
git clone https://github.com/qsnyder/impact-cts.git

echo "##################################################################"
echo "# Downloading Consul-Terraform-Sync (CTS) binary.... #############"
echo "##################################################################"
curl https://releases.hashicorp.com/consul-terraform-sync/0.6.0/consul-terraform-sync_0.6.0_linux_amd64.zip -o impact-cts/cts/cts.zip
unzip impact-cts/cts/cts.zip -d impact-cts/cts/
rm -rf impact-cts/cts/cts.zip

echo "##################################################################"
echo "# Downloading Terraform binary.... ###############################"
echo "##################################################################"
curl https://releases.hashicorp.com/terraform/1.1.9/terraform_1.1.9_linux_amd64.zip -o impact-cts/pre-req/tf.zip
unzip impact-cts/pre-req/tf.zip -d impact-cts/pre-req/
rm -rf impact-cts/pre-req/tf.zip

echo "##################################################################"
echo "# Ensuring scripts are executable.... ############################"
echo "##################################################################"
chmod +x impact-cts/cts/app-exec.sh
chmod +x impact-cts/cts/app01-start.sh
chmod +x impact-cts/cts/app02-start.sh
chmod +x impact-cts/cts/consul-srv-start.sh
chmod +x impact-cts/cts/cts-start.sh

echo "##################################################################"
echo "# Pulling Consul server container.... ############################"
echo "##################################################################"
docker pull consul

echo "##################################################################"
echo "# Building application container.... #############################"
echo "##################################################################"
docker build -t cts-nginx:0.1 impact-cts/docker/.

echo ""
echo "##################################################################"
echo "# Source code and binaries downloaded.  Containers built. ########"
echo "# Next Steps: ####################################################"
echo "# - Apply tenant config to fabric ################################"
echo "# - Start CTS binary  ############################################"
echo "# - Run containers ###############################################"
echo "# - Start nginx on app containers ################################"
echo "##################################################################"⏎
