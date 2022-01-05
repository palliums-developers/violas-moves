script {
    use Std::VLSHashMap;
    use Std::Debug;
    //use 0x1::Vector;
    //use 0x1::Hash;
    //use 0x1::BCS;

    fun main() {

        let i: u64 = 0; 
        let hm = &mut VLSHashMap::new<u64>(1000);
        while (i < 6) {
            VLSHashMap::insert(hm, &i, &i);
            Debug::print(&VLSHashMap::get_col_count(hm, &i));
            Debug::print(&VLSHashMap::exist(hm, &i));
            Debug::print(&100000000000000);
            i = i + 1;
        };


        /*******************
        */
        Debug::print(&1000000000000001);
    }

}
