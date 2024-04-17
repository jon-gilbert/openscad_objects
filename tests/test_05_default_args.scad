
include <openscad_objects/objects.scad>

module test_obj_default_args() {
    function V(vlist=[], mutate=[]) = Object( "V", 
        ["string=s=yoink", 
            "integer=i=10", 
            "neg_int=i=-10", 
            "int_point=i=0.1",
            "b_false=b=false", 
            "b_true=b=true", 
            "undefined=u", 
            "list=l=[1, 2]", 
            ["proper_list", "l", [1, 2]],
            "object=o"],
        vlist=vlist, mutate=mutate );

    v = V([]);
    assert( obj_is_obj(v) );
    assert( obj_accessor_get(v, "string") == "yoink" );
    assert( obj_accessor_get(v, "string", default="yeet" ) == "yeet" );
    assert( obj_accessor_get(v, "string", default=undef ) == "yoink" );
    assert( obj_accessor_get(v, "integer") == 10 );
    assert( obj_accessor_get(v, "integer", default=100 ) == 100 );
    assert( obj_accessor_get(v, "integer", default=-1 ) == -1 );
    assert( obj_accessor_get(v, "neg_int") == -10 );
    assert( obj_accessor_get(v, "int_point") == 0.1 );
    assert( obj_accessor_get(v, "b_false") == false );
    assert( obj_accessor_get(v, "b_true") == true );
    assert( obj_accessor_get(v, "undefined") == undef );
    assert( obj_accessor_get(v, "list") == [] );
    assert( obj_accessor_get(v, "proper_list") == [1, 2] );
    assert( obj_accessor_get(v, "object") == undef );


    function W(vlist=[], mutate=[]) = Object( "W", [
            ["string",          "s", "yoink"], 
            ["integer",         "i", 10], 
            ["neg_int",         "i", -1], 
            ["int_point",       "i", 0.1],
            ["zero",            "i", 0],
            ["b_false",         "b", false], 
            ["b_true",          "b", true], 
            ["undefined",       "u", "whatever"], 
            ["list",            "l", [1, 2] ], 
            ["object",          "o", V() ],
        ],
        vlist=vlist, mutate=mutate );

    w = W();
    assert( obj_is_obj(w) );
    assert( obj_accessor_get(w, "string") == "yoink" );
    assert( obj_accessor_get(w, "neg_int") == -1 );
    assert( obj_accessor_get(w, "int_point") == 0.1 );
    assert( obj_accessor_get(w, "zero") == 0 );
    assert( obj_accessor_get(w, "b_false") == false );
    assert( obj_accessor_get(w, "b_true") == true );
    assert( obj_accessor_get(w, "undefined") == undef );
    assert( obj_accessor_get(w, "list") == [1, 2] );
    assert( obj_is_obj( obj_accessor_get(w, "object") ) );
    assert( obj_accessor_get(w, "object") == V() );

    function X(vlist=[], mutate=[]) = Object("X", [
        ["o", "o", V(["string", "asdf"]) ]
        ], vlist=vlist, mutate=mutate);
    x = X();
    assert( obj_is_obj(x) );
    assert( obj_is_obj( obj_accessor(x, "o") ) );
    assert( obj_toc_get_type( obj_accessor(x, "o") ) == "V" );
    assert( obj_accessor( obj_accessor(x, "o"), "string") == "asdf" );

}
test_obj_default_args();


