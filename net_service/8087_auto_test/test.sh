#!/bin/bash


case `hostname` in 
WROC3000|wroc3k)
	echo 3k
	;;
server.com|abc)
	echo hehe
	;;
*)
	echo SB
	;;
esac
