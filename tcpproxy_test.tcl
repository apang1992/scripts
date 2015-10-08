#!/home/dspang/local/bin/tclsh

fconfigure stdout -buffering none

set api_site $env(api_site)
set api_port $env(api_port)
set api_host $env(api_host)
set proxy_server $env(proxy_server)

set user_id $env(user_id)

set strong_token $env(strong_token)

if {[catch {socket $api_site $api_port} sock ]} {
	puts stderr "open socket error"
	exit 1
}

fconfigure $sock -buffering none
fconfigure $sock -encoding utf-8

#puts "$user_id $api_site $api_port $api_host $strong_token"

puts $sock "GET /v1/services/anylink?user_id=$user_id&limit=1000 HTTP/1.1"
puts $sock "Host:$api_host"
puts $sock "Authorization:Bearer $strong_token"
puts $sock "Content-Type: application/x-www-form-urlencoded; charset=UTF-8"
puts $sock "Connection:close"
puts $sock ""

#set port_tmp 0
while {[gets $sock line] >= 0} {
#	puts $line
	if { 1 == [regexp {.*"port": "([0-9]*)".*} "$line" ] } {
		regexp {.*"port": "([0-9]*)".*} "$line" {[0-9]*} port_tmp
		lappend ports $port_tmp
	}
}

#puts $ports
#puts [llength $ports]

close $sock

proc handle_data {sock} {
	puts -nonewline $sock "GET /1000 HTTP/1.1\n\n"
	set response [read $sock]
	puts $response
	close $sock
}

for {set i 0} {$i<3} {incr i} {
#for {set i 0} {$i<[llength $ports]} {incr i} 
	set p [lindex $ports $i]

	set sock1($i) [socket $proxy_server $p]
	fconfigure $sock1($i) -buffering none -translation lf -blocking 0
	fileevent $sock1($i) readable [list handle_data $sock1($i)]
}

vwait forever



