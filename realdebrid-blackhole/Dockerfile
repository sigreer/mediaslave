# Use a base image with necessary tools
FROM alpine:latest

# Install necessary packages: transmission-cli, aria2c, jq, curl, wget, inotify-tools, bash
RUN apk update && apk add --no-cache \
    transmission \
    transmission-cli \
    transmission-extra \
    aria2 \
    jq \
    curl \
    wget \
    inotify-tools \
    bash

# Create a user named 'apps' with UID 568
RUN adduser -D -u 568 apps

# Set the user to 'apps' before copying the script
USER apps

# Copy your shell script into the container
COPY --chown=apps:apps torrent2debrid.sh /usr/local/bin/torrent2debrid.sh

# Copy the transmission-show binary to /usr/local/bin

# Switch back to root to set permissions
USER root

# Make the script executable
RUN chmod u+x /usr/local/bin/torrent2debrid.sh

# Set the user to 'apps' for running the container
USER apps

# Set the working directory
WORKDIR /data

# Export the REALDEBRID_APIKEY for use in the script
ENV REALDEBRID_APIKEY=""

# Set the PATH to include /usr/bin and /usr/local/bin
ENV PATH="/usr/local/bin:/usr/bin:${PATH}"

# Use bash for the CMD
SHELL ["/bin/bash", "-c"]

# Command to check for existing torrent files and then watch for new ones
CMD find /data/torrentfiles -type f -name '*.torrent' -exec /usr/local/bin/torrent2debrid.sh {} /data/downloaded-torrents \; && \
inotifywait -m -e create /data/torrentfiles --format '%f' --exclude '.*[^.torrent]$' | \
while read torrentfile; do \
    /usr/local/bin/torrent2debrid.sh "/data/torrentfiles/$torrentfile" "/data/downloaded-torrents" \
    >> /proc/1/fd/1 2>> /proc/1/fd/2; \
done
