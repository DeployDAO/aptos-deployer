/// Module containing helpers for deploying resource accounts.
///
/// Resource accounts allow the module to sign as itself on-chain, which is useful for actions such as Coin initialization.
///
/// # Usage
///
/// Tooling to make this module easier to use is a work in progress. For now, one can perform the following steps:
///
/// 1. Create a new public/private keypair via `aptos key generate`.
/// 2. Call `Deployer::create_resource_account_with_auth_key` with the generated public key.
/// 3. Upload your module via `aptos move publish`.
/// 4. Call `Deployer::acquire_signer_capability` from an initialization function in your module. You will need to provide the private key as a signer.
/// 5. Call `Deployer::freeze_account` to deactivate the private key.

module Deployer::Deployer {
    use Std::Signer;
    use Std::Vector;
    use AptosFramework::Account::{Self, SignerCapability};
    use AptosFramework::Coin;
    use AptosFramework::TestCoin::TestCoin;

    /// Holds the SignerCapability.
    /// This can only ever be held by the resource account itself.
    struct SignerCapabilityStore has key, drop {
        /// The SignerCapability of the resource.
        resource_signer_cap: SignerCapability
    }

    /// Creates a new resource account and rotates the authentication key to either
    /// the optional auth key if it is non-empty (though auth keys are 32-bytes)
    /// or the source accounts current auth key.
    public(script) fun create_resource_account(
        origin: &signer,
        seed: vector<u8>,
        optional_auth_key: vector<u8>
    ) {
        let (resource, resource_signer_cap) = Account::create_resource_account(origin, seed);
        move_to(&resource, SignerCapabilityStore { resource_signer_cap });
        Coin::register<TestCoin>(&resource);
        let auth_key = if (Vector::is_empty(&optional_auth_key)) {
            Account::get_authentication_key(Signer::address_of(origin))
        } else {
            optional_auth_key
        };
        Account::rotate_authentication_key_internal(&resource, auth_key);
    }

    /// When called by the resource account, it will retrieve the capability associated with that
    /// account and rotate the account's auth key to 0x0 making the account inaccessible without
    /// the SignerCapability.
    public fun retrieve_resource_account_cap(
        resource: &signer
    ): SignerCapability acquires SignerCapabilityStore {
        let SignerCapabilityStore { resource_signer_cap } = move_from<SignerCapabilityStore>(Signer::address_of(resource));
        let zero_auth_key = x"0000000000000000000000000000000000000000000000000000000000000000";
        let resource = Account::create_signer_with_capability(&resource_signer_cap);
        Account::rotate_authentication_key_internal(&resource, zero_auth_key);
        resource_signer_cap
    }
}
