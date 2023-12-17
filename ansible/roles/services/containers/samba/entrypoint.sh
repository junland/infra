#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (C) 2023 John Unland

# Make sure samba user exists, exit if it does not.
if ! getent passwd samba >/dev/null 2>&1; then
    echo "samba user does not exist, exiting"
    exit 1
fi
# Make sure samba group exists, exit if it does not.
if ! getent group samba >/dev/null 2>&1; then
    echo "samba group does not exist, exiting"
    exit 1
fi

# Create share directory if it does not exist.
if [ ! -d /share ]; then
    mkdir /share
fi

# Make sure share directory is owned by samba user and group.
chown samba:samba /share

# Make sure share directory is writable by samba user.
chmod 770 /share

# Start samba in the foreground.
exec /usr/sbin/smbd --foreground --no-process-group --configfile=/etc/samba/smb.conf
