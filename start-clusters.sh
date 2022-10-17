#!/usr/bin/env bash
set -euo pipefail

consul agent -dev -config-file dc1.hcl &
consul agent -dev -config-file dc2.hcl &
consul agent -dev -config-file dc3.hcl &
