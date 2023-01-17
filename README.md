# ark_postgres
PostgreSQL Docker image based on Rocky Linux

## RHEL Official Postgres 13

registry.redhat.io/rhel8/postgresql-13  is equivelent RHEL Official PostGres Image

# Documentation on Parameters

https://catalog.redhat.com/software/containers/rhel8/postgresql-13/5ffdbdef73a65398111b8362?container-tabs=overview

## Source code 
RHEL official Postgres 13 is at https://github.com/docker-library/postgres

## How to build:

docker build -t 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_postgres:latest .

docker push 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_postgres:latest

## How to run: (Helm)

helm repo add arkcase https://arkcase.github.io/ark_helm_charts/

helm install ark-activemq arkcase/ark-postgres

helm uninstall ark-postgres

## How to run: (Docker)

docker run -d --name ark_postgres -e POSTGRESQL_USER=user -e POSTGRESQL_PASSWORD=pass -e POSTGRESQL_DATABASE=db -p 5432:5432  -e MYSQL_ROOT_PASSWORD=mypass -p 3306:3306 345280441424.dkr.ecr.ap-south-1.amazonaws.com/ark_postgres:latest

docker exec -it ark_postgres /bin/bash

docker stop ark_postgres

docker rm ark_postgres

## How to run: (Kubernetes)

kubectl create -f pod_ark_postgres.yaml

kubectl exec -it pod/postgres -- bash

kubectl delete -f pod_ark_postgres.yaml
