#!/bin/bash

disk=$1
shift
for f in $@ ; do
    case $f in
	*.BAS)
	    dragondos write $disk $f $f -basic
	    ;;
	*.BIN)
	    dragondos write $disk $f $f
	    ;;
    esac
    error=$?
    if [ $error != 0 ];
    then break
    fi
done
exit $error
