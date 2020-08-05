import logging.config
from pathlib import Path

DIR = Path(__file__).parent.absolute()
LOGPATH = f'{DIR.parent.parent}/logs'


def addDebugHandler(debugfilename):
    .
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
    .
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

