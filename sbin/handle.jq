.devices |
#map(select(false == has("product_version") or .product_version == ""))|
map(select(.product_type == "MX8A"))|
map({device_id:.device_id,connection_status:.connection_status,device_mac:.device_mac,product_type:.product_type,})|
#.[0:3]|
.
