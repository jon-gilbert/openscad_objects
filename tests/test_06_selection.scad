include <../object_common_functions.scad>

function TestObj(vlist=[], mutate=[]) = Object("TestObj", ["aint=i", "bint=i=1", "cstr=s", "dint=i", "estr=s"], vlist=vlist, mutate=mutate);


obj_listing = [ 
    TestObj(["aint", 4,
        "bint", 14,
        "cstr", "alpha",
        "dint", 1,
        "estr", "aaa",
        ]),
    TestObj(["aint", 0,
        "bint", 10,
        "cstr", "bravo",
        "estr", "bbb",
        ]),
    TestObj(["aint", 1,
        "bint", 11,
        "cstr", "charlie",
        "dint", 3,
        "estr", "aaa",
        ]),
    TestObj(["aint", 3,
        "bint", undef,
        "cstr", "delta",
        "estr", "bbb",
        ]),
    TestObj(["aint", 2,
        "bint", undef,
        "cstr", "echo",
        "dint", 2,
        "estr", "bbb",
        ]),
    ];


module test_obj_select() {
    x1 = obj_select( obj_listing, [0] );
    assert( len(x1) == 1,
        str("returned list from obj_select must be 1: ", x1 ) );
    assert( obj_accessor_get( x1[0], "aint" ) == 4,
        str("returned aint for index 0 must be 4: ", x1 ) );

    x2 = obj_select( obj_listing, [0, 3] );
    assert( len(x2) == 2,
        str("returned list from obj_select must be 2: ", x2 ) );
    assert( obj_accessor_get( x2[0], "cstr" ) == "alpha",
        str("first cstr returned must be 'alpha': ", x2[0] ) );
    assert( obj_accessor_get( x2[1], "cstr" ) == "delta",
        str("second cstr returned must be 'delta': ", x2[1] ) );
}
test_obj_select();


module test_obj_select_by_attr_defined() {
    x1 = obj_select_by_attr_defined(obj_listing, "aint");
    assert( len(x1) == 5, 
        str("x1 must have 5 elements: ", x1 ) );
    assert( [for (obj=x1) obj_accessor_get(obj, "aint")] == [4, 0, 1, 3, 2],
        str("returned defined aint list must be [4, 0, 1, 3, 2]: ", x1 ) );
    
    x2 = obj_select_by_attr_defined(obj_listing, "dint");
    assert( len(x2) == 3,
        str("x2 must have 3 elements: ", len(x2), " -- ", x2 ) );
    assert( [for (obj=x2) obj_accessor_get(obj, "dint")] == [1, 3, 2],
        str("returned dint of x2 list must be [1, 3, 2]: ", x2 ) );
}
test_obj_select_by_attr_defined();


module test_obj_select_by_attr_value() {
    x1 = obj_select_by_attr_value(obj_listing, "cstr", "alpha");
    assert( len(x1) == 1, 
        str("returned x1 must one element: ", x1) );
    assert( obj_accessor_get(x1[0], "cstr") == "alpha",
        str("returned obj cstr must match 'alpha': ", x1[0] ) );

    x2 = obj_select_by_attr_value(obj_listing, "estr", "aaa");
    assert( len(x2) == 2,
        str("returned x2 must have two elements: ", x2) );
    assert( [for (obj=x2) obj_accessor_get(obj, "cstr")] == ["alpha", "charlie"],
        str("returned 'estr' x2 must have 'cstr's of ['alpha', 'charlie']: ", x2 ) );
}
test_obj_select_by_attr_value();


module test_obj_select_values_from_obj_list() {
    v1 = obj_select_values_from_obj_list(obj_listing, "cstr");
    assert( v1 == ["alpha", "bravo", "charlie", "delta", "echo"],
        str("returned 'cstr' from object listing must match ['alpha', 'bravo', et al]: ", v1 ) );

    v2 = obj_select_values_from_obj_list(obj_listing, "dint");
    assert( v2 == [1, undef, 3, undef, 2],
        str("returned 'dint' values must match [1, undef, 3, undef, 2]: ", v2) );

}
test_obj_select_values_from_obj_list();


module test_obj_sort_by_attribute() {
    aint_sorted_cstrs = [ "bravo", "charlie", "echo", "delta", "alpha" ];
    bint_sorted_cstrs = [ "delta", "echo", "bravo", "charlie", "alpha" ];
    cstr_sorted_idxs = [ "alpha", "bravo", "charlie", "delta", "echo" ];
    
    s1 = obj_sort_by_attribute(obj_listing, "aint");
    s1_cstrs = obj_select_values_from_obj_list( s1, "cstr" ); 
    assert( s1_cstrs == aint_sorted_cstrs,
        str("returned sort for 'aint' must match ", aint_sorted_cstrs, ": ", s1_cstrs, "; s1: ", s1 ) );

    s2 = obj_sort_by_attribute(obj_listing, "bint");
    s2_cstrs = obj_select_values_from_obj_list(s2, "cstr");
    assert( s2_cstrs == bint_sorted_cstrs,
        str("returned sort for 'bint' must match ", bint_sorted_cstrs, ": ", s2_cstrs ) );

    s3 = obj_sort_by_attribute(obj_listing, "cstr");
    s3_cstrs = obj_select_values_from_obj_list(s3, "cstr");
    assert( s3_cstrs == cstr_sorted_idxs,
        str("returned sort for 'cstr' must match ", cstr_sorted_idxs, ": ", s3_cstrs ) );

}
test_obj_sort_by_attribute();


module test_obj_regroup_list_by_attr() {
    r1 = obj_regroup_list_by_attr(obj_listing, "estr");
    shape1 = list_shape(r1);
    assert(shape1[0] == 2,
        str("expected two elements when grouping with estr, got ", shape1[0]));
    r1_0_cstr = sort( obj_select_values_from_obj_list(r1[0], "cstr") );
    assert(r1_0_cstr == ["alpha", "charlie"],
        str("expected first elements in r1 must be ['alpha', 'charlie']: ", r1_0_cstr));
    
    r2 = obj_regroup_list_by_attr(obj_listing, "dint");
    shape2 = list_shape(r2);
    assert(shape2[0] == 3,
        str("expected 3 elements when grouping with dint, got ", shape2[0]));
}
test_obj_regroup_list_by_attr();


module test_obj_select_by_attrs_values() {
    s1_comp = [ TestObj(["aint", 2, "bint", undef, "cstr", "echo", "dint", 2, "estr", "bbb" ]) ];

    s1 = obj_select_by_attrs_values(obj_listing, [ ["estr", "bbb"], ["cstr", "echo"] ]);
    assert(len(s1) == 1,
        str("returned list must be one element long"));
    assert(s1 == s1_comp,
        str("returned list must match comparison list"));
    
    s2_comp = [ TestObj(["aint", 4, "bint", 14, "cstr", "alpha", "dint", 1, "estr", "aaa" ]) ];
    s2 = obj_select_by_attrs_values(obj_listing, [["cstr", "alpha"]]);
    assert(len(s2) == 1,
        str("returned list must be 1"));
    assert(s2 == s2_comp,
        str("returned list must be the same as the source list", s2, s2_comp));

    s3_comp = [];
    s3 = obj_select_by_attrs_values(obj_listing, [["cstr", "unmatched"]]);
    assert(len(s3) == 0,
        str("returned list must be 0"));
    assert(s3 == s3_comp,
        str("returned list must be the same as the source list (eg, empty)"));
    
}
test_obj_select_by_attrs_values();


