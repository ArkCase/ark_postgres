-- Upgrades from 8.2.0 to next release

-- NOTE:
-- If and when this script is executed, you should also additionally  execute the following script
-- "pentaho_mart_upgrade_audit_postgresql.sql"
-- distributed in the same folder of the server, otherwise don't execute it.

-- changes in hibernate database

DROP INDEX public.IDX_AUD_OID;
ALTER TABLE public.PRO_AUDIT ALTER COLUMN OBJ_ID TYPE varchar(1024);
CREATE INDEX IDX_AUD_OID ON public.PRO_AUDIT (OBJ_ID);


