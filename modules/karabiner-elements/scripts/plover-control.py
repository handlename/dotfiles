#!/usr/bin/env python3
import os
import sys
import tempfile
from multiprocessing.connection import Client


def main():
    if len(sys.argv) < 2:
        return

    command = sys.argv[1]
    socket_path = os.path.join(tempfile.gettempdir(), "plover_socket")

    if not os.path.exists(socket_path):
        return

    try:
        with Client(socket_path, "AF_UNIX", authkey=b"plover") as conn:
            conn.send(("command", command))
    except Exception:
        pass


if __name__ == "__main__":
    main()
