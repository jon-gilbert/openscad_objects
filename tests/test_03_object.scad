

include <../object_common_functions.scad>


function gen_test_type_object() = 
    let(
        _obj = Object("TestTypeObject", 
            ["string=s", "integer=i", "boolean=b", "list=l", "undefined=u", "object=o"],
            ["string", "string", "integer", 1, "boolean", true, "list", [1], "undefined", undef] )
    )
    obj_accessor_set(_obj, "object", nv=_obj);


module test_obj_build_toc() {
    // test string-based paired creation
    toc = obj_build_toc("Test", ["one=i", "two=s"], []);
    assert( obj_is_obj( [toc, undef, undef] ));

    assert( obj_toc_get_type([toc, undef, undef]) == "Test" );
    assert( obj_toc_attr_len([toc, undef, undef]) == 2 );
    assert( obj_toc_get_attr_names([toc, undef, undef]) == ["_toc_", "one", "two"] );

    // test mutate TOC propgation
    mtoc = obj_build_toc("Test", ["three=i", "four=s"], [toc, undef, undef] );
    assert( obj_toc_get_type([mtoc, undef, undef]) == "Test" );
    assert( obj_toc_attr_len([mtoc, undef, undef]) == 2 );
    assert( obj_toc_get_attr_names([mtoc, undef, undef]) == ["_toc_", "one", "two"], toc);

    // test list-based paired TOC creation
    ptoc = obj_build_toc("TestP", [["five", "i"], ["six", "s"]], []);
    assert( obj_toc_get_type([ptoc, undef, undef]) == "TestP" );
    assert( obj_toc_attr_len([ptoc, undef, undef]) == 2 );
    assert( obj_toc_get_attr_names([ptoc, undef, undef]) == ["_toc_", "five", "six"] );
}
test_obj_build_toc();


module test_test_type_obj() {
    obj = gen_test_type_object();
    assert( obj_is_obj(obj) );
    assert( obj_is_valid(obj) );
    assert( obj_toc_get_type(obj) == "TestTypeObject" );
}
test_test_type_obj();


module test_obj_data_types() {
    assert( len(ATTRIBUTE_DATA_TYPES) > 0 );

    assert( obj_type_is_valid("s") );
    assert( obj_type_is_valid("i") );
    assert( obj_type_is_valid("b") );
    assert( obj_type_is_valid("l") );
    assert( obj_type_is_valid("u") );
    assert( obj_type_is_valid("o") );
}
test_obj_data_types();


module test_obj_type_check_value() {
    obj = gen_test_type_object();

    assert( obj_type_check_value(obj, "string", "abcd") );
    assert( obj_type_check_value(obj, "string", "    ") );
    assert( obj_type_check_value(obj, "string", "	") );   // a literal tab
    assert( obj_type_check_value(obj, "string", "") );
    assert( obj_type_check_value(obj, "string", "\"asd\"") );
    assert( obj_type_check_value(obj, "string", "1") );
    assert( obj_type_check_value(obj, "string", "0") );
    assert( obj_type_check_value(obj, "string", "undef") );

    assert( obj_type_check_value(obj, "integer", 1) );
    assert( obj_type_check_value(obj, "integer", 0) );
    assert( obj_type_check_value(obj, "integer", -1) );
    assert( obj_type_check_value(obj, "integer", 1.2) );
    assert( obj_type_check_value(obj, "integer", PI) );
    assert( obj_type_check_value(obj, "integer", 65535) );
    assert( obj_type_check_value(obj, "integer", -65535) );

    assert( obj_type_check_value(obj, "boolean", true) );
    assert( obj_type_check_value(obj, "boolean", false) );

    assert( obj_type_check_value(obj, "list", []) );
    assert( obj_type_check_value(obj, "list", [1, 2]) );
    assert( obj_type_check_value(obj, "list", [1, [4]]) );

    assert( obj_type_check_value(obj, "undefined", undef) );

    // TODO: when we've got workings to compare object types, augment here.
    assert( obj_type_check_value(obj, "object", obj) );
}
test_obj_type_check_value();


module test_obj_is_obj() {
    function C(vlist=[], mutate=[]) = Object( 
        "C", 
        ["string=s", "integer=i", "boolean=b", "list=l", "undefined=u", "object=o"],
        vlist=vlist, mutate=mutate );
    obj = C();
    assert( is_list(obj),  str( "obj needs to be a list, it is a:", obj ));
    assert( _defined(obj), str( "obj needs to be defined (it cannot be empty), its def status is:", _defined(obj) ));
    assert( len(obj[0]) == len(obj), str( "length of obj[0] needs to be the same as the length of obj: ", len(obj[0]), " vs ", len(obj) ));
    assert( list_shape( list_tail( obj_toc_get_attributes(obj), 1 ), 1) == 3, 
        str( "all attributes listed in toc (not the toc type tho) need to be similar depth" ));
}
test_obj_is_obj();


module test_construction() {
    function C(vlist=[], mutate=[]) = Object( 
        "C", 
        ["string=s", "integer=i", "boolean=b", "list=l", "undefined=u", "object=o"],
        vlist=vlist, mutate=mutate );

    assert( obj_is_obj( C() ) );
    assert( obj_is_obj( C([]) ) );

    c_obj = C([["string", "a"]]);
    assert( obj_accessor_get(c_obj, "string") == "a" );

    c2_obj = C([["integer", 8]], mutate=c_obj);
    assert( obj_accessor_get(c2_obj, "string") == "a" );
    assert( obj_accessor_get(c2_obj, "integer") == 8 );

    c3_obj = C(mutate=c2_obj);
    assert( c2_obj == c3_obj );

    c4_obj = C(["string", "abc", "integer", 12, "list", [1], "boolean", false]);
    c5_obj = C(["integer", 12, "string", "abc", "boolean", false, "list", [1]]);
    c6_obj = C([["integer", 12], ["boolean", false], ["list", [1]], ["string", "abc"]]);
    assert( c4_obj == c5_obj );
    assert( c4_obj == c6_obj );
}
test_construction();


module test_obj_accessor() {
    function D(vlist=[], mutate=[]) = Object( "D", 
        ["string=s", "integer=i", "boolean=b", "list=l", "undefined=u", "object=o"],
        vlist=vlist, mutate=mutate );

    obj = gen_test_type_object();
    assert( obj_accessor(obj, "string") == "string" );
    assert( obj_accessor(obj, "integer") == 1 );
    assert( obj_accessor(obj, "boolean") == true );
    assert( obj_accessor(obj, "list") == [1] );
    assert( obj_accessor(obj, "undefined") == undef );   // BRAK: ... what happens if there's a default?
    assert( obj_accessor(obj, "undefined", default="popup") == "popup" );

    // test getting with a defaults:
    assert( obj_accessor(obj, "string", default="abc") == "string" );
    assert( obj_accessor(obj, "string", default=undef) == "string" );
    // test getting an undefeind with a default provided
    // NOTE: if we ever get default returns typechecking, this'll break. 
    assert( obj_accessor(obj, "undefined", default="abc") == "abc" );

    // after changing an attribute, make sure all the others are unchanged
    new_thing = obj_accessor(obj, "string", nv="gnirts");
    assert( obj_is_obj(new_thing) );
    assert( obj_accessor(new_thing, "string") == "gnirts" );
    assert( obj_accessor(new_thing, "integer") == 1 );
    assert( obj_accessor(new_thing, "boolean") == true );
    assert( obj_accessor(new_thing, "list") == [1] );
    assert( obj_accessor(new_thing, "undefined") == undef );

    // make sure different types can be gotten with defaults against
    // an empty obj
    new_thing2 = D();
    assert( obj_accessor(new_thing2, "string", default="2") == "2" );
    assert( obj_accessor(new_thing2, "integer", default=2) == 2 );

    
    write_thing = D(["string", "asdf"]);
    assert( obj_accessor(write_thing, "string") == "asdf" );
    wt2 = obj_accessor(write_thing, "string", nv="1234");
    assert( obj_accessor(wt2, "string") == "1234" );
    assert( obj_accessor(wt2, "string", nv=undef) == "1234" );
    wt3 = obj_accessor_set(wt2, "string", nv="wasd");
    assert( obj_accessor(wt3, "string") == "wasd" );
    
    wt4 = obj_accessor_unset(write_thing, "string");
    assert( obj_accessor(wt4, "string") == undef );

    // specific test: setting a bool value to true at obj construction, 
    // then flipping it to false via obj_accessor:
    o2 = D(["boolean", true]);
    assert( obj_accessor_get(o2, "boolean") == true );
    o22 = obj_accessor(o2, "boolean", nv=false);
    assert( obj_is_obj(o22), str( "return object is: ", o22 ) );
    assert( obj_accessor_get(o22, "boolean") == false );

    // test to see if we can successfully get back nothing with an undefined object
    // UPDATE as of 'issue-9': undefined values as objects? Is this REALLY a supportable case?
    //o6 = undef;
    //assert( obj_accessor(o6, "string", default="default") == "default" );

    // this should error out, and there's no way in OpenSCAD to trap exceptions:
    //assert( obj_accessor(o6, "string" ) == "undef" );

}
test_obj_accessor();


module test_obj_tocs() {
    function F(vlist=[], mutate=[]) = Object( "F", 
        ["string=s", "integer=i", "boolean=b", "list=l", "undefined=u", "object=o"],
        vlist=vlist, mutate=mutate );

    obj = F([]);
    assert( obj_is_obj(obj) );
    assert( obj_toc_get_type(obj) == "F" );
    assert( obj_toc_get_attributes(obj) == [["_toc_", "o"], ["string", "s", undef], ["integer", "i", undef], ["boolean", "b", undef], ["list", "l", []], ["undefined", "u", undef], ["object", "o", undef]], obj_toc_get_attributes(obj) ); 
    assert( obj_toc_get_attr_names(obj) == ["_toc_", "string", "integer", "boolean", "list", "undefined", "object"] );
    assert( obj_toc_get_attr_types(obj) == ["o", "s", "i", "b", "l", "u", "o"] );

    assert( obj_get_values(obj) == [undef, undef, undef, undef, undef, undef] );
    assert( obj_has_value(obj) == false );
    assert( obj_toc_attr_len(obj) == 6 );

    assert( obj_toc_get_attr_type_by_name(obj, "string") == "s" );
    assert( obj_toc_get_attr_type_by_name(obj, "integer") == "i" );
    assert( obj_toc_get_attr_type_by_name(obj, "boolean") == "b" );
    assert( obj_toc_get_attr_type_by_name(obj, "list") == "l" );
    assert( obj_toc_get_attr_type_by_name(obj, "undefined") == "u" );
    assert( obj_toc_get_attr_type_by_name(obj, "object") == "o" );

    assert( obj_has(obj, "string") == true );
    assert( obj_has(obj, "integer") == true );
    assert( obj_has(obj, "boolean") == true );
    assert( obj_has(obj, "list") == true );
    assert( obj_has(obj, "undefined") == true );
    assert( obj_has(obj, "object") == true );
    assert( obj_has(obj, "none") == false );
    assert( obj_has(obj, undef) == false );
    assert( obj_has(obj, "") == false );
    assert( obj_has(obj, []) == false );
    assert( obj_has(obj, true) == false );
    assert( obj_has(obj, false) == false );

}
test_obj_tocs();



