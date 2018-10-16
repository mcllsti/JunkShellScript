#man(1)				 junk man page				man(1)



#NAME
       junk - moves files to a junk folder

#SYNOPSIS
       junk [OPTION]... [FILENAME]

#DESCRIPTION
       Junk is a program that will move a specified file to the Junk Directory
       or perform other functions on the Junk directory. If  there  is	not  a
       Junk directory then the program will create one for the user.



       Junk  can  be  given a command line option to run a function or if sup-
       plied without a command line option or file to junk then it will run an
       menu to allow a user to interactivley choose an option.

#OPTIONS
       -l     Displays	a list of the contents of the Junk directory with file
	      name,size and type properties.

       -d     Interactivly deletes the contents of the Junk directory.

       -r filename
	      Recovers the file with the given name from  the  Junk  directory
	      and places it in the current directory.

       -t     Displays	a total size of each system users Junk directories and
	      a final overall total.

       -w     Opens a seperate terminal where the system will give  output  on
	      any changes, deletion of creation of files in the junk dir.

       -k     Ends the watch program if it is running

#WATCH COMMAND
       The  watch  command is a large add on script that comes with junk. Once
       run It will open an external command window where it will not show  any
       output  unless  a  file	in  the   junkdir  has	been added, removed or
       changed.  The watch is updated every 15 seconds and keeps track of  all
       changes in that time

#ERROR CODES
       0      Exit Sucessfully

       1      Exits with general error such as file missing

       2      Junk Dir Directory is empty

#RUNNING ENVIROMENT
       This  script  has been specifically designed for Linux mint 17.3 and at
       current time has no cross compatability.  The  terminal	emulator  that
       must  be  used  when running this script is the Xfce terminal.  Without
       this emulator then the watch script will fail to run.

#SEE ALSO
       mv(1), rm(1)

#BUGS
       No known bugs  All  bugs  should  be  submitted	to  (dmcall200@caledo-
       nia.ac.uk).

#AUTHOR
       Written	by  Daryl  McAllister  (dmcall200@caledonia.ac.uk)  1/10/17  -
       30/10/17: Free Usage.



1.0				  20/10/2017				man(1)
