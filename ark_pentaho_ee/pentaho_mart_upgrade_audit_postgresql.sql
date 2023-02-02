﻿-- Pentaho Monitoring Datamart, Audit related tables
-- Upgrades from 8.2.x to next release

ALTER TABLE pentaho_operations_mart.PRO_AUDIT_STAGING ALTER COLUMN OBJ_ID TYPE varchar(1024);
ALTER TABLE pentaho_operations_mart.DIM_INSTANCE ALTER COLUMN CONTENT_ID TYPE varchar(1024);
