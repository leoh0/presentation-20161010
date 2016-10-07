#!/usr/bin/env bash

docker run --rm -v $(pwd):/revealjs/md/ -p 8000:8000 leoh0/revealjs-docker-base
