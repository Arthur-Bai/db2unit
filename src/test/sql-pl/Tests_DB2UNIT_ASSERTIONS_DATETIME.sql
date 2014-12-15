--#SET TERMINATOR @

/*
 This file is part of db2unit: A unit testing framework for DB2 LUW.
 Copyright (C)  2014  Andres Gomez Casanova (@AngocA)

 db2unit is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 db2unit is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.

 Andres Gomez Casanova <angocaATyahooDOTcom>
*/

SET CURRENT SCHEMA DB2UNIT_ASSERTIONS_DATETIME @

SET PATH = "SYSIBM","SYSFUN","SYSPROC","SYSIBMADM", DB2UNIT_2_BETA, DB2UNIT_ASSERTIONS_DATETIME @

/**
 * Tests for datetime assertions.
 *
 * Version: 2014-05-01 1
 * Author: Andres Gomez Casanova (AngocA)
 * Made in COLOMBIA.
 */

-- Previously create the table in order to compile these tests.
BEGIN
 DECLARE STATEMENT VARCHAR(128);
 DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END;
 SET STATEMENT = 'CREATE TABLE REPORT_TESTS LIKE DB2UNIT_2_BETA.REPORT_TESTS';
 EXECUTE IMMEDIATE STATEMENT;
END @

ALTER TABLE DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
  ALTER COLUMN SUITE_NAME
  SET WITH DEFAULT 'DB2UNIT_ASSERTIONS_DATETIME' @

-- DATETIME

-- Compares two identical timestamps sucessfully.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_01()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 TIMESTAMP;
  DECLARE TSTMP2 TIMESTAMP;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_01';

  SET TSTMP1 = '1981-03-03-14.25.03';
  SET TSTMP2 = '1981-03-03-14.25.03';
  CALL DB2UNIT.ASSERT_TIMESTAMP_EQUALS(TSTMP1, TSTMP2);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares two identical dates sucessfully.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_02()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 DATE;
  DECLARE TSTMP2 DATE;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_02';

  SET TSTMP1 = '1981-03-03';
  SET TSTMP2 = '1981-03-03';
  CALL DB2UNIT.ASSERT_DATE_EQUALS(TSTMP1, TSTMP2);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares two identical times successfully.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_03()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 TIME;
  DECLARE TSTMP2 TIME;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_03';

  SET TSTMP1 = '14.25.03';
  SET TSTMP2 = '14.25.03';
  CALL DB2UNIT.ASSERT_TIME_EQUALS(TSTMP1, TSTMP2);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares two different timestamps.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_04()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 TIMESTAMP;
  DECLARE TSTMP2 TIMESTAMP;

  SET EXPECTED_MSG = 'The value of both timestamps is different';

  SET TSTMP1 = '1981-03-03-14.25.03';
  SET TSTMP2 = '1981-03-03-13.25.03';
  CALL DB2UNIT.ASSERT_TIMESTAMP_EQUALS(TSTMP1, TSTMP2);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Actual  : "1981-03-03-13.25.03.000000"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);
  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Expected: "1981-03-03-14.25.03.000000"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'TIMESTAMP_EQUALS';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares two different dates.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_05()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 DATE;
  DECLARE TSTMP2 DATE;

  SET EXPECTED_MSG = 'The value of both dates is different';

  SET TSTMP1 = '1981-03-03';
  SET TSTMP2 = '2014-03-03';
  CALL DB2UNIT.ASSERT_DATE_EQUALS(TSTMP1, TSTMP2);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Actual  : "2014-03-03"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);
  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Expected: "1981-03-03"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'DATE_EQUALS';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares two times sucessfully.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_06()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 TIME;
  DECLARE TSTMP2 TIME;

  SET EXPECTED_MSG = 'The value of both times is different';

  SET TSTMP1 = '14.25.03';
  SET TSTMP2 = '14.25.04';
  CALL DB2UNIT.ASSERT_TIME_EQUALS(TSTMP1, TSTMP2);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Actual  : "14:25:04"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);
  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Expected: "14:25:03"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'TIME_EQUALS';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares timestamp with null.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_07()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 TIMESTAMP;
  DECLARE TSTMP2 TIMESTAMP;

  SET EXPECTED_MSG = 'Nullability difference';

  SET TSTMP1 = '1981-03-03-14.25.03';
  SET TSTMP2 = NULL;
  CALL DB2UNIT.ASSERT_TIMESTAMP_EQUALS(TSTMP1, TSTMP2);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Actual  : NULL'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);
  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Expected: "1981-03-03-14.25.03.000000"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'TIMESTAMP_EQUALS';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares date with null.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_08()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 DATE;
  DECLARE TSTMP2 DATE;

  SET EXPECTED_MSG = 'Nullability difference';

  SET TSTMP1 = '1981-03-03';
  SET TSTMP2 = NULL;
  CALL DB2UNIT.ASSERT_DATE_EQUALS(TSTMP1, TSTMP2);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Actual  : NULL'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);
  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Expected: "1981-03-03"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'DATE_EQUALS';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares time with null.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_09()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 TIME;
  DECLARE TSTMP2 TIME;

  SET EXPECTED_MSG = 'Nullability difference';

  SET TSTMP1 = '14.25.03';
  SET TSTMP2 = NULL;
  CALL DB2UNIT.ASSERT_TIME_EQUALS(TSTMP1, TSTMP2);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Actual  : NULL'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);
  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Expected: "14:25:03"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'TIME_EQUALS';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares timestamp with null.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_10()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 TIMESTAMP;
  DECLARE TSTMP2 TIMESTAMP;

  SET EXPECTED_MSG = 'Nullability difference';

  SET TSTMP1 = NULL;
  SET TSTMP2 = '1981-03-03-14.25.03';
  CALL DB2UNIT.ASSERT_TIMESTAMP_EQUALS(TSTMP1, TSTMP2);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Actual  : "1981-03-03-14.25.03.000000"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);
  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Expected: NULL'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'TIMESTAMP_EQUALS';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares date with null.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_11()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 DATE;
  DECLARE TSTMP2 DATE;

  SET EXPECTED_MSG = 'Nullability difference';

  SET TSTMP1 = NULL;
  SET TSTMP2 = '1981-03-03';
  CALL DB2UNIT.ASSERT_DATE_EQUALS(TSTMP1, TSTMP2);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Actual  : "1981-03-03"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);
  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Expected: NULL'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'DATE_EQUALS';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares time with null.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_12()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 TIME;
  DECLARE TSTMP2 TIME;

  SET EXPECTED_MSG = 'Nullability difference';

  SET TSTMP1 = NULL;
  SET TSTMP2 = '14.25.03';
  CALL DB2UNIT.ASSERT_TIME_EQUALS(TSTMP1, TSTMP2);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Actual  : "14:25:03"'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);
  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = 'Expected: NULL'
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'TIME_EQUALS';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares two null timestamps.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_13()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 TIMESTAMP;
  DECLARE TSTMP2 TIMESTAMP;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_13';

  SET TSTMP1 = NULL;
  SET TSTMP2 = NULL;
  CALL DB2UNIT.ASSERT_TIMESTAMP_EQUALS(TSTMP1, TSTMP2);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares two null dates.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_14()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 DATE;
  DECLARE TSTMP2 DATE;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_14';

  SET TSTMP1 = NULL;
  SET TSTMP2 = NULL;
  CALL DB2UNIT.ASSERT_DATE_EQUALS(TSTMP1, TSTMP2);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Compares two null times.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_15()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP1 TIME;
  DECLARE TSTMP2 TIME;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_15';

  SET TSTMP1 = NULL;
  SET TSTMP2 = NULL;
  CALL DB2UNIT.ASSERT_TIME_EQUALS(TSTMP1, TSTMP2);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Test a null timestamp.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_16()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP TIMESTAMP;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_16';

  SET TSTMP = NULL;
  CALL DB2UNIT.ASSERT_TIMESTAMP_NULL(TSTMP);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Tests a null date.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_17()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP DATE;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_17';

  SET TSTMP = NULL;
  CALL DB2UNIT.ASSERT_DATE_NULL(TSTMP);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Tests a null time.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_18()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP TIME;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_18';

  SET TSTMP = NULL;
  CALL DB2UNIT.ASSERT_TIME_NULL(TSTMP);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Test a not null timestamp.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_19()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP TIMESTAMP;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_19';

  SET TSTMP = '1981-03-03-14.25.03';
  CALL DB2UNIT.ASSERT_TIMESTAMP_NOT_NULL(TSTMP);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Tests a not null date.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_20()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP DATE;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_20';

  SET TSTMP = '1981-03-03';
  CALL DB2UNIT.ASSERT_DATE_NOT_NULL(TSTMP);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Tests a not null time.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_21()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP TIME;

  SET EXPECTED_MSG = 'Executing TEST_DATETIME_21';

  SET TSTMP = '14.25.03';
  CALL DB2UNIT.ASSERT_TIME_NOT_NULL(TSTMP);

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Test a null timestamp.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_22()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP TIMESTAMP;

  SET EXPECTED_MSG = 'The given value is "NOT NULL"';

  SET TSTMP = '1981-03-03-14.25.03';
  CALL DB2UNIT.ASSERT_TIMESTAMP_NULL(TSTMP);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'TIMESTAMP_NULL';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Tests a null date.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_23()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP DATE;

  SET EXPECTED_MSG = 'The given value is "NOT NULL"';

  SET TSTMP = '1981-03-03';
  CALL DB2UNIT.ASSERT_DATE_NULL(TSTMP);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'DATE_NULL';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Tests a null time.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_24()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP TIME;

  SET EXPECTED_MSG = 'The given value is "NOT NULL"';

  SET TSTMP = '14.25.03';
  CALL DB2UNIT.ASSERT_TIME_NULL(TSTMP);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'TIME_NULL';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Test a not null timestamp.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_25()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP TIMESTAMP;

  SET EXPECTED_MSG = 'The given value is "NULL"';

  SET TSTMP = NULL;
  CALL DB2UNIT.ASSERT_TIMESTAMP_NOT_NULL(TSTMP);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'TIMESTAMP_NOT_NULL';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Tests a not null date.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_26()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP DATE;

  SET EXPECTED_MSG = 'The given value is "NULL"';

  SET TSTMP = NULL;
  CALL DB2UNIT.ASSERT_DATE_NOT_NULL(TSTMP);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'DATE_NOT_NULL';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Tests a not null time.
CREATE OR REPLACE PROCEDURE TEST_DATETIME_27()
 BEGIN
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE TSTMP TIME;

  SET EXPECTED_MSG = 'The given value is "NULL"';

  SET TSTMP = NULL;
  CALL DB2UNIT.ASSERT_TIME_NOT_NULL(TSTMP);
  CALL DB2UNIT.BACK_TO_EXECUTING();

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'TIME_NOT_NULL';

  SELECT MESSAGE INTO ACTUAL_MSG
    FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE DATE = (SELECT MAX(DATE)
      FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  DELETE FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS
    WHERE MESSAGE = EXPECTED_MSG
    AND DATE = (SELECT MAX(DATE) FROM DB2UNIT_ASSERTIONS_DATETIME.REPORT_TESTS);

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);
 END @

-- Register the suite.
CALL DB2UNIT.REGISTER_SUITE(CURRENT SCHEMA) @

