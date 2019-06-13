#!/bin/sh

rm -rf dist/*

cp -a public/* dist
parcel build src/* -d dist --public-url '.'
