// reuse SALU and reduce memory access

#define API4_SALU_CS_UPDATE_INIT(NAME, BASE, INDEX, RES, EST, SIZE) \
	table NAME##_add_base_table { \
	    actions { \
	        NAME##_add_base_table_act; \
	    } \
	    default_action: NAME##_add_base_table_act; \
	} \
	action NAME##_add_base_table_act () { \
        add_to_field(INDEX, BASE); \
	} \
    register  NAME##_register { \
        width: 32; \
        static: NAME##_update_table; \
        instance_count: SIZE; \
    } \
    table NAME##_update_table { \
        actions { \
            NAME##_update_table_act; \
        } \
        default_action: NAME##_update_table_act; \
    } \
    action NAME##_update_table_act () { \
        register_read(EST, NAME##_register, INDEX); \
        add_to_field(EST, RES); \
        register_write(NAME##_register, INDEX, EST); \
    }

#define API4_SALU_CS_UPDATE_CALL(NAME) \
    apply(NAME##_add_base_table); \
    apply(NAME##_update_table);

