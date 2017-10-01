# docker-restic

[![Docker Pulls](https://img.shields.io/docker/pulls/jsmitsnl/docker-restic.svg)](https://hub.docker.com/r/jsmitsnl/docker-restic/) [![Docker layers](https://images.microbadger.com/badges/image/jsmitsnl/docker-restic.svg)](https://microbadger.com/images/jsmitsnl/docker-restic) [![Github Stars](https://img.shields.io/github/stars/johansmitsnl/docker-restic.svg?label=github%20%E2%98%85)](https://github.com/johansmitsnl/docker-restic/) [![Github Stars](https://img.shields.io/github/contributors/johansmitsnl/docker-restic.svg)](https://github.com/johansmitsnl/docker-restic/) [![Github Forks](https://img.shields.io/github/forks/johansmitsnl/docker-restic.svg?label=github%20forks)](https://github.com/johansmitsnl/docker-restic/)

Restic is a fantastic backup tool. To wrap this in a usefull and flexible docker container there is this repo.

Includes:

* [restic](https://github.com/restic/restic)
* cron (for scheduling)

----

## Usage

#### Get latest image
You can run restic command very like this:

```bash
docker pull jsmitsnl/docker-restic:latest
```

```bash
docker run --rm -e RESTIC_REPOSITORY="s3:https://s3.amazonaws.com/some-repo" \
                -e AWS_ACCESS_KEY_ID="keyid" \
                -e AWS_SECRET_ACCESS_KEY="topsecret" \
                -e RESTIC_PASSWORD="some_good_hash" jsmitsnl/docker-restic \
                -v /:/data
                restic snapshots
```


#### Create a `docker-compose.yml`

Adapt this file with your FQDN. Install [docker-compose](https://docs.docker.com/compose/) in the version `1.6` or higher.

`restart: always` ensures that the restic server container is automatically restarted by Docker in cases like a Docker service or host restart or container exit.

```yaml
version: '2'

services:
  restic:
    restart: always
    image: jsmitsnl/docker-restic:latest
    hostname: backup
    domainname: domain.com
    container_name: restic
    volumes:
      - /:/data
    environment:
      - RESTIC_BACKUP_OPTIONS="--exclude=/data/dir/*"
      - RESTIC_REPOSITORY="s3:https://s3.amazonaws.com/some-repo"
      - AWS_ACCESS_KEY_ID="keyid"
      - AWS_SECRET_ACCESS_KEY="topsecret"
      - RESTIC_PASSWORD="some_good_hash"
```

----

## Examples

__Listed in these examples are also the defaults__

__to change the backup times__:

For example you want to run the backup every day at 03:15.

```yaml
version: '2'

services:
  restic:
    restart: always
    image: jsmitsnl/docker-restic:latest
    hostname: backup
    domainname: domain.com
    container_name: restic
    volumes:
      - /:/data
    environment:
      - CRON_BACKUP_EXPRESSION="15   3  *   *   *"
      - RESTIC_BACKUP_OPTIONS="--exclude=/data/dir/*"
      - RESTIC_REPOSITORY="s3:https://s3.amazonaws.com/some-repo"
      - AWS_ACCESS_KEY_ID="keyid"
      - AWS_SECRET_ACCESS_KEY="topsecret"
      - RESTIC_PASSWORD="some_good_hash"
```


__to change the clean times and periods__:

For example you want to run the backup every day at 00:00

```yaml
version: '2'

services:
  restic:
    restart: always
    image: jsmitsnl/docker-restic:latest
    hostname: backup
    domainname: domain.com
    container_name: restic
    volumes:
      - /:/data
    environment:
      - CRON_CLEANUP_EXPRESSION="0   0  *   *   *"
      - RESTIC_CLEANUP_KEEP_WEEKLY=5
      - RESTIC_CLEANUP_KEEP_MONTHLY=12
      - RESTIC_CLEANUP_KEEP_YEARLY=75
      - RESTIC_CLEANUP_OPTIONS="--prune"
      - RESTIC_BACKUP_OPTIONS="--exclude=/data/dir/*"
      - RESTIC_REPOSITORY="s3:https://s3.amazonaws.com/some-repo"
      - AWS_ACCESS_KEY_ID="keyid"
      - AWS_SECRET_ACCESS_KEY="topsecret"
      - RESTIC_PASSWORD="some_good_hash"
```

#### Start the container

    docker-compose up -d mail

You're done!

----

## Commands to start with

A full explanation of the commands and options you can refer to the [manual](https://restic.readthedocs.io/en/stable/index.html) of [restic](https://github.com/restic/restic)

#### Initialize the repository

```bash
docker run --rm -e RESTIC_REPOSITORY="s3:https://s3.amazonaws.com/some-repo" \
                -e AWS_ACCESS_KEY_ID="keyid" \
                -e AWS_SECRET_ACCESS_KEY="topsecret" \
                -e RESTIC_PASSWORD="some_good_hash" jsmitsnl/docker-restic \
                -v /:/data
                restic init
```


#### List the snapshots

```bash
docker run --rm -e RESTIC_REPOSITORY="s3:https://s3.amazonaws.com/some-repo" \
                -e AWS_ACCESS_KEY_ID="keyid" \
                -e AWS_SECRET_ACCESS_KEY="topsecret" \
                -e RESTIC_PASSWORD="some_good_hash" jsmitsnl/docker-restic \
                -v /:/data
                restic snapshots
```



#### Restore a snapshot

```bash
docker run --rm -e RESTIC_REPOSITORY="s3:https://s3.amazonaws.com/some-repo" \
                -e AWS_ACCESS_KEY_ID="keyid" \
                -e AWS_SECRET_ACCESS_KEY="topsecret" \
                -e RESTIC_PASSWORD="some_good_hash" jsmitsnl/docker-restic \
                -v /:/data
                restic restore _id_ --target /data/restore_location
```

#### Start a backup now when the container is running with the name _restic_

```bash
docker exec restic supervisorctl start restic_backup
```



## Environment variables

#### RESTIC_BACKUP_OPTIONS

  - **""** => None set by default

#### RESTIC_CLEANUP_KEEP_DAILY

  - **7** => to keep 7 daily backups

#### RESTIC_CLEANUP_KEEP_WEEKLY

  - **5** => to keep 5 daily backups

#### RESTIC_CLEANUP_KEEP_MONTHLY

  - **12** => to keep 12 daily backups

#### RESTIC_CLEANUP_KEEP_YEARLY

  - **75** => to keep 75 daily backups

#### RESTIC_CLEANUP_OPTIONS

  - **"--prune"** => Clean the repository of old backups

#### CRON_BACKUP_EXPRESSION

  - **"15   3  *   *   *"** => Fire at 03:15 every day

#### CRON_CLEANUP_EXPRESSION

  - **"15  0  0   *   *"** => Fire at 00:15 on the first day of every month
