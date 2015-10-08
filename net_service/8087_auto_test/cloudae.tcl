#!/var/run/tclsh
load /var/run/tcl_lib/libtls1.6.4.so
source /var/run/tcl_lib/tls.tcl
source /var/run/tcl_lib/json.tcl
source /var/run/common.tcl

set device_id [exec nvram_get DevID]

fconfigure stdout -buffering none

set user_id $env(user_id)
set api_site $env(api_site)
set api_port $env(api_port)
set api_host $env(api_host)
set strong_token $env(strong_token)
set device_id $env(device_id)

set forever 0
set response ""

proc handle_response {sock} {
	upvar forever forever
	upvar response response
	if {[eof $sock]} {
		close $sock
		puts $response
		set forever 1
	} else {
		append response [read $sock]
	}
}

set sock [tls::socket $api_site $api_port]
fconfigure $sock -buffering none -blocking 0
fconfigure $sock -encoding utf-8 -translation lf

set body [format "service_object_name=auto_test_device&origin_service_port=8100&protocol=tcp&service_object_id=%s&service_name=auto_test_service" $device_id]
set body_len [string length $body]

puts $sock "POST /v1/services/anylink?user_id=$user_id HTTP/1.1"
puts $sock "Host:$api_host"
puts $sock "Authorization:Bearer $strong_token"
puts $sock "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
puts $sock "Connection:close"
puts $sock "Content-Length:$body_len"
puts $sock ""
puts -nonewline $sock $body

fileevent $sock readable [list handle_response $sock]
vwait forever

set forever 0
set response ""

set sock [tls::socket $api_site $api_port]
fconfigure $sock -buffering none -blocking 0
fconfigure $sock -encoding utf-8 -translation lf

puts $sock "GET /v1/services/anylink?user_id=$user_id HTTP/1.1"
puts $sock "Host:$api_host"
puts $sock "Authorization:Bearer $strong_token"
puts $sock "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
puts $sock "Connection:close"
puts $sock ""

fileevent $sock readable [list handle_response $sock]
vwait forever

set sock_server [socket -server accept_handler 8100]
proc accept_handler {sock remote_ip remote_port} {
        #puts "$sock $remote_ip $remote_port"
        puts -nonewline $sock helloa
        flush $sock
        close $sock
        upvar sock_server sock_server
        close $sock_server
}

set fd [open tmp[pid] w+]
puts $fd $response
flush $fd
close $fd
set param_port ""
append param_port {.anylink[] | select(.origin_service_port == "8100" and .service_object_id == "}
append param_port $device_id
append param_port {" ) | .port}
append param_ip {.anylink[] | select(.origin_service_port == "8100" and .service_object_id == "}
append param_ip $device_id
append param_ip {" ) | .ip}
set proxy_port [exec cat tmp[pid] | sed -n {/^{$/,/^}/p} | jq  $param_port | sed {s/"//g} ]
set proxy_site [exec cat tmp[pid] | sed -n {/^{$/,/^}/p} | jq  $param_ip | sed {s/"//g} ]
#set proxy_port [exec cat tmp[pid] | sed -n {/^{$/,/^}/p} | jq {.anylink[] | select(.origin_service_port == "8100" and .service_object_id == "$device_id" ) | .port} | sed {s/"//g} ]
#set proxy_site [exec cat tmp[pid] | sed -n {/^{$/,/^}/p} | jq {.anylink[] | select(.origin_service_port == "8100" and .service_object_id == "$device_id" ) | .ip} | sed {s/"//g} ]
set proxy_data ""

set client_OK 0
puts "$proxy_site $proxy_port"
set sock_client [socket $proxy_site $proxy_port]
proc read_data {sock} {
	upvar proxy_data proxy_data
        upvar client_OK client_OK
        append proxy_data [read $sock 1]
	if {[eof $sock]} {
        	close $sock
        	set client_OK 1
	}
}
fileevent $sock_client readable [list read_data $sock_client]

vwait client_OK
#puts $proxy_data
if {$proxy_data != "helloa" } {
	puts "proxy error"
	puts "proxy data is $proxy_data"
	exit 1
} else {
	puts "\033\[32mTCP proxy OK \033\[0m"
	exit 0
}

