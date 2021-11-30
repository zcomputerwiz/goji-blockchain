import click
from goji.util.keychain import supports_keyring_passphrase


@click.command("init", short_help="Create or migrate the configuration")
@click.option(
    "--create-certs",
    "-c",
    default=None,
    help="Create new SSL certificates based on CA in [directory]",
    type=click.Path(),
)
@click.option(
    "--fix-ssl-permissions",
    is_flag=True,
    help="Attempt to fix SSL certificate/key file permissions",
)
@click.option("--testnet", is_flag=True, help="Configure this goji install to connect to the testnet")
@click.option("--set-passphrase", "-s", is_flag=True, help="Protect your keyring with a passphrase")
@click.pass_context
def init_cmd(ctx: click.Context, create_certs: str, fix_ssl_permissions: bool, testnet: bool, **kwargs):
    """
    Create a new configuration or migrate from previous versions to current

    \b
    Follow these steps to create new certificates for a remote harvester:
    - Make a copy of your Farming Machine CA directory: ~/.goji/[version]/config/ssl/ca
    - Shut down all goji daemon processes with `goji stop all -d`
    - Run `goji init -c [directory]` on your remote harvester,
      where [directory] is the the copy of your Farming Machine CA directory
    - Get more details on remote harvester on Goji wiki:
      https://github.com/Goji-Network/goji-blockchain/wiki/Farming-on-many-machines
    """
    from pathlib import Path
    from .init_funcs import init
    from goji.cmds.passphrase_funcs import initialize_passphrase

    set_passphrase = kwargs.get("set_passphrase")
    if set_passphrase:
        initialize_passphrase()

    init(Path(create_certs) if create_certs is not None else None, ctx.obj["root_path"], fix_ssl_permissions, testnet)


if not supports_keyring_passphrase():
    from goji.cmds.passphrase_funcs import remove_passphrase_options_from_cmd

    # TODO: Remove once keyring passphrase management is rolled out to all platforms
    remove_passphrase_options_from_cmd(init_cmd)


if __name__ == "__main__":
    from .init_funcs import goji_init
    from goji.util.default_root import DEFAULT_ROOT_PATH

    goji_init(DEFAULT_ROOT_PATH)