# Init pipenv and add a few basics
# -------------------------------------------
pipenv --three
pipenv install -d flake8 yapf pylint ipykernel
pipenv install pyyaml

# Initialise the linting and style settings
# -------------------------------------------
touch .style.yapf
echo '[style]
# https://github.com/google/yapf#knobs
based_on_style = pep8
column_limit = 99' >> .style.yapf

touch .flake8
echo '[flake8]
# https://flake8.pycqa.org/en/latest/user/options.html
ignore = E133,E501,W503
max-line-length = 80
max-complexity = 15
select = B,C,E,F,W,T4,B9,Q0' >> .flake8

touch .pylintrc
echo '[MASTER]
init-hook="from pylint.config import find_pylintrc;
import os, sys; sys.path.append(os.path.dirname(find_pylintrc()))"
' >> .pylintrc

touch .mypy.ini
echo '[mypy]
warn_return_any = True
warn_unused_configs = True

[mypy-src.*]
ignore_missing_imports = True' >> .mypy.ini

# Initialise folder structure
# -------------------------------------------
mkdir src
touch src/__init__.py

touch src/main.py
echo '"""
Module Description.


"""
import logging

from _config import configureLogging

configureLogging()
logger = logging.getLogger(__name__)' >> src/main.py


# Configuration and Settings
# -------------------------------------------
CONFIGDIR=src/_config
mkdir $CONFIGDIR

echo "__all__ = ['logging', 'settings']

from .logging import configureLogging
from .settings import loadSettings, saveSettings
" >> $CONFIGDIR/__init__.py

# Logging Configs
# -------------------------------------------

echo "import logging.config
from pathlib import Path

DIR = Path(__file__).parent.absolute()
LOGPATH = f'{DIR.parent.parent}/logs'


def addDebugHandler(debugfilename):
    """."""
    dHandler = logging.handlers.RotatingFileHandler(debugfilename,
                                                    mode='a',
                                                    maxBytes=200000,
                                                    backupCount=1,
                                                    encoding=None,
                                                    delay=False)

    dFormatter = logging.Formatter('{asctime} - {name} - {levelname:8s} - {message}', style='{')
    dHandler.setFormatter(dFormatter)
    logging.getLogger().addHandler(dHandler)


def configureLogging():
    """."""
    Path(LOGPATH).mkdir(exist_ok=True)
    mainfilename = Path(f'{LOGPATH}/main.log')

    logging.config.fileConfig(fname=Path(f'{DIR}/logging.cfg'),
                              defaults={
                                  'mainfilename': mainfilename,
                              },
                              disable_existing_loggers=False)

    debugfilename = Path(f'{LOGPATH}/debug.log')
    addDebugHandler(debugfilename)

    # Set ERROR level logging on verbose modules
    modules = ['botocore', 'urllib3', 'googleapiclient']
    for module in modules:
        logging.getLogger(module).setLevel(logging.ERROR)
" >> $CONFIGDIR/logging.py

touch $CONFIGDIR/logging.cfg
echo "[loggers]
keys=root

[handlers]
keys=consoleHandler,fileHandler

[formatters]
keys=simpleFormatter

[logger_root]
level=DEBUG
handlers=consoleHandler,fileHandler

[handler_consoleHandler]
class=StreamHandler
level=DEBUG
formatter=simpleFormatter
args=(sys.stdout,)

[handler_fileHandler]
class=FileHandler
level=DEBUG
formatter=simpleFormatter
args=('%(mainfilename)s','a','utf8')


[formatter_simpleFormatter]
format=%(asctime)s - %(name)s - %(levelname)s - %(message)s" >> $CONFIGDIR/logging.cfg

# Settings file tools
# -------------------------------------------
echo "from pathlib import Path

import yaml

DIR = Path(__file__).parent.parent
SETTINGS_PATH = Path(f'{DIR}/settings.yaml').absolute()


def saveSettings(settings) -> None:
    with open(SETTINGS_PATH, 'w') as f:
        yaml.dump(settings, f)


def loadSettings() -> dict:
    with open(SETTINGS_PATH, 'r') as f:
        settings = yaml.full_load(f)
    return settings

" >> $CONFIGDIR/settings.py

touch src/settings.yaml
echo '---' >> src/settings.yaml

# vscode settings
# -------------------------------------------
mkdir .vscode
touch .vscode/settings.json

#  get the shell and put in vscode settings...
PIPENV_VENV_PATH=$(pipenv --venv)
echo "{
  \"python.pythonPath\": \"$PIPENV_VENV_PATH\",
  \"python.formatting.provider\": \"yapf\"
}
" >> .vscode/settings.json

# Init files
touch readme.md
touch .env

# Git repository
# -------------------------------------------
touch .gitignore
echo  '.pyc \n__pycache__ \nlogs' >> .gitignore

git init
git add -A
git commit -m "first commit"