psql -U ${PGUSER} -d ${POSTGRESQL_DATABASE} -a -f /opt/app-root/src/ark_pentaho_ee/create_quartz_postgresql.sql
psql -U ${PGUSER} -d ${POSTGRESQL_DATABASE} -a -f /opt/app-root/src/ark_pentaho_ee/create_repository_postgresql.sql
psql -U ${PGUSER} -d ${POSTGRESQL_DATABASE} -a -f /opt/app-root/src/ark_pentaho_ee/create_jcr_postgresql.sql
psql -U ${PGUSER} -d ${POSTGRESQL_DATABASE} -a -f /opt/app-root/src/ark_pentaho_ee/pentaho_mart_postgresql.sql
