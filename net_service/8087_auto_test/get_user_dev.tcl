#!/var/run/tclsh
load /var/run/tcl_lib/libtls1.6.4.so
source /var/run/tcl_lib/tls.tcl
source /var/run/tcl_lib/json.tcl
source /var/run/common.tcl

set user_id [lindex $argv 0]
set strong_token [lindex $argv 1]

set sock [tls::socket $api_site $api_port]
fconfigure $sock -buffering none -blocking 1 -translation lf

puts $sock "GET /v1/devices?user_id=$user_id&limit=1000 HTTP/1.1"
puts $sock "Host:$api_host"
puts $sock "Connection: close"
puts $sock "Authorization:Bearer $strong_token"
puts $sock ""

after 10000 {
	puts "{get user's devices timeout!}"
	exit
}
	
fileevent $sock readable {
	#puts "in event"
        set response [read $sock]
	puts $response
	regexp ".*\r\n\r\n({.*}).*$" $response aaa json
	my_puts $json
	dump_json $json
        close $sock
	exit 0
}
vwait forever

