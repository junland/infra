#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2023 John Unland

VIRTD_CMDS="virtd libvird virtchd virtinterfaced virtlockd virtlogd virtlxcd virtnetworkd virtnodedevd virtnwfilterd virtproxyd virtqemud virtsecred virtstoraged virtvboxd virtxend"
EXEC_CMD=$1

# If no command is passed, exit.
if [ -z "$EXEC_CMD" ]; then
    echo "No command passed, exiting"
    exit 1
fi

# Evaluate if command is in the list of virtd commands.
if ! echo "$VIRTD_CMDS" | grep -qx "$EXEC_CMD"; then
    echo "Command $EXEC_CMD is not a virtd command, exiting"
    exit 1
fi

# if virtd is passed as the first command, it will actually be libvirtd instead.
if [ "$EXEC_CMD" = "virtd" ]; then
    EXEC_CMD="libvirtd"
fi

# Make sure command exists.
if ! command -v "$EXEC_CMD" >/dev/null 2>&1; then
    echo "Command $EXEC_CMD does not exist, exiting"
    exit 1
fi

# Now set the command with the full path.
EXEC_CMD=$(command -v "$EXEC_CMD")

# Run the command with the rest of the arguments passed to this script. but ignore the first argument.
exec "$EXEC_CMD" "${@:2}"
