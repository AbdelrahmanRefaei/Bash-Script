#! /bin/bash

set -Eeuo pipefail

dest=""
source=""
compress=false
verbose=false
TIMESTAMP=$(date +%F-%T)
help_message(){
	echo "=========Backup Script==========="
	echo "-s <file name>  Source directory to backup (required)"
	echo "-d <file name>  Destination directory (required)"
	echo "-c        Compress the backup (optional)"
	echo "-v 	Verbose mode to show files being copied (optional)"
	echo "-h	Display this help message"
}

#message function
message(){
	echo "[$(date +%F-%T)]-[ERROR]:$1"
}
message2(){
	echo "Use $0 -h for usage info."
	exit 1
}
option_validation(){
if [[ -z "$dest" || -z "$source" ]]; then
	message "Both source (-s) and destination (-d) directories are required"
	message2 
fi
}
source_validation(){
if [[ ! -e "$source" ]]; then
	message "Source Directory doesn't exist"
	message2
fi
}
dest_validation(){
if [[ -e "$dest" && ! -d "$dest" ]]; then
        message "Destination exists but isn't a directory"
        message2
fi
if [[ ! -d "$dest" ]]; then
	if [[ "$verbose" = "true" ]]; then
		echo "Destination Directory '$dest' doesn't exist"
		echo "Creating the Directory...."
		mkdir -p "$dest"
	fi


fi

}
tar_verbose=""
rsync_verbose=""

tar_verbosev(){
if [[ "$verbose" = "true" ]]; then
	tar_verbose="v"
	rsync_verbose="-v"
fi
}
compress_t(){
	
source_name=$(basename "$source")
tar_verbosev
arch_name="${dest}/${source}_${TIMESTAMP}.tar.gz"
echo "Creating compressed backup: $arch_name"
tar -cz${tar_verbose}f "$arch_name" -C "$(dirname "$source")" "$source_name"
echo "Compressed backup completed successfully!"
}
backup_t(){
source_name=$(basename "$source")
target_file="${dest}/${source}_${TIMESTAMP}"
echo "Creating directory backup: $target_file"
		if command -v rsync &>/dev/null; then
			tar_verbosev
			rsync -a ${rsync_verbose} "$source" "$target_file"
		else
			cp -r ${rsync_verbose} "$source" "$target_file"
		fi
		echo "Backup Completed Successfully!"

}
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
