# Init pipenv and add a few basics
# -------------------------------------------
pipenv --python 3.8.1
pipenv install -d flake8 yapf pylint ipykernel pre-commit
pipenv install pyyaml

# Initialise the linting and style settings
# -------------------------------------------
touch .style.yapf
echo '[style]
# https://github.com/google/yapf#knobs
based_on_style = pep8
column_limit = 99' > .style.yapf

touch .flake8
echo '[flake8]
# https://flake8.pycqa.org/en/latest/user/options.html
ignore = E133,E501,W503
max-line-length = 80
max-complexity = 15
select = B,C,E,F,W,T4,B9,Q0' > .flake8

touch .pylintrc
echo '[MASTER]
init-hook="from pylint.config import find_pylintrc;
import os, sys; sys.path.append(os.path.dirname(find_pylintrc()))"
' > .pylintrc

touch .mypy.ini
echo '[mypy]
warn_return_any = True
warn_unused_configs = True

[mypy-src.*]
ignore_missing_imports = True' > .mypy.ini

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
logger = logging.getLogger(__name__)' > src/main.py


# Configuration and Settings
# -------------------------------------------
CONFIGDIR=src/_config
mkdir $CONFIGDIR

echo "__all__ = ['logging', 'settings']

from .logging import configureLogging
from .settings import loadSettings, saveSettings
" > $CONFIGDIR/__init__.py

# Logging Configs
# -------------------------------------------

echo "import logging.config
from pathlib import Path

import yaml

DIR = Path(__file__).parent.absolute()
LOGPATH = DIR.parent.parent / 'logs'


def configureLogging():
    \"\"\".\"\"\"
    Path(LOGPATH).mkdir(exist_ok=True)
    mainfilename = LOGPATH / 'main.log'
    debugfilename = LOGPATH / 'debug.log'

    with open(DIR / 'logging.yaml', 'r') as f:
        log_cfg = yaml.full_load(f)

    log_cfg['handlers']['file_handler']['filename'] = mainfilename
    log_cfg['handlers']['rotating_handler']['filename'] = debugfilename

    logging.config.dictConfig(log_cfg)

    # Set ERROR level logging on verbose modules
    modules = ['botocore', 'urllib3', 'googleapiclient']
    for module in modules:
        logging.getLogger(module).setLevel(logging.ERROR)
" > $CONFIGDIR/logging.py

touch $CONFIGDIR/logging.yaml
echo "---
version: 1
disable_existing_loggers: false
formatters:
  simple:
    format: '%(asctime)s - %(name)s - %(levelname)s - %(message)s'

handlers:
  console:
    class: logging.StreamHandler
    formatter: simple
    level: ERROR
    stream: ext://sys.stdout

  file_handler:
    class: logging.FileHandler
    formatter: simple
    level: ERROR
    filename: ''
    encoding: 'utf8'

  rotating_handler:
    class: logging.handlers.RotatingFileHandler
    formatter: simple
    level: DEBUG
    filename: ''
    maxBytes: 200000
    backupCount: 1
    encoding: 'utf8'

root:
  level: DEBUG
  handlers: [console, file_handler, rotating_handler]
" > $CONFIGDIR/logging.yaml

# Settings file tools
# -------------------------------------------
echo "from pathlib import Path

import yaml

DIR = Path(__file__).parent.parent
SETTINGS_PATH = Path(DIR).absolute()


def saveSettings(settings: dict, settings_path: Path = SETTINGS_PATH) -> None:
    settings_path.mkdir(exist_ok=True, parents=True)
    with open(settings_path / 'settings.yaml', 'w') as f:
        yaml.dump(settings, f)


def loadSettings(settings_path: Path = SETTINGS_PATH) -> dict:
    if (not (settings_path / 'settings.yaml').exists()):
        saveSettings({})
    with open(settings_path / 'settings.yaml', 'r') as f:
        settings = yaml.full_load(f)
    return settings


def updateSettings(settings: dict, update: dict):
    settings.update(update)
    saveSettings(settings)


" > $CONFIGDIR/settings.py

touch src/settings.yaml
echo '---' > src/settings.yaml

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
" > .vscode/settings.json


# \"python.formatting.yapfArgs\": [\"--fixers\", \"quotes\", \"--force-quote-type\", \"single\"],

# Init files
echo "
# Project Name

```text
awesome name style
```

badges

## Table of Contents

- [Project Name](#project-name)
  - [Table of Contents](#table-of-contents)
  - [About The Project](#about-the-project)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
  - [Usage](#usage)
  - [Roadmap](#roadmap)
  - [Contributing](#contributing)
  - [License](#license)
  - [Contact](#contact)
  - [Acknowledgements](#acknowledgements)

## About The Project

template

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

This is an example of how to list things you need to use the software and how to install them.

```sh
e.g.
```

### Installation

1. Clone the repo

```sh
e.g.
```

## Usage

Examples

_For more examples, please refer to the [Documentation](https://)_

## Roadmap

See the [open issues](https://) for a list of proposed features (and known issues).

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.

## License

None. See `LICENSE` for more information.

## Contact

Your Name - [@](https://twitter.com/) - email

Project Link: [https://](https://)

## Acknowledgements

- [blank](link)
" > README.md
touch .env

# Git repository
# -------------------------------------------
touch .gitignore
echo  '.pyc \n__pycache__ \nlogs' > .gitignore

# git init
# git add -A
# git commit -m "first commit"