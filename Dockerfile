# Stolen from https://github.com/lindycoder/prepopulated-mysql-container-example
FROM mariadb:latest as builder

# That file does the DB initialization but also runs mysql daemon, by removing the last line it will only init
RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_PASSWORD=test
ENV MYSQL_USER=test 
ENV MYSQL_DATABASE=test

COPY sql/tables.sql /docker-entrypoint-initdb.d/1_tables.sql
COPY sql/lookups.sql /docker-entrypoint-initdb.d/2_lookups.sql
COPY sql/data.sql /docker-entrypoint-initdb.d/3_data.sql
COPY sql/routines.sql /docker-entrypoint-initdb.d/4_routines.sql

# Need to change the datadir to something else that /var/lib/mysql because the parent docker file defines it as a volume.
# https://docs.docker.com/engine/reference/builder/#volume :
#       Changing the volume from within the Dockerfile: If any build steps change the data within the volume after
#       it has been declared, those changes will be discarded.
RUN ["/usr/local/bin/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db", "--aria-log-dir-path", "/initialized-db"]

RUN rm /docker-entrypoint-initdb.d/1_tables.sql /docker-entrypoint-initdb.d/2_lookups.sql /docker-entrypoint-initdb.d/3_data.sql /docker-entrypoint-initdb.d/4_routines.sql

FROM mariadb:latest

COPY --from=builder /initialized-db /var/lib/mysql
