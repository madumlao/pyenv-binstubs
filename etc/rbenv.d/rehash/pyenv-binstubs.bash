#!/usr/bin/env bash

register_binstubs()
{
  local root
  local potential_path
  if [ "$1" ]; then
    root="$1"
  else
    root="$PWD"
  fi
  while [ -n "$root" ]; do
    if [ -f "$root/Pipfile" ]; then
      potential_path="$(cd $root; pipenv --venv 2>/dev/null)"
      if [ -d "$potential_path" ]; then
        for shim in "$potential_path"/bin/*; do
          if [ -x "$shim" ]; then
            register_shim "${shim##*/}"
          fi
        done
      fi
      break
    fi
    root="${root%/*}"
  done
}

register_bundles ()
{
  # go through the list of bundles and run make_shims
  if [ -f "${PYENV_ROOT}/bundles" ]; then
    OLDIFS="${IFS:-$' \t\n'}"
    IFS=$'\n' bundles=(`cat ${PYENV_ROOT}/bundles`)
    IFS="$OLDIFS"
    for bundle in "${bundles[@]}"; do
      bundle_root="$(echo $bundle|cut -f 1 -d :)"
      register_binstubs "$bundle_root"
    done
  fi
}

register_user_binstubs()
{
  potential_path="$(get_userbase)/bin"
  for shim in $potential_path/*; do
    # potential_path is executable AND a python script
    if [ -x "$shim" ] && head -n1 "$shim" | grep -q '^#.*python'; then
      register_shim "${shim##*/}"
    fi
  done
}

add_to_bundles ()
{
  local root
  if [ "$1" ]; then
    root="$1"
  else
    root="$PWD"
  fi

  # look for the deepest parent that has a Pipfile
  until [ -f "$root/Pipfile" ]; do
    if [ -z "$root" ]; then break; fi
    root="${root%/*}"
  done
  # also check for Pipfile in /
  if ! [ -f "$root/Pipfile" ]; then root="/"; fi

  # no pipfile found, ignore
  if ! [ -f "$root/Pipfile" ]; then return; fi

  # update the list of bundles to remove any stale ones
  local new_bundle
  new_bundle=true
  new_bundles=${PYENV_ROOT}/bundles.new.$$
  : > $new_bundles
  if [ -s ${PYENV_ROOT}/bundles ]; then
    OLDIFS="${IFS:-$' \t\n'}"
    IFS=$'\n' bundles=(`cat ${PYENV_ROOT}/bundles`)
    IFS="$OLDIFS"
    for bundle in "${bundles[@]}"; do
      bundle_root="$(echo $bundle|cut -f 1 -d :)"
      pipenv_root="$(echo $bundle|cut -f 2 -d :)"
      if [ "X$bundle_root" = "X$root" ]; then
        new_bundle=false
      fi
      if [ -f "$bundle_root/Pipfile" ]; then
        pipenv_root="$(cd $bundle_root; pipenv --venv 2>/dev/null)"
        echo "$bundle_root:$pipenv_root" >> $new_bundles
      fi
    done
  fi
  if [ "$new_bundle" = "true" ]; then
    # add the given path to the list of bundles
    echo "$root:$($PIPENV_COMMAND --venv)" >> $new_bundles
  fi
  mv -f $new_bundles ${PYENV_ROOT}/bundles
}

PIPENV_COMMAND="$(get_pipenv)"
if [ -z "$DISABLE_BINSTUBS" ] && [ -x "$PIPENV_COMMAND" ]; then
  add_to_bundles
  register_bundles
  register_user_binstubs
fi

