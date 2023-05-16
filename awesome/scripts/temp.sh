#!/usr/bin/env bash
#
case $@ in
    cpu | Cpu | CPU )
        sensors | awk -F\  '/[Pp]ackage\ id\ 0/{print $4}'  2>/dev/null | grep -E -o '[0-9]{2,3}'
        ;;

    fan-speed)
        sensors | awk -F\  '/cpu_fan/{print $2}' 2>/dev/null
        ;;

    gpu | Gpu | GPU)
        sensors | sed -n $(sensors | sed -n '/GPU/='),+4p | awk -F\  '/temp1/{print $2}' 2>/dev/null
        ;;
    *)
        exit 0
        ;;

esac

