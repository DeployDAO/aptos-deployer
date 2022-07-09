# Aptos Deployer

Module containing helpers for deploying resource accounts.

Resource accounts allow the module to sign as itself on-chain, which is useful for actions such as Coin initialization.

# Usage

Tooling to make this module easier to use is a work in progress. For now, one can perform the following steps:

1. Create a new public/private keypair via `aptos key generate`.
2. Call `Deployer::create_resource_account_with_auth_key` with the generated public key.
3. Upload your module via `aptos move publish`.
4. Call `Deployer::acquire_signer_capability` from an initialization function in your module. You will need to provide the private key as a signer.
5. Call `Deployer::freeze_account` to deactivate the private key.

## Installation

To use Deployer in your code, add the following to the `[addresses]` section of your `Move.toml`:

```toml
[addresses]
Deployer = "0xcf43589ea2a37ecab7c39657db15939e23e93972bc0481b51c4797c1f2d78a75"
```

## License

Apache-2.0
