#[test_only]
module deployer::deployer_test {
    use std::signer;
    use std::vector;
    use aptos_framework::account;
    use deployer::deployer;
    use aptest::check;

    #[test(
        origin = @0x1245d0cf838606de0efd8bdfcc80b80cb4198f589b14ecac66ccc83035102c00,
        derived = @0x5619226f0d2aed6b65d85877006e3c7b06cbef093341e349302bdf378b1667fa,
    )]
    public entry fun test_create_and_retrieve(
        origin: signer,
        derived: signer,
    ) {
        account::create_account(signer::address_of(&origin));

        deployer::create_resource_account(&origin, b"test", vector::empty());
        let resource_signer_cap = deployer::retrieve_resource_account_cap(&derived);
        let resource = account::create_signer_with_capability(&resource_signer_cap);
        check::borrow_eq(&derived, &resource);
    }
}