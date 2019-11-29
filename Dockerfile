# Build Phase
FROM golang:1.13-alpine

ENV RESTIC_VERSION="0.9.6"

# Install the items
RUN apk update \
  && apk add ca-certificates wget gnupg git \
  && update-ca-certificates \
  && wget -qO /tmp/restic-${RESTIC_VERSION}.tar.gz "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic-${RESTIC_VERSION}.tar.gz" \
  && cd /tmp \
  && tar -xf /tmp/restic-${RESTIC_VERSION}.tar.gz -C /tmp/ \
  && cd /tmp/restic-${RESTIC_VERSION} \
  && go run build.go \
  && mv restic /go/bin/restic \
  && rm -rf /tmp/restic* /var/cache/apk/*


# Release phase
FROM golang:1.11-alpine

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
COPY --from=0 /go/bin/restic /go/bin/restic
ADD ./target/start_cron.sh /go/bin
ADD ./target/supervisor_restic.ini /etc/supervisor.d/restic.ini

RUN apk update && \
    apk add ca-certificates fuse gnupg openssh supervisor && \
    chmod +x /go/bin/start_cron.sh && \
    mkdir -p /var/log/supervisor && \
    rm -rf /var/cache/apk/*

# Start the process
CMD supervisord -c /etc/supervisord.conf

