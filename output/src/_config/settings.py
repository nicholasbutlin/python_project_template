from pathlib import Path

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


