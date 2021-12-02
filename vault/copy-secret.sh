#!/bin/bash
# Create secrets egine

#vault secrets enable -path=secrets kv
#vault secrets enable -path=secrets2 kv
vault kv put secrets/secret1 username=jon password=mypass
vault kv put secrets/secret1/more username=jon password=mypass

originpath=secrets/secret1
destinationpath=secrets2/secret1
vault kv get -format=json -field=data $originpath | vault kv put $destinationpath -
