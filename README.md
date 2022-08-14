# Aptos Deployer

Module containing helpers for deploying resource accounts.

Resource accounts allow the module to sign as itself on-chain, which is useful for actions such as Coin initialization.

# Usage

The [aptos-create-resource-account](https://github.com/aptosis/aptos-toolkit/tree/master/crates/aptos-create-resource-account) uses
this module internally. Please read the documentation for that crate for more information.

## Manual creation

One can perform the following steps:

1. Create a new public/private keypair via `aptos key generate`.
2. Call `deployer::create_resource_account` with the generated public key.
3. Upload your module via `aptos move publish`.
4. Call `deployer::acquire_signer_capability` from an initialization function in your module. You will need to provide the private key as a signer.

## Installation

To use deployer in your code, add the following to the `[addresses]` section of your `Move.toml`:

```toml
[addresses]
deployer = "0x1245d0cf838606de0efd8bdfcc80b80cb4198f589b14ecac66ccc83035102c00"
```

## License

Apache-2.0
