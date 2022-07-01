# aptos-deployer

Helper module for deploying Aptos modules to resource accounts.

Resource accounts allow the module to sign as itself on-chain, which is useful for actions such as Coin initialization.

## Usage

Tooling to make this module easier to use is a work in progress. For now, one can perform the following steps:

1. Create a new public/private keypair via `aptos key generate`.
2. Call `Deployer::create_resource_account_with_auth_key` with the generated public key.
3. Upload your module via `aptos move publish`.
4. Call `Deployer::acquire_signer_capability` from an initialization function in your module. You will need to provide the private key as a signer.
5. Call `Deployer::freeze_account` to deactivate the private key.

## License

Aptos Deployer is licensed under the Apache License, Version 2.0.
