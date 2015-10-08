#!/bin/bash

for ((;;));do
	nc -l 9999 < mips-strace
done


