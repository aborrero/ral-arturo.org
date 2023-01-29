#!/bin/bash

set -ex

rm -f Gemfile
echo 'source "https://rubygems.org"' >> Gemfile
echo 'gem "jekyll"' >> Gemfile
echo 'gem "jekyll-paginate"' >> Gemfile

docker run --rm --volume="$PWD:/site" -p 4000:4000 bretfisher/jekyll-serve
