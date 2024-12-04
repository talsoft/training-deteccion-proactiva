#!/bin/bash
if [ "$1" == "env" ]; then echo env >> /tmp/check.log; else if [ "$1" == "export" ]; then  echo export >> /tmp/check.log; else if [[ "$1" == *"./LinEnu"* ]]; then echo LinEnum >> /tmp/check.log; fi fi fi
if [ "$1" == "curl" ]; then echo curl >> /tmp/check.log; else if [ "$1" == "wget" ]; then  echo wget >> /tmp/check.log;  fi fi
