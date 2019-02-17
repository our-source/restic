FROM golang:1.11-alpine
MAINTAINER Johan Smits <johan@smitsmail.net>

ENV RESTIC_VERSION="0.9.4"

# Backup options
ENV RESTIC_BACKUP_OPTIONS=""

# Cleanup params
ENV RESTIC_CLEANUP_KEEP_DAILY=7
ENV RESTIC_CLEANUP_KEEP_WEEKLY=5
ENV RESTIC_CLEANUP_KEEP_MONTHLY=12
ENV RESTIC_CLEANUP_KEEP_YEARLY=75
ENV RESTIC_CLEANUP_OPTIONS="--prune"

# Default interval times can be set in cron expression
# Fire at 03:15 every day
ENV CRON_BACKUP_EXPRESSION="15   3  *   *   *"
# Fire at 00:15 on the first day of every month
ENV CRON_CLEANUP_EXPRESSION="15  0  0   *   *"

# Script and config
ADD ./target/start_cron.sh /go/bin
ADD ./target/supervisor_restic.ini /etc/supervisor.d/restic.ini

# Install the items
RUN apk update \
  && apk add ca-certificates wget supervisor gnupg \
  && update-ca-certificates \
  && wget -O /tmp/restic-${RESTIC_VERSION}.tar.gz "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic-${RESTIC_VERSION}.tar.gz" \
  && cd /tmp \
  && tar -xf /tmp/restic-${RESTIC_VERSION}.tar.gz -C /tmp/ \
  && cd /tmp/restic-${RESTIC_VERSION} \
  && go run build.go \
  && mv restic /go/bin/restic \
  && chmod +x /go/bin/start_cron.sh \
  && cd / \
  && mkdir -p /var/log/supervisor \
  && rm -rf /tmp/restic* /var/cache/apk/*

# Start the process
CMD supervisord -c /etc/supervisord.conf

