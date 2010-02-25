#!/bin/bash

export RUBYLIB=/var/rails/owatch/lib
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin

ruby /var/rails/owatch/lib/batch/parse_schedule.rb $1
