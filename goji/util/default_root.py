import os
from pathlib import Path

DEFAULT_ROOT_PATH = Path(os.path.expanduser(os.getenv("GOJI_ROOT", "~/.goji/mainnet"))).resolve()

DEFAULT_KEYS_ROOT_PATH = Path(os.path.expanduser(os.getenv("GOJI_KEYS_ROOT", "~/.goji_keys"))).resolve()
