#!/usr/bin/tclsh

if {$argc != 1} {
	puts "arg error"
	exit
} else {
	set loop [lindex $argv 0]
}

fconfigure stdout -buffering none

set user_id $env(user_id)

set prefix [string range $user_id 0 5]

set api_site $env(api_site)
set api_port $env(api_port)
set api_host $env(api_host)
set strong_token $env(strong_token)

set sock [socket $api_site $api_port]
fconfigure $sock -buffering none -blocking 0
fconfigure $sock -encoding utf-8 -translation lf

for {set i 0} {$i<$loop} {incr i} {
        set mac [format "%s%06d" $prefix $i]
	set host_name [format "host_%06d" $i]
        set device_id [exec {genId} {-m} "$mac"]

	set body [format "service_object_name=%s&origin_service_port=8080&protocol=tcp&service_object_id=%s&service_name=web_remote_service" $host_name $device_id]
	set body_len [string length $body]

        puts $sock "POST /v1/services/anylink?user_id=$user_id HTTP/1.1"
        puts $sock "Host:$api_host"
	puts $sock "Authorization:Bearer $strong_token"
        puts $sock "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
        puts $sock "Connection:keep-alive"
        puts $sock "Content-Length:$body_len"
        puts $sock ""
        puts -nonewline $sock $body
	after 500
	puts [read $sock]


}

after 2000

set response [read $sock]
puts $response
flush stdout

close $sock

