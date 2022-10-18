#!/usr/bin/env bash
set -euo pipefail

consul agent -dev -config-file dc1.hcl &
consul agent -dev -config-file dc2.hcl &
consul agent -dev -config-file dc3.hcl &

sleep 5
consul partition create -name 1p1
consul partition create -http-addr localhost:7500 -name 3p1
consul partition create -http-addr localhost:7500 -name 3p2
