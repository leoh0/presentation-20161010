#!/usr/bin/env bash

docker run --rm -v $(pwd)/md/:/revealjs/md/ -p 8000:8000 leoh0/revealjs-docker-base
