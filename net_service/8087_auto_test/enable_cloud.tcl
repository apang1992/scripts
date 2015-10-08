#!/var/run/tclsh
load /var/run/tcl_lib/libtls1.6.4.so
source /var/run/tcl_lib/tls.tcl
source /var/run/tcl_lib/json.tcl
source /var/run/common.tcl

proc enable_cloud {} {
	upvar #0 dev_ip ip
	upvar #0 dev_port port
	upvar #0 dev_pass pass
	if {$port == 8080} {
		set channel [socket $ip $port]
	} else {
		set channel [tls::socket $ip $port]
	}
        fconfigure $channel -buffering none
        puts $channel "POST /cloud/json?method=gw.config.set&id80000=on HTTP/1.1"
        puts $channel "Connection:close"
        puts $channel ""
        set response [read $channel]
	regexp ".*\r\n\r\n({.*}).*$" $response aaa json
	my_puts $json
	dump_json $json
        close $channel
	return [::json::json2dict $json]
}


set ret [enable_cloud]
#if {[dict get $ret result] != "OK"} {
#	puts "enable cloud OK"
#} else {
#	puts "enable cloud failed"
#}

set start_time [clock seconds]

for {set conn_status "connecting" ; set count 0} {$conn_status == "connecting"} {incr count} {
	if {$count > 50} {
		puts "have retried 10 times,maybe connection failed"
		break
	}
	puts "$count ======="
	set conn_status [dict get [get_state] id80001]
	if { $conn_status  == "connecting" } {
		after 2000
		continue
	}
}

if {$count <= 50} {
	set end_time [clock seconds]
	puts "Connect to mqtt server time consumption:[expr $end_time - $start_time] second(s)"
}

if { "on" == [dict get [get_state_q] id80000] } {
	exit 9
} else {
	exit 1
}
	
