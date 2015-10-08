#!/home/dspang/local/bin/tclsh

lappend auto_path /usr/local/lib
lappend auto_path /home/dspang/local/lib

package require tls



tls::socket -server accept_func -certfile server.crt -keyfile server.key 8086

proc accept_func {chan remote_ip remote_port} {
#	puts "$remote_ip $remote_port"
	set line [gets $chan]
	puts $chan [string toupper $line]
	close $chan
}

vwait forever
