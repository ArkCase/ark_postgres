# Note: ubi8/s2i-core:rhel8.7 is equivelent RHEL 8 Official Base Image
# Note: registry.redhat.io/rhel8/postgresql-13  is equivelent PostGres Image
# https://catalog.redhat.com/software/containers/rhel8/postgresql-13/5ffdbdef73a65398111b8362?container-tabs=gti
# 
# Source code for RHEL official Postgres 13 is at https://github.com/docker-library/postgres
#
###########################################################################################################
# How to build: 
#
# docker build -t arkcase/postgres:latest .
# docker push arkcase/postgres:latest 
#
# How to run: (Helm)
#
# helm repo add arkcase https://arkcase.github.io/ark_helm_charts/
# helm install ark-activemq arkcase/ark-postgres
# helm uninstall ark-postgres
#
# How to run: (Docker)
#
# docker run -d --name ark_postgres -e POSTGRESQL_USER=user -e POSTGRESQL_PASSWORD=pass -e POSTGRESQL_DATABASE=db -p 5432:5432  -e MYSQL_ROOT_PASSWORD=mypass -p 3306:3306 arkcase/postgres:latest
# docker exec -it ark_postgres /bin/bash
# docker stop ark_postgres
# docker rm ark_postgres
#
# How to run: (Kubernetes)
#
# kubectl create -f pod_ark_postgres.yaml
# kubectl exec -it pod/postgres -- bash
# kubectl delete -f pod_ark_postgres.yaml
#
###########################################################################################################

ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG VER="13"

ARG PSQL_KEY="https://www.postgresql.org/media/keys/ACCC4CF8.asc"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/base"
ARG BASE_VER="24.04"
ARG BASE_VER_PFX=""
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}:${BASE_VER_PFX}${BASE_VER}"

FROM "${BASE_IMG}"

ARG VER
ARG PSQL_KEY

ENV POSTGRESQL_VERSION="${VER}" \
    HOME="/var/lib/postgresql" \
    PGUSER="postgres" \
    APP_DATA="${APP_ROOT}"

ENV SUMMARY="PostgreSQL is an advanced Object-Relational database management system" \
    DESCRIPTION="PostgreSQL is an advanced Object-Relational database management system (DBMS). \
The image contains the client and server programs that you'll need to \
create, run, maintain and access a PostgreSQL DBMS server."

LABEL summary="${SUMMARY}" \
      description="${DESCRIPTION}" \
      io.k8s.description="${DESCRIPTION}" \
      io.k8s.display-name="PostgreSQL ${VER}" \
      version="1"

EXPOSE 5432

ENV APP_USER="${PGUSER}"
ENV APP_UID="26"
ENV APP_GROUP="${APP_USER}"
ENV APP_GID="${APP_UID}"

RUN groupadd --gid "${APP_UID}" --system "${APP_USER}" && \
    useradd --gid "${APP_GROUP}" --home-dir "${HOME}" --create-home --shell /sbin/nologin --uid "${APP_UID}" --system "${APP_USER}"

COPY root/usr/libexec/fix-permissions /usr/libexec/fix-permissions

ENV PGBASE="${HOME}/${VER}"
ENV PGDATA="${PGBASE}/main"
ENV PGRUN="/var/run/postgresql"
ENV PATH="/usr/lib/postgresql/${VER}/bin:${PATH}"

RUN mkdir -p "${PGDATA}" && chown -R "${APP_USER}:${APP_GROUP}" "${HOME}" && \
    test "$(id -u "${APP_USER}"):$(id -g "${APP_GROUP}")" = "${APP_UID}:${APP_GID}"

# Make sure we use the correct PostgreSQL version
RUN export PGSQL_SIG="/etc/apt/trusted.gpg.d/postgresql.gpg" && \
    export PGSQL_LIST="/etc/apt/sources.list.d/pgdg.list" && \
    curl -fsSL "${PSQL_KEY}" | gpg --dearmor -o "${PGSQL_SIG}" && \
    chmod 0644 "${PGSQL_SIG}" && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | \
        tee  "${PGSQL_LIST}" && \
    chmod 0644 "${PGSQL_LIST}"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
        postgresql-${VER} \
        postgresql-client-${VER} \
        postgresql-${VER}-pgaudit \
      && \
    apt-get clean && \
    mkdir -p "${PGDATA}" && \
    /usr/libexec/fix-permissions "${HOME}" "${PGRUN}"

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/postgresql \
    ENABLED_COLLECTIONS=

COPY root /
RUN secure-permissions

# Not using VOLUME statement since it's not working in OpenShift Online:
# https://github.com/sclorg/httpd-container/issues/30
# VOLUME ["/var/lib/pgsql/data"]

# S2I permission fixes
# --------------------
# 1. unless specified otherwise (or - equivalently - we are in OpenShift), s2i
#    build process would be executed as 'uid=26(postgres) gid=26(postgres)'.
#    Such process wouldn't be able to execute the default 'assemble' script
#    correctly (it transitively executes 'fix-permissions' script).  So let's
#    add the 'postgres' user into 'root' group here
#
# 2. we call fix-permissions on $APP_DATA here directly (UID=0 during build
#    anyways) to assure that s2i process is actually able to _read_ the
#    user-specified scripting.
RUN usermod -a -G "root,${ACM_GROUP}" "${PGUSER}" && \
    /usr/libexec/fix-permissions --read-only "${APP_DATA}"

USER "${PGUSER}"

ENTRYPOINT [ "/entrypoint" ]
CMD ["run-postgresql"]
