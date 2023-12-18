header_type md_t {
    fields {
        alpha:32;
        level:32;
        h:24;
        base:32;
        threshold:32;
        est:32;
    }
}
#define METADATA_STAGE(D) \
    metadata md_t md_##D;


header_type original_md_t {
    fields {
        alpha:32;
        level:32;
        h1:1;
        h2:1;
        h3:1;
        h4:1;
        h5:1;
        h6:1;
        h7:1;
        h8:1;
        h9:1;
        h10:1;
        h11:1;
        h12:1;
        h13:1;
        h14:1;
        h15:1;
        h16:1;
        h17:1;
        h18:1;
        h19:1;
        h20:1;
        h21:1;
        h22:1;
        h23:1;
        h24:1;
    }
}

#define ORIGINAL_METADATA_STAGE(D) \
	metadata original_md_t md_##D;
