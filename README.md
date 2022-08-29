# Sample Code for Consul-Terraform-Sync Learning Lab

This repository contains files for the CTS LL hosted within the ACI automation learning track on [developer.cisco.com](https://developer.cisco.com), designed for the Cisco DevNet LL2.0 web-based learning environment.  This sample code is meant to showcase the ease of setup for using CTS to automatically add/remove application hosts from an Endpoint Security Group (ESG) within an ACI tenant.

## Requirements

- ACI fabric or simulator running > v5.0 software
  - ESGs were introduced in ACI v5.0.  Previous versions do not have support for this construct
  - The [reservable ACI v5.2 sandbox](https://devnetsandbox.cisco.com/RM/Diagram/Index/4eaa9878-3e74-4105-b26a-bd83eeaa6cd9?diagramType=Topology) through DevNet Sandbox is also supported
- System capable of supporting the CTS binary.  As of the initial publication of this lab, Linux (`386`, `amd64`, `arm`, and `arm64`), macOS (`amd64` only, no M1/ARM), Solaris, and Windows (`386` and `amd64`) are supported
  - The jumphost included with the DevNet reservable sandbox is supported if you chose to invoke this repository setup script outside of the LL2.0 environment
- The CTS input file assumes a specific set of configuration applied to the ACI fabric.  This can be applied manually or using the included Terraform file to apply the configuration.
  - The jumphost included with the DevNet reservable sandbox is supported if you chose to invoke this repository setup script outside of the LL2.0 environment

## Repository Contents

### `pre-req`

If desired, this folder is used to instantiate the proper scaffolding onto the ACI fabric, including a tenant, VRF, and application profile.  All resource arguments are hard-coded (no use of variable files) and the configuration will be applied to the ACI fabric in the DevNet sandbox, as defined by 

```hcl
provider "aci" {
  username = "admin"
  password = "C1sco12345"
  url      = "https://localhost:8082"
  insecure = true
}
```

The use of `localhost:8082` may seem weird, as the target is a fabric that lives in some remote sandbox.  However, due to the use of forward proxies with the VPN connection for LL2.0, all traffic destined for the ACI simulator needs to be passed through the port exposed as part of `ocproxy` options within the `openconnect` process.

If you wish to perform this on a different fabric, please modify the file prior to using.

### `docker`

This folder contains the required Dockerfile and entrypoint script for the application container used within this lab.  This container uses `nginx` as its base and installs `consul`.  The `docker-entrypoint.sh` script configures the required Consul parameters to register with the server.  Once the container has been built, this folder will not be used for any activity within the lab.

### `cts`
The majority of the lab will be performed using the contents of this folder, which each of the files listed performing the following functions

- `input.tf`
  - Defines the variables used within the Terraform actions performed using the CTS binary.  These can be changed as desired for your implementation, but are defaulted to the values used within the `pre-req` folder for tenant, VRF, and application profile names.  If changes are desired, ensure that the information under `pre-req/main.tf` aligns with what is in this file
- `config.hcl`
  - This will look very familiar to the HCL written to support a standard Terraform configuration, with a few tweaks.  This file instructs the CTS binary where the Consul server instance resides, which Terraform provider to utilize for the actions (as well as any credential information), and the required inputs that will define the actions taken based on Consul changes.  In this case, it will pull the source files from a pre-built NIA use-case that aligns to this lab and use the `input.tf` file as a variable input source as required.  In this repository, the ACI target fabric is given as `localhost:8082`, which references the forwarded port through the `ocproxy` enabled tunnel within the VPN.
- `cts-start.sh`
  - This is a simple script to start the CTS binary with the appropriate inputs
- `consul-srv-start.sh`
  - This script will perform the `docker run` command for the Consul server with the appropriate command-line flags, namely exposing the proper ports, defining a name for the container, and binding to the correct interface
- `app0{x}-start.sh`
  - Each app-start script contains the appropriate `docker run` commands to instantiate the application containers.  This includes the required Consul config to validate the correct function of the service, interface binding, and the name of the container

## Usage

A setup script has been added to this repository to speed the time to deployment

1. `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/qsnyder/impact-cts/main/setup.sh)"`
2. `cd cts-esg-sample-code/pre-req`
3. `./terraform init`
4. `./terraform plan -out tf.plan`
5. `./terraform apply "tf.plan"`
6. `cd ../cts/`
7. `./consul-srv-start.sh`
8. `./cts-start.sh`

When complete, you'll be able to access the Consul server web UI by clicking on the briefcase at the top of the learning lab and clicking on the first entry link.  This should launch the Consul UI in a new window, using a URL that is unique for your specific instance of the lab.  Accessing the webUI will show the current Consul services, which is currently just the base system as no applications have been registered.
Since the CTS binary is started with logs displayed to stdout, open a new terminal window and perform the following

9. `cd cts-esg-sample-code/cts/`
10. `./app01-start.sh`

Returning to the Consul UI -- you'll see a new service instance called "App" appear with a red "X" next to it.  This indicates that the new app container has registered to Consul, but the service checks are failing due to the proper service being down.  To bring it up, we need to enable the webserver.  Use the `app-exec.sh` container to log into the running `app01` container

11. `./app-exec.sh app01`
12. `service nginx start`

Viewing the Consul UI should now indicate a green check mark next to the "App" service deployment.  Additionally, streamed log output from the CTS binary should appear in the console window running that application.  The final check is to navigate to the ACI web UI by clicking on the briefcase at the top of the lab window and choosing the second link, which will launch a new window that will bring you to the ACI login page.  Logging in with the credentials `admin/C1sco12345`, and clicking on **Tenants > Consul > Application Profiles > esg_ap** and will allow you to verify that a new "IP subnet selector" has been created.

To break out of the running container -- you can use the `<CTRL-P><CTRL-Q>` key combination.  Once there, you can start the second container using `./app02-start.sh` and following the same process to instantiate the `nginx` service on this container.

To verify the destroy action, you can use the `app-exec.sh` script to log into the desired container and invoke `service nginx stop` to stop the  `nginx` service, which will cause the Consul response for that container to fail and it will be removed from the ESG using the CTS actions.
