#!/home/dspang/local/bin/tclsh
lappend auto_path /usr/local/lib

package require Tcl 8.5
package require Thread 2.5
package require ftp


if { $argc > 0 } {
        set port [lindex $argv 0]
} else {
        set port 8081
}

#puts "port:$port"

socket -server _connect_client $port

proc _connect_client {sock remote_ip remote_port} {
        after 0 [list connect_client $sock $remote_ip $remote_port]
}

proc connect_client {sock remote_ip remote_port} {
	#puts "$remote_ip $remote_port"
	set child_tid [thread::create {

		lappend auto_path /usr/local/lib
		package require ftp
		proc get_remote_file {file_path} {
			set dir_name [file dirname $file_path]
			set file_name [file tail $file_path]
			set token [ftp::Open 192.168.2.64 release release -mode passive]
			::ftp::Type $token binary
			ftp::Cd $token $dir_name
			ftp::Get $token $file_name -variable data
			#puts $data
			ftp::Close $token
			return $data
		}

		proc ReadLine {sock} {
			global remote_ip
			set fchan [open noauth_module.sh r]
			set data [read $fchan]
			fconfigure $fchan -translation binary -buffering none
			close $fchan
			if {[catch {gets $sock line} len] || [eof $sock]}  {
				catch {close $sock}
				thread::release
			} elseif {$len == -1} {
				handleLine $sock "auth_flag=A\n"
				handleLine $sock "public_flag=0\n"
				handleLine $sock $data
			} else {
				if {$line == "A0"} {
					handleLine $sock "auth_flag=A\n"
                                	handleLine $sock "public_flag=0\n"
				} elseif {$line == "A1"} {
					handleLine $sock "auth_flag=A\n"
                                        handleLine $sock "public_flag=1\n"
				} elseif {$line == "A2"} {
					handleLine $sock "auth_flag=A\n"
                                        handleLine $sock "public_flag=2\n"
				} elseif {$line == "B0"} {
					handleLine $sock "auth_flag=B\n"
                                        handleLine $sock "public_flag=0\n"
				} elseif {$line == "B1"} {
					handleLine $sock "auth_flag=B\n"
                                        handleLine $sock "public_flag=1\n"
				} else {
					handleLine $sock "error_flag=1\n"
				}
				handleLine $sock $data
			}
		#	puts "line:$line"
			flush $sock
			catch {close $sock}
			thread::release
		}

		proc handleLine {sock line} {
			SendMessage $sock $line
		}

		proc SendMessage {sock msg} {
			if {[catch {puts -nonewline $sock $msg} error]} {
				puts stderr "Error writing to socket: $error"
				catch {close $sock}
				thread::release
			}
		}
		thread::wait
	}]

	thread::detach $sock

	thread::send -async $child_tid [list set sock $sock]
	thread::send -async $child_tid [list set remote_ip $remote_ip]

	thread::send -async $child_tid {
		thread::attach $sock
		fconfigure $sock -buffering none -blocking 0
		fconfigure $sock -translation binary -buffersize 0
		after 2000 [list ReadLine $sock]
	}

}

vwait forever
