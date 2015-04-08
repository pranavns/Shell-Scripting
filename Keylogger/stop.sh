#!/bin/sh

#Script to stop myKeylogger process using catchable interruption

ps aux | grep "myKeylogger" | awk '{ print $2}' | xargs kill -SIGINT

cat output_file.txt 
