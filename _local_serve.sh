#!/bin/bash

set -ex

rm -f Gemfile
echo 'source "https://rubygems.org"' >> Gemfile
echo 'gem "jekyll"' >> Gemfile
echo 'gem "jekyll-paginate"' >> Gemfile

podman run --rm --volume="$PWD:/site" -p 4000:4000 docker.io/bretfisher/jekyll-serve
