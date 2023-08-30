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
ARG BASE_REPO="arkcase/base"
ARG BASE_TAG="8-01"
ARG VER="13"
ARG BLD="03"

FROM "${PUBLIC_REGISTRY}/${BASE_REPO}:${BASE_TAG}"

ARG VER

# PostgreSQL image for OpenShift.
# Volumes:
#  * /var/lib/pgsql/data   - Database cluster for PostgreSQL
# Environment:
#  * $POSTGRESQL_USER     - Database user name
#  * $POSTGRESQL_PASSWORD - User's password
#  * $POSTGRESQL_DATABASE - Name of the database to create
#  * $POSTGRESQL_ADMIN_PASSWORD (Optional) - Password for the 'postgres'
#                           PostgreSQL administrative account

ENV POSTGRESQL_VERSION=${VER} \
    HOME=/var/lib/pgsql \
    PGUSER=postgres \
    APP_DATA=/opt/app-root

ENV SUMMARY="PostgreSQL is an advanced Object-Relational database management system" \
    DESCRIPTION="PostgreSQL is an advanced Object-Relational database management system (DBMS). \
The image contains the client and server programs that you'll need to \
create, run, maintain and access a PostgreSQL DBMS server."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="PostgreSQL ${VER}" \
      io.openshift.expose-services="5432:postgresql" \
      io.openshift.tags="database,postgresql,postgresql${VER},postgresql-${VER}" \
      io.openshift.s2i.assemble-user="26" \
      name="rhel8/postgresql-${VER}" \
      com.redhat.component="postgresql-${VER}-container" \
      version="1" \
      com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#rhel" \
      usage="podman run -d --name postgresql_database -e POSTGRESQL_USER=user -e POSTGRESQL_PASSWORD=pass -e POSTGRESQL_DATABASE=db -p 5432:5432 rhel8/postgresql-${VER}" \
      maintainer="SoftwareCollections.org <sclorg@redhat.com>"

EXPOSE 5432

COPY root/usr/libexec/fix-permissions /usr/libexec/fix-permissions

# This image must forever use UID 26 for postgres user so our volumes are
# safe in the future. This should *never* change, the last test is there
# to make sure of that.
RUN yum -y module enable postgresql:${VER} && \
    INSTALL_PKGS="rsync tar gettext bind-utils nss_wrapper postgresql-server postgresql-contrib" && \
    INSTALL_PKGS="$INSTALL_PKGS pgaudit" && \
    yum -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y reinstall tzdata && \
    yum -y clean all --enablerepo='*' && \
    localedef -f UTF-8 -i en_US en_US.UTF-8 && \
    test "$(id postgres)" = "uid=26(postgres) gid=26(postgres) groups=26(postgres)" && \
    mkdir -p /var/lib/pgsql/data && \
    /usr/libexec/fix-permissions /var/lib/pgsql /var/run/postgresql

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/postgresql \
    ENABLED_COLLECTIONS=

COPY root /
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

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
RUN usermod -a -G root,${ACM_GROUP} postgres && \
    /usr/libexec/fix-permissions --read-only "$APP_DATA"

USER 26

ENTRYPOINT [ "/entrypoint" ]
CMD ["run-postgresql"]
