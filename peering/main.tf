terraform {
  # This is local, because it's simply generating from a template and not changing consul.
  # The output files from this module are what should be used with terraform cloud / remote.
  backend "local" {}
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

  # We will use this to do lexicographical comparisons by fetching indexes.
  order = sort([ for p in local.consul_providers: p.alias ])

  unclean_pairs = flatten([
    for a in local.order: [
      for d in local.order:
        index(local.order, a) < index(local.order, d)
          ? { acceptor: a, dialer: d }
          : {}
    ]
  ])
  pairs = setsubtract(distinct(local.unclean_pairs), [{}])
}

