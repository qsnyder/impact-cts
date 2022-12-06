#!/bin/bash

APIC=10.10.20.14

printf "\n*** logging in ***\n"
OUT=$(curl -s -X POST -k https://$APIC/api/aaaLogin.json -d '{ "aaaUser" : { "attributes" : { "name" : "admin" , "pwd" : "C1sco12345" } } }' -c cookie.txt EOF)

ERRCODE=$(echo $OUT | jq --raw-output '.imdata[0] .error .attributes .code')
ERRTEXT=$(echo $OUT | jq --raw-output '.imdata[0] .error .attributes .text')

# Check if an error code exists
if [ "${ERRCODE//[0-9]}" = "" ]
then
	printf "$ERRCODE : $ERRTEXT\n"
	exit 0
else
	printf "Login OK"
fi

printf "\n\n*** listing all tenants ***\n"
curl -s -b cookie.txt -X GET -k https://$APIC/api/node/class/fvTenant.json | jq --raw-output '.imdata[] .fvTenant .attributes .name'

printf "\n*** removing cookie.txt*** \n\n"
rm cookie.txt