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
	potential_command="$pipenv_root/bin/$PYENV_COMMAND"
	if ! [ -x "$potential_command" ]; then
	  version_name="$(pyenv version-name)"
	  if [ "$version_name" = "system" ]; then
	    potential_command="$(get_system_command $PYENV_COMMAND)"
	  else
	    potential_command="$PYENV_ROOT/versions/$version_name/bin/$PYENV_COMMAND"
	  fi
	fi

	if [ -x "$potential_command" ]; then
	  PYENV_COMMAND_PATH="$potential_command"
	fi

	break
      fi
    fi
    root="${root%/*}"
  done
}

if [ -z "$DISABLE_BINSTUBS" ]; then
  user_command="$(get_userbase)/bin/$PYENV_COMMAND"
  if [ -x "$user_command" ]; then
    PYENV_COMMAND_PATH="$user_command"
  fi

  PIPENV_COMMAND="$(get_pipenv)"
  if [ -x "$PIPENV_COMMAND" ]; then
    check_for_binstubs
  fi
fi
