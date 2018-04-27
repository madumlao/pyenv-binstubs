#!/usr/bin/env bash

check_for_binstubs()
{
  local root
  local potential_path
  root="$PWD"
  while [ -n "$root" ]; do
    if [ -f "$root/Pipfile" ]; then
      # check pipenv prefix
      bundles="$PYENV_ROOT/bundles"

      # determine which venv to use from bundles file
      if ! [ -f $bundles ]; then
	pyenv rehash
      fi

      if [ -f $bundles ]; then
	bundle_line="$(egrep "^$root:" $bundles)"
	bundle_root="$(echo $bundle_line | cut -f 1 -d :)"
	pipenv_root="$(echo $bundle_line | cut -f 2 -d :)"
	PYENV_COMMAND_PATH="$pipenv_root/bin/$PYENV_COMMAND"
	if ! [ -x "$PYENV_COMMAND_PATH" ]; then
	  PYENV_COMMAND_PATH="$PYENV_ROOT/versions/$version_name/bin/$PYENV_COMMAND"
	fi
	break
      fi
    fi
    root="${root%/*}"
  done
}

version_name="$(pyenv version-name)"
if [ "$version_name" = "system" ]; then
  echo "TODO: support system python"
  exit
else
  PIPENV_COMMAND="$PYENV_ROOT/versions/$version_name/bin/pipenv"
fi
if [ -z "$DISABLE_BINSTUBS" ] && [ -x "$PIPENV_COMMAND" ]; then
  check_for_binstubs
fi
