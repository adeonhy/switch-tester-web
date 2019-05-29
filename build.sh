#!/bin/sh

rm -rf dist/*

parcel build src/* -d dist --public-url '.'
