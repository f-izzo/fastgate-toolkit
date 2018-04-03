#!/bin/sh

case "$1" in
	start)
		echo "Starting SSH daemon..."
		dropbear -r /etc/dropbear/dropbear_rsa_host_key
		exit 0
		;;

	stop)
		echo "Stopping SSH daemon..."
		killall dropbear 2>/dev/null
		exit 0
		;;

	*)
		echo "$0: unrecognized option $1"
		exit 1
		;;

esac

