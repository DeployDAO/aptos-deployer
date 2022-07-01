//! Module containing helpers for deploying resource accounts.

module Deployer::Deployer {
    use Std::Signer;
    use AptosFramework::Account::{Self, SignerCapability};

    /// Holds the SignerCapability.
    /// This can only ever be held by this Deployer.
    struct SignerCapabilityStore has key, drop {
        /// The SignerCapability of the account.
        signer_cap: SignerCapability
    }

    /// Initializes a resource account for the given account.
    public(script) fun create_resource_account_with_auth_key(
        payer: &signer,
        new_auth_key: vector<u8>
    ) {
        let (s, signer_cap) = Account::create_resource_account(payer);
        move_to(&s, SignerCapabilityStore { signer_cap });
        Account::rotate_authentication_key(s, new_auth_key);
    }

    /// Acquires the SignerCapability of an account.
    /// This can be used to give the SignerCapability to the module, or to some sort of DAO.
    public fun acquire_signer_capability(
        owner: &signer
    ): SignerCapability acquires SignerCapabilityStore {
        let SignerCapabilityStore { signer_cap } = move_from<SignerCapabilityStore>(Signer::address_of(owner));
        signer_cap
    }

    /// Makes an account immutable by setting its auth key to 0-- only the Signer capability will work.
    public(script) fun freeze_account(account: signer) {
        Account::rotate_authentication_key(
            account,
            x"0000000000000000000000000000000000000000000000000000000000000000"
        );
    }
}
