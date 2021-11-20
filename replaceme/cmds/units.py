from typing import Dict

# The rest of the codebase uses mojis everywhere.
# Only use these units for user facing interfaces.
units: Dict[str, int] = {
    "goji": 10 ** 12,  # 1 goji (XGJ) is 1,000,000,000,000 moji (1 trillion)
    "moji": 1,
    "colouredcoin": 10 ** 3,  # 1 coloured coin is 1000 colouredcoin mojis
}
