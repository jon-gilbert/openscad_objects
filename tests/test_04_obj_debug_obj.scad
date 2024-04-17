
include <openscad_objects/objects.scad>

module test_obj_debug_obj() {
    // this ONLY tests if obj_debug_obj() returns scucessfully. 
    // ideally, we'll expand this to include pattern content examination like 
    // we do in.. openscad_logging, I believe, but for now we care 
    // mostly about the function not exploding.
    obj = Object("TestObject", ["string=s=yoink"]);
    value = obj_debug_obj(obj);
}
test_obj_debug_obj();

