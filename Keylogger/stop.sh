#!/bin/sh

#Script to stop myKeylogger process using catchable interruption 'SIGINT'
#Displays the content of keyStrokes.txt

ps aux | grep "myKeylogger" | awk '{ print $2}' | xargs kill -SIGINT

cat keyStrokes.txt 
