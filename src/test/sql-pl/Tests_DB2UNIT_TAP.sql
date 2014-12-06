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

SET CURRENT SCHEMA DB2UNIT_TAP @

SET PATH = "SYSIBM","SYSFUN","SYSPROC","SYSIBMADM", DB2UNIT_2_BETA, DB2UNIT_TAP @

/**
 * Tests for the TAP report.
 *
 * Version: 2014-12-06 V2_BETA
 * Author: Andres Gomez Casanova (AngocA)
 * Made in COLOMBIA.
 */

BEGIN
 DECLARE STATEMENT VARCHAR(128);
 DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END;
 SET STATEMENT = 'CREATE SCHEMA DB2UNIT_TAP';
 EXECUTE IMMEDIATE STATEMENT;
END @

-- Creates the given schema.
CREATE OR REPLACE PROCEDURE CREATE_SCHEMA_TABLE(
  IN SCH_NAME ANCHOR SYSCAT.SCHEMATA.SCHEMANAME
  )
 BEGIN
  DECLARE SENTENCE ANCHOR DB2UNIT_2_BETA.MAX_VALUES.SENTENCE;
  DECLARE STMT STATEMENT;

  SET SENTENCE = 'CREATE SCHEMA ' || SCH_NAME ;
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
 END @

-- Drops the given schema and its table.
CREATE OR REPLACE PROCEDURE DROP_SCHEMA_TABLE(
  IN SCH_NAME ANCHOR SYSCAT.SCHEMATA.SCHEMANAME
  )
 BEGIN
  DECLARE SENTENCE ANCHOR DB2UNIT_2_BETA.MAX_VALUES.SENTENCE;
  DECLARE INEXISTANT_TABLE CONDITION FOR SQLSTATE '42704';
  DECLARE STMT STATEMENT;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '42893' SET SENTENCE = '';
  DECLARE CONTINUE HANDLER FOR SQLSTATE '42884' SET SENTENCE = '';
  DECLARE CONTINUE HANDLER FOR INEXISTANT_TABLE SET SENTENCE = '';

  SET SENTENCE = 'DROP TABLE ' || SCH_NAME || '.REPORT_TESTS';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  SET SENTENCE = 'DROP SCHEMA ' || SCH_NAME || ' RESTRICT';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
 END @

CALL SYSPROC.ADMIN_DROP_SCHEMA('DB2UNIT_TAP_TEST_2', NULL, 
  'ERRORSCHEMA', 'ERRORTABLE_2') @

-- Test fixtures
-- Drops all tables and schemas.
CREATE OR REPLACE PROCEDURE ONE_TIME_TEAR_DOWN()
 BEGIN
  DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END;
  CALL DROP_SCHEMA_TABLE('DB2UNIT_TAP_TEST_2');
 END @

-- Creates the necessary schemas.
CREATE OR REPLACE PROCEDURE ONE_TIME_SETUP()
 BEGIN
  DECLARE CONTINUE HANDLER FOR SQLSTATE '42710' BEGIN END;
  -- If a previous execution did not correctly finished.
  CALL ONE_TIME_TEAR_DOWN();

  CALL CREATE_SCHEMA_TABLE('DB2UNIT_TAP_TEST_2');
 END @

CREATE OR REPLACE PROCEDURE SETUP()
 P_SETUP: BEGIN
--  CALL DB2UNIT.CLEAN();
 END P_SETUP @

CREATE OR REPLACE PROCEDURE TEAR_DOWN()
 P_TEAR_DOWN: BEGIN
  -- Your code
 END P_TEAR_DOWN @

-- Tests that there is not a report when no run_suite before.
CREATE OR REPLACE PROCEDURE TEST_NO_TEST()
 BEGIN
  DECLARE EXPECTED VARCHAR(1000);
  DECLARE ACTUAL VARCHAR(1000);
  DECLARE EXPECTED_MSG_TEXT VARCHAR(32672);
  DECLARE ACTUAL_MSG_TEXT VARCHAR(32672);
  DECLARE NO_PREV_EXEC CONDITION FOR SQLSTATE 'DBUN1';

  SET EXPECTED = 'Impossible to retrieve the last execution.';
  SET EXPECTED_MSG_TEXT = 'SQL0438N  Application raised error or warning '
    || 'with diagnostic text: "Impossible to retrieve the last execution.".  '
    || 'SQLSTATE=DBUN1   ';
  CALL DB2UNIT.CLEAN_LAST_EXEC();
  BEGIN
   DECLARE CONTINUE HANDLER FOR NO_PREV_EXEC
     BEGIN
      GET DIAGNOSTICS EXCEPTION 1 ACTUAL = DB2_TOKEN_STRING;
      GET DIAGNOSTICS EXCEPTION 1 ACTUAL_MSG_TEXT = MESSAGE_TEXT;
     END;
   CALL DB2UNIT.CREATE_TAP_REPORT();
  END;

  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED, ACTUAL);
  CALL DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG_TEXT, ACTUAL_MSG_TEXT);
 END @

-- Tests report when ok.
CREATE OR REPLACE PROCEDURE TEST_ONE_PASSED()
 BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE EXPECTED SMALLINT;
  DECLARE ACTUAL SMALLINT;
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE SCHEMA_NAME ANCHOR SYSCAT.SCHEMATA.SCHEMANAME;
  DECLARE TEST_NAME ANCHOR SYSCAT.PROCEDURES.PROCNAME;
  DECLARE SENTENCE ANCHOR DB2UNIT_2_BETA.MAX_VALUES.SENTENCE;
  DECLARE STMT STATEMENT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_TAP.TEST_ONE_PASSED.DB2UNIT_TAP_TEST_2',
    LOGGER_ID);

  SET SCHEMA_NAME = 'DB2UNIT_TAP_TEST_2';
  SET TEST_NAME = 'TEST_2';

  SET SENTENCE = 'CREATE OR REPLACE PROCEDURE ' || SCHEMA_NAME || '.'
    || TEST_NAME || '() '
    || 'BEGIN '
    || 'END ';
  CALL LOGGER.ERROR(LOGGER_ID, SENTENCE);
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  CALL DB2UNIT_2_BETA.DB2UNIT.RUN_SUITE(SCHEMA_NAME);

  CALL DB2UNIT.CREATE_TAP_REPORT();

  SET EXPECTED = 3;
  SET ACTUAL = (SELECT COUNT(1) FROM DB2UNIT_2_BETA.TAP_REPORT);
  CALL DB2UNIT.ASSERT_INT_EQUALS(EXPECTED, ACTUAL);

  SET EXPECTED_MSG = 'TAP version 13';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 1);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = '1..1';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 2);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'ok 1 ' || TEST_NAME;
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 3 FETCH FIRST 1 ROW ONLY);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET SENTENCE = 'DROP PROCEDURE ' || SCHEMA_NAME || '.' || TEST_NAME || '()';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  SET SENTENCE = 'DROP TABLE ' || SCHEMA_NAME || '.REPORT_TESTS';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  DELETE FROM DB2UNIT_2_BETA.SUITES
    WHERE SUITE_NAME = SCHEMA_NAME;
 END @

-- Tests the report when one fails.
CREATE OR REPLACE PROCEDURE TEST_ONE_FAILED()
 BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE EXPECTED SMALLINT;
  DECLARE ACTUAL SMALLINT;
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE SCHEMA_NAME ANCHOR SYSCAT.SCHEMATA.SCHEMANAME;
  DECLARE TEST_NAME ANCHOR SYSCAT.PROCEDURES.PROCNAME;
  DECLARE SENTENCE ANCHOR DB2UNIT_2_BETA.MAX_VALUES.SENTENCE;
  DECLARE STMT STATEMENT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_TAP.TEST_ONE_PASSED.DB2UNIT_TAP_TEST_3',
    LOGGER_ID);

  SET SCHEMA_NAME = 'DB2UNIT_TAP_TEST_3';
  SET TEST_NAME = 'TEST_3';

  SET SENTENCE = 'CREATE OR REPLACE PROCEDURE ' || SCHEMA_NAME || '.'
    || TEST_NAME || '() '
    || 'BEGIN '
    || ' CALL DB2UNIT.FAIL(); '
    || 'END ';
  CALL LOGGER.ERROR(LOGGER_ID, SENTENCE);
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  CALL DB2UNIT_2_BETA.DB2UNIT.RUN_SUITE(SCHEMA_NAME);

  CALL DB2UNIT.CREATE_TAP_REPORT();

  SET EXPECTED = 7;
  SET ACTUAL = (SELECT COUNT(1) FROM DB2UNIT_2_BETA.TAP_REPORT);
  CALL DB2UNIT.ASSERT_INT_EQUALS(EXPECTED, ACTUAL);

  SET EXPECTED_MSG = 'TAP version 13';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 1);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = '1..1';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 2);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'not ok 1 ' || TEST_NAME;
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 3 FETCH FIRST 1 ROW ONLY);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET SENTENCE = 'DROP PROCEDURE ' || SCHEMA_NAME || '.' || TEST_NAME || '()';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  SET SENTENCE = 'DROP TABLE ' || SCHEMA_NAME || '.REPORT_TESTS';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  DELETE FROM DB2UNIT_2_BETA.SUITES
    WHERE SUITE_NAME = SCHEMA_NAME;
 END @

-- Tests the report when hit error.
CREATE OR REPLACE PROCEDURE TEST_ONE_ERROR()
 BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE EXPECTED SMALLINT;
  DECLARE ACTUAL SMALLINT;
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE SCHEMA_NAME ANCHOR SYSCAT.SCHEMATA.SCHEMANAME;
  DECLARE TEST_NAME ANCHOR SYSCAT.PROCEDURES.PROCNAME;
  DECLARE SENTENCE ANCHOR DB2UNIT_2_BETA.MAX_VALUES.SENTENCE;
  DECLARE STMT STATEMENT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_TAP.TEST_ONE_PASSED.DB2UNIT_TAP_TEST_4',
    LOGGER_ID);

  SET SCHEMA_NAME = 'DB2UNIT_TAP_TEST_4';
  SET TEST_NAME = 'TEST_4';

  SET SENTENCE = 'CREATE OR REPLACE PROCEDURE ' || SCHEMA_NAME || '.'
    || TEST_NAME || '() '
    || 'BEGIN '
    || ' SIGNAL SQLSTATE VALUE ''TEST4''; '
    || 'END ';
  CALL LOGGER.ERROR(LOGGER_ID, SENTENCE);
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  CALL DB2UNIT_2_BETA.DB2UNIT.RUN_SUITE(SCHEMA_NAME);

  CALL DB2UNIT.CREATE_TAP_REPORT();

  SET EXPECTED = 6;
  SET ACTUAL = (SELECT COUNT(1) FROM DB2UNIT_2_BETA.TAP_REPORT);
  CALL DB2UNIT.ASSERT_INT_EQUALS(EXPECTED, ACTUAL);

  SET EXPECTED_MSG = 'TAP version 13';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 1);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = '1..1';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 2);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'not ok 1 ' || TEST_NAME;
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 3 FETCH FIRST 1 ROW ONLY);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET SENTENCE = 'DROP PROCEDURE ' || SCHEMA_NAME || '.' || TEST_NAME || '()';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  SET SENTENCE = 'DROP TABLE ' || SCHEMA_NAME || '.REPORT_TESTS';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  DELETE FROM DB2UNIT_2_BETA.SUITES
    WHERE SUITE_NAME = SCHEMA_NAME;
 END @

-- Tests the report when all happens.
CREATE OR REPLACE PROCEDURE TEST_ALL_TYPES()
 BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE EXPECTED SMALLINT;
  DECLARE ACTUAL SMALLINT;
  DECLARE RANDOM BOOLEAN;
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE SCHEMA_NAME ANCHOR SYSCAT.SCHEMATA.SCHEMANAME;
  DECLARE TEST_NAME ANCHOR SYSCAT.PROCEDURES.PROCNAME;
  DECLARE SENTENCE ANCHOR DB2UNIT_2_BETA.MAX_VALUES.SENTENCE;
  DECLARE STMT STATEMENT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_TAP.TEST_ONE_PASSED.DB2UNIT_TAP_TEST_5',
    LOGGER_ID);

  SET SCHEMA_NAME = 'DB2UNIT_TAP_TEST_5';

  SET SENTENCE = 'CREATE OR REPLACE PROCEDURE ' || SCHEMA_NAME || '.TEST_51() '
    || 'BEGIN '
    || 'END ';
  CALL LOGGER.ERROR(LOGGER_ID, SENTENCE);
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;

  SET SENTENCE = 'CREATE OR REPLACE PROCEDURE ' || SCHEMA_NAME || '.TEST_52() '
    || 'BEGIN '
    || ' CALL DB2UNIT.FAIL(); '
    || 'END ';
  CALL LOGGER.ERROR(LOGGER_ID, SENTENCE);
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;

  SET SENTENCE = 'CREATE OR REPLACE PROCEDURE ' || SCHEMA_NAME || '.TEST_53() '
    || 'BEGIN '
    || ' SIGNAL SQLSTATE VALUE ''TEST5''; '
    || 'END ';
  CALL LOGGER.ERROR(LOGGER_ID, SENTENCE);
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  SET RANDOM = DB2UNIT.GET_RANDOM_SORT();
  CALL DB2UNIT.RANDOM_SORT(FALSE);
  CALL DB2UNIT_2_BETA.DB2UNIT.RUN_SUITE(SCHEMA_NAME);
  CALL DB2UNIT.RANDOM_SORT(RANDOM);

  CALL DB2UNIT.CREATE_TAP_REPORT();

  SET EXPECTED = 12;
  SET ACTUAL = (SELECT COUNT(1) FROM DB2UNIT_2_BETA.TAP_REPORT);
  CALL DB2UNIT.ASSERT_INT_EQUALS(EXPECTED, ACTUAL);

  SET EXPECTED_MSG = 'TAP version 13';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 1);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = '1..3';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 2);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'ok 1 TEST_51';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 3 FETCH FIRST 1 ROW ONLY);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'not ok 2 TEST_52';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 4 FETCH FIRST 1 ROW ONLY);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = 'not ok 3 TEST_53';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 9 FETCH FIRST 1 ROW ONLY);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET SENTENCE = 'DROP PROCEDURE ' || SCHEMA_NAME || '.TEST_51()';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  SET SENTENCE = 'DROP PROCEDURE ' || SCHEMA_NAME || '.TEST_52()';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  SET SENTENCE = 'DROP PROCEDURE ' || SCHEMA_NAME || '.TEST_53()';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  SET SENTENCE = 'DROP TABLE ' || SCHEMA_NAME || '.REPORT_TESTS';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  DELETE FROM DB2UNIT_2_BETA.SUITES
    WHERE SUITE_NAME = SCHEMA_NAME;
 END @

-- Tests empty test suite.
CREATE OR REPLACE PROCEDURE TEST_EMPTY()
 BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE EXPECTED SMALLINT;
  DECLARE ACTUAL SMALLINT;
  DECLARE ACTUAL_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE EXPECTED_MSG ANCHOR DB2UNIT_2_BETA.REPORT_TESTS.MESSAGE;
  DECLARE SCHEMA_NAME ANCHOR SYSCAT.SCHEMATA.SCHEMANAME;
  DECLARE TEST_NAME ANCHOR SYSCAT.PROCEDURES.PROCNAME;
  DECLARE SENTENCE ANCHOR DB2UNIT_2_BETA.MAX_VALUES.SENTENCE;
  DECLARE STMT STATEMENT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_TAP.TEST_ONE_PASSED.DB2UNIT_TAP_TEST_6',
    LOGGER_ID);

  SET SCHEMA_NAME = 'DB2UNIT_TAP_TEST_6';
  CALL CREATE_SCHEMA_TABLE(SCHEMA_NAME);
  CALL DB2UNIT_2_BETA.DB2UNIT.RUN_SUITE(SCHEMA_NAME);

  CALL DB2UNIT.CREATE_TAP_REPORT();

  SET EXPECTED = 2;
  SET ACTUAL = (SELECT COUNT(1) FROM DB2UNIT_2_BETA.TAP_REPORT);
  CALL DB2UNIT.ASSERT_INT_EQUALS(EXPECTED, ACTUAL);

  SET EXPECTED_MSG = 'TAP version 13';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 1);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET EXPECTED_MSG = '1..0';
  SET ACTUAL_MSG = (SELECT MESSAGE FROM DB2UNIT_2_BETA.TAP_REPORT
    WHERE NUMBER = 2);
  CALL DB2UNIT_2_BETA.DB2UNIT.ASSERT_STRING_EQUALS(EXPECTED_MSG, ACTUAL_MSG);

  SET SENTENCE = 'DROP TABLE ' || SCHEMA_NAME || '.REPORT_TESTS';
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT;
  DELETE FROM DB2UNIT_2_BETA.SUITES
    WHERE SUITE_NAME = SCHEMA_NAME;
 END @

-- Register the suite.
CALL DB2UNIT.REGISTER_SUITE(CURRENT SCHEMA) @

