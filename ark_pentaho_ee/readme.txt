https://help.hitachivantara.com/Documentation/Pentaho/9.4/Setup/Use_PostgreSQL_as_Your_Repository_Database_(Archive_installation)

Run the SQL scripts in the table below.

NoteThese scripts require administrator permissions on the server to run them.
CautionIf you have a different port or different password, make sure that you change the password and port numbers in these examples to match the ones in your configuration.
Run these scripts from the PSQL Console window in the pgAdminIII tool:

Action				SQL Script
Create Quartz			\i <your filepath>/data/postgresql/create_quartz_postgresql.sql
Create Hibernate repository	\i <your filepath>/data/postgresql/create_repository_postgresql.sql
Create Jackrabbit		\i <your filepath>/data/postgresql/create_jcr_postgresql.sql
Create Pentaho Operations mart	\i <your filepath>/data/postgresql/pentaho_mart_postgresql.sql
