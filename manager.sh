#! /bin/bash


set -Eeuo pipefail

declare -A student_name
declare -A student_grade

studentadd(){

	read -r -p "Enter the Student Name: " name
	read -r -p "Enter the Student ID: "   id
	read -r -p "Enter the Student Grade: " grade
	ID_check
	student_name["$id"]="$name"
	student_grade["$id"]="$grade"
echo "$id : $name : $grade" >> student_info.txt
echo "Date Saved Successfully!"


}

dataretrieve(){

	while IFS=: read -r id name grade 
	do
		student_name["$id"]="$name"
		student_grade["$id"]="$grade"
	done < student_info.txt
}

studentdisplay(){
	dataretrieve
	for id in "${!student_grade[@]}"
	do
		echo "Student ID: $id"
		echo "Student Name: ${student_name[$id]}"
		echo "Student Grade: ${student_grade[$id]}"
		echo "------------------------------------"
	done
}
studentsearch(){
dataretrieve
read -r -p "Enter the ID: " SID
ID_check
found=false
for id in "${!student_name[@]}"
do
	if [[ $id -eq "$SID" ]]; then
		found=true
		echo "*****Student Found!*****"
		echo "Student ID: $id"
		echo "Student Name: ${student_name[$id]}"
		echo "Student Grade: ${student_grade[$id]}"
		echo "------------------------------------"
	break
	fi
done
	if [[ "$found" == false ]]; then

		echo "ID doesn't exit Enter a valid ID!"
	fi


}
# Choice Entry Must be Numbers only 
# ID entry in the Search, New Student
choice_check(){
if [[ -z "$CHO" || !"$CHO" =~ ^[0-9]+$ ]]; then
	echo "ERROR: Enter a valid number(0-5)!"
	exit 1
fi
}
ID_check(){
if [[ -z "$SID" || !"$SID" =~ ^[0-9]+$ ]]; then
	echo "ERROR: Enter a valid number!"
	exit 1
fi
}
menu(){
	echo "===========Student Manager============"
	echo "1. Add a Student"
	echo "2. Display all Students"
	echo "3. Search for student by ID"
	echo "4. Calculate average grade"
	echo "5. Exit"
	echo "======================================"
}
avg(){
dataretrieve


sum=0

count=${#student_grade[@]}
	for id in "${!student_grade[@]}"
	do 
		((sum+=student_grade[$id]))
	done

	if ((count>0)); then
		average=$((sum / count))
		echo "Average = $average"
	else
		echo "No Students found!"
	fi
}


main(){
while true; do
	menu
	read -p "Enter your Choice(1-5): " CHO
	choice_check
	case "$CHO" in
		1)
		studentadd
		;;
		2)
		studentdisplay
		;;
		3)
		studentsearch
		;;
	  	4)
		avg
		;;
		5)
		echo "Goodbye!"
		exit 0
		;;
		*)
		echo "Invalid Choice!"
		exit 1
esac
			

done
}
main
