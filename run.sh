#!/bin/bash
sudo docker run -dp 3939:3939 -p 3940:3940 -e SQLITE_URI="/sqldata/db.sqlite" -e RUST_BACKTRACE=1 archpad
