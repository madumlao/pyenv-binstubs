remove_from_path() {
  local path_to_remove="$1"
  local path_before
  local result=":${PATH//\~/$HOME}:"
  while [ "$path_before" != "$result" ]; do
    path_before="$result"
    result="${result//:$path_to_remove:/:}"
  done
  result="${result%:}"
  echo "${result#:}"
}

get_system_python()
{
  [ "$(get_system_command python)" ] && get_system_command python || get_system_command python3
}

get_system_pipenv()
{
  get_system_command pipenv
}

get_system_command()
{
  command=$1
  OLDPATH="$PATH"
  PATH="$(remove_from_path "${PYENV_ROOT}/shims")"
  which $command || true
  PATH="$OLDPATH"
}

get_userbase()
{
  $(get_system_python) -c "from __future__ import print_function; import site; print(site.getuserbase())"
}

get_pipenv()
{
  local version_name
  local OLDPATH

  version_name="$(pyenv version-name)"

  # look for pipenv first in python version
  if [ "$version_name" = "system" ]; then
    PIPENV_COMMAND="$(get_system_pipenv)"
  else
    PIPENV_COMMAND="$PYENV_ROOT/versions/$version_name/bin/pipenv"
  fi

  # then in user dir
  if ! [ -x "$PIPENV_COMMAND" ]; then
    PIPENV_COMMAND="$(get_userbase)/bin/pipenv"
  fi

  echo $PIPENV_COMMAND
}
