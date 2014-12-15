@echo off
::  This file is part of db2unit: A unit testing framework for DB2 LUW.
:: Copyright (C)  2014  Andres Gomez Casanova (@AngocA)
::
:: db2unit is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
::
:: db2unit is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::
:: Andres Gomez Casanova <angocaATyahooDOTcom>

:: Execute all tests.
::
:: Version: 2014-05-10 V2_BETA
:: Author: Andres Gomez Casanova (AngocA)
:: Made in COLOMBIA.

call init-dev.bat

db2 connect > NUL
if %ERRORLEVEL% NEQ 0 (
 echo Please connect to a database before the execution of the tests
) else (
 Setlocal EnableDelayedExpansion
 if "%1" == "-np" (
  set PAUSE_INSTALL=false
  set TIME_INI=echo !time!
 ) else if "%1" == "-ix" (
  set PAUSE_INSTALL=install_false
 ) else (
   set PAUSE_INSTALL=true
 )

 if "!PAUSE_INSTALL!" == "true" (
  echo Executing all tests with pauses in between.
 ) else if "!PAUSE_INSTALL!" == "install_false" (
  echo Installing and executing all tests without pauses.
 ) else if "!PAUSE_INSTALL!" == "false" (
  echo Executing all tests.
 ) else (
  echo Error expanding variable
  exit /B -1
 )
 call:executeTest DB2UNIT_EMPTY
 call:executeTest DB2UNIT_EXECUTION
 call:executeTest DB2UNIT_EXECUTION_2
 call:executeTest DB2UNIT_ASSERTIONS_GENERAL
 call:executeTest DB2UNIT_ASSERTIONS_BOOLEAN
 call:executeTest DB2UNIT_ASSERTIONS_DATETIME
 call:executeTest DB2UNIT_ASSERTIONS_NUMBER
 call:executeTest DB2UNIT_ASSERTIONS_STRING
 call:executeTest DB2UNIT_ASSERTIONS_STRING_LONG
 call:executeTest DB2UNIT_ASSERTIONS_TABLE
 call:executeTest DB2UNIT_ASSERTIONS_XML
 call:executeTest DB2UNIT_TAP

 db2 "CALL DB2UNIT.REPORT_RECENT_EXECUTIONS"

 if not "!PAUSE_INSTALL!" == "true" (
  set TIME_END=echo !time!
  echo Difference:
  echo !TIME_INI! start
  echo !TIME_END! end
 )
 Setlocal DisableDelayedExpansion
 set PAUSE_INSTALL=
)
goto:eof

:: Execute a given test.
:executeTest
 set schema=%~1
 echo ====Next: %schema%
 if "!PAUSE_INSTALL!" == "true" (
  pause
  call %DB2UNIT_SRC_TEST_SCRIPT_PATH%\test.bat %schema% i x
 ) else if "!PAUSE_INSTALL!" == "install_false" (
  call %DB2UNIT_SRC_TEST_SCRIPT_PATH%\test.bat %schema% i x
 ) else (
  call %DB2UNIT_SRC_TEST_SCRIPT_PATH%\test.bat %schema% x
 )
goto:eof

