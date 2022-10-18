terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">=2.0.0"
    }
  }
}


variable "write_to_dir" {
  type = string
  default = "generated_module"
}

variable "provider_json_file" {
  type = string
  default = "consul_providers.tf.json"
}

variable "peerings" {
  type = list(object({
    alias = string
    partition = optional(string, "")
  }))
  default = []
}


resource "local_file" "output_main_file" {
  content = templatefile("${path.module}/template.tftpl", {
    pairs = local.pairs
  })
  filename = "${var.write_to_dir}/main.tf"
}

resource "local_file" "output_provider_file" {
  content = file("${var.provider_json_file}")
  filename = "${var.write_to_dir}/consul_providers.tf.json"
}

locals {
  consul_providers = jsondecode(file("${var.provider_json_file}")).provider.consul
  providers_by_alias = { for p in local.consul_providers: p.alias => p }

  # Default to the providers list if peerings are not explicitly defined.
  peerings = length(var.peerings) > 0 ? var.peerings : [ for p in local.consul_providers: { alias: p.alias, partition: "" } ]

  # We will use this to do lexicographical comparisons by fetching indexes.
  order = sort([ for p in local.peerings: "${p.alias}+${p.partition}" ])

  unclean_pairs = flatten([
    for a in local.peerings: [
      for d in local.peerings:
        index(local.order, "${a.alias}+${a.partition}") < index(local.order, "${d.alias}+${d.partition}") && a.alias != d.alias
          ? {
              acceptor: a.alias,
              acceptor_partition: a.partition,
              acceptor_name: a.partition == "" ? a.alias: "${a.alias}_${a.partition}",
              dialer: d.alias,
              dialer_partition: d.partition,
              dialer_name: d.partition == "" ? d.alias: "${d.alias}_${d.partition}",
            }
          : {}
    ]
  ])
  # This will contain the list of all clusters that should be contacting eachother.
  # A cluster cannot peer to itself.
  cluster_pairs = setsubtract(distinct(local.unclean_pairs), [{}])

  # We could stop here if partitions didn't exist.
  pairs = local.cluster_pairs
}

