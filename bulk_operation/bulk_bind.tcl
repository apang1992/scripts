#!/usr/bin/tclsh
#

if {$argc == 1 } {
	set loop_start 0
	set loop_end [lindex $argv 0] 	
} elseif { $argc == 2} {
	set loop_start [lindex $argv 0]
	set loop_end [lindex $argv 1]
} else {
	puts "usage error"
	exit 1
} 	
	
fconfigure stdout -buffering none

set user_id $env(user_id)

set api_site $env(api_site)
set api_port $env(api_port)
set api_host $env(api_host)
set strong_token $env(strong_token)
set active_token $env(active_token)

set prefix [string range $user_id 0 5]

puts $prefix
set sock [socket $api_site $api_port]
fconfigure $sock -buffering none -blocking 0 -translation lf

for {set i $loop_start} {$i<$loop_end} {incr i} {
        set mac [format "%s%06d" $prefix $i]
	set device_id [exec {genId} {-m} "$mac"]
	puts "$device_id: [string length $device_id]"

	set body  "user_id=$user_id"
	set body_length [string length $body]	
	
	puts $sock "POST /v1/devices/$device_id/actions/bind HTTP/1.1"
	puts $sock "Host:$api_host"
	puts $sock "Authorization:Bearer $active_token"
	puts $sock "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
	puts $sock "Connection:keep-alive"
	puts $sock "Content-Length:$body_length"
	puts $sock ""
	puts -nonewline $sock $body

}


fileevent $sock readable {
	after 2000
	set response [read $sock]
	puts $response
	flush stdout
	close $sock
	exit 0
}

vwait forever
