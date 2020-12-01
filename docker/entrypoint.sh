#!/bin/bash
set -x

runRspec(){
  local case=${1:-""}
  local bn=${case}

  if [ -n "${case}" ]; then
    bn="$(basename "${case}")/"
  fi
  if [ -n "${RUBY_VERSION}" ]; then
    bn="$RUBY_VERSION-$bn"
  fi
  if [ -n "${FRAMEWORKS}" ]; then
    bn="$FRAMEWORKS-$bn"
  fi
  bundle exec rspec \
    -f progress \
    -r yarjuf -f JUnit -o "spec/junit-reports/${bn}ruby-agent-junit.xml" ${case}
}

# For debugging purposes
ls -ltra ${GEM_HOME}
find ${GEM_HOME} -type f -ls
whoami
groups


bundle check || (rm Gemfile.lock && bundle)

# If first arg is a spec path, run spec(s)
if [[ $1 == spec/* ]]; then
  runRspec $@
  exit $?
fi

# If no arguments, run all specs
if [[ $# == 0 ]]; then
  runRspec
  exit $?
fi

# Otherwise, run args as command
$@

