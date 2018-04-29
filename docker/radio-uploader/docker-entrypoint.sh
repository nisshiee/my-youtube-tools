#!/usr/bin/env bash

set -ex

if [ $# -eq 2 ]; then
  cd /tmp
  python /download-webm.py "$1"
  aws s3 cp out.webm "$2"
else
  cat <<USAGE
Usage
  docker run https://www.youtube.com/watch?v=xxxxxxxxxx s3://bucket/path/to/upload.webm
USAGE
fi
