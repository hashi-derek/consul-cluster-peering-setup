terraform {
  # This is local, because it's simply generating from a template and not changing consul.
  # The output files from this module are what should be used with terraform cloud / remote.
  backend "local" {}
}

locals {
  clusters = [
    { alias: "cluster1" },
    { alias: "cluster2", partition: "mypart" },
    { alias: "cluster3" },
  ]
}

module "peerings" {
  source = "../peering/"
  peering_acceptors = local.clusters
  peering_dialers = local.clusters
}

/*
module "peerings" {
  source = "github.com/hashi-derek/consul-cluster-peering-setup//peering?ref=add_partitions"
  peering_acceptors = [
   { alias: "cluster1" },
   { alias: "cluster2" },
   { alias: "cluster2", partition: "mypart" },
  ]
  peering_dialers = [
   { alias: "cluster1" },
   { alias: "cluster2", partition: "mypart" },
  ]
}
*/
