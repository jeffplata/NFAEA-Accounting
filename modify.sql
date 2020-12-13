/* ---------------------------------------------------------------------- */
/* Script generated with: DeZign for Databases V10.0.2                    */
/* Target DBMS:           Firebird 2                                      */
/* Project file:          Project2.dez                                    */
/* Project name:                                                          */
/* Author:                                                                */
/* Script type:           Alter database script                           */
/* Created on:            2020-12-12 20:10                                */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Drop foreign key constraints                                           */
/* ---------------------------------------------------------------------- */

ALTER TABLE LOAN DROP CONSTRAINT MEMBER_LOAN;

/* ---------------------------------------------------------------------- */
/* Alter table "MEMBER"                                                   */
/* ---------------------------------------------------------------------- */

ALTER TABLE MEMBER ADD
    IS_ACTIVE CHAR(1);

/* ---------------------------------------------------------------------- */
/* Add foreign key constraints                                            */
/* ---------------------------------------------------------------------- */

ALTER TABLE LOAN ADD CONSTRAINT MEMBER_LOAN 
    FOREIGN KEY (MEMBER_ID) REFERENCES MEMBER (ID);
