#! /usr/bin/env bash

testdir="$(dirname "${BASH_SOURCE[0]}")"

# create a new search directory to test with commands like `getent` broken
hole="$testdir/$(mktemp -d)"
export PATH="$hole:$PATH"

disable_posix () {
  mv node_modules/posix node_modules/posix~
}
disable_getent () {
  touch "$hole/getent"
  chmod -x "$hole/getent"
}

cleanup () {
  # reverse disable_posix
  # If there's a backed-up posix module to cleanup
  if [[ -e node_modules/posix~ ]]; then
    # if the real posix module exists (maybe it was reinstalled?)
    if [[ -e node_modules/posix ]]; then
      # delete the backed up module
      rm -rf node_modules/posix~
    # if the real posix module is missing (what we'd expect)
    else
      # move the backed-up module back to the original location
      mv node_modules/posix~ node_modules/posix
    fi
  fi

  # clean up temporary directories
  rm -r "$hole"
}

catch () {
  echo "Error on line $1"
  cleanup
  exit 1
}

trap 'catch $LINENO' ERR

test_user () {
  [ "$(node "$testdir/bin/getUser.js" "$1")" == "$1 $2" ]
  [ "$(node "$testdir/bin/getUser.js" "$2")" == "$1 $2" ]
  [ "$(node "$testdir/bin/getUserSync.js" "$1")" == "$1 $2" ]
  [ "$(node "$testdir/bin/getUserSync.js" "$2")" == "$1 $2" ]
}

test_group () {
  [ "$(node "$testdir/bin/getGroup.js" "$1")" == "$1 $2" ]
  [ "$(node "$testdir/bin/getGroup.js" "$2")" == "$1 $2" ]
  [ "$(node "$testdir/bin/getGroupSync.js" "$1")" == "$1 $2" ]
  [ "$(node "$testdir/bin/getGroupSync.js" "$2")" == "$1 $2" ]
}

stress_test_user () {
  test_user "$@"
}

stress_test_group () {
  test_group "$@"
}


test_user "$USER" "$UID"
test_group "$(id -gn)" "$(id -g)"
# TODO: test every user/group we can get from getent

cleanup
