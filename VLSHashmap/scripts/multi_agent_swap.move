script {
    use DiemFramework::DiemAccount;
    use Std::Signer;
    use Std::XDX;
    use Std::XUS;

    fun main<Coin1, Coin2>(account1: signer, 
            account2: signer, 
            amount_xus: u64, 
            amount_xdx: u64) {
        let account1_withdrawal_cap: DiemAccount::withDrawCapability;
        let account2_withdrawal_cap: DiemAccount::withDrawCapability;
        let account1_addr: address;
        let account2_addr: address;
        let metadata: vector<u8>;
        let metadata_signature: vector<u8>;

        //First account1 pays account2 in currency XUS
        account1_withdrawal_cap = DiemAccount::extract_withdraw_capability(&account1);
        account2_addr = Signer::address_of(account2);
        DiemAccount::pay_from<Coin1>(
                &account1_withdrawal_cap, account2_addr, amount_xus, metadata, metadata_signature
                );
        DiemAccount::restore_withdraw_capability(account1_withdrawal_cap);


        //Then account2 pays account1 in currency XDX
        account2_withdrawal_cap = DiemAccount::extract_withdraw_capability(&account2);
        account1_addr = Signer::address_of(&account1);
        DiemAccount::pay_from<Coin2>(
                &account2_withdrawal_cap, account1_addr, amount_xdx, metadata, metadata_signature
                );
        DiemAccount::restore_withdraw_capability(account2_withdrawal_cap);


    }
}
