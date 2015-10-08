#!/usr/bin/tclsh

if {$argc != 1 } { 
	puts "Usage: $argv0 file"
	exit 1 
} else {
	set device_file [lindex $argv 0]
}

set api_site $env(api_site)
set api_port $env(api_port)
set api_host $env(api_host)
set user_id $env(user_id)
set strong_token $env(strong_token)


set fd [open $device_file r]


set sock [socket $api_site $api_port]
fconfigure $sock -buffering none -blocking 0 -translation lf
fconfigure $fd -translation lf


gets $fd device_id

while { [string length $device_id] > 0  } {
	#puts $device_id
	
	puts $sock "DELETE /v1/devices/$device_id?user_id=$user_id HTTP/1.1"
	puts $sock "Host:$api_host"
	puts $sock "Authorization:Bearer $strong_token"
	puts $sock "Connection:keep-alive"
	puts $sock ""	

	
	gets $fd device_id
	set device_id [string range $device_id 0 35]
	after 200

	puts [read $sock]
}


exit

fileevent $sock readable {

set response [read $sock ]
puts $response
exit

}

vwait forever


