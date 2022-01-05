module DiemFramework:MultiAgentSwap {
    use DiemFramework::DiemAccount;
    use Std::Signer;
    use Std::Vector;
    use DiemFramework::XUS;
    use DiemFramework::XDX;
    use Std::Debug;

    fun swap_nometadata<CoinTypeA, CoinTypeB>(
            account_a: signer, 
            account_b: signer, 
            amount_xus: u64, 
            amount_xdx: u64
            ) {

        Debug::print(&amount_xdx);
        Debug::print(&amount_xus);
        let metadata_a = Vector::empty<u8>();
        let metadata_a_signature = Vector::empty<u8>();
        let metadata_b = Vector::empty<u8>();
        let metadata_b_signatureB = Vector::empty<u8>();
        //First account_a pays account_b in currency XUS
        let account_a_withdrawal_cap = DiemAccount::extract_withdraw_capability(&account_a);
        let account_b_addr = Signer::address_of(&account_b);
        Debug::print(&account_b_addr);
        Debug::print(&account_a_withdrawal_cap);
        DiemAccount::pay_from<CoinTypeA>(
                &account_a_withdrawal_cap, account_b_addr, amount_xus, metadata_a, metadata_a_signature
                );
        DiemAccount::restore_withdraw_capability(account_a_withdrawal_cap);


        //Then account_b pays account_a in currency XDX
        let account_b_withdrawal_cap = DiemAccount::extract_withdraw_capability(&account_b);
        let account_a_addr = Signer::address_of(&account_a);
        Debug::print(&account_a_addr);
        DiemAccount::pay_from<CoinTypeB>(
                &account_b_withdrawal_cap, account_a_addr, amount_xdx, metadata_b, metadata_b_signatureB
                );
        DiemAccount::restore_withdraw_capability(account_b_withdrawal_cap)
    }
}
