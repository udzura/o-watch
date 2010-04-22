#!/bin/bash

export RUBYLIB=`dirname $0`/../../lib
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin

ruby ${RUBYLIB}/batch/parse_schedule.rb $1
