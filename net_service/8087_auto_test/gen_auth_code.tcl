#!/var/run/tclsh
load /var/run/tcl_lib/libtls1.6.4.so
source /var/run/tcl_lib/tls.tcl
source /var/run/tcl_lib/json.tcl
source /var/run/common.tcl

proc gen_auth_code {} {
	upvar #0 dev_ip ip
        upvar #0 dev_port port
        upvar #0 dev_pass pass
	upvar #0 login_item login_item
	upvar #0 login_pass login_pass
	if {$port == 8080} {
		set channel [socket $ip $port]
	} else {
		set channel [tls::socket $ip $port]
	}
        fconfigure $channel -buffering none

        puts $channel "POST /cloud/json?method=gw.app.action&authcode=create HTTP/1.1"
        puts $channel "Connection:close"
        puts $channel ""
        set response [read $channel]
	regexp ".*\r\n\r\n({.*}).*$" $response aaa json
	my_puts $json
	dump_json $json
        close $channel
}

gen_auth_code

if { [string length [dict get [get_auth_state] id80011]] > 0 && 1 } {
        exit 9
} else {
        exit 1
}

