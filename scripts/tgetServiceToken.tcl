#!/home/dspang/local/bin/tclsh
lappend auto_path /home/dspang/local/lib
lappend auto_path /usr/local/lib
package require tls
package require json
set api_site $env(api_site)
set api_port $env(api_port)
set api_host $env(api_host)
set accounts_site $env(accounts_site)
set accounts_port $env(accounts_port)
set accounts_host $env(accounts_host)
set icloud_site $env(icloud_site)
set icloud_port $env(icloud_port)
set icloud_host $env(icloud_host)
set email $env(email)
set password $env(password)
set user_id $env(user_id)

set sock [tls::socket $accounts_site $accounts_port]
fconfigure $sock -buffering none -blocking 1 -translation lf

set body "user=$email&pwd=$password"
set body_length [string length $body]
puts $sock "POST /passports/serviceLogin?callback=abc HTTP/1.1"
puts $sock "Host: $accounts_host "
puts $sock "Content-Type: application/x-www-form-urlencoded"
puts $sock "Connection:Close"
puts $sock "Content-Length:$body_length"
puts $sock ""
puts -nonewline $sock "$body"

set response ""
set passTokenDone ""

proc handle {sock} {
	upvar response response
	upvar passTokenDone passTokenDone
	if { ! [eof $sock] } {
		append response [read $sock 1]
	} else {
#		puts $response
		set passTokenDone 0
		close $sock 
	}
}
fileevent $sock readable [list handle $sock]
vwait passTokenDone

regexp "({.*})" $response json
regexp {beegosessionID=([0-9a-zA-Z]*); } $response cookie beegoSessionId
#puts $beegoSessionId
set passToken [dict get [::json::json2dict $json] pass_token]


set sock [tls::socket $accounts_site $accounts_port]
fconfigure $sock -buffering none -blocking 1 -translation lf

set body "user=$email&pwd=$password"
set body_length [string length $body]
puts $sock "GET /passports/serviceAuth?userId=$user_id&session=zzzzz HTTP/1.1"
puts $sock "Host: $accounts_host "
puts $sock "Content-Type: application/x-www-form-urlencoded"
puts $sock "Cookie: beegosessionID=$beegoSessionId;passToken=$passToken"
puts $sock "Connection:Close"
puts $sock ""

set response ""
set authDone ""

proc handle_auth {sock} {
        upvar response response
        upvar authDone authDone
        if { ! [eof $sock] } {
                append response [read $sock 1]
        } else {
 #               puts $response
                set authDone 0
                close $sock
        }
}
fileevent $sock readable [list handle_auth $sock]
vwait authDone

regexp "auth=(\[0-9a-zA-Z\]*)" $response cookie auth
#puts $auth

set sock [tls::socket $icloud_site $icloud_port]
fconfigure $sock -buffering none -blocking 1 -translation lf

puts $sock "GET /sts?auth=$auth HTTP/1.1"
puts $sock "Host: $icloud_host "
puts $sock "Connection:Close"
puts $sock ""

set response ""
set serviceTokenDone ""

proc handle_serviceToken {sock} {
        upvar response response
        upvar serviceTokenDone serviceTokenDone
        if { ! [eof $sock] } {
                append response [read $sock 1]
        } else {
#               puts $response
                set serviceTokenDone 0
                close $sock
        }
}
fileevent $sock readable [list handle_serviceToken $sock]
vwait serviceTokenDone

regexp "serviceToken=(\[0-9a-zA-Z\]*)" $response cookie serviceToken
puts $serviceToken

exit

