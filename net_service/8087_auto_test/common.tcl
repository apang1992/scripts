foreach i [array names env] {
	set $i $env($i)
}


set debug 0
fconfigure stdout -buffering none

proc dump_json {content} {
	set json_dict [::json::json2dict $content]
	foreach i [dict keys $json_dict] {
		switch $i {
			id80000 {puts -nonewline "Cloud service     : "}
			id80001 {puts -nonewline "Connection status : "}
			id80002 {puts -nonewline "Bind status       : "}
			id80003 {puts -nonewline "Email             : "}
			id80004 {puts -nonewline "password          : "}
			id80005 {puts -nonewline "update list       : "}
			id80006 {puts -nonewline "user id           : "}
			id80007 {puts -nonewline "active token      : "}
			id80008 {puts -nonewline "device key        : "}
			id80011 {puts -nonewline "auth code         : "}
			id80012 {puts -nonewline "auth code status  : "}
			id80013 {puts -nonewline "authrized userid  : "}
			result  {puts -nonewline "result            : "}
			default {puts -nonewline "$i\t: "}
		}
		puts "[dict get $json_dict $i]" 
	}
}

proc get_state {} {
        upvar #0 dev_ip ip
        upvar #0 dev_port port
        upvar #0 dev_pass pass
        if {$port == 8080} {
                set channel [socket $ip $port]
        } else {
                set channel [tls::socket $ip $port]
        }
        fconfigure $channel -buffering none
        puts $channel "POST /cloud/json?method=gw.config.get&id=80000 HTTP/1.1"
        puts $channel "Connection:close"
        puts $channel ""
        set response [read $channel]
	#puts $response
        regexp ".*\r\n\r\n({.*}).*$" $response aaa json
        #puts $json
        dump_json $json
        close $channel
        return [::json::json2dict $json]
}

proc get_state_q {} {
        upvar #0 dev_ip ip
        upvar #0 dev_port port
        upvar #0 dev_pass pass
        if {$port == 8080} {
                set channel [socket $ip $port]
        } else {
                set channel [tls::socket $ip $port]
        }
        fconfigure $channel -buffering none
        puts $channel "POST /cloud/json?method=gw.config.get&id=80000 HTTP/1.1"
        puts $channel "Connection:close"
        puts $channel ""
        set response [read $channel]
        #puts $response
        regexp ".*\r\n\r\n({.*}).*$" $response aaa json
        #puts $json
        #dump_json $json
        close $channel
        return [::json::json2dict $json]
}

proc get_auth_state {} {
        upvar #0 dev_ip ip
        upvar #0 dev_port port
        upvar #0 dev_pass pass
        if {$port == 8080} {
                set channel [socket $ip $port]
        } else {
                set channel [tls::socket $ip $port]
        }
        fconfigure $channel -buffering none
        puts $channel "POST /cloud/json?method=gw.config.get&id=80011&id=80012&id=80013 HTTP/1.1"
        puts $channel "Connection:close"
        puts $channel ""
        set response [read $channel]
        #puts $response
        regexp ".*\r\n\r\n({.*}).*$" $response aaa json
        #puts $json
        dump_json $json
        close $channel
        return [::json::json2dict $json]
}

proc login {} {
	upvar #0 dev_ip ip
        upvar #0 dev_port port
        upvar #0 dev_pass pass
        if {$port == 8080} {
                set channel [socket $ip $port]
        } else {
                set channel [tls::socket $ip $port]
        }
        fconfigure $channel -buffering none
        puts $channel "POST /xml?method=gw.account.login&id51=$pass HTTP/1.1"
        puts $channel "Connection:close"
        puts $channel ""
        my_puts [read $channel]
        close $channel
}

proc logout {} {
	upvar #0 dev_ip ip
        upvar #0 dev_port port
        upvar #0 dev_pass pass
        if {$port == 8080} {
                set channel [socket $ip $port]
        } else {
                set channel [tls::socket $ip $port]
        }
        fconfigure $channel -buffering none
        puts $channel "POST /xml?method=gw.account.logout HTTP/1.1"
        puts $channel "Connection:close"
        puts $channel ""
        my_puts [read $channel]
        close $channel
}

proc my_puts {content} {
        global debug debug
        if {$debug == 1} {
                puts $content
        }
}

proc debug_puts {content} {
        global debug debug
        if {$debug == 1} {
                puts $content
        }
}
