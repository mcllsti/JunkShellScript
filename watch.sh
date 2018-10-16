#!/bin/bash

function DirHandling ()
{


if [ ! -d ~/.junkdir ]; then															
	echo "Nothing to watch: The junk dir is missing!"
	exit 1;
fi

if [ ! -n "$(ls -A ~/.junkdir)" ]; then										
	echo "Nothing to watch: The junk dir is empty!"
	exit 2;
fi


if [ ! -d ~/.tempCheck ]; then														
	mkdir ~/.tempCheck
else
  rm -r ~/.tempCheck
	mkdir ~/.tempCheck
fi

}



function Initalmd5 ()
{

for file in ~/.junkdir/*																			
do
md5=$(md5sum "$file" | awk {'print $1'})
fileName=$(basename "$file")
echo $md5 > ~/.tempCheck/"$fileName".md5
done

}


function DeletionChangeCheck ()
{
for file in ~/.tempCheck/*																	
do
fileName=$(basename "$file" .md5)
prev=""

		if find ~/.junkdir -name "$fileName" -print -quit | grep -q '^'; then    
			if find ~/.tempCheck -name "$fileName.md5" -print -quit | grep -q '^'; then   
				prev=$(cat "$file")
			else
				prev="0"
			fi
		else
			echo "`date`: $fileName removed from junkdir." 
			rm $file
		fi

    if [ -s "${file}" ]; then																
      md5=`md5sum ~/.junkdir/$fileName | cut -d" " -f1 |tee "${SAVEDIR}/${file}"`   
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


function CreationChangeCheck ()
{
for file in ~/.junkdir/*																
do
	fileName=$(basename "$file".md5)
	if [ -s "$file" ]; then															
		if [ ! -s ~/.tempCheck/"$fileName" ]; then         
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


function trapExit ()
{
	rm -r ~/.tempCheck
	echo "Exiting..."

}

	



trap "trapExit ; exit" SIGINT											



DirHandling																				
Initalmd5																					

while :																						
do

DeletionChangeCheck															
CreationChangeCheck																
	
sleep 15																					
done

exit 0
