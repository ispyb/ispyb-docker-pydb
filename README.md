# ispyb-docker-pydb

A prepopulated mariadb ready for use with https://github.com/ispyb/py-ispyb for development and testing.

## Building

```bash
docker build -t ispyb-pydb .
```

Prebuilt images are available from ispyb on dockerhub: https://hub.docker.com/r/ispyb/ispyb-pydb

## Running

```bash
docker run --name mariadb ispyb-pydb
```

## Using

Two users are available:

-   Normal user:

    -   Login: `abcd`
    -   Password: Anything but not empty.

-   Admin user:
    -   Login: `efgh`
    -   Password: Anything but not empty.

Proposal name is `blc00001` and session is `blc00001-1`.
