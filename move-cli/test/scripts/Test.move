script {
    use Std::Debug;

    fun multiswap(
            account1: signer, 
            account2: signer, 
            amount_xus: u64, 
            amount_xdx: u64 
            ) {
        Debug::print(&account1);
        Debug::print(&account2);
        Debug::print(&amount_xdx);
        Debug::print(&amount_xus);

    }
}
