#!/bin/bash

function checkDirExists ()
{


if [ ! -d ~/.junkdir ]; then																					
  echo 'Junk Directory has not been found'
  createDirectory
fi
	

}



function checkFileExists ()
{

if find ~/.junkdir -name $1 -print -quit | grep -q '^'; then											
  return 0
else
  echo "the file does not exist!"
  exit 1
fi
	
}




function createDirectory ()
{

	mkdir ~/.junkdir																																
	echo 'Junk Directory has been created'
	checkDirExists

}



function checkDirSize ()
{

if [ -n "$(ls -A ~/.junkdir)" ]; then
dataI=$(find ~/.junkdir/* -type f -print0 | xargs -0 stat --print='%s\n' | awk '{total+=$1} END {print total}') 

	if [ "$dataI" \> 1024 ]; then																							
		echo "--WARNING--: The junk directory is over 1K in size"
	else
		return 0
	fi
fi

}




function checkDirEmpty ()
{
if [ -n "$(ls -A ~/.junkdir)" ]; then
	echo "Hey"																						
  checkDirSize && return 0
else	
  echo "The junk directory is empty!"
  exit 2 
fi
}


function lCommand ()
{

  checkDirExists
  checkDirEmpty

	fileNames=$( ls -A ~/.junkdir )																								
	fileSizes=$(find ~/.junkdir/* -printf '%s\n';)
	fileTypes=$(find ~/.junkdir/* | xargs file |  awk '{print $3}')

	printf "%-20s %-20s %-20s\n" "File Name" "Size" "Type"								
	printf "%-20s %-20s %-20s\n" "-----" "-----" "-----"
	Output=$(paste <(echo "$fileNames") <(echo "$fileSizes") <(echo "$fileTypes") | awk '{ printf "%-20s %-20s %-20s\n" , $1, $2, $3 }' )

	echo "$Output"
}




function rCommand ()
{

	fileToRecover="$1"																										

	if [ -z "$fileToRecover" ]; then																		
  	echo "Enter the name of the file you wish to recover" 
  	read -r response
  	fileToRecover=${response};
	fi

	checkDirExists
	checkDirEmpty
	checkFileExists $fileToRecover

	filePath=$(find ~/.junkdir -name $fileToRecover)										
	currentPath=$(pwd)

	mv "$filePath" "$currentPath"																				

	echo "File has been restored to current working directory"

}




function dCommand ()
{

	checkDirExists
	checkDirEmpty
	echo "Are you sure you wish to delete the entire contents of the junk folder? Y/N "
    	read -r response																							
    	case $response in
        	[yY][eE][sS]|[yY]) 																					
            	rm -r ~/.junkdir/*																			
  	    	echo "Folder Contents Deleted" 
           	 ;;
       	 *)																														
           	 echo "Folder Contents not deleted"
           	 ;;
    	esac
}



function tCommand ()
{

	Output=$(du -csb /home/*/.junkdir )																		

	printf "%-10s %10s\n" "Size" "User Junk Dir Path" 
	printf "%-10s %10s\n" "-----" "-----"
	echo "$Output"
}



function junkFunction ()
{

checkDirExists
checkDirSize
if find "$(pwd)" -name $1 -print -quit | grep -q '^'; then						
  mv $1 ~/.junkdir	
	echo "File Moved"																									
else
  echo "the file does not exist!"
  exit 1
fi

}


function wFunction ()
{
checkDirExists
checkDirEmpty
	if pgrep -x "watch.sh" > /dev/null																
then
 		 echo "The watch script is already running!"
else
xfce4-terminal -e ./watch.sh &							
fi

}


function kFunction ()
{


	if pgrep -x "watch.sh" > /dev/null															
then
 		 pkill -f watch.sh
else
    echo "The watch script is not running!"
fi

}



function trapExit ()
{
	checkDirExists
	checkDirEmpty
	
	noOfFiles=$(ls ~/.junkdir | wc -l)																		
 
	echo $'\n'"Current number of files in Junk directory: " "$noOfFiles"
	echo "Exiting..."

}


function usage (){
    echo "usage: junk [File][-ldtwk] [-r file]"
    echo "  -l      lists files in junk dir"
    echo "  -d      interactively deletes all files in junk dir"
    echo "  -t      displays totals for all users junk dirs"
    echo "  -w      runs a watch command on junk dir in seperate terminal"
    echo "  -k	    Ends the watch command and closes seperate terminal"
    echo "  -r file  recovers a specified file"
    exit 1
}





trap "trapExit ; exit" SIGINT


echo "Author: DARYL MCALLISTER"
echo "StudentId: S1222204"


while getopts :lr:dtwk args 																					
do
  case $args in
     l) lCommand;;
     r) rCommand $2;;
     d) dCommand;; 
     t) tCommand;; 
     w) wFunction;; 
     k) kFunction;;     
     :) echo "extra data missing, option -$OPTARG";;
    \?) usage;;
  esac
done

((pos = OPTIND - 1))
shift $pos

PS3='option> '


if (( $# == 0 ))
then if (( $OPTIND == 1 )) 
 then select menu_list in list recover delete total watch kill exit
      do case $menu_list in
         "list") lCommand;;
         "recover") rCommand;;
         "delete") dCommand;;
         "total") tCommand;;
         "watch") wFunction;;
         "kill") kFunction;;
         "exit") exit 0;;
         *) echo "unknown option";;
         esac
      done
 fi
else 
  junkFunction $1
fi

exit 0
