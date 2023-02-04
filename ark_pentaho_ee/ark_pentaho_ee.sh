#!/bin/bash

say() {
	echo -e "${@}"
}

fail() {
	say "${@}" 1>&2
	exit ${EXIT_CODE:-1}
}

[ -v PGUSER ] || PGUSER="postgres"
SRC_DIR="/opt/app-root/src/ark_pentaho_ee"

SCRIPTS=(
	"${SRC_DIR}/create_quartz_postgresql.sql"
	"${SRC_DIR}/create_repository_postgresql.sql"
	"${SRC_DIR}/create_jcr_postgresql.sql"
	"${SRC_DIR}/pentaho_mart_postgresql.sql"
)

for SQL in "${SCRIPTS[@]}" ; do
	psql -U "${PGUSER}" -a -f "${SQL}" || fail "Failed to execute the initialzation script [${SSQL}]"
done
exit 0
