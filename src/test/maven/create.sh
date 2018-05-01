#!/bin/bash
# This file is part of db2unit: A unit testing framework for DB2 LUW.
# Copyright (C)  2014, 2015  Andres Gomez Casanova (@AngocA)
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

# Creates a database.
#
# Version: 2018-01-14 V2_BETA
# Author: Andres Gomez Casanova (AngocA)
# Made in COLOMBIA.

DB=$(db2 list db directory | awk '/alias/ && /DB2UNIT/ {print $4}')
if [ -n "${DB}" ] ; then
 echo "Dropping current db2unit database..."
 db2 drop db db2unit
fi
echo "Creating database..."
db2 create db db2unit

echo "Installing log4db2"
cd /tmp
if [ -r  log4db2.tar.gz ] ; then
 tar -xf log4db2.tar.gz
 cd log4db2
 db2 connect to db2unit
 . ./install
else
 echo "Please put the log4db2 (log4db2.tar.gz) installer in the /tmp directory."
fi

echo "Environment was configured."
