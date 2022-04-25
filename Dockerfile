# Stolen from https://github.com/lindycoder/prepopulated-mysql-container-example
FROM mariadb:latest as builder

RUN ["sed", "-i", "s/exec \"$@\"/echo \"not running $@\"/", "/usr/local/bin/docker-entrypoint.sh"]

ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_PASSWORD=test
ENV MYSQL_USER=test 
ENV MYSQL_DATABASE=test

RUN apt-get update && apt-get install -y wget && \
    wget https://gitlab.esrf.fr/ui/ispyb-docker-pydb/-/raw/main/sql/tables.sql && \
    wget https://gitlab.esrf.fr/ui/ispyb-docker-pydb/-/raw/main/sql/lookups.sql && \
    wget https://gitlab.esrf.fr/ui/ispyb-docker-pydb/-/raw/main/sql/data.sql && \
    wget https://gitlab.esrf.fr/ui/ispyb-docker-pydb/-/raw/main/sql/routines.sql && \
    mv tables.sql /docker-entrypoint-initdb.d/1_tables.sql && \
    mv lookups.sql /docker-entrypoint-initdb.d/2_lookups.sql && \
    mv data.sql /docker-entrypoint-initdb.d/3_data.sql && \
    mv routines.sql /docker-entrypoint-initdb.d/4_routines.sql && \
    /usr/local/bin/docker-entrypoint.sh mysqld --datadir /initialized-db --aria-log-dir-path /initialized-db && \
    rm /docker-entrypoint-initdb.d/1_tables.sql /docker-entrypoint-initdb.d/2_lookups.sql /docker-entrypoint-initdb.d/3_data.sql /docker-entrypoint-initdb.d/4_routines.sql && \
    apt-get clean autoclean && apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/*

FROM mariadb:latest
COPY --from=builder /initialized-db /var/lib/mysql
