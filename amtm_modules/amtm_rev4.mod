#!/bin/sh
#bof
c_url(){ /usr/sbin/curl -fsNL --connect-timeout 10 --retry 3 --max-time 12 "$@";}
#eof
