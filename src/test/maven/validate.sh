#!/bin/bash
# This file is part of db2unit: A unit testing framework for DB2 LUW.
# Copyright (C)  2014, 2015, 2018  Andres Gomez Casanova (@AngocA)
#
# db2unit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# db2unit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Andres Gomez Casanova <angocaATyahooDOTcom>

# Validates if Db2 is installed, instance is configured and it is started.
#
# Version: 2018-05-01 V2_BETA
# Author: Andres Gomez Casanova (AngocA)
# Made in COLOMBIA.

# Check if current OS is Linux
case $(uname -s) in
 Linux)
  echo "Current OS is Linux"
  ;;
 Darwin)
  echo "Current OS is Mac OS"
  ;;
 *)
  echo "Current OS is not a Linux. Impossible to determine if Db2 is installed."
  exit
  ;;
esac

DIR=$(strings /var/db2/global.reg 2> /dev/null | grep -s '^\/' | sort | uniq | grep -v sqllib | grep -v das | head -1)
echo "Directory $DIR"
if [ ! -x ${DIR}/bin/db2 ] ; then
 echo "DB2 non installed."
 exit 1
else
 echo "DB2 is installed."

 DB2_CONF=$(db2level | grep tokens | wc -l)
 if [ ${DB2_CONF} -ne 0 ] ; then
  echo "DB2 is configured."

  DB2_UP=$(db2pd - | grep Up)
  if [ -n "${DB2_UP}" ] ; then
   echo "A Db2 instance is running."
  else
   echo "Please start the Db2 instance."
   exit 3
  fi
 else
  echo "Please configure the current environment to a Db2 instance."
  exit 2
 fi
fi
