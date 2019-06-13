#!/bin/sh

rm -rf dist/*

# dummy
touch dist/sw.js

parcel build src/* -d dist --public-url '.'
