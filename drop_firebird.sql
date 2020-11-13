/* ---------------------------------------------------------------------- */
/* Script generated with: DeZign for Databases V10.0.2                    */
/* Target DBMS:           Firebird 2                                      */
/* Project file:          Project2.dez                                    */
/* Project name:                                                          */
/* Author:                                                                */
/* Script type:           Database drop script                            */
/* Created on:            2020-11-12 20:19                                */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Drop foreign key constraints                                           */
/* ---------------------------------------------------------------------- */

ALTER TABLE LOAN DROP CONSTRAINT PRODUCT_LOAN;

ALTER TABLE LOAN DROP CONSTRAINT MEMBER_LOAN;

/* ---------------------------------------------------------------------- */
/* Drop table "LOAN"                                                      */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE LOAN DROP CONSTRAINT PK_LOAN;

DROP TABLE LOAN;

/* ---------------------------------------------------------------------- */
/* Drop table "MEMBER"                                                    */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE MEMBER DROP CONSTRAINT PK_MEMBER;

DROP TABLE MEMBER;

/* ---------------------------------------------------------------------- */
/* Drop table "PRODUCT"                                                   */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE PRODUCT DROP CONSTRAINT PK_PRODUCT;

ALTER TABLE PRODUCT DROP CONSTRAINT TUC_PRODUCT_1;

DROP TABLE PRODUCT;
