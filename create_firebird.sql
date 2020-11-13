/* ---------------------------------------------------------------------- */
/* Script generated with: DeZign for Databases V10.0.2                    */
/* Target DBMS:           Firebird 2                                      */
/* Project file:          Project2.dez                                    */
/* Project name:                                                          */
/* Author:                                                                */
/* Script type:           Database creation script                        */
/* Created on:            2020-11-12 20:19                                */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Add tables                                                             */
/* ---------------------------------------------------------------------- */

/* ---------------------------------------------------------------------- */
/* Add table "PRODUCT"                                                    */
/* ---------------------------------------------------------------------- */

CREATE TABLE PRODUCT (
    ID INTEGER NOT NULL,
    NAME VARCHAR(80) NOT NULL,
    INTEREST_RATE NUMERIC(15,2),
    MAX_AMOUNT NUMERIC(15,2),
    TERMS INTEGER,
    DATE_STARTED DATE,
    DATE_ENDED DATE,
    IS_ACTIVE CHAR(1),
    CONSTRAINT PK_PRODUCT PRIMARY KEY (ID),
    CONSTRAINT TUC_PRODUCT_1 UNIQUE (NAME)
);

/* ---------------------------------------------------------------------- */
/* Add table "MEMBER"                                                     */
/* ---------------------------------------------------------------------- */

CREATE TABLE MEMBER (
    ID INTEGER NOT NULL,
    LAST_NAME VARCHAR(80) CHARACTER SET UTF8 COLLATE UTF8,
    FIRST_NAME VARCHAR(80) CHARACTER SET UTF8 COLLATE UTF8,
    MIDDLE_NAME VARCHAR(80) CHARACTER SET UTF8 COLLATE UTF8,
    SUFFIX_NAME VARCHAR(80) CHARACTER SET UTF8 COLLATE UTF8,
    CONSTRAINT PK_MEMBER PRIMARY KEY (ID)
);

/* ---------------------------------------------------------------------- */
/* Add table "LOAN"                                                       */
/* ---------------------------------------------------------------------- */

CREATE TABLE LOAN (
    ID INTEGER NOT NULL,
    AMOUNT NUMERIC(15,2),
    TRANS_DATE DATE,
    INTEREST NUMERIC(15,2),
    INTEREST_RATE NUMERIC(15,2),
    PAYMENT_START DATE,
    TERMS INTEGER,
    MEMBER_ID INTEGER,
    PRODUCT_ID INTEGER,
    CONSTRAINT PK_LOAN PRIMARY KEY (ID)
);

/* ---------------------------------------------------------------------- */
/* Add foreign key constraints                                            */
/* ---------------------------------------------------------------------- */

ALTER TABLE LOAN ADD CONSTRAINT PRODUCT_LOAN 
    FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT (ID);

ALTER TABLE LOAN ADD CONSTRAINT MEMBER_LOAN 
    FOREIGN KEY (MEMBER_ID) REFERENCES MEMBER (ID);
