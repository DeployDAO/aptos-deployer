/// Module for publishing packages to resource accounts.
module deployer::deployer {
    use std::signer;
    use aptos_framework::account::{Self, SignerCapability};

    /// Holds the SignerCapability.
    /// This can only ever be held by the resource account itself.
    struct SignerCapabilityStore has key, drop {
        /// The SignerCapability of the resource.
        resource_signer_cap: SignerCapability
    }

    public entry fun publish_package_txn(
        deployer: &signer,
        seed: vector<u8>,
        metadata_serialized: vector<u8>,
        code: vector<vector<u8>>,
    ) {
        let (resource, resource_signer_cap) = account::create_resource_account(deployer, seed);
        aptos_framework::code::publish_package_txn(&resource, metadata_serialized, code);
        move_to(&resource, SignerCapabilityStore { resource_signer_cap });
    }

    /// Retrieves the resource account signer capability once, allowing the package to be able
    /// to sign as itself.
    public fun retrieve_resource_account_cap(
        resource: &signer
    ): SignerCapability acquires SignerCapabilityStore {
        let SignerCapabilityStore { resource_signer_cap } = move_from<SignerCapabilityStore>(signer::address_of(resource));
        resource_signer_cap
    }

    /// Creates the address for a resource account.
    public fun create_resource_account_address(origin: address, seed: vector<u8>): address {
        let bytes = std::bcs::to_bytes(&origin);
        std::vector::append(&mut bytes, seed);
        aptos_framework::byte_conversions::to_address(std::hash::sha3_256(bytes))
    }
}
