#!/usr/bin/tclsh
#

set api_site $env(api_site)
set api_port $env(api_port)
set api_host $env(api_host)
set user_id $env(user_id)
set strong_token $env(strong_token)


set sock [socket $api_site $api_port]
fconfigure $sock -buffering none -blocking 1 -translation lf

puts $sock "GET /v1/devices?user_id=$user_id&limit=1000 HTTP/1.1"
puts $sock "Host:$api_host"
puts $sock "Authorization:Bearer $strong_token"
puts $sock "Connection:close"
puts $sock ""

fileevent $sock readable {

set response [read $sock ]

puts $response
exit 0
}

vwait forever

