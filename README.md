# pyenv-binstubs: A Pipenv Plugin for pyenv

This plugin makes [pyenv](http://github.com/pyenv/pyenv/) transparently
aware of project-specific venv binaries created by [pipenv](https://pypi.python.org/pypi/pipenv).

This means you don't have to type `pipenv run ${command}` ever again!

## Installation

To install pyenv-binstubs, clone this repository into your ~/.pyenv/plugins directory.

    $ git clone https://github.com/ianheggie/pyenv-binstubs.git "$(pyenv root)/plugins/pyenv-binstubs"

Then for each application directory run the following just once:

    $ pipenv install [other stuff]

Normally, pipenv takes care of provisioning / linking to a virtualenv. However, to use the virtualenv, you have to spawn a pipenv subshell or use pipenv run. What a pain!

pipenv-binstubs simplifies this by detecting that a pipenv virtualenv exists, and using the pyenv-generated shims to forward to the executables in the virtualenv.

## Usage

Simply type the name of the command you want to run! Thats all folks! Eg:

    $ pip --version

This plugin searches from the current directory up towards root for a directory containing a Pipfile.
If such a directory is found, then the plugin checks for the desired command in directory's virtualenv (effectively running 'pipenv run'), then in its python version.

To confirm that the pipenv binary is being used, run the command:

    $ pyenv which COMMAND

To show which package pip will use, run the command:

    $ pip show PACKAGE

You can disable the searching for pipenv binaries by setting the environment variable DISABLE\_BINSTUBS to a non empty string:

    $ DISABLE_BINSTUBS=1 pyenv which command

You can list the bundles (project directories) and their associated virtualenv directories using the command:
    
    $ pyenv bundles

## License

Copyright (c) 2018 Mark Dumlao - Released under the same terms as [rbenv's MIT-License](https://github.com/rbenv/rbenv#license)

## Contributors

Thanks go to:

* [ianheggie](https://github.com/ianheggie) pyenv-binstubs was forked from his rbenv-binstubs plugin for rbenv!
* [pyenv](https://github.com/pyenv/pyenv) for pyenv itself
* [sstephenson](https://github.com/rbenv/rbenv) for rbenv
