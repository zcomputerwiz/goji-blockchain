from typing import KeysView, Generator

SERVICES_FOR_GROUP = {
    "all": "goji_harvester goji_timelord_launcher goji_timelord goji_farmer goji_full_node goji_wallet".split(),
    "node": "goji_full_node".split(),
    "harvester": "goji_harvester".split(),
    "farmer": "goji_harvester goji_farmer goji_full_node goji_wallet".split(),
    "farmer-no-wallet": "goji_harvester goji_farmer goji_full_node".split(),
    "farmer-only": "goji_farmer".split(),
    "timelord": "goji_timelord_launcher goji_timelord goji_full_node".split(),
    "timelord-only": "goji_timelord".split(),
    "timelord-launcher-only": "goji_timelord_launcher".split(),
    "wallet": "goji_wallet goji_full_node".split(),
    "wallet-only": "goji_wallet".split(),
    "introducer": "goji_introducer".split(),
    "simulator": "goji_full_node_simulator".split(),
}


def all_groups() -> KeysView[str]:
    return SERVICES_FOR_GROUP.keys()


def services_for_groups(groups) -> Generator[str, None, None]:
    for group in groups:
        for service in SERVICES_FOR_GROUP[group]:
            yield service


def validate_service(service: str) -> bool:
    return any(service in _ for _ in SERVICES_FOR_GROUP.values())
