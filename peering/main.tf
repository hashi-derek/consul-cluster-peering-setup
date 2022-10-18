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

variable "partitions" {
  type = map(list(string))
  default = {}
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

# TODO remove this
resource "local_file" "test_file" {
  content = jsonencode(local.a_partition_pairs)
  filename = "${var.write_to_dir}/test_output.json"
}


locals {
  consul_providers = jsondecode(file("${var.provider_json_file}")).provider.consul

  # We will use this to do lexicographical comparisons by fetching indexes.
  order = sort([ for p in local.consul_providers: p.alias ])

  unclean_pairs = flatten([
    for a in local.order: [
      for d in local.order:
        index(local.order, a) < index(local.order, d)
          ? { acceptor: a, dialer: d, acceptor_partition: "", dialer_partition: "" }
          : {}
    ]
  ])
  cluster_pairs = setsubtract(distinct(local.unclean_pairs), [{}])

  # We could stop here if partitions didn't exist.
  # pairs = local.cluster_pairs



  # Attach any defined partitions.
  a_partition_pairs = flatten([
    for p in local.cluster_pairs: [
      for a in try(var.partitions[p.acceptor], []):
       {
        acceptor: p.acceptor,
        dialer: p.dialer,
        acceptor_partition: a,
       }
    ]
  ])
  d_partition_pairs = flatten([
    for p in local.cluster_pairs: [
      for d in try(var.partitions[p.dialer], []):
       {
        acceptor: p.acceptor,
        dialer: p.dialer,
        dialer_partition: d,
       }
    ]
  ])

  /*
  cross_product_pairs = flatten([
    for a in 
  ])

  # Merge the two different partition lists together
  a_lookup_pairs = {
    for p in local.a_partition_pairs: "${p.acceptor};${p.acceptor_partition};${p.dialer};${p.dialer_partition}" => p
  }
  d_lookup_pairs = {
    for p in local.d_partition_pairs: "${p.acceptor};${p.acceptor_partition};${p.dialer};${p.dialer_partition}" => p
  }
  pairs = distinct([
    for 
  ])
  */
  

  pairs = local.cluster_pairs
}

