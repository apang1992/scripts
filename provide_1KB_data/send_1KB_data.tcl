#!/home/dspang/local/bin/tclsh
#

package require Tcl 8.5
package require Thread 2.5

if { $argc > 0 } {
        set port [lindex $argv 0]
} else {
        set port 8080
}

puts "port:$port"

socket -server _connect_client $port

proc _connect_client {sock remote_ip remote_port} {
        after 0 [list connect_client $sock $remote_ip $remote_port]
}

proc connect_client {sock remote_ip remote_port} {
        set child_tid [thread::create {
                thread::wait
        }]

        thread::detach $sock

        thread::send -async $child_tid [list set sock $sock]

        thread::send -async $child_tid {
                thread::attach $sock
                fconfigure $sock -buffering line -blocking 0
                fileevent $sock readable [list read_line $sock]
                puts -nonewline $sock "abcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxyabcdefghijklmnopqrstuvwxy"
		catch {close $sock}
		thread::release
        }

}

vwait forever
