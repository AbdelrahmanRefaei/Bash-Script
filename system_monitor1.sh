#!/bin/env bash


set -euo pipefail

OUTPUT_FILE=""
AUTO=false


declare -a REPORT


usage(){

	echo "Usage: $0 [-a] [-o file] [-h]"
	echo ""
	echo "Options:         "
	echo "-o [FILE NAME] Save Output to File"
	echo "-a Run all the checks"
	echo "-h Usage of the Script"
}

check_cpu(){

	local CPU
	CPU=$(ps -aux --sort=-%cpu | head -n 10)
        REPORT+=("========== CPU ==========")
        REPORT+=("$CPU")

        echo "-----CPU Usage-----"
        echo "$CPU"
	echo
}

check_mem(){
	local MEM
	MEM=$(free -h)
	REPORT+=("==========Memory=========")
	REPORT+=("$MEM")
	echo "-------Memory Usage------"
	echo "$MEM"
	echo
}

check_disk(){
        local DISK

	DISK=$(df -h)
	REPORT+=("========Disk=========")
	REPORT+=("$DISK")
	
        echo "-----Disk Usage-----"
	echo "$DISK"
	echo
}


check_network(){
        local NET

        NET=$(ip addr && echo && ip route)
	REPORT+=("==========Network Status==========")
        REPORT+=("$NET")
        echo "----Network Status----"
	echo "$NET"
	echo
}

check_processes(){
        local PROS
	PROS=$(ps -aux --sort=-%cpu | head -n 6)
        REPORT+=("========Top 5 Processes=========")
	REPORT+=("$PROS")
        echo "----Top 5 Processes----"
	echo "$PROS"
	echo
}
run_all(){
check_cpu
echo ""
check_mem
echo ""
check_disk
echo ""
check_network
echo ""
check_processes
echo ""
}

save_report(){
if [[ -n "$OUTPUT_FILE" ]]; then
	printf "%s\n\n" "${REPORT[@]}" > "$OUTPUT_FILE"
	echo "Report saved to : $OUTPUT_FILE"
fi	
}


main_menu(){
select option in \
"CPU" \
"Memory" \
"Disk" \
"Network" \
"Processes" \
"Exit"
do
	case "$option" in
		CPU)
			check_cpu
			;;
                Memory)
			check_mem
			;;
		Disk)
			check_disk
		        ;;
		Network)
			check_network
		        ;;
		Processes)
			check_processes
		        ;;
		Exit)
			echo "Goodbye!"
			break
		        ;;
		*)
		echo "Invalid Option."
		;;
esac
done
}

while getopts ":o:ah" opt; do
        case "$opt" in
                o)
			 OUTPUT_FILE="$OPTARG"

            touch "$OUTPUT_FILE" 2>/dev/null || {
                echo "Cannot write to $OUTPUT_FILE"
                exit 1
            }
            ;;
                a)
                        AUTO=true
                        ;;
                h)
                        usage
                        exit 0
                        ;;
                :)
			echo "Option -$OPTARG requires an argument"
			exit 1
                        ;;
                \?)
			echo "Invalid Option: -$OPTARG"
			usage
			exit 1
                        ;;

esac
done

main(){
if [[ "$AUTO" == true ]]; then
	run_all
else
	main_menu
fi

save_report


}

main
