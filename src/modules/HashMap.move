address 0x1 {
    module HashMap {
        use 0x1::Vector;
        use 0x1::BCS;
        use 0x1::Hash;

        struct Col<T> has store, drop, copy{
            key:            vector<u8>,
            value:          T
        }

        struct Row<T> has store, drop, copy{
            cols:           vector<Col<T>>,
        }

        struct Table<T> has store, drop, copy{
            rows:           vector<Row<T>>,
            threshold:      u64,
            total_count:    u128,
        }

        public fun new_col<T: copy + drop>(key: &vector<u8>, value: &T): Col<T> {
            Col<T> {
                key:    *key,
                value:  *value
            }
        }

        fun new_row<T>(): Row<T> {
            Row<T> {
                cols:   Vector::empty<Col<T>>()
            }
        }
        fun new_table<T>(capacity: u64): Table<T> {

            let rows =  Vector::empty<Row<T>>();
            let i = 0;
            while(i < capacity) {
                Vector::push_back(&mut rows, new_row<T>());
                i = i + 1;
            };

            Table<T> {
                rows: rows,
                threshold : capacity, 
                total_count: 0 
            }
        }
        public fun new<T>(init_capacity: u64): Table<T> {
            let capacity: u64= 1;
            while( capacity < init_capacity) {
                capacity = capacity << 1;
            };

            let table = new_table<T>(capacity);
            table
        }

        public fun hash_code(key: &vector<u8>): u128 {
            let index = 0;
            let code: u128 = 1;
            while (index < Vector::length(key) / 2) {
                let kv: u8  = *Vector::borrow(key, index);
                code        = 31 * code +  (kv as u128);
                index       = index + 1;
            };

            code
        }

        public fun make_bcs_key<TK>(key: &TK): vector<u8> {
            let bcs_key     = BCS::to_bytes(key);
            bcs_key
        }

        public fun make_hash_key<TK>(key: &TK): vector<u8> {
            let bcs_key     = make_bcs_key(key);
            let hash_key    = Hash::sha3_256(bcs_key);
            hash_key
        }

        public fun get_index<TV>(m: &Table<TV>, key: &vector<u8>): u64 {
            let code        = hash_code(key);
            let index       = code % (m.threshold as u128);
            (index as u64)
        }

        public fun key_is_identical(key_from: &vector<u8>, key_to: &vector<u8>): bool {
            let state = Vector::length(key_from) == Vector::length(key_to);
            if (state) {
                let i = 0;
                while(i < Vector::length(key_from)) {
                    if (Vector::borrow(key_from, i) != Vector::borrow(key_to, i)) {
                        state = false;
                        return state
                    };
                    i = i + 1;
                };
            };
            
            state
        }

        fun update<TK, TV: copy + drop>(m: &mut Table<TV>, key: &TK,  value: &TV, cover: bool): bool {
            let hash_key    = make_hash_key(key);
            let bcs_key     = make_bcs_key(key);
            let index       = get_index(m, &hash_key);
            let rows        = &mut m.rows;
            let row         = Vector::borrow_mut(rows, index); 
            let cur         = 0;
            let exist: bool = false;
            let cols = &mut row.cols;
            while (cur < Vector::length(cols)) {
                let col = Vector::borrow(cols, cur);
                if (!exist && key_is_identical(&col.key, &bcs_key)) {
                    exist     = true; 
                    if(cover) {
                        Vector::remove(cols, cur);
                        Vector::push_back(cols, new_col(&bcs_key, value));
                    }; 
                    cur = cur + 1;
                } else {
                    cur = cur + 1;
                }
            };

            if (!exist) {
                Vector::push_back(cols, new_col(&bcs_key, value));
            };
            exist
        }

        public fun threshold<TV>(m: &Table<TV>): u64 {
            m.threshold
        }

        public fun insert<TK, TV: copy + drop>(m: &mut Table<TV>, key: &TK, value: &TV) {
            update<TK, TV>(m, key, value, true);
        }

        public fun entry<TK, TV: copy + drop>(m: &mut Table<TV>, key: &TK, value: &TV) {
            update<TK, TV>(m, key, value, false);
        }

        public fun exist<TK, TV: copy + drop>(m: &Table<TV>, key: &TK) : bool {
            let hash_key    = make_hash_key(key);
            let bcs_key     = make_bcs_key(key);
            let index       = get_index(m, &hash_key);
            let row         = Vector::borrow(&m.rows, index); 
            let cur         = 0;
            let state       = false;
            let cols        = &row.cols;
            while (cur < Vector::length(cols)) {
                let col = Vector::borrow(cols, cur );
                if (!state && key_is_identical(&col.key, &bcs_key)) {
                    state = true; 
                    cur = cur + 1;
                } else {
                    cur = cur + 1;
                }
            }; 
            state
        }
        //temp
        public fun get_m_count< TV: copy + drop>(m: &mut Table<TV>): u64 {
            let len = Vector::length(&m.rows);
            len
        }
        public fun get_col_count<TK, TV: copy + drop>(m: &mut Table<TV>, key: &TK): u64{
            let hash_key    = make_hash_key(key);
            let index       = get_index(m, &hash_key);
            let rows        = &mut m.rows;
            let row         = Vector::borrow_mut(rows, index); 
            let len = Vector::length(&row.cols);
            len
        }
    }
}
