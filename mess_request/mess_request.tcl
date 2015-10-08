#!/home/dspang/local/bin/tclsh

lappend auto_path "/usr/local/lib"
package require base64
package require md5


set null_fd [open /dev/null w+]

#set authinfo [base64::encode ${username}:${password}]

proc randomData {length} {
	set result ""
	for {set x 0} {$x<$length} {incr x} {
		set result "$result[expr { int(2 * rand()) }]"
	}
	return $result
}

set rand_data [randomData [expr {int(2*rand())}]]
set rand_data [base64::encode $rand_data]
set rand_data [md5::md5 -hex $rand_data]

proc rand_string {length} {
	set rand_data [randomData [expr {int(2*rand())}]]
	set rand_data [base64::encode $rand_data]
	set rand_data [md5::md5 -hex $rand_data]
	set rand_data [string range $rand_data 0 [expr { int(9 * rand()) }]]
	set rand_data [md5::md5 -hex $rand_data]
	set rand_data [string range $rand_data 0 [expr { int(9 * rand()) }]]
	return $rand_data
}



#puts [rand_string 5]


set request_o {GET URI HTTP/1.1
Connection:close

}


for {} {1} {} {
	set sock [socket -async 127.0.0.1 6930]
	fconfigure $sock -buffering none -blocking 0 -translation binary
	set request [regsub -all {\mURI\M} $request_o /[rand_string 5]/[rand_string 5]/[rand_string 5]]
	puts $request
	puts -nonewline $sock $request
	after 100
	set response [read $sock]
	puts $null_fd $response
	flush $sock
	close $sock 
}



