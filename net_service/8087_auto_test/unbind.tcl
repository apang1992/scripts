#!/var/run/tclsh
load /var/run/tcl_lib/libtls1.6.4.so
source /var/run/tcl_lib/tls.tcl
source /var/run/tcl_lib/json.tcl
source /var/run/common.tcl

set debug 0

proc unbind {} {
	upvar #0 dev_ip ip
        upvar #0 dev_port port
        upvar #0 dev_pass pass
	if {$port == 8080} {
		set channel [socket $ip $port]
	} else {
		set channel [tls::socket $ip $port]
	}
        fconfigure $channel -buffering none
        puts $channel "POST /cloud/json?method=gw.config.set&id80002=false HTTP/1.1"
        puts $channel "Connection:close"
        puts $channel ""
        set response [read $channel]
	regexp ".*\r\n\r\n({.*}).*$" $response aaa json
	my_puts $json
	dump_json $json
        close $channel
}

unbind
get_state

