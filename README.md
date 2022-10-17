This repo contains a Terraform module for easily peering multiple Consul clusters together.

Because Terraform modules have a restriction with not allowing dynamically generated providers,
this is a two-step approach (each Consul cluster is a provider entry).

To run the demo:

```
# Open a terminal
./start-clusters.sh

# Open a second terminal

# Generate a terraform module for peering clusters
cd peering
terraform init && terraform apply -auto-approve

# Setup peering on the Consul clusters
cd generated_module
terraform init && terraform apply -auto-approve

# View the peerings
cd ../..
./show-peerings.sh
```

All three clusters should now be peered with eachother. Clusters are setup by comparing provider
alias values -- the dialer is always the greater value and acceptor is always the lesser value.

Note that the providers must be specified in JSON format (see `peering/consul_providers.tf.json`)
so that terraform can parse the JSON and iterate through the entries. Terraform does not have a
way to read arbitrary HCL files.

