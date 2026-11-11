#! /bin/bash



#=====Meta Data======
# Usage: Basic Backup Bashscript
# AUthor: Abdelrahman Refaei

set -Eeuo pipefail

# Colors
if [[ -t 1 ]]; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    RESET=''
fi

dest=""
source=""
compress=false
verbose=false
TIMESTAMP=$(date +%F-%T)
help_message(){
	echo "${CYAN}=========Backup Script===========${RESET}"
	echo "${GREEN}-s <file name>${RESET}  Source directory to backup (required)"
	echo "${GREEN}-d <file name>${RESET}  Destination directory (required)"
	echo "${YELLOW}-c${RESET}        Compress the backup (optional)"
	echo "${YELLOW}-v${RESET} 	Verbose mode to show files being copied (optional)"
	echo "${BLUE}-h${RESET}	Display this help message"
}

# Message function for most repeated echo commands
message(){
 	echo "${RED}[$(date +%F-%T)]-[ERROR]:$1${RESET}"
}
message2(){
	echo "${BLUE}Use $0 -h for usage info.${RESET}"
	exit 1
}

# Validation for Options directory (Must not be empty and source existance)
option_validation(){
if [[ -z "$dest" || -z "$source" ]]; then
 	message "${RED}Both source (-s) and destination (-d) directories are required${RESET}"
	message2 
fi
}
source_validation(){
if [[ ! -e "$source" ]]; then
	message "${RED}Source Directory doesn't exist${RESET}"
	message2
fi
}
dest_validation(){
if [[ -e "$dest" && ! -d "$dest" ]]; then
   	 message "${BLUE}Destination exists but isn't a directory${RESET}"
        message2
fi
if [[ ! -d "$dest" ]]; then
	if [[ "$verbose" = "true" ]]; then
		echo "${BLUE}Destination Directory '$dest' doesn't exist${RESET}"
	 	echo "${MAGENTA}Creating the Directory....${RESET}"
		mkdir -p "$dest"
	fi


fi

}
# Verbose option check
tar_verbose=""
rsync_verbose=""

tar_verbosev(){
if [[ "$verbose" = "true" ]]; then
	tar_verbose="v"
	rsync_verbose="-v"
fi
}

# Compress check to use in the other function
compress_t(){
	
source_name=$(basename "$source")
tar_verbosev
arch_name="${dest}/${source}_${TIMESTAMP}.tar.gz"
	 echo "${MAGENTA}Creating compressed backup: $arch_name ${RESET}"
tar -cz${tar_verbose}f "$arch_name" -C "$(dirname "$source")" "$source_name"
	 echo "${GREEN}Compressed backup completed successfully! ${RESET}"
}
backup_t(){
source_name=$(basename "$source")
target_file="${dest}/${source}_${TIMESTAMP}"
	 echo "${MAGENTA}Creating directory backup: $target_file ${RESET}"
		if command -v rsync &>/dev/null; then
			tar_verbosev
			rsync -a ${rsync_verbose} "$source" "$target_file"
		else
			cp -r ${rsync_verbose} "$source" "$target_file"
		fi
		 echo "${GREEN}Backup Completed Successfully! ${RESET}"
}

# Main Function to combine all the functions
main_func(){
option_validation
source_validation
dest_validation
tar_verbosev
if [[ "compress" = "true" ]]; then
	compress_t
else
	backup_t
fi
}

main(){
while getopts ":s:d:chv" opt; do
	case "$opt" in
		s) source="$OPTARG" ;;
		d) dest="$OPTARG" ;;
		c) compress=true ;;
		v) verbose=true ;;
		h)
			help_message
			exit 0
			;;
		\?)
			message "Invalid Option -$OPTARG" >&2
			message2
			;;
		:)
			message "Option -$OPTARG Requires an Argument" >&2
			message2
			;;
	esac
done
main_func
}

main "$@"
