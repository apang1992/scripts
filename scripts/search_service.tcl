#!/usr/bin/tclsh
#
lappend auto_path /home/dspang/local/lib
package require tls

set api_site $env(api_site)
set api_port $env(api_port)
set api_host $env(api_host)
set strong_token $env(strong_token)

set user_id $env(user_id)

fconfigure stdout -buffering none

set sock [tls::socket $api_site $api_port]

fconfigure $sock -buffering none
fconfigure $sock -encoding utf-8

puts $sock "GET /v1/services/anylink?user_id=$user_id&limit=1000 HTTP/1.1"
puts $sock "Host:$api_host"
puts $sock "Authorization:Bearer $strong_token"
puts $sock "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
puts $sock "Connection:close"
puts $sock ""

set response [read $sock]
puts $response
flush stdout

close $sock
