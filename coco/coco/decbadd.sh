#!/bin/bash

disk=$1
shift
for f in $@ ; do
    echo $f
    case $f in
	*.BAS)
	    decb copy -tb0 $f $disk,$f
	    ;;
	*.BIN)
	    decb copy -b2 $f $disk,$f
	    ;;
    esac
    error=$?
    if [ $error != 0 ];
    then break
    fi
done
exit $error
