#!/usr/bin/env python3

import sys
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import time

class FileChangeHandler(FileSystemEventHandler):
    def __init__(self, filename, command):
        self.filename = filename
        self.command = command
        self.process = None
        self.start_process()

    def on_modified(self, event):
        if not event.is_directory and event.src_path.endswith(self.filename):
            self.restart_process()

    def start_process(self):
        self.process = subprocess.Popen(self.command, shell=True)

    def stop_process(self):
        if self.process:
            self.process.terminate()
            self.process = None

    def restart_process(self):
        self.stop_process()
        time.sleep(1)
        self.start_process()

if __name__ == "__main__":
    print(sys.argv)
    if len(sys.argv) != 3:
        print("Usage: watch.py <filename> <command>")
        sys.exit(1)

    filename = sys.argv[1]
    command = sys.argv[2]

    event_handler = FileChangeHandler(filename, command)
    observer = Observer()
    observer.schedule(event_handler, '.', recursive=False)
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()

    observer.join()