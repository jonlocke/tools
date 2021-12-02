#!/bin/bash
#set -x

# Script to copy Kubernetes auth roles from one vault to another..

vault_addr1=$VAULT_ADDR1
vault_token1=$VAULT_TOKEN1

vault_addr2=$VAULT_ADDR2
vault_token2=$VAULT_TOKEN2

# vault auth enable -path=jon kubernetes or vault auth disable jon -- to create or delete

echo "_____ Copying k8s auth methods _____"

old=kubernetes
new=kubernetes

export VAULT_ADDR=$vault_addr1; export VAULT_TOKEN=$vault_token1

roles=`vault list -format json auth/$old/role`

for rolename in $(echo "${roles}" | jq -r '.[] ' ); do

echo "-- $rolename"

 _jq() {
     echo "${rolename}"
    }

export VAULT_ADDR=$vault_addr1; export VAULT_TOKEN=$vault_token1

   SP=$(vault read -format json auth/$old/role/$(_jq) | jq .data.bound_service_account_names | jq .[] | tr -d '"')
   NS=$(vault read -format json auth/$old/role/$(_jq) | jq .data.bound_service_account_namespaces | jq .[] | tr -d '"')
   POL=$(vault read -format json auth/$old/role/$(_jq) | jq .data.policies | tr -d "\n" | tr -d '"' | tr -d "[" | tr -d "]" | tr -d " ")
# POL="pol-allusers,default"

echo "-$rolename has the following keywords set"
echo "--bound_service-account_names=${SP}"
echo "--bound_service-account_namespaces=${NS}"
echo "--policies=${POL}"
echo "--writing role $rolename to cluster $new"

export VAULT_ADDR=$vault_addr2; export VAULT_TOKEN=$vault_token2

vault write auth/$new/role/$rolename bound_service_account_names=${SP} bound_service_account_namespaces=${NS} policies=${POL} ttl=3600

done

echo "_____ Copying Policies _____"
# Get all the policies and recreate in the new vault
export VAULT_ADDR=$vault_addr1; export VAULT_TOKEN=$vault_token1
policies=`vault policy list -format json`

for polname in $(echo "${policies}" | jq -r '.[] ' ); do

if [ $polname != "root" ]; then

   echo "-- $polname"
   export VAULT_ADDR=$vault_addr1; export VAULT_TOKEN=$vault_token1
   POLCONTENTS=$(vault policy read $polname)
   echo "--- Policy contents: $polname"

   export VAULT_ADDR=$vault_addr2; export VAULT_TOKEN=$vault_token2
   echo "Writing policy - $polname"
   echo $POLCONTENTS | vault policy write $polname -
   
else
   echo "-- ignoring root policy"
fi

done
