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

SET CURRENT SCHEMA DB2UNIT_2_BETA @

/**
 * XML report to integrate with tools like Hudson. The XML format is the same
 * as jUnit.
 *
 * Version: 2014-12-29 V2_BETA
 * Author: Andres Gomez Casanova (AngocA)
 * Made in COLOMBIA.
 */

ALTER MODULE DB2UNIT ADD
  PROCEDURE XML_REPORT (
  )
  LANGUAGE SQL
  SPECIFIC P_XML_REPORT
  DYNAMIC RESULT SETS 1
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_XML_REPORT: BEGIN

  DECLARE EXEC_CURSOR CURSOR
    WITH RETURN TO CALLER FOR
    WITH

  -- All messages for each test case.
    ALL_MESSAGES (SUITE_NAME, EXECUTION_ID, TEST_NAME, ALL_MESSAGES) AS
    (SELECT
      SUITE_NAME, EXECUTION_ID, TEST_NAME,
      LISTAGG(MESSAGE, '\n') WITHIN GROUP (ORDER BY DATE)
     FROM DB2UNIT_EXAMPLE.REPORT_TESTS
     GROUP BY SUITE_NAME, EXECUTION_ID, TEST_NAME
    ),

    -- Error messages and type of error.
    ERRORS (SUITE_NAME, EXECUTION_ID, TEST_NAME, ERROR_MESSAGE, ERROR_TYPE) AS
    (SELECT
      SUITE_NAME, EXECUTION_ID, TEST_NAME,
      SUBSTR(MESSAGE, 44),
      SUBSTR(MESSAGE, 15, 28)
     FROM DB2UNIT_EXAMPLE.REPORT_TESTS
     WHERE FINAL_STATE IS NULL
     AND TEST_NAME IN (
      SELECT
       TEST_NAME
      FROM DB2UNIT_EXAMPLE.REPORT_TESTS
      WHERE FINAL_STATE = 'Error'
     )
     AND MESSAGE IS NOT NULL AND MESSAGE <> ''
    ),

    -- Date and name of the failed tests.
    FAIL_INFO (SUITE_NAME, EXECUTION_ID, TEST_NAME, DATE) AS
    (SELECT
      SUITE_NAME, EXECUTION_ID, TEST_NAME, DATE
     FROM DB2UNIT_EXAMPLE.REPORT_TESTS
     WHERE FINAL_STATE = 'Failed'
    ),

    -- Ordered messages from failed tests.
    FAIL_ROWS (SUITE_NAME, EXECUTION_ID, TEST_NAME, MESSAGE, RANK) AS
    (SELECT
      R.SUITE_NAME, R.EXECUTION_ID, R.TEST_NAME, MESSAGE,
      ROW_NUMBER() OVER(PARTITION BY R.TEST_NAME)
     FROM DB2UNIT_EXAMPLE.REPORT_TESTS R JOIN FAIL_INFO I
     ON (R.SUITE_NAME = I.SUITE_NAME AND R.EXECUTION_ID = I.EXECUTION_ID
      AND R.TEST_NAME = I.TEST_NAME)
     WHERE FINAL_STATE IS NULL
     AND MESSAGE IS NOT NULL AND MESSAGE <> ''
    ),

    -- Type of failed tests.
    FAIL_TYPE (SUITE_NAME, EXECUTION_ID, TEST_NAME, FAIL_TYPE) AS
    (SELECT
      SUITE_NAME, EXECUTION_ID, TEST_NAME, MESSAGE
     FROM FAIL_ROWS
     WHERE RANK = 1
    ),

    -- Messages of failed tests.
    FAIL_MESSAGE (SUITE_NAME, EXECUTION_ID, TEST_NAME, FAIL_MESSAGE) AS
    (SELECT
      SUITE_NAME, EXECUTION_ID, TEST_NAME,
      LISTAGG(MESSAGE, '\n')
     FROM FAIL_ROWS
     WHERE RANK <> 1
     GROUP BY SUITE_NAME, EXECUTION_ID, TEST_NAME
    ),

    -- Complete description of test cases.
    TESTCASE (SUITE_NAME, EXECUTION_ID, TEST_NAME, XML) AS
    (SELECT
      SUITE_NAME, EXECUTION_ID, TEST_NAME,
      XMLELEMENT(NAME "testcase",
       XMLATTRIBUTES(
        TEST_NAME AS "name",
        '0' AS "assertions", -- TODO
        SUITE_NAME || '.' || TEST_NAME AS "classname",
        DURATION/1000 AS "time" -- Milliseconds
       ),
       CASE
        WHEN FINAL_STATE = 'Unstarted'
         THEN XMLELEMENT(NAME "skipped")
        WHEN FINAL_STATE = 'Error'
         THEN XMLELEMENT(
          NAME "error",
          XMLATTRIBUTES(
           (
            SELECT
             MIN(ERROR_MESSAGE)
            FROM ERRORS E JOIN DB2UNIT_2_BETA.RESULT_TESTS R
            ON (E.SUITE_NAME = R.SUITE_NAME AND E.EXECUTION_ID = R.EXECUTION_ID
            AND E.TEST_NAME = R.TEST_NAME)
           ) AS "message",
           (
            SELECT
             MIN(ERROR_TYPE)
            FROM ERRORS E JOIN DB2UNIT_2_BETA.RESULT_TESTS R
            ON (E.SUITE_NAME = R.SUITE_NAME AND E.EXECUTION_ID = R.EXECUTION_ID
            AND E.TEST_NAME = R.TEST_NAME)
           ) AS "type"
          )
         )
        WHEN FINAL_STATE = 'Failed'
         THEN XMLELEMENT(
          NAME "failure",
          XMLATTRIBUTES(
           (
            SELECT
             MIN(FAIL_MESSAGE)
            FROM FAIL_MESSAGE F JOIN DB2UNIT_2_BETA.RESULT_TESTS R
            ON (F.SUITE_NAME = R.SUITE_NAME AND F.EXECUTION_ID = R.EXECUTION_ID
            AND F.TEST_NAME = R.TEST_NAME)
           ) AS "message",
           (
            SELECT
             MIN(FAIL_TYPE)
            FROM FAIL_TYPE F JOIN DB2UNIT_2_BETA.RESULT_TESTS R
            ON (F.SUITE_NAME = R.SUITE_NAME AND F.EXECUTION_ID = R.EXECUTION_ID
            AND F.TEST_NAME = R.TEST_NAME)
           ) AS "type"
          )
         )
       END,
       (
        SELECT
         XMLELEMENT(NAME "system-out",
          XMLAGG(
            XMLTEXT(MESSAGE || '\n')
          )
         )
        FROM DB2UNIT_EXAMPLE.REPORT_TESTS R2
        WHERE R2.SUITE_NAME = R.SUITE_NAME
        AND R2.EXECUTION_ID = R.EXECUTION_ID
        AND R2.TEST_NAME = R.TEST_NAME
       )
      ) XML
     -- The schema changes for each test suite. -- TODO ???
     FROM DB2UNIT_2_BETA.RESULT_TESTS R
    ),

    -- Execution properties.
    PROPERTIES(SUITE_NAME, PROPERTIES) AS
    (SELECT
      SUITE_NAME,
      PROPERTIES -- TODO the XML schema for properties has not been defined.
     FROM DB2UNIT_2_BETA.SUITES
    ),

    -- Most recent execution date of each test suite.
    RECENT_DATE_EXEC(SUITE_NAME, DATE) AS
    (SELECT
      SUITE_NAME, MAX(DATE)
     FROM DB2UNIT_2_BETA.SUITES_EXECUTIONS SE JOIN DB2UNIT_2_BETA.EXECUTIONS E
     ON (E.EXECUTION_ID = SE.EXECUTION_ID)
     GROUP BY SE.SUITE_NAME
    ),

    -- Complete information of the most recent exeuction of each test suite.
    RECENT_EXEC (SUITE_NAME, EXECUTION_ID, DATE, TOTAL_TESTS, PASSED_TESTS,
      FAILED_TESTS, ERROR_TESTS, UNEXEC_TESTS, DURATION) AS
    (SELECT
      SE.SUITE_NAME, SE.EXECUTION_ID, R.DATE, TOTAL_TESTS, PASSED_TESTS,
      FAILED_TESTS, ERROR_TESTS, UNEXEC_TESTS, DURATION
     FROM DB2UNIT_2_BETA.SUITES_EXECUTIONS SE JOIN DB2UNIT_2_BETA.EXECUTIONS E
     ON (E.EXECUTION_ID = SE.EXECUTION_ID) JOIN RECENT_DATE_EXEC R
     ON (R.SUITE_NAME = SE.SUITE_NAME AND R.DATE = E.DATE)
    ),

    ---- Test suite
    TEST_SUITES (SUITE_NAME, MESSAGE) AS
    (SELECT
      SUITE_NAME,
      XMLELEMENT(
       NAME "testsuite",
       XMLATTRIBUTES(
        SUITE_NAME AS "name",
        TOTAL_TESTS AS "tests",
        UNEXEC_TESTS AS "disabled",
        ERROR_TESTS  AS "errors",
        FAILED_TESTS AS "failures",
        'localhost' AS "hostname", -- TODO get hostname
        '0' AS "id", -- TODO consecutive ID
        DURATION AS "time",
        DATE AS "timestamp"),
       XMLELEMENT(
        NAME "properties"
        ,
        (
         SELECT
          XMLQUERY('$PROPERTIES')
         FROM PROPERTIES P
         WHERE P.SUITE_NAME = R.SUITE_NAME
        )
        OPTION NULL ON NULL
       ),
       (
        SELECT
         XMLAGG(XMLQUERY('$XML'))
        FROM TESTCASE T 
        WHERE T.SUITE_NAME = R.SUITE_NAME
      )
      )
     FROM RECENT_EXEC R
     GROUP BY SUITE_NAME, TOTAL_TESTS, UNEXEC_TESTS, ERROR_TESTS, FAILED_TESTS,
      DURATION, DATE
    ),

    -- Summary of the execution.
    SUMMARY (TESTS, FAILURES, ERRORS, DISABLED) AS
    (SELECT
      SUM(TOTAL_TESTS) TESTS, SUM(FAILED_TESTS) FAILURES,
      SUM(ERROR_TESTS) ERRORS, SUM(UNEXEC_TESTS) DISABLED
     FROM RECENT_EXEC R
    )

    -- Complete XML document.
    SELECT
     XMLELEMENT(
      NAME "testsuites",
      XMLATTRIBUTES(
       (
        SELECT
         DISABLED
        FROM SUMMARY
       ) AS "disabled",
       (
        SELECT
         ERRORS
        FROM SUMMARY
       ) AS "errors",
       (
        SELECT
         FAILURES
        FROM SUMMARY
       ) AS "failures",
       'db' AS NAME, -- TODO get database name
       (
        SELECT
         TESTS
        FROM SUMMARY
       ) AS "tests",
       '0' AS TIME -- TODO sum time
      ),
      (
       SELECT
        XMLAGG(XMLQUERY('$MESSAGE'))
       FROM TEST_SUITES
      )
     )
    FROM SUMMARY;

  OPEN EXEC_CURSOR;
 END P_XML_REPORT @

