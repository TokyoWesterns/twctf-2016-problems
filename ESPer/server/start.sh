#!/bin/bash
cd `dirname $0`
export RANDFILE=`mktemp`
exec /usr/bin/ruby2.0 problem.rb
