#!/usr/bin/tclsh

if {$argc != 2} {
	exit
}

set server [lindex $argv 0]
set port [lindex $argv 1]

if {[catch {socket $server $port} sock]} { 
	puts "fail"
}

catch {puts -nonewline [read $sock ]}

catch {close $sock }



