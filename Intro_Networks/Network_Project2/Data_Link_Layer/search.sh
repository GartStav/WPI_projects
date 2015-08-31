#!/bin/bash

for i in `ls`
do
	
	grep $1 $i > /dev/null
	if [ $? -eq 0 ]
	then
		
		echo found '#'"$n" "$1" from $i

	fi
done
