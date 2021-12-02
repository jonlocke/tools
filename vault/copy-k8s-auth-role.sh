#!/bin/bash
#set -x

# ensure VAULT_TOKEN and VAULT_ADDR are set

# this copies roles from one k8s auth to another... ie when a user cluster is upgraded

old=kubernetes
new=jon

roles=`vault list -format json auth/kubernetes/role`

for rolename in $(echo "${roles}" | jq -r '.[] ' ); do

echo $rolename

 _jq() {
     echo "${rolename}"
    }

   SP=$(vault read -format json auth/$old/role/$(_jq) | jq .data.bound_service_account_names | jq .[] | tr -d '"')
   NS=$(vault read -format json auth/$old/role/$(_jq) | jq .data.bound_service_account_namespaces | jq .[] | tr -d '"')
   POL=$(vault read -format json auth/$old/role/$(_jq) | jq .data.policies | tr -d "\n" | tr -d '"' | tr -d "[" | tr -d "]" | tr -d " ")
# POL="pol-allusers,default"

echo "-$rolename has the following keywords set"
echo "--bound_service-account_names=${SP}"
echo "--bound_service-account_namespaces=${NS}"
echo "--policies=${POL}"
echo "--writing role $rolename to cluster $new"
vault write auth/$new/role/$rolename bound_service_account_names=${SP} bound_service_account_namespaces=${NS} policies=${POL} ttl=3600

done
