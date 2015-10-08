#!/bin/bash
for i in `../scripts/search_service.tcl   | grep service_id  | sed 's/^.*".*":.*"\(.*\)",$/\1/g'`;do  
	echo -e "DELETE /v1/services/anylink/$i HTTP/1.1\nAuthorization:Bearer $strong_token\nHost:$api_host\n\n"| nc $nc_flag $api_site $api_port 
done




exit



#!/usr/bin/tclsh
#
fconfigure stdout -buffering none

set user_id $env(user_id)

set prefix [string range $user_id 0 5]

set api_site $env(api_site)
set api_port $env(api_port)

for {set i 0} {$i<100} {incr i} {
        set mac [format "%s%06d" $prefix $i]
	set host_name [format "host_%06d" $i]
        set device_id [exec {../bin/genId} {-m} "$mac"]

	set body [format "service_object_name=%s&origin_service_port=8080&protocol=tcp&service_object_id=%s&service_name=web_remote_service" $host_name $device_id]
	set body_len [string length $body]
	set sock [socket $api_site $api_port]
#	set sock stdout

        fconfigure $sock -buffering none
	fconfigure $sock -encoding utf-8

        puts $sock "DELETE /v1/services/anylink/ HTTP/1.1"
        puts $sock "Host:api.newrocktech.com"
        puts $sock "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
        puts $sock "Connection:close"
        puts $sock "Content-Length:$body_len"
        puts $sock ""
        puts -nonewline $sock $body


#	continue

        set response [read $sock]
        puts $response
        flush stdout

        close $sock

}
