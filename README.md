# Ruby script for updating AVCHD (MTS,M2TS, etc) movies creation date timestamp on Flickr

## Why?
When a movie is uploaded to Flickr, creation timestamp is taken from its metadata. Flickr's ability to export AVCHD metadata is limited so it falls back to using upload date. This leads to movies being displayed in incorrect order when sorting by date taken.
## What it does?
This script fetches file modification date from original local files and updates 'date taken' attribute of videos previously uploaded to Flickr. The match between local and uploaded files is done by name. A local folder corresponds to a Flickr album.
## How it works?

## Prerequisites
-Ruby runtime environment
-Original movie files available by local path with unchaged names
-Movie titles on Flickr reflect original file names (default behaviour)
