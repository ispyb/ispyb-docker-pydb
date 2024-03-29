# Stolen from https://github.com/lindycoder/prepopulated-mysql-container-example
FROM mariadb:latest as builder

# That file does the DB initialization but also runs mysql daemon, by removing the last line it will only init
RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_PASSWORD=test
ENV MYSQL_USER=test 
ENV MYSQL_DATABASE=test

RUN apt-get update && apt-get install -y wget && \
    wget https://raw.githubusercontent.com/ispyb/ispyb-database/main/schema/1_tables.sql && \
    wget https://raw.githubusercontent.com/ispyb/ispyb-database/main/schema/2_lookups.sql && \
    wget https://raw.githubusercontent.com/ispyb/ispyb-database/main/schema/3_data.sql && \
    wget https://raw.githubusercontent.com/ispyb/ispyb-database/main/schema/4_data_user_portal.sql && \
    wget https://raw.githubusercontent.com/ispyb/ispyb-database/main/schema/5_routines.sql && \
    mv *.sql /docker-entrypoint-initdb.d/ && \
    apt-get clean autoclean && apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/*

# Need to change the datadir to something else that /var/lib/mysql because the parent docker file defines it as a volume.
# https://docs.docker.com/engine/reference/builder/#volume :
#       Changing the volume from within the Dockerfile: If any build steps change the data within the volume after
#       it has been declared, those changes will be discarded.
RUN ["/usr/local/bin/docker-entrypoint.sh", "mysqld", "--datadir", "/initialized-db", "--aria-log-dir-path", "/initialized-db"]

RUN rm /docker-entrypoint-initdb.d/*

FROM mariadb:latest

COPY --from=builder /initialized-db /var/lib/mysql
