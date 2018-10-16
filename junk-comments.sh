#!/bin/bash
#===================================================================================
#
# FILE: junk.sh
#
# USAGE: --
#
# DESCRIPTION: List and/or delete all stale links in directory trees.
# The default starting directory is the current directory.
# Don’t descend directories on other filesystems.

# NOTES: Created with notes from open source Steve Parker Linux Books
# AUTHOR: Daryl McAllister , S1222204
# VERSION: 1.0
# CREATED: 10.10.2017 - 30.10.17
#===================================================================================


#===================================================================================
#																		WARNING
#This file is for comment references only and should not be run due to changed names
#If this file is to be run then the "-comments" part of the name should be removed 
#from it and its sister watch-comments.sh file
#===================================================================================


#=== FUNCTION ================================================================
# NAME: checkDirExists
# DESCRIPTION: Checks to see if the junk directory exists
#===============================================================================
function checkDirExists ()
{


if [ ! -d ~/.junkdir ]; then																					#If the chunkdir is not there then run create directory
  echo 'Junk Directory has not been found'
  createDirectory
fi
	

}



#=== FUNCTION ================================================================
# NAME: checkFileExists
# DESCRIPTION: Checks to see if the junk directory exists
#===============================================================================
function checkFileExists ()
{

if find ~/.junkdir -name $1 -print -quit | grep -q '^'; then											#if the file can be found then continue
  return 0
else
  echo "the file does not exist!"
  exit 1
fi
	
}



#=== FUNCTION ================================================================
# NAME: createDirectory
# DESCRIPTION: Outputs a list in the terminal of the contents of the junk directory
#===============================================================================
function createDirectory ()
{

	mkdir ~/.junkdir																																#makes the junk dir then checks to ensure it was made
	echo 'Junk Directory has been created'
	checkDirExists

}


#=== FUNCTION ================================================================
# NAME: checkDirSize
# DESCRIPTION: Checks if the junk dir is over a certain size and displays message if so
#===============================================================================
function checkDirSize ()
{
																																							
if [ -n "$(ls -A ~/.junkdir)" ]; then
dataI=$(find ~/.junkdir/* -type f -print0 | xargs -0 stat --print='%s\n' | awk '{total+=$1} END {print total}') #gets total size of all files

	if [ "$dataI" \> 1024 ]; then																							#if the total size is bigger than 1K 		
		echo "--WARNING--: The junk directory is over 1K in size"
	else
		return 0
	fi
fi

}



#=== FUNCTION ================================================================
# NAME: checkDirEmpty
# DESCRIPTION: Checks if the junk directory is empty.
#===============================================================================
function checkDirEmpty ()
{
if [ -n "$(ls -A ~/.junkdir)" ]; then																						#if the dir is not empty move onto check dir size else error
  checkDirSize && return 0
else	
  echo "The junk directory is empty!"
  exit 2
fi
}

#=== FUNCTION ================================================================
# NAME: lCommand
# DESCRIPTION: Outputs a list in the terminal of the contents of the junk directory
#===============================================================================
function lCommand ()
{

  checkDirExists
  checkDirEmpty

	fileNames=$( ls -A ~/.junkdir )																								#Seperately get the file name,size and type and store
	fileSizes=$(find ~/.junkdir/* -printf '%s\n';)
	fileTypes=$(find ~/.junkdir/* | xargs file |  awk '{print $3}')

	printf "%-20s %-20s %-20s\n" "File Name" "Size" "Type"								#printf for formatating and paste and awk for joining then formating
	printf "%-20s %-20s %-20s\n" "-----" "-----" "-----"
	Output=$(paste <(echo "$fileNames") <(echo "$fileSizes") <(echo "$fileTypes") | awk '{ printf "%-20s %-20s %-20s\n" , $1, $2, $3 }' )

	echo "$Output"
}



#=== FUNCTION ================================================================
# NAME: rCommand
# DESCRIPTION: Recovers a specified file and places it in the current directory
# PARAMETER 1: name of file to be recovered
#===============================================================================
function rCommand ()
{

	fileToRecover="$1"																										#get the file from the passed in CMD line arguments

	if [ -z "$fileToRecover" ]; then																			#if it exists
  	echo "Enter the name of the file you wish to recover" 
  	read -r response
  	fileToRecover=${response};
	fi

	checkDirExists
	checkDirEmpty
	checkFileExists $fileToRecover

	filePath=$(find ~/.junkdir -name $fileToRecover)											#find the path
	currentPath=$(pwd)

	mv "$filePath" "$currentPath"																				#move to current directory

	echo "File has been restored to current working directory"

}



#=== FUNCTION ================================================================
# NAME: dCommand
# DESCRIPTION: Interactivley deletes the contents of the junk directory
#===============================================================================
function dCommand ()
{

	checkDirExists
	checkDirEmpty
	echo "Are you sure you wish to delete the entire contents of the junk folder? Y/N "
    	read -r response																								#reading responce gets the users input
    	case $response in
        	[yY][eE][sS]|[yY]) 																					#regular expression for any type of yes input
            	rm -r ~/.junkdir/*																			#deletes entire folder
  	    	echo "Folder Contents Deleted" 
           	 ;;
       	 *)																														#anything other than yes
           	 echo "Folder Contents not deleted"
           	 ;;
    	esac
}



#=== FUNCTION ================================================================
# NAME: tCommand
# DESCRIPTION: Shows a list of size of all junk directories by user and a total
#===============================================================================
function tCommand ()
{

	Output=$(du -csb /home/*/.junkdir )																		#sets the output of the total of all junk directories

	printf "%-10s %10s\n" "Size" "User Junk Dir Path" 
	printf "%-10s %10s\n" "-----" "-----"
	echo "$Output"
}



#=== FUNCTION ================================================================
# NAME: junkFunction
# DESCRIPTION: Takes the specified file and moves it to the junk folder
#===============================================================================
function junkFunction ()
{
																									
checkDirExists
checkDirSize
if find "$(pwd)" -name $1 -print -quit | grep -q '^'; then						#if the file can be found in current directory
  mv $1 ~/.junkdir	
	echo "File Moved"																									#move to junk folder																			
else
  echo "the file does not exist!"
  exit 1
fi

}

#=== FUNCTION ================================================================
# NAME: wFunction
# DESCRIPTION: Runs a watch script to monitor changes in junk dir in a seperate window
#===============================================================================
function wFunction ()
{
checkDirExists
checkDirEmpty
	if pgrep -x "watch.sh" > /dev/null																#if the watch script is running give error
then
 		 echo "The watch script is already running!"
else
  	xfce4-terminal -e ./watch.sh &																	#run watchscript in new terminal and continue current terminal
fi

}

#=== FUNCTION ================================================================
# NAME: kFunction
# DESCRIPTION: Ends the watch script
#===============================================================================
function kFunction ()
{


	if pgrep -x "watch.sh" > /dev/null															#if watch script is running then find it and end it
then
 		 pkill -f watch.sh
else
    echo "The watch script is not running!"
fi

}



#=== FUNCTION ================================================================
# NAME: trapExit
# DESCRIPTION: Displays the total number of files in the Junkdir and displays exit message
#===============================================================================
function trapExit ()
{
	checkDirExists
	checkDirEmpty
	
	noOfFiles=$(ls ~/.junkdir | wc -l)																		#get total number of files and display them
 
	echo $'\n'"Current number of files in Junk directory: " "$noOfFiles"
	echo "Exiting..."

}
#=== FUNCTION ================================================================
# NAME: trapExit
# DESCRIPTION: Displays the total number of files in the Junkdir and displays exit message
#===============================================================================

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



#----MAIN----#


trap "trapExit ; exit" SIGINT


echo "Author: DARYL MCALLISTER"
echo "StudentId: S1222204"

#----------------------------------------------------------------------
# Getops that deals with command line user input
#----------------------------------------------------------------------
while getopts :lr:dtwk args 																					# options handling from command line
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

#----------------------------------------------------------------------
# Menu system that functions when no command line input is explicitly stated by user
#----------------------------------------------------------------------
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

