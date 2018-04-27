#!/bin/bash

# Progressbar function
# @param int $1 start progressbar general
# @param int $2 end progressbar general
# @param int $3 start progressbar default
# @param int $4 end progressbar default
function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done

    let __progress=(${3}*100/${4}*100)/100
    let __done=(${__progress}*4)/10
    let __left=40-$__done

    filename="Traduzindo: "${5}

    #clear;
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

    __fill=$(printf "%${__done}s")
    __empty=$(printf "%${__left}s")

    clear;
    tput cup 2 0
    COLUMNS=$(tput cols)
    printf "%*s\n" $(((${#filename}+$COLUMNS)/2)) "$filename"

    tput cup 3 0
    COLUMNS=$(tput cols)
    tp1="Progresso:        [${__fill// /#}${__empty// /-}] ${__progress}%";
	printf "%*s" $(((${#tp1}+$COLUMNS)/2)) "$tp1";

	tput cup 4 0
	COLUMNS=$(tput cols)
	tp2="Progresso Geral: [${_fill// /#}${_empty// /-}] ${_progress}%";
	printf "%*s" $(((${#tp1}+$COLUMNS)/2)) "$tp2";
}


function getFileName() {
    fl=$(basename "$1" )
    fn="${fl%.*}"".${fl##*.}"
    echo $fn
}

function getExtension() {
    fl=$(basename "$1" )
    fn="${fl##*.}"
    echo $fn
}





msg="Enter directory for translate files srt"
COLUMNS=$(tput cols)
clear;
echo -e "\n"
printf "%*s\n" $(((${#msg}+$COLUMNS)/2)) "$msg"
#Read url to download video
read directory

if [ ! -d "$directory" ]; then
	clear;
	msg="Directory doesn't exist. Aborting";
  	echo -e "\n"
	printf "%*s\n" $(((${#msg}+$COLUMNS)/2)) "$msg"
	exit 1;
fi


cd "$directory"

_start=1

start=1
end=100

n=1

e="srt"
i=1;
for file in *; do	
	ext=$(getExtension "$file")
    if [ "$ext" = "$e" ]; then
        FILES[$i]=$file
        i=$(( $i + 1 ))
    fi
done
flength=${#FILES[@]}

clear;

# Proof of concept
for i in $(seq ${flength})
do

	#Set file
	fname="${FILES[$i]}"

    ProgressBar ${i} ${flength} ${n} ${end} ${fname}

	#Read file into array (Read by break line)
	IFS=$'\n' lines=($(cat $fname))

	#Get length lines
	wlines=${#lines[@]}

	#text line
	line=""	

	for n in $(seq ${#lines[*]}); do
		if [[ "${lines[$n]}" =~ ^[a-zA-Z].*$ ]]; then
	    	line="${lines[$n]}"
			response=$(trans -no-warn -brief "en:pt-BR" $line)
			if echo $response | grep -q 'fatal: remote host and port information'; then
				echo -e "\n\n\nGoogle translate not responding\nWait one minute and try again.\nexit";
				exit 1;
			fi;
			lines[$n]=$response
			ProgressBar ${i} ${flength} ${n} ${wlines} ${fname}
	    fi	    
	done
	#printf "%s\n" "${lines[@]}" > "pt-"$fname  
done

ProgressBar ${i} ${flength} ${wlines} ${wlines} ${fname}

msg="FINALIZOU!"
COLUMNS=$(tput cols)
echo -e "\n"
printf "%*s\n" $(((${#msg}+$COLUMNS)/2)) "$msg"
echo "";
exit 0;