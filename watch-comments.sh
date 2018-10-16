#!/bin/bash
#===================================================================================
#
# FILE: watch.sh
#
# USAGE: --
#
# DESCRIPTION: Child program for junk.sh -
# Watches for all creation, deletion and changes to files in the junk dir
# Then prints the changes on the console for the user to monitor
#	Prints every 15 seconds untill closed with junk.sh -k or SIGINT
#
# NOTES: Created with notes from open source Steve Parker Linux Books
# AUTHOR: Daryl McAllister , S1222204
# VERSION: 1.0
# CREATED: 10.10.2017 - 30.10.17
#===================================================================================


#===================================================================================
#																		WARNING
#This file is for comment references only and should not be run due to changed names
#If this file is to be run then the "-comments" part of the name should be removed 
#from it and its sister junk-comments.sh file
#===================================================================================




#=== FUNCTION ================================================================
# NAME: DirHandling
# DESCRIPTION: Checks to see if the junk directory exists and if not then it exits
#							 Checks to see if the tempCheck directory exists and if it does then
# 						 It removes it and creates a clean copy or just creates one if it does not exist
#===============================================================================
function DirHandling ()
{


if [ ! -d ~/.junkdir ]; then															#Checking that there is a junk dir
	echo "Nothing to watch: The junk dir is missing!"
	exit 1;
fi

if [ ! -n "$(ls -A ~/.junkdir)" ]; then										#Checking that the junk dir is not empty
	echo "Nothing to watch: The junk dir is empty!"
	exit 2;
fi


if [ ! -d ~/.tempCheck ]; then														#makes dir if not existing or removes and creates a fresh
	mkdir ~/.tempCheck
else
  rm -r ~/.tempCheck
	mkdir ~/.tempCheck
fi

}


#=== FUNCTION ================================================================
# NAME: Initalmd5
# DESCRIPTION: Gets the starting md5sum's for all files in the junkdir
#===============================================================================
function Initalmd5 ()
{

for file in ~/.junkdir/*																			#for every file in junkdir, generate md5sum file
do
md5=$(md5sum "$file" | awk {'print $1'})
fileName=$(basename "$file")
echo $md5 > ~/.tempCheck/"$fileName".md5
done

}

#=== FUNCTION ================================================================
# NAME: DeletionChangeCheck
# DESCRIPTION: Watches and echos out any changes or deletions
#===============================================================================
function DeletionChangeCheck ()
{
for file in ~/.tempCheck/*																		#for every generated md5 file
do
fileName=$(basename "$file" .md5)
prev=""

		if find ~/.junkdir -name "$fileName" -print -quit | grep -q '^'; then    #if the file exists in junkdir 
			if find ~/.tempCheck -name "$fileName.md5" -print -quit | grep -q '^'; then   #and has a cororsponding md5sum file
				prev=$(cat "$file")
			else
				prev="0"
			fi
		else
			echo "`date`: $fileName removed from junkdir." 
			rm $file
		fi

    if [ -s "${file}" ]; then																#if the file exists and has content
      md5=`md5sum ~/.junkdir/$fileName | cut -d" " -f1 |tee "${SAVEDIR}/${file}"`   #do a md5checksum, take the hash and post it to file
      if [ "$prev" != "$md5" ]; then
        case "$prev" in
          0) echo "`date`: $fileName added to junk dir." ;;
          *) echo "`date`: $fileName changed." 
             ;;
        esac
      fi
    fi
done
}

#=== FUNCTION ================================================================
# NAME: CreationCheck
# DESCRIPTION: Watches and echos out any creations or deletions
#===============================================================================
function CreationChangeCheck ()
{
for file in ~/.junkdir/*																#for every file in the junk dir
do
	fileName=$(basename "$file".md5)
	if [ -s "$file" ]; then																#if the file exists and has content
		if [ ! -s ~/.tempCheck/"$fileName" ]; then          #if there is no cororsponding md5checksum file
							prev1="0"
		else
			prev1="1"
		fi
	fi
    if [ -s "$file" ]; then
      md52=`md5sum "$file" | cut -d" " -f1 |tee ~/.tempCheck/$fileName`
      if [ "$prev1" != "$md52" ]; then
        case "$prev1" in
          0) echo "`date`: $file added to junk dir." ;;
          *) :
             ;;
        esac
     fi
   fi
done
}

#=== FUNCTION ================================================================
# NAME: trapExit
# DESCRIPTION: Deletes the tempCheck dir before exiting on SIGINT
#===============================================================================
function trapExit ()
{
	rm -r ~/.tempCheck
	echo "Exiting..."

}

	



#-----MAIN-----#
trap "trapExit ; exit" SIGINT											#Trap for dealing with SIGINT



DirHandling																				#Call Dirhandling to check junkdir and initilize the tempCheck dir
Initalmd5																					#Get an inital md5sum of all files in junkdir

while :																						#infiniteloop
do

DeletionChangeCheck																#do checks for file changes and deletions
CreationChangeCheck																#do checks for file creations
	
sleep 15																					#wait for 15 seconds before continueing to start again
done

exit 0
