#!/bin/sh

rm -rf dist/*

cp public/* dist
parcel build src/* -d dist --public-url '.'
