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


resource "local_file" "output_main_file" {
  content = templatefile("${path.module}/template.tftpl", {
    consul_providers = local.consul_providers
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
    for k in local.order: [
      for r in local.order:
        index(local.order, k) < index(local.order, r)
          ? { acceptor: k, dialer: r }
          : {}
    ]
  ])
  pairs = setsubtract(distinct(local.unclean_pairs), [{}])
}

