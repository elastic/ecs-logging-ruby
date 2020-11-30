#!/usr/bin/env bash
VERSION=${1:2.7.2}
export PATH="$HOME/.rbenv/bin:$PATH"
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone git@github.com:rbenv/ruby-build.git ~/.rbenv/plugins/ruby-buildCloning into '/var/lib/jenkins/.rbenv/plugins/ruby-build'...
eval "$(rbenv init -)"
rbenv install "${VERSION}"
