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

SET CURRENT SCHEMA DB2UNIT_1A @

/**
 * Asserts implementation.
 * Return codes:
 * 0 - OK.
 * 1 - Nullability difference.
 * 2 - Different values.
 * 3 - Different length.
 * 4 - Invalid value.
 * 5 - Opposite nullability.
 * 6 - Fail.
 * 7 - Not empty table.
 * 8 - Empty table.
 * 9 - Object does not exist.
 * 10 - Different quantity of columns.
 * 11 - Different values in column.
 * 12 - Different quantity of values in column.
 * 13 - The quantity of different items is not the same in column.
 * 14 - Some of the entry values are null.
 *
 * Version: 2014-05-02 1-Alpha
 * Author: Andres Gomez Casanova (AngocA)
 * Made in COLOMBIA.
 */

/**
 * Max size for assertion messages.
 */
ALTER MODULE DB2UNIT ADD
  VARIABLE MESSAGE_OVERHEAD SMALLINT CONSTANT 50 @

/**
 * Size of the chunk of a truncated string.
 */
ALTER MODULE DB2UNIT ADD
  VARIABLE MESSAGE_CHUNK SMALLINT CONSTANT 100 @

/**
 * Processes the given message.
 */
ALTER MODULE DB2UNIT ADD
  FUNCTION PROC_MESSAGE(
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT
  ) RETURNS ANCHOR MAX_VALUES.MESSAGE_ASSERT
  LANGUAGE SQL
  SPECIFIC F_PROC_MESSAGE
  DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 F_PROC_MESSAGE: BEGIN
  IF (MESSAGE = '') THEN
   SET MESSAGE = NULL;
  END IF;
  SET MESSAGE = COALESCE(MESSAGE || '. ', '');
  RETURN MESSAGE;
 END F_PROC_MESSAGE @

/**
 * Returns a character representation of the given boolean.
 *
 * IN VALUE
 *   Value to convert.
 * RETURN
 *   The corresponding represtation of the given boolean.
 */
ALTER MODULE DB2UNIT ADD
  FUNCTION BOOL_TO_CHAR(
  IN VALUE BOOLEAN
  ) RETURNS CHAR(5)
  LANGUAGE SQL
  SPECIFIC F_BOOL_TO_CHAR
  DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 F_BOOL_TO_CHAR: BEGIN
  DECLARE RET CHAR(5) DEFAULT 'FALSE';

  IF (VALUE IS NULL) THEN
    SET RET = 'NULL';
  ELSEIF (VALUE = TRUE) THEN
   SET RET = 'TRUE';
  END IF;
  RETURN RET;
 END F_BOOL_TO_CHAR @

-- GENERAL

/**
 * Fails the current message giving a reason in the message.
 *
 * IN MESSAGE
 *   Related message to the fail.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE FAIL (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT
  )
  LANGUAGE SQL
  SPECIFIC P_FAIL_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_FAIL_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_FAIL_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);

  CALL WRITE_IN_REPORT (MESSAGE || 'Test failed');
  SET TEST_RESULT = RESULT_FAILED;
  SET RET = 6;

  RETURN RET;
 END P_FAIL_MESSAGE @

-- STRING

/**
 * Asserts if the given two strings are the same, in nullability, in length and
 * in content.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN EXPECTED
 *   Expected boolean.
 * IN ACTUAL
 *   Actual boolean.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_STRING_EQUALS (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN EXPECTED ANCHOR MAX_STRING.STRING,
  IN ACTUAL ANCHOR MAX_STRING.STRING
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_STRING_EQUALS_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_STRING_EQUALS_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE SHOW BOOLEAN DEFAULT FALSE;
  DECLARE LENGTH SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_STRING_EQUALS_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, EXPECTED);
  CALL LOGGER.DEBUG(LOGGER_ID, ACTUAL);

  -- Check values.
  IF ((EXPECTED IS NULL AND ACTUAL IS NOT NULL)
    OR (EXPECTED IS NOT NULL AND ACTUAL IS NULL)) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'Nullability difference');
   SET SHOW = TRUE;
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 1;
  ELSEIF (LENGTH(EXPECTED) <> LENGTH(ACTUAL)) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'Strings have different lengths');
   SET SHOW = TRUE;
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 3;
  ELSEIF (EXPECTED <> ACTUAL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The content of both strings is different');
   SET SHOW = TRUE;
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 2;
  END IF;

  -- Show problems.
  IF (SHOW = TRUE) THEN
   IF (EXPECTED IS NOT NULL) THEN
    SET LENGTH = LENGTH(EXPECTED);
    IF (LENGTH < MAX_MESSAGE - MESSAGE_OVERHEAD) THEN
     CALL WRITE_IN_REPORT (SUBSTR('Expected      : "' || EXPECTED || '"', 1,
       512));
    ELSE
     SET EXPECTED = SUBSTR(EXPECTED, 1, MESSAGE_CHUNK) || '"..."'
       || SUBSTR(EXPECTED, LENGTH - MESSAGE_CHUNK);
     CALL WRITE_IN_REPORT (SUBSTR('Expd truncated: "' || EXPECTED || '"', 1,
       512));
    END IF;
   ELSE
    CALL WRITE_IN_REPORT ('Expected      : NULL');
   END IF;
   IF (ACTUAL IS NOT NULL) THEN
    SET LENGTH = LENGTH(ACTUAL);
    IF (LENGTH < MAX_MESSAGE - MESSAGE_OVERHEAD) THEN
     CALL WRITE_IN_REPORT (SUBSTR('Actual        : "' || ACTUAL || '"', 1,
       512));
    ELSE
     SET ACTUAL = SUBSTR(ACTUAL, 1, MESSAGE_CHUNK) || '"..."'
       || SUBSTR(ACTUAL, LENGTH - MESSAGE_CHUNK);
     CALL WRITE_IN_REPORT (SUBSTR('Actl truncated: "' || ACTUAL || '"', 1,
       512));
    END IF;
   ELSE
    CALL WRITE_IN_REPORT ('Actual        : NULL');
   END IF;
  END IF;

  RETURN RET;
 END P_ASSERT_STRING_EQUALS_MESSAGE @

/**
 * Asserts if the given string is null.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN STRING
 *   Value to check if it is null.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_STRING_NULL (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN STRING ANCHOR MAX_STRING.STRING
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_STRING_NULL_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_STRING_NULL_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_STRING_NULL_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, STRING);

  -- Check value.
  IF (STRING IS NOT NULL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The given string is "NOT NULL"');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 5;
  END IF;

  RETURN RET;
 END P_ASSERT_STRING_NULL_MESSAGE @

/**
 * Asserts if the given string is not null.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN STRING
 *   Value to check if it is not null.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_STRING_NOT_NULL (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN STRING ANCHOR MAX_STRING.STRING
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_STRING_NOT_NULL_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_STRING_NOT_NULL_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_STRING_NOT_NULL_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, STRING);

  -- Check value.
  IF (STRING IS NULL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The given string is "NULL"');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 5;
  END IF;

  RETURN RET;
 END P_ASSERT_STRING_NOT_NULL_MESSAGE @

-- BOOLEAN

/**
 * Asserts if the given two booleans are the same, in nullability and in
 * content.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN EXPECTED
 *   Expected boolean.
 * IN ACTUAL
 *   Actual boolean.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_BOOLEAN_EQUALS (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN EXPECTED BOOLEAN,
  IN ACTUAL BOOLEAN
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_BOOLEAN_EQUALS_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_BOOLEAN_EQUALS_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE SHOW BOOLEAN DEFAULT FALSE;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_BOOLEAN_EQUALS_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, BOOL_TO_CHAR(EXPECTED));
  CALL LOGGER.DEBUG(LOGGER_ID, BOOL_TO_CHAR(ACTUAL));

  -- Check values.
  IF ((EXPECTED IS NULL AND ACTUAL IS NOT NULL)
    OR (EXPECTED IS NOT NULL AND ACTUAL IS NULL)) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'Nullability difference');
   SET SHOW = TRUE;
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 1;
  ELSEIF (EXPECTED <> ACTUAL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The value of both booleans is different');
   SET SHOW = TRUE;
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 2;
  END IF;

  -- Show problems.
  IF (SHOW = TRUE) THEN
   IF (EXPECTED IS NOT NULL) THEN
    CALL WRITE_IN_REPORT ('Expected: "' || BOOL_TO_CHAR(EXPECTED) || '"');
   ELSE
    CALL WRITE_IN_REPORT ('Expected: NULL');
   END IF;
   IF (ACTUAL IS NOT NULL) THEN
    CALL WRITE_IN_REPORT ('Actual  : "' || BOOL_TO_CHAR(ACTUAL) || '"');
   ELSE
    CALL WRITE_IN_REPORT ('Actual  : NULL');
   END IF;
  END IF;

  RETURN RET;
 END P_ASSERT_BOOLEAN_EQUALS_MESSAGE @

/**
 * Asserts if the given value is true.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN CONDITION
 *   Value to check against TRUE.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_BOOLEAN_TRUE (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN CONDITION BOOLEAN
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_BOOLEAN_TRUE_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_BOOLEAN_TRUE_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_BOOLEAN_TRUE_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, BOOL_TO_CHAR(CONDITION));

  -- Check value.
  IF (CONDITION = FALSE) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The given value is "FALSE"');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 4;
  END IF;

  RETURN RET;
 END P_ASSERT_BOOLEAN_TRUE_MESSAGE @

/**
 * Asserts if the given value is false.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN CONDITION
 *   Value to check against FALSE.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_BOOLEAN_FALSE (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN CONDITION BOOLEAN
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_BOOLEAN_FALSE_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_BOOLEAN_FALSE_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_BOOLEAN_FALSE_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, BOOL_TO_CHAR(CONDITION));

  -- Check value.
  IF (CONDITION = TRUE) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The given value is "TRUE"');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 4;
  END IF;

  RETURN RET;
 END P_ASSERT_BOOLEAN_FALSE_MESSAGE @

/**
 * Asserts if the given boolean is null.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN CONDITION
 *   Value to check if it is null.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_BOOLEAN_NULL (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN CONDITION BOOLEAN
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_BOOLEAN_NULL_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_BOOLEAN_NULL_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_BOOLEAN_NULL_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, BOOL_TO_CHAR(CONDITION));

  -- Check value.
  IF (CONDITION IS NOT NULL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The given value is "NOT NULL"');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 5;
  END IF;

  RETURN RET;
 END P_ASSERT_BOOLEAN_NULL_MESSAGE @

/**
 * Asserts if the given boolean is not null.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN CONDITION
 *   Value to check if it is not null.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_BOOLEAN_NOT_NULL (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN CONDITION BOOLEAN
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_BOOLEAN_NOT_NULL_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_BOOLEAN_NOT_NULL_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_BOOLEAN_NOT_NULL_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, BOOL_TO_CHAR(CONDITION));

  -- Check value.
  IF (CONDITION IS NULL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The given value is "NULL"');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 5;
  END IF;

  RETURN RET;
 END P_ASSERT_BOOLEAN_NOT_NULL_MESSAGE @

-- INTEGER

/**
 * Asserts if the given two int are the same, in nullability and in content.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN EXPECTED
 *   Expected int.
 * IN ACTUAL
 *   Actual int.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_INT_EQUALS (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN EXPECTED BIGINT,
  IN ACTUAL BIGINT
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_INT_EQUALS_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_INT_EQUALS_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE SHOW BOOLEAN DEFAULT FALSE;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_INT_EQUALS_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, EXPECTED);
  CALL LOGGER.DEBUG(LOGGER_ID, ACTUAL);

  -- Check values.
  IF ((EXPECTED IS NULL AND ACTUAL IS NOT NULL)
    OR (EXPECTED IS NOT NULL AND ACTUAL IS NULL)) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'Nullability difference');
   SET SHOW = TRUE;
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 1;
  ELSEIF (EXPECTED <> ACTUAL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The value of both integers is different');
   SET SHOW = TRUE;
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 2;
  END IF;

  -- Show problems.
  IF (SHOW = TRUE) THEN
   IF (EXPECTED IS NOT NULL) THEN
    CALL WRITE_IN_REPORT ('Expected: "' || EXPECTED || '"');
   ELSE
    CALL WRITE_IN_REPORT ('Expected: NULL');
   END IF;
   IF (ACTUAL IS NOT NULL) THEN
    CALL WRITE_IN_REPORT ('Actual  : "' || ACTUAL || '"');
   ELSE
    CALL WRITE_IN_REPORT ('Actual  : NULL');
   END IF;
  END IF;

  RETURN RET;
 END P_ASSERT_INT_EQUALS_MESSAGE @

/**
 * Asserts if the given value is null.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN VALUE
 *   Value to check if it is null.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_INT_NULL (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN VALUE BIGINT
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_INT_NULL_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_INT_NULL_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_INT_NULL_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, VALUE);

  -- Check value.
  IF (VALUE IS NOT NULL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The given value is "NOT NULL"');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 5;
  END IF;

  RETURN RET;
 END P_ASSERT_INT_NULL_MESSAGE @

/**
 * Asserts if the given int is not null.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN VALUE
 *   Value to check if it is not null.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_INT_NOT_NULL (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN VALUE BIGINT
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_INT_NOT_NULL_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_INT_NOT_NULL_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_INT_NOT_NULL_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, VALUE);

  -- Check value.
  IF (VALUE IS NULL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The given value is "NULL"');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 5;
  END IF;

  RETURN RET;
 END P_ASSERT_INT_NOT_NULL_MESSAGE @

-- DECIMAL

/**
 * Asserts if the given two decimals are the same, in nullability and in
 * content.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN EXPECTED
 *   Expected decimal.
 * IN ACTUAL
 *   Actual decimal.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_DEC_EQUALS (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN EXPECTED DECFLOAT,
  IN ACTUAL DECFLOAT
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_DEC_EQUALS_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_DEC_EQUALS_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE SHOW BOOLEAN DEFAULT FALSE;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_DEC_EQUALS_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, EXPECTED);
  CALL LOGGER.DEBUG(LOGGER_ID, ACTUAL);

  -- Check values.
  IF ((EXPECTED IS NULL AND ACTUAL IS NOT NULL)
    OR (EXPECTED IS NOT NULL AND ACTUAL IS NULL)) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'Nullability difference');
   SET SHOW = TRUE;
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 1;
  ELSEIF (EXPECTED <> ACTUAL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The value of both decimals is different');
   SET SHOW = TRUE;
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 2;
  END IF;

  -- Show problems.
  IF (SHOW = TRUE) THEN
   IF (EXPECTED IS NOT NULL) THEN
    CALL WRITE_IN_REPORT ('Expected: "' || EXPECTED || '"');
   ELSE
    CALL WRITE_IN_REPORT ('Expected: NULL');
   END IF;
   IF (ACTUAL IS NOT NULL) THEN
    CALL WRITE_IN_REPORT ('Actual  : "' || ACTUAL || '"');
   ELSE
    CALL WRITE_IN_REPORT ('Actual  : NULL');
   END IF;
  END IF;

  RETURN RET;
 END P_ASSERT_DEC_EQUALS_MESSAGE @

/**
 * Asserts if the given value is null.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN VALUE
 *   Value to check if it is null.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_DEC_NULL (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN VALUE DECFLOAT
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_DEC_NULL_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_DEC_NULL_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_DEC_NULL_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, VALUE);

  -- Check value.
  IF (VALUE IS NOT NULL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The given value is "NOT NULL"');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 5;
  END IF;

  RETURN RET;
 END P_ASSERT_DEC_NULL_MESSAGE @

/**
 * Asserts if the given decimal is not null.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN VALUE
 *   Value to check if it is not null.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_DEC_NOT_NULL (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN VALUE DECFLOAT
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_DEC_NOT_NULL_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_DEC_NOT_NULL_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_DEC_NOT_NULL_MESSAGE',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, VALUE);

  -- Check value.
  IF (VALUE IS NULL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The given value is "NULL"');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 5;
  END IF;

  RETURN RET;
 END P_ASSERT_DEC_NOT_NULL_MESSAGE @

-- TABLES

/**
 * Checks the equality of a same column name in two tables.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN EXPECTED_SCHEMA
 *   Schema of the table as model.
 * IN EXPECTED_TABLE_NAME
 *   Name of the table to analyze.
 * IN ACTUAL_SCHEMA
 *   Schema of the resulting table.
 * IN ACTUAL_TABLE_NAME
 *   Name of the resulting table.
 * IN COLNAME
 *   Name of the column in both tables.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE CHECK_COLUMN (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN EXPECTED_SCHEMA ANCHOR SYSCAT.TABLES.TABSCHEMA,
  IN EXPECTED_TABLE_NAME ANCHOR SYSCAT.TABLES.TABNAME,
  IN ACTUAL_SCHEMA ANCHOR SYSCAT.TABLES.TABSCHEMA,
  IN ACTUAL_TABLE_NAME ANCHOR SYSCAT.TABLES.TABNAME,
  IN COLNAME ANCHOR SYSCAT.COLUMNS.COLNAME
  )
  LANGUAGE SQL
  SPECIFIC P_CHECK_COLUMN
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_CHECK_COLUMN: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INTEGER DEFAULT 0;
  DECLARE SENTENCE ANCHOR MAX_VALUES.SENTENCE;
  DECLARE ACTUAL_QTY INT;
  DECLARE EXPECTED_QTY INT;
  DECLARE ACTUAL_TOTAL INT DEFAULT 0;
  DECLARE EXPECTED_TOTAL INT DEFAULT 0;
  DECLARE ACTUAL_VALUE VARCHAR(32672);
  DECLARE EXPECTED_VALUE VARCHAR(32672);
  DECLARE AT_END BOOLEAN DEFAULT FALSE; -- End of the cursor.
  DECLARE DIFFERENT BOOLEAN DEFAULT FALSE;
  DECLARE STMT STATEMENT;
  DECLARE EXPECTED_CURSOR CURSOR
    FOR EXPECTED_RS;
  DECLARE ACTUAL_CURSOR CURSOR
    FOR ACTUAL_RS;
  DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET AT_END = TRUE;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.CHECK_COLUMN', LOGGER_ID);

  SET SENTENCE = 'SET ? = (SELECT COUNT(1) FROM (SELECT DISTINCT ' || COLNAME
    || ' FROM ' || EXPECTED_SCHEMA || '.' || EXPECTED_TABLE_NAME || '))';
  CALL LOGGER.DEBUG(LOGGER_ID, SENTENCE);
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT INTO EXPECTED_TOTAL;
  SET SENTENCE = 'SET ? = (SELECT COUNT(1) FROM (SELECT DISTINCT ' || COLNAME
    || ' FROM ' || ACTUAL_SCHEMA || '.' || ACTUAL_TABLE_NAME || '))';
  CALL LOGGER.DEBUG(LOGGER_ID, SENTENCE);
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT INTO ACTUAL_TOTAL;
  IF (EXPECTED_TOTAL <> ACTUAL_TOTAL) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The quantity of different items is '
     || 'not the same in column: ' || COLNAME);
   SET RET = 13;
  END IF;

  IF (RET = 0) THEN
   SET SENTENCE = 'SELECT DISTINCT ' || COLNAME || ', COUNT(1) '
     || 'FROM ' || EXPECTED_SCHEMA || '.' || EXPECTED_TABLE_NAME || ' '
     || 'GROUP BY ' || COLNAME;
   CALL LOGGER.DEBUG(LOGGER_ID, SENTENCE);
   PREPARE EXPECTED_RS FROM SENTENCE;

   SET SENTENCE = 'SELECT DISTINCT ' || COLNAME || ', COUNT(1) '
     || 'FROM ' || ACTUAL_SCHEMA || '.' || ACTUAL_TABLE_NAME || ' '
     || 'GROUP BY ' || COLNAME;
   CALL LOGGER.DEBUG(LOGGER_ID, SENTENCE);
   PREPARE ACTUAL_RS FROM SENTENCE;

   OPEN EXPECTED_CURSOR;
   OPEN ACTUAL_CURSOR;

   FETCH EXPECTED_CURSOR INTO EXPECTED_VALUE, EXPECTED_QTY;
   FETCH ACTUAL_CURSOR INTO ACTUAL_VALUE, ACTUAL_QTY;

   WHILE(AT_END = FALSE AND DIFFERENT = FALSE) DO
    IF (EXPECTED_VALUE <> ACTUAL_VALUE) THEN
     CALL WRITE_IN_REPORT (MESSAGE || 'Different values in column: '
       || COLNAME);
     SET DIFFERENT = TRUE;
     SET RET = 11;
    ELSEIF (EXPECTED_QTY <> ACTUAL_QTY) THEN
     CALL WRITE_IN_REPORT (MESSAGE || 'Different quantity of values in '
       || 'column: ' || COLNAME);
     SET DIFFERENT = TRUE;
     SET RET = 12;
    END IF;
    IF (DIFFERENT = FALSE) THEN
     FETCH EXPECTED_CURSOR INTO EXPECTED_VALUE, EXPECTED_QTY;
     FETCH ACTUAL_CURSOR INTO ACTUAL_VALUE, ACTUAL_QTY;
    END IF;
   END WHILE;
  END IF;

  RETURN RET;
 END P_CHECK_COLUMN @

/**
 * Asserts if the given two tables are equal in structure and content.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN EXPECTED_SCHEMA
 *   Schema of the table as model.
 * IN EXPECTED_TABLE_NAME
 *   Name of the table to analyze.
 * IN ACTUAL_SCHEMA
 *   Schema of the resulting table.
 * IN ACTUAL_TABLE_NAME
 *   Name of the resulting table.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_TABLE_EQUALS (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN EXPECTED_SCHEMA ANCHOR SYSCAT.TABLES.TABSCHEMA,
  IN EXPECTED_TABLE_NAME ANCHOR SYSCAT.TABLES.TABNAME,
  IN ACTUAL_SCHEMA ANCHOR SYSCAT.TABLES.TABSCHEMA,
  IN ACTUAL_TABLE_NAME ANCHOR SYSCAT.TABLES.TABNAME
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_TABLE_EQUALS_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_TABLE_EQUALS_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET INT;
  DECLARE EXP_QTY SMALLINT;
  DECLARE ACT_QTY SMALLINT;
  DECLARE INDEX SMALLINT;
  DECLARE COLNAME ANCHOR SYSCAT.COLUMNS.COLNAME;
  DECLARE SENTENCE ANCHOR MAX_VALUES.SENTENCE;
  DECLARE STMT STATEMENT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.ASSERT_TABLE_EQUALS',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, EXPECTED_SCHEMA);
  CALL LOGGER.DEBUG(LOGGER_ID, EXPECTED_TABLE_NAME);
  CALL LOGGER.DEBUG(LOGGER_ID, ACTUAL_SCHEMA);
  CALL LOGGER.DEBUG(LOGGER_ID, ACTUAL_TABLE_NAME);
  IF (EXPECTED_SCHEMA IS NULL OR EXPECTED_TABLE_NAME IS NULL
    OR ACTUAL_SCHEMA IS NULL OR ACTUAL_TABLE_NAME IS NULL) THEN
    CALL WRITE_IN_REPORT (SUBSTR(MESSAGE || 'Some of the entry values are '
      || 'null: ' || COALESCE(EXPECTED_SCHEMA, 'NULL') || ',' 
      || COALESCE(EXPECTED_TABLE_NAME, 'NULL') || ',' 
      || COALESCE(ACTUAL_SCHEMA, 'NULL') || ',' 
      || COALESCE(ACTUAL_TABLE_NAME, 'NULL'), 1, 512));
    SET RET = 14;
  END IF;

  -- Checks qty of columns.
  IF (RET = 0) THEN
   SET SENTENCE = 'SET ? = (SELECT COLCOUNT '
     || 'FROM SYSCAT.TABLES '
     || 'WHERE TABSCHEMA = ''' || EXPECTED_SCHEMA || ''' '
     || 'AND TABNAME = ''' || EXPECTED_TABLE_NAME || ''')';
   CALL LOGGER.DEBUG(LOGGER_ID, SENTENCE);
   PREPARE STMT FROM SENTENCE;
   EXECUTE STMT INTO EXP_QTY;
   SET SENTENCE = 'SET ? = (SELECT COLCOUNT '
     || 'FROM SYSCAT.TABLES '
     || 'WHERE TABSCHEMA = ''' || ACTUAL_SCHEMA || ''' '
     || 'AND TABNAME = ''' || ACTUAL_TABLE_NAME || ''')';
   CALL LOGGER.DEBUG(LOGGER_ID, SENTENCE);
   PREPARE STMT FROM SENTENCE;
   EXECUTE STMT INTO ACT_QTY;
   IF (EXP_QTY <> ACT_QTY) THEN
    CALL WRITE_IN_REPORT (MESSAGE || 'Different quantity of columns');
    SET RET = 10;
   END IF;
  END IF;

  -- Checks the content of the columns.
  IF (RET = 0) THEN
   SET INDEX = 0;
   WHILE (INDEX < EXP_QTY AND RET = 0) DO
    SET SENTENCE = 'SET ? = (SELECT COLNAME '
      || 'FROM SYSCAT.COLUMNS '
      || 'WHERE TABSCHEMA = ''' || EXPECTED_SCHEMA || ''' '
      || 'AND TABNAME = ''' || EXPECTED_TABLE_NAME || ''' '
      || 'AND COLNO = ' || INDEX || ')';
    CALL LOGGER.DEBUG(LOGGER_ID, SENTENCE);
    PREPARE STMT FROM SENTENCE;
    EXECUTE STMT INTO COLNAME;
    CALL CHECK_COLUMN(MESSAGE, EXPECTED_SCHEMA, EXPECTED_TABLE_NAME,
      ACTUAL_SCHEMA, ACTUAL_TABLE_NAME, COLNAME);
    GET DIAGNOSTICS RET = DB2_RETURN_STATUS;
    SET INDEX = INDEX + 1;
   END WHILE;
  END IF;

  RETURN RET;
 END P_ASSERT_TABLE_EQUALS_MESSAGE @

/**
 * Checks if the table is empty. Returns TRUE if the table is empty, false
 * otherwise.
 *
 * IN SCHEMA
 *   Schema of the table.
 * IN TABLE_NAME
 *   Name of the table to analyze.
 */
ALTER MODULE DB2UNIT ADD
  FUNCTION CHECK_TABLE_EMPTYNESS (
  IN SCHEMA ANCHOR SYSCAT.TABLES.TABSCHEMA,
  IN TABLE_NAME ANCHOR SYSCAT.TABLES.TABNAME
  ) RETURNS BOOLEAN
  LANGUAGE SQL
  SPECIFIC F_CHECK_TABLE_EMPTYNESS
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 F_CHECK_TABLE_EMPTYNESS: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE RET BOOLEAN;
  DECLARE CNT INT;
  DECLARE SENTENCE ANCHOR MAX_VALUES.SENTENCE;
  DECLARE WHOLE_NAME ANCHOR SYSCAT.TABLES.TABNAME;
  DECLARE STMT STATEMENT;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.CHECK_TABLE_EMPTYNESS',
    LOGGER_ID);

  IF (SCHEMA IS NOT NULL) THEN
    SET WHOLE_NAME = TRIM(SCHEMA) || '.' || TRIM(TABLE_NAME);
  ELSE
    SET WHOLE_NAME = TRIM(TABLE_NAME);
  END IF;

  SET SENTENCE = 'SET ? = (SELECT COUNT(0) '
    || 'FROM ' || WHOLE_NAME || ')';
  CALL LOGGER.DEBUG(LOGGER_ID, SENTENCE);
  PREPARE STMT FROM SENTENCE;
  EXECUTE STMT INTO CNT;

  IF (CNT > 0) THEN
   SET RET = FALSE;
  ELSEIF (CNT = 0) THEN
   SET RET = TRUE;
  ELSE
   SET RET = NULL;
  END IF;
  RETURN RET;
 END F_CHECK_TABLE_EMPTYNESS @

/**
 * Asserts that the given name corresponds to an empty table with a related
 * test message.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN SCHEMA
 *   Schema of the table.
 * IN TABLE_NAME
 *   Name of the table to analyze.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_TABLE_EMPTY (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN SCHEMA ANCHOR SYSCAT.TABLES.TABSCHEMA,
  IN TABLE_NAME ANCHOR SYSCAT.TABLES.TABNAME
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_TABLE_EMPTY_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_TABLE_EMPTY_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE EMPTY BOOLEAN;
  DECLARE RET INT;
  DECLARE EXIT HANDLER FOR SQLSTATE '42704'
    BEGIN
     CALL WRITE_IN_REPORT('Table does not exist ' || COALESCE(SCHEMA, 'NULL') 
       || '.' || COALESCE(TABLE_NAME, 'NULL'));
     SET RET = 9;
     RETURN RET;
    END;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_TABLE_EMPTY',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, TABLE_NAME);

  -- Check value.
  SET EMPTY = CHECK_TABLE_EMPTYNESS(SCHEMA, TABLE_NAME);
  IF (EMPTY = FALSE) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The table is not empty');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 7;
  END IF;

  RETURN RET;
 END P_ASSERT_TABLE_EMPTY_MESSAGE @

/**
 * Asserts that the given name corresponds to a non empty table with a related
 * test message.
 *
 * IN MESSAGE
 *   Related message to the test.
 * IN SCHEMA
 *   Schema of the table.
 * IN TABLE_NAME
 *   Name of the table to analyze.
 */
ALTER MODULE DB2UNIT ADD
  PROCEDURE ASSERT_TABLE_NON_EMPTY (
  IN MESSAGE ANCHOR MAX_VALUES.MESSAGE_ASSERT,
  IN SCHEMA ANCHOR SYSCAT.TABLES.TABSCHEMA,
  IN TABLE_NAME ANCHOR SYSCAT.TABLES.TABNAME
  )
  LANGUAGE SQL
  SPECIFIC P_ASSERT_TABLE_NON_EMPTY_MESSAGE
  DYNAMIC RESULT SETS 0
  MODIFIES SQL DATA
  NOT DETERMINISTIC
  NO EXTERNAL ACTION
  PARAMETER CCSID UNICODE
 P_ASSERT_TABLE_NON_EMPTY_MESSAGE: BEGIN
  DECLARE LOGGER_ID SMALLINT;
  DECLARE EMPTY BOOLEAN;
  DECLARE RET INT;
  DECLARE EXIT HANDLER FOR SQLSTATE '42704'
    BEGIN
     CALL WRITE_IN_REPORT('Table does not exist ' || COALESCE(SCHEMA, 'NULL')
       || '.' || COALESCE(TABLE_NAME, 'NULL'));
     SET RET = 9;
     RETURN RET;
    END;

  CALL LOGGER.GET_LOGGER('DB2UNIT_1A.DB2UNIT.P_ASSERT_TABLE_NON_EMPTY',
    LOGGER_ID);
  -- Pre process
  SET MESSAGE = PROC_MESSAGE(MESSAGE);
  SET RET = 0;
  CALL LOGGER.DEBUG(LOGGER_ID, MESSAGE);
  CALL LOGGER.DEBUG(LOGGER_ID, TABLE_NAME);

  -- Check value.
  SET EMPTY = CHECK_TABLE_EMPTYNESS(SCHEMA, TABLE_NAME);
  IF (EMPTY = TRUE) THEN
   CALL WRITE_IN_REPORT (MESSAGE || 'The table is empty');
   SET TEST_RESULT = RESULT_FAILED;
   SET RET = 7;
  END IF;

  RETURN RET;
 END P_ASSERT_TABLE_NON_EMPTY_MESSAGE@