/// Module containing helpers for deploying resource accounts.
///
/// Resource accounts allow the module to sign as itself on-chain, which is useful for actions such as Coin initialization.
///
/// # Usage
/// 
/// The [aptos-create-resource-account](https://github.com/aptosis/aptos-toolkit/tree/master/crates/aptos-create-resource-account) uses
/// this module internally. Please read the documentation for that crate for more information.
/// 
/// ## Manual creation
///
/// One can perform the following steps:
///
/// 1. Create a new public/private keypair via `aptos key generate`.
/// 2. Call `deployer::create_resource_account` with the generated public key.
/// 3. Upload your module via `aptos move publish`.
/// 4. Call `deployer::acquire_signer_capability` from an initialization function in your module. You will need to provide the private key as a signer.

module deployer::deployer {
    use std::signer;
    use std::vector;
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::coin;
    use aptos_framework::test_coin::TestCoin;

    /// Holds the SignerCapability.
    /// This can only ever be held by the resource account itself.
    struct SignerCapabilityStore has key, drop {
        /// The SignerCapability of the resource.
        resource_signer_cap: SignerCapability
    }

    /// Creates a new resource account and rotates the authentication key to either
    /// the optional auth key if it is non-empty (though auth keys are 32-bytes)
    /// or the source accounts current auth key.
    /// 
    /// This differs from [aptos_framework] in that it registers a `TestCoin` store for the new account.
    public entry fun create_resource_account(
        origin: &signer,
        seed: vector<u8>,
        optional_auth_key: vector<u8>
    ) {
        let (resource, resource_signer_cap) = account::create_resource_account(origin, seed);
        move_to(&resource, SignerCapabilityStore { resource_signer_cap });
        coin::register<TestCoin>(&resource);
        let auth_key = if (vector::is_empty(&optional_auth_key)) {
            account::get_authentication_key(signer::address_of(origin))
        } else {
            optional_auth_key
        };
        account::rotate_authentication_key_internal(&resource, auth_key);
    }

    /// When called by the resource account, it will retrieve the capability associated with that
    /// account and rotate the account's auth key to 0x0 making the account inaccessible without
    /// the SignerCapability.
    public fun retrieve_resource_account_cap(
        resource: &signer
    ): SignerCapability acquires SignerCapabilityStore {
        let SignerCapabilityStore { resource_signer_cap } = move_from<SignerCapabilityStore>(signer::address_of(resource));
        let zero_auth_key = x"0000000000000000000000000000000000000000000000000000000000000000";
        let resource = account::create_signer_with_capability(&resource_signer_cap);
        account::rotate_authentication_key_internal(&resource, zero_auth_key);
       resource_signer_cap
    }
}
