echo "localhost:7500 peerings"
consul peering list -http-addr=localhost:7500
echo "localhost:8500 peerings"
consul peering list -http-addr=localhost:8500
echo "localhost:9500 peerings"
consul peering list -http-addr=localhost:9500
