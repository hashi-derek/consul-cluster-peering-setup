This repo contains a Terraform module for easily peering multiple Consul clusters together.

Because Terraform modules have a restriction with not allowing dynamically generated providers,
this is a two-step approach (each Consul cluster is a provider entry).

To run the demo:

```
# Open a terminal
./start-clusters.sh

# Open a second terminal

# Generate a terraform module for peering clusters
cd module-test
terraform init && terraform apply -auto-approve

# Setup peering on the Consul clusters
cd generated_module
terraform init && terraform apply -auto-approve

# View the peerings
cd ../..
./show-peerings.sh
```

All three clusters should now be peered with eachother. 
