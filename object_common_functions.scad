// LibFile: object_common_functions.scad
//   Functions for creating and accessing object-like lists. 
//   .
//   **Note:** that throughout this file and elsewhere within the 507 (a separate project not yet linkable), we loosely refer to things as 
//   objects. I *wish* they were real, blessed, official capital-O Objects,
//   and they're not. See docs/HOWTO.md on a quick-start minimum number of steps to get 
//   this into your OpenSCAD modules. 
//   .
//   Also, throughout the examples here we talk about an "Axle" model. This is described 
//   also in the HOWTO.md doc. It's loosely based on an actual object class in the 507, 
//   and used as a simple, contrived example. 
//
// FileSummary: Functions for creating and accessing object-like lists.
// Includes:
//   include <object_common_functions.scad>
//

// this may break within 507, and if so, comment it out. 
include <BOSL2/std.scad>


// Section: Object Functions
//   These functions assist the creating and usage of Object-like lists ("Objects").
//
// Function: Object()
// Description:
//   Creates a list of values from either `vlist` or `mutate` arguments with the same indexing as 
//   `obj_attrs`. This resulting list can be treated as a loose "object". 
//   `vlist` listing is a variable list of `[attribute, value]` lists. 
//   Attribute pairs can be in any order. Attribute pairs may not be repeated. 
//   Unspecified attributes will be set to `undef`. 
//   `Object()` returns a new list that should be treated as an opaque object.
//   .
//   Optionally, an existing, similar object can be provided via the `mutate` argument: that 
//   existing list will be used as the original set of object attribute values, and any 
//   new values provided in `vlist` will take precedence.
// Usage:
//   object_list = Object("ObjectName", Obj_attributes, vlist);
//   object_list = Object("ObjectName", Obj_attributes, vlist, mutate=object_list);
// Arguments:
//   obj_name = The "name" of the object (think "classname"), for example: `Axle`. No default. 
//   obj_attrs = The list of known attributes and their type for this object, eg: `["length=i", "style=s", "optional_attr=[]"]`. No default. 
//   ---
//   vlist = Variable list of attributes and values: `[ ["length", 10], ["style", "none"] ]`; **or,** a list of running attribute value pairing: `["length", 10, "style", "none"]`.  No default. 
//   mutate = An existing Object of a similar `obj_name` type on which to pre-set values. Default: `[]`
//
// Example: empty object creation:
//   Axle_attributes = ["diameter=i", "length=i"];
//   function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
//   echo(Axle());
//   // emits: ECHO: "[["Axle", ["diameter", "i"], ["length", "i"]], undef, undef]
//
// Example: pre-populating object attributes at creation: 
//   Axle_attributes = ["diameter=i", "length=i"];
//   function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   // axle == [["Axle", ["diameter", "i"], ["length", "i"]], 10, 30];
//
// Example: pre-populating again, but with a simpler `vlist`:
//   Axle_attributes = ["diameter=i", "length=i"];
//   function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
//   axle2 = Axle(["diameter", 6]);
//   // axle2 == [["Axle", ["diameter", "i"], ["length", "i"]], 6, undef];
//
// Example: showing how mutation works: 
//   Axle_attributes = ["diameter=i", "length=i"];
//   function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   // axle == [["Axle", ["diameter", "i"], ["length", "i"]], 10, 30];
//   axle2 = Axle([["length", 40]], mutate=axle);
//   // axle2 == [["Axle", ["diameter", "i"], ["length", "i"]], 10, 40];
//
// EXTERNAL - 
//    is_list(), list_insert(), list_shape(), list_pad(), list_set() (BOSL2); 
function Object(obj_name, obj_attrs=[], vlist=[], mutate=[]) =
    assert(is_list(obj_attrs), str(obj_name, " argument 'obj_attrs' must be a list"))
    assert(is_list(vlist), str(obj_name, " argument 'vlist' must be a list"))
    let(_ = _assert_assign_if_defined(mutate, obj_is_obj(mutate), 
        str(obj_name, " argument 'mutate' must be an Object")))
    let(
        // build the TOC. The TOC ends up looking like:
        //   ["Name", ["attr1", "type1"], ["attr2", "type2"] ... ]
        // If no type is specified in the obj_attrs or in mutate, each 
        // attribute's `type` will be "undef". 
        obj_toc = obj_build_toc(obj_name, obj_attrs, mutate),
        
        // examine vlist: if it's not a consistent dimensional length at the second 
        // level, assume that `vlist` is in fact an `arglist`, and convert it thus. 
        // Otherwise, take vlist as it is passed. Should look like:
        //    v = [["attr1name", "value1"], ["attr2name", "value2"] ... ]
        v = (_defined(list_shape(vlist, undef)[1]))
            ? vlist
            : attr_arglist_to_vlist(vlist),
        
        // get the number of attributes we're dealing with, because 
        // we use it pretty frequently here:
        attr_count = obj_toc_attr_len( (obj_is_obj(mutate)) ? mutate : [obj_toc] ),

        // construct a base_obj that is either whatever is in 
        // `mutate`, or an undef padded list of the same length of 
        // attributes. The base_obj is a list, with the TOC 
        // in the first (zeroth) posistion, and attribute values 
        // in the remaining indexed positions. 
        base_obj = (obj_is_obj(mutate)) 
            ? mutate
            : list_pad([obj_toc], attr_count + 1, undef),

        // if there's anything in `v`, recurisvely assign them 
        // to the base_obj. Otherwise, just use the base object. 
        // DON'T start down the _rec_assign_vlist_to_obj() path 
        // if `v` is zero-length.
        obj = (len(v) > 0) 
            ? _rec_assign_vlist_to_obj(base_obj, v)
            : base_obj
    )
    obj;


function _rec_assign_vlist_to_obj(obj, vlist) =
    assert(len(vlist) > 0, "_rec_assign_vlist_to_obj() MUST have a non-zero-len vlist passed")
    let(
        attr_name = vlist[0][0],
        attr_id = obj_toc_attr_id_by_name(obj, attr_name),
        attr_value = vlist[0][1],
        next_obj = (len(vlist) < 2) 
            ? obj 
            : _rec_assign_vlist_to_obj( obj, slice(vlist, 1) )
    )
    (_defined(attr_id)) ? list_set(next_obj, [attr_id], [attr_value]) : obj;


// Function: obj_is_obj()
// Description: 
//   Given a thing, returns true if that thing can be considered an Object, of any type. 
//   .
//   To be considered an Object, a thing must: be a list; have a zeroth element defined; 
//   have a length that is the same length as its zeroth element; and, whose sub-list 
//   elements under its zeroth element have the same depth and count.
//   .
//   If the thing matches those requirements, `obj_is_obj()` returns `true`; otherwise, it will return `false`.
// Arguments:
//   obj = An Object list (potentially). No default. 
// Continues:
//   It is not an error to test for an object and have it return `false`. 
function obj_is_obj(obj) = 
    (is_list(obj))                                          // "Object base type must be a list")
        && (_defined(obj[0]))                               // "First element in object list must be defined"
        && (len(obj[0]) == len(obj))                        // "Objects must have the same number of elements and attributes in its TOC")
        && (list_shape(list_tail(obj_toc_get_attributes(obj), 1), 1) == 2);  // "Attributes and type pairing within the TOC must be consistent, and must be 2")


// Function: obj_is_valid()
// Description:
//   Given an object, returns `true` if the object is "valid", and `false` otherwise. "Valid" in this 
//   context means the object is an object (as per `obj_is_obj()`); and, has at least one attribute element; whose 
//   attributes all have a valid type assigned; and, whose attributes with values all match their specified types. 
// Arguments:
//   obj = An Object list. No default. 
// Continues:
//   It is not an error to test for an object and have it return `false`. 
function obj_is_valid(obj) =
    ((obj_is_obj(obj))                          // object must be an object
        && (len(obj) > 0)                       // length of object must be greater than 0
        && obj_value_datatype_check(obj));      // value check for all attributes must pass


function obj_value_datatype_check(obj) = !in_list(false, 
    [ for (i=[1:obj_toc_attr_len(obj)]) obj_type_check_value(obj, obj_toc_attr_name_by_id(obj, i), obj[i]) ] );


// Function: obj_debug_obj()
// Description: 
//   Given an object, return a string of debug layout information 
//   of the object. Nested objects within the object will also 
//   be expanded with a visual indent.
// Usage:
//   obj_debug_obj(obj);
// Arguments:
//   obj = An Object list. No default. 
// Continues:
//   `obj_debug_obj()` does not output this debugging information anywhere: it's up 
//   to the caller to do this. 
// Example:
//   axle = Axle([["diameter", 10]]);
//   echo(obj_debug_obj(axle));
//   // yields:
//   //   ECHO: "0: _toc_: ["Axle", "diameter", "length"]
//   //   1: diameter: 10 (i)
//   //   2: length: undef (i)"
function obj_debug_obj(obj, ws="") =
    let(
        debug_data_toc = str(ws, "0: _toc_: ", obj_toc_get_type(obj)),
        debug_data = [
            for( i=[1:obj_toc_attr_len(obj)] ) 
                str(ws, 
                    i, ": ", obj_toc_attr_name_by_id(obj, i), " (", obj_toc_get_attr_types(obj)[i], "): ", 
                    (obj_toc_get_attr_types(obj)[i] == "o" && defined(obj_accessor_get(obj, obj_toc_attr_name_by_id(obj, i)))) 
                        ? str("\n", 
                            obj_debug_obj(obj_accessor_get(obj, obj_toc_attr_name_by_id(obj, i)), ws=str(ws, "   "))
                            )
                        : obj_accessor_get(obj, obj_toc_attr_name_by_id(obj, i))
                    ) 
            ],
        full_data = list_insert(debug_data, [0], [debug_data_toc])
    )
    str_join(full_data, "\n");


// --------------------------------------------------------------------------------------------------------------------------------
// Subsection: Object Table-of-Contents Functions
//   These are functions specific to interacting with an Object's Table-of-Contents (TOC). 
//   In general these aren't really functions you'd need in your day-to-day model. In particular, 
//   functions without given examples probably should be shied away from.
//   

// Function: obj_build_toc()
// Description: 
//   Given an object name, an attribute-type set, and optionally an existing object to mutate from,
//   construct a table-of-contents (TOC) and return it. 
// Arguments:
//   obj_name = The "name" of the object (think "classname"), for example: `Axle`. No default. 
//   obj_attrs = The list of known attributes and their type for this object, eg: `["length=i", "style=s", "optional_attr=[]"]`. No default. 
//   mutate = An existing Object of a similar `obj_name` type on which to pre-set values. No default. 
function obj_build_toc(obj_name, obj_attrs, mutate) = 
    assert(_defined(obj_attrs) || _defined(mutate), 
        "obj_build_toc: at least one of either obj_attrs or mutate must be provided")
    let(
        toc_attrs_with_type = [ for ( i=[0:len(obj_attrs) - 1] ) attr_and_type_from_string_or_pairs(obj_attrs[i]) ],
        new_toc = list_insert(toc_attrs_with_type, [0], [obj_name])
    )
    (obj_is_obj(mutate)) ? obj_toc(mutate) : new_toc;


// Function: obj_toc()
// Description:
//   Given an object, return that object's TOC. 
// Usage:
//   toc = obj_toc(obj);
// Arguments:
//   obj = An Object list. No default. 
function obj_toc(obj) = obj[0];


// Function: obj_toc_get_type()
// Description: 
//   Given an object, return its "type" from its TOC. If there is no TOC, an error is raised. 
// Usage:
//   obj_toc_get_type(obj);
// Arguments:
//   obj = An Object list. No default. 
// Example:
//   axle = Axle([["diameter", 10]]);
//   type = obj_toc_get_type(axle);
//   // type == "Axle"
function obj_toc_get_type(obj) = 
    (_defined(obj[0][0])) 
        ? obj[0][0] 
        : assert(false, str("obj_toc_get_type(): passed value has no object type:", obj));


// Function: obj_toc_get_attributes()
// Description:
//   Given an object, return its list of attributes. This may differ from the list of 
//   attributes in the object's TOC, because of the TOC itself.
//   .
//   `obj_toc_get_attributes()` returns the TOC index as an attribute pair 
//   of a literal "TOC", and an attribute type of `o`; should look like `["_toc_", "o"]`. 
// Usage:
//   obj_toc_get_attributes(obj);
// Arguments:
//   obj = An Object list. No default. 
// Example:
//   axle = Axle([]);
//   attrs = obj_toc_get_attributes(axle);
//   // attrs == [["_toc_", "o"], ["diameter", "i"], ["length", "i"]];
function obj_toc_get_attributes(obj) = 
    list_insert( 
        slice(obj[0], 1),
        [0], [["_toc_", "o"]]
    );


// Function: obj_toc_get_attr_names()
// Description:
//   Given an object, return its list of attribute names. 
// Usage:
//   obj_toc_get_attr_names(obj);
// Arguments:
//   obj = An Object list. No default.
// Example:
//   axle = Axle([]);
//   names = obj_toc_get_attr_names(axle);
//   // names == ["_toc_", "diameter", "length"];
// Todo: 
//   honestly I'm not wild about the TOC being returned in the list of attributes. 
function obj_toc_get_attr_names(obj) = [ for (i=obj_toc_get_attributes(obj)) i[0] ];


// Function: obj_toc_get_attr_types()
// Description:
//   Given an object, return its list of attribute types. Types are 
//   returned in the same order and index as their corresponding attributes.. 
// Usage:
//   obj_toc_get_attr_types(obj);
// Arguments:
//   obj = An Object list. No default.
// Example:
//   axle = Axle([]);
//   names = obj_toc_get_attr_types(axle);
//   // names == ["o", "i", "i"];
// Todo: 
//   honestly I'm not even really sure *when* you'd use this.
function obj_toc_get_attr_types(obj) = [ for (i=obj_toc_get_attributes(obj)) i[1] ];


// Function: obj_toc_attr_len()
// Description:
//   Given an object, return the number of attributes defined for that object. 
// Usage:
//   length = obj_toc_attr_len(obj);
// Arguments:
//   obj = An Object list. No default.
// Todo: 
//   I'm not super wild about the TOC being considered in this length
function obj_toc_attr_len(obj) = len(obj[0]) - 1;


// Function: obj_toc_get_attr_type_by_name()
// Description:
//   Given an object and an attribute name, return the attribute data type 
//   expected for that attribute. 
//   Valid data types are listed in `ATTRIBUTE_DATA_TYPES`.
// Usage:
//   type = obj_toc_get_attr_type_by_name(obj, name);
// Arguments:
//   obj = An Object list. No default. 
//   name = The attribute name for whose data type you want. No default.
// Example:
//   axle = Axle();
//   type = obj_toc_get_attr_type_by_name(axle, "diameter");
//   // type == "i"
function obj_toc_get_attr_type_by_name(obj, name) = obj_toc_get_attr_type_by_id(obj, obj_toc_attr_id_by_name(obj, name)); 


// Function: obj_toc_get_attr_type_by_id()
// Description:
//   Given an object and an attribute id, return the attribute data type 
//   expected for that attribute. 
//   Valid data types are listed in `ATTRIBUTE_DATA_TYPES`.
// Usage:
//   type = obj_toc_get_attr_type_by_id(obj, id);
// Arguments:
//   obj = An Object list. No default. 
//   id = The attribute id for whose data type you want. No default.
// Example:
//   axle = Axle();
//   type = obj_toc_get_attr_type_by_id(axle, 1);
//   // type == "i"
function obj_toc_get_attr_type_by_id(obj, id) = obj_toc_get_attr_types(obj)[ id ];


// Function: obj_toc_attr_id_by_name()
// Usage:
//   obj_addr_id_by_name(object, name);
// Description:
//   Tranlate function to convert attribute names to list index in the object's attribute TOC. 
//   Given an object with a valid TOC and a `name` argument, looks up the `name` within the TOC 
//   and returns the expected index of the attribute within the object list. 
//   .
//   If `name` is not found within the TOC, or if no TOC is found at index `0`, an error is thrown. 
//   .
//   Functionally the opposite of `obj_toc_attr_id_by_name()`. 
// Example:
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   // axle == [["Axle", ["diameter", "i"], ["length", "i"]], 10, 30];
//   id = obj_toc_attr_id_by_name(axle, "diameter");
//   // id == 1
// Example:
//   axle = Axle([]);
//   // axle == [["Axle", ["diameter", "i"], ["length", "i"]], undef, undef];
//   id = obj_toc_attr_id_by_name(axle, "not-found");
//   // error is thrown
// EXTERNAL - 
//   is_list() (BOSL2);
function obj_toc_attr_id_by_name(obj, name) = 
    assert(is_list(obj[0]), 
        str("obj_toc_attr_id_by_name(): first item in obj ",
            "expected to be a TOC, instead found '", 
            obj[0], "' (", obj, ")"))
    let(
        id = (name == "_toc_") 
            ? 0
            : [ for ( i = [1:obj_toc_attr_len(obj)] ) if (name == obj[0][i][0]) i ][0] 
    )
    assert(_defined(id), 
        str("obj_toc_attr_id_by_name(): No id match for attribute '", name, 
            "' found for ", obj_toc_get_type(obj),
            ". Available attribute names are: ", obj_toc_get_attr_names(obj) ))
    id;


// Function: obj_toc_attr_name_by_id()
// Usage:
//   obj_toc_attr_name_by_id(object, id);
// Description:
//   Translate function to convert attribute IDs (indexed positions within the object list) to the object 
//   attribute's name within the object's TOC. Given an object with a valid TOCC and an `id` argument, 
//   returns the name at that `id` list index from the object's TOC. 
//   .
//   If `id` is not found within the TOC, or if no TOC is found at index `0`, an error is thrown. 
//   .
//   Functionally the opposite of `obj_toc_attr_id_by_name()`. 
// Example:
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   // axle == [["Axle", "diameter", "length"], 10, 30];
//   name = obj_toc_attr_name_by_id(axle, 1);
//   // name == "diameter"
// Example:
//   axle = Axle([]);
//   // axle == [["Axle", "diameter", "length"], undef, undef];
//   name = obj_toc_attr_name_by_id(axle, 3);
//   // error is thrown
// EXTERNAL - 
//   is_list() (BOSL2); 
function obj_toc_attr_name_by_id(obj, id) = 
    assert(is_list(obj[0]), 
        str("obj_toc_attr_name_by_id(): first item in obj expected ",
            "to be a TOC, instead found ", obj[0]))
    let(
        name = (id == 0) ? "_toc_" : obj[0][id][0]
    )
    assert(_defined(name), 
        str("obj_toc_attr_name_by_id(): No name match for id '", id, 
            "' found for ", obj_toc_get_type(obj),
            ". Available attributes range from 0 through ", 
            len(obj_toc_get_attr_names(obj)) ))
    name;


// Function: attr_arglist_to_vlist()
// Description:
//   When you have an existing object and want named module arguments to 
//   take precedence with a mutation, attr_arglist_to_vlist() simplifies that 
//   process. Pass the arguments and their values as a flat list, and 
//   attr_arglist_to_vlist() will return a vlist suitable for a new object. 
// Usage:
//   vlist = attr_arglist_to_vlist(flattened_arglist);
//   [["length", 10], ["height", 10]] = attr_arglist_to_vlist(["length", 10, "height", 10, "wall", undef]);
// Example:
//   module axle(axle, length=undef, height=undef) {
//      vlist = attr_arglist_to_vlist(["length", length, "height", height]);
//      //  for arguments that have a value, returns `[[attr, val]]`. 
//      localized_axle = Axle(vlist, mutate=axle);
//      // localized_axle now has all the values of `axle`, except 
//      // for arguments to this module that are defined. 
//   }
// EXTERNAL - 
//   list_to_matrix() (BOSL2);
function attr_arglist_to_vlist(list) = [ for (i=list_to_matrix(list, 2)) if (_defined(i[1])) i ];
    

// Function: attr_and_type_from_string_or_pairs()
// Description:
//   Given either a list-pair of `[attribute, type]`, or a string of `attribute=type`, 
//   return a tuple list-pair of `[attribute, type]`. `attribute` should be an attribute name 
//   for an object list under construction. If `type` is gleanable, it should be one of 
//   types listed in `ATTRIBUTE_DATA_TYPES`. If `type` is not gleanable, it will be set to `undef`. 
// Arguments:
//   tuple = Either a string or list pair from which to construct the pairing. 
// Todo:
//   no real format or bounds checking is done on `tuple`, perhaps we should.
function attr_and_type_from_string_or_pairs(tuple) = 
    let(
        default_type = undef,
        pairs = (is_list(tuple)) ? tuple : str_split(tuple, "="),
        attr_name = pairs[0],
        attr_type = (_defined(pairs[1])) ? pairs[1] : default_type
        )
    assert(_defined(attr_name),
        str("attr_and_type_from_string_or_pairs(): No attribute ",
            "name gleanable from '", tuple, "'"))
    [attr_name, attr_type];


// Function: obj_get_values()
// Description:
//   Given an object, return the values of the attributes listed in its 
//   TOC, as a list. This is functionally the same as doing `[for (i=[1:len(obj[0])-1]) obj[i]]`.
//   Values are returned in the order in which they're stored in the object. 
//   .
//   `obj_get_values()` does not return the object's TOC, so `len(object) > len(obj_get_values(object))`. 
//   .
//   `obj_get_values()` does not return values via the built-in accessor `obj_accessor()`, and no 
//   value defaults or type checking is done on the values before they're returned. 
// Usage:
//   obj_get_values(obj);
// Arguments:
//   obj = An Object list. No default. 
// Example:
//   axle = Axle([["diameter", 5], ["length", 10]]);
//   values = obj_get_values(axle);
//   // values == [5, 10];
function obj_get_values(obj) = slice(obj, 1);


// Function: obj_has_value()
// Description:
//   Given an object, return `true` if any one of its attributes are defined. If no attributes 
//   have a value defined, `obj_has_value()` returns `false`. 
//   .
//   Note: `obj_has_value()` does not evaluate the values of an object using any accessors, there is no 
//   conditional evaluation of the values done: objects that provide accessors with defaults 
//   won't use those accessors here, and unset attribute values will be considered undefined. 
// Usage:
//   obj_has_value(obj);
// Arguments:
//   obj = An Object list. No default. 
// Example:
//   axle = Axle([]);
//   retr = obj_has_value(axle);
//   // retr is `false`
// Example:
//   axle = Axle([["length", 20]]);
//   retr = obj_has_value(axle);
//   // retr is `true`
function obj_has_value(obj) = (_defined_len(obj_get_values(obj)) > 0) ? true : false;



// Subsection: Object Base Accessors
//   The attribute accessors. There's one mutatable accessor, `obj_accessor()`, that 
//   can both `get` and `set` values by attribute name. There are also 
//   two get- and set-specific accessors: `obj_accessor_get()` returns attributes in a 
//   read-only manner; and, `obj_accessor_set()` returns a modifed object list after 
//   setting the attribute to a new value. And, there is `obj_accessor_unset()`, to 
//   set a named attribute explicitly to `undef` (essentially, a delete).
//
// Function: obj_accessor()
// Description:
//   Basic accessor for object attributes. Given an object `obj` and an attribute name `name`, operates on that attribute. 
//   The operation depends on what other options are passed. Calls to `obj_accessor()` with an `nv` (new-value) option 
//   defined will create a new object based on `obj` with the new value set for `name`, and then will return that 
//   new object (a "set" operation). 
//   Calls to `obj_accessor()` without the `nv` option will look the current 
//   value of `name` up in the object and return it (a "get" operation). "Get" operations can provide a `default` option: 
//   if a `default` is defined and the value of `name` in the object is undefined, the value of `default` will be returned
//   instead. 
//   
// Usage:
//   obj_accessor(obj, name, <default=undef>, <nv=undef>);
// Usage: to retrieve an attribute's value from an object:
//   value = obj_accessor(obj, name);
// Usage: to set an attribute's value into an object:
//   new_object = obj_accessor(obj, name, nv=new_value);
// Arguments:
//   obj = An Object list. No default. 
//   name = The attribute name to access. The name must be present in `obj`'s TOC. No default. 
//   ---
//   default = If provided, and if there is no existing value for `name` in the object `obj`, returns the value of `default` instead. 
//   nv = If provided, `accessor()` will update the value of the `name` attribute and return a new Object list. *The existing Object list is unmodified.*
// Continues:
//   It's not an error to provide both `default` and `nv` in the same request, but doing so will yield a warning 
//   nonetheless. If they're both present, `obj_accessor()` will act on the new value in `nv` and return a new object 
//   list, and not evaluate or set the value from `default`. 
//   .
//   It's not an error to provide a `nv` argument that is `undef`; however, if you're unknowningly passing `undef` with `nv` 
//   expecting it to clear the attribute in that object, or because you thought it was set to a value, `obj_accessor()` 
//   won't know what you meant to do and will act as if you wanted to "get" the value for that attribute. To explicitly 
//   clear an object's attribute, use `obj_accessor_unset()`. To explicitly set an attribute to a new value, use 
//   `obj_accessor_set()` (which will error out if `nv` is not defined). 
// Example: direct "get" call to `obj_accessor()`:
//   axle = Axle(["length", 30]]);
//   length = obj_accessor(axle, "length");
//   // length == 30
//   diameter = obj_accessor(axle, "diameter", default=10);
//   // diameter == 10
//   // (diameter is unset in the `axle` object, so the default of 10 is returned instead)
// Example: direct "set" calls to `obj_accessor()`:
//   axle = Axle([["length", 30]]);
//   new_axle = obj_accessor(axle, "length", nv=6);
//   // new_axle's `length` value is now 6. 
//   // axle's `length` value is still 30.
// Example: gotcha when providing `undef` as a new-value:
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   new_axle = obj_accessor(axle, "length", nv=undef);
//   // new_axle == 6, because obj_accessor() didn't see a value for nv, and returned the "length" attribute instead.
// Example: providing a class-specific "glue" accessor:
//   function axle_acc(axle, name, default=undef, nv=undef) = obj_accesor(axle, name, default, nv);
//   // ..
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   dia = axle_acc(axle, "diameter");
//   // dia == 10
// Example: providing a class- and attribute-specific "glue" accessor:
//   function axle_diameter(axle, default=undef, nv=undef) = obj_accessor(axle, "diameter", default=default, nv=nv);
//   // ...
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   diameter = axle_diameter(axle);
//   // diameter == 10
//   new_axle = axle_diameter(axle, nv=9);
//   // new_axle == [9, 30] 
// Todo: 
//   when getting an attribute without a value and a default is provided, do a type check on the default value before returning
// EXTERNAL - 
//   list_set() (BOSL2);
function obj_accessor(obj, name, default=undef, nv=undef) = 
    let(
        _ = (_defined(default) && _defined(nv))
            ? echo(str("WARNING: obj_accessor(): ",
                obj_toc_get_type(obj), ": both 'default' and 'nv' are specified for '", 
                name, "', but only 'nv' takes effect."))
            : undef,
        id = obj_toc_attr_id_by_name(obj, name)
    )        
    (nv) 
        ? (id == 0)
            ? assert(false, str("obj_accessor(): ", obj_toc_get_type(obj), 
                ": Can't use obj_accessor() to change the TOC."))
            : (obj_type_check_value(obj, name, nv))
                ? list_set(obj, id, nv)
                : assert(false, str("obj_accessor(): new value for '", name, 
                    "' doesn't match that attribute's type of '"))
        : _first([obj[id], default]);


// Function: obj_accessor_get()
// Description:
//   Basic "get" accessor for Objects. Given an object `obj` and attribute name `name`, `obj_accessor_get()` will look the current 
//   value of `name` up in the object and return it (a "get" operation). Callers can provide a `default` option: 
//   if a `default` is defined and the value of `name` in the object is undefined, the value of `default` will be returned
//   instead. 
// Usage:
//   obj_accessor_get(obj, name, <default=undef>);
// Arguments:
//   obj = An Object list. No default. 
//   name = The attribute name to access. The name must be present in `obj`'s TOC.
//   ---
//   default = If provided, and if there is no existing value for `name` in the object `obj`, returns the value of `default` instead. 
// Continues:
//   Note that `obj_accessor_get()` will accept a `nv` option, to make writing accessor glue easier, but 
//   that `nv` option won't be evaluated or used. 
// Example: direct calls to `obj_accessor_get()`:
//   length = obj_accessor_get(axle, "length");
// Example: passing `nv` yields no change:
//   retr = obj_accessor_get(axle, "length", nv=25);
//   // retr == 30 (or, whatever the Axle's `length` previously was)
// Example: providing a class- and attribute-specific "glue" read-only accessor:
//   function get_axle_length(axle, default=undef) = obj_accesor_get(axle, "length", default=default);
//   // ..
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   length = get_axle_length(axle);
//   // length == 30
function obj_accessor_get(obj, name, nv=undef, default=undef) = 
    let(
        _ = (_defined(nv))
            ? echo(str("WARNING: obj_accessor_get(): ", 
                obj_toc_get_type(obj),
                ": 'nv' argument provided to read-only ",
                "obj_accessor_get(), and will be ignored."))
            : undef
    )
    obj_accessor(obj, name, default=default);


// Function: obj_accessor_set()
// Description:
//   Basic "set" accessor for Objects. Given an object `obj`, an attribute name `name`, and a new value `nv` for that 
//   attribute, `obj_accessor_set()` will 
//   return a new Object list with the updated value for that attribute. **The existing list is unmodified,** and 
//   a wholly new Object with the new value is returned instead. 
//   .
//   It is an error to call `obj_accessor_set()` without a new value (`nv`) passed. If the value of `name` needs to be 
//   removed, use `obj_accessor_unset()` instead. 
// Usage:
//   obj_accessor_set(obj, name, nv);
// Arguments:
//   obj = An Object list. No default. 
//   name = The attribute name to access. The name must be present in `obj`'s TOC.
//   nv = If provided, `obj_accessor_set()` will update the value of the `name` attribute and return a new Object list. *The existing Object list is unmodified.*
// Continues:
//   Note that `obj_accessor_set()` will accept a `default` option, to make writing accessor 
//   glue easier, but it won't be evaluated or used. 
// Example: direct call to `obj_accessor_set()`
//   new_axle = obj_accessor_set(axle, "length", nv=20);
//   // new_axle's `length` attribute is now 20
// Example: providing a class- and attribute-specific "glue" write-only accessor:
//   function set_axle_length(axle, nv) = obj_accessor_set(axle, "length", nv);
//   // ..
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   new_axle = set_axle_length(axle, 40);
//   // new_axle == [["Axle", "diameter", "length"], 10, 40];
// Example: gotchas when setting undefined values with `obj_accessor()`:
//   // Setting no value in `nv` will *not* do what you want!
//   function set_axle_length(axle, nv=undef) = obj_accessor(axle, "length", nv);
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   new_axle = set_axle_length(axle);
//   // new_axle == 30  //<--- This is the `length` value, NOT a new object. 
//   // Because the `nv` option wasn't provided, the call arrived into `obj_accessor()` as `undef`, and 
//   // was treated as a "get". 
function obj_accessor_set(obj, name, nv, default=undef) = 
    assert(_defined(name), str("obj_accessor_set(): attribute name must ",
        "be provided; called with: ", name))
    assert(_defined(nv), 
        str("obj_accessor_set(): ",
            obj_toc_get_type(obj),
            ": No new value (nv) passed when for changing the '", name, "' attribute."))
    let(
        _ = (_defined(default))
            ? echo(str("WARNING: 'default' argument provided to write-only ",
                "obj_accessor_set(), and will be ignored."))
            : undef
    )
    obj_accessor(obj, name, nv=nv);


// Function: obj_accessor_unset()
// Description:
//   Basic "delete" accessor for Objects. A new Object will be returned 
//   with the un-set attribute value. **The existing Object list is unmodified,** and a 
//   wholly new Object list with the unset value is returned instead. 
// Usage:
//   obj_accessor_unset(obj, name);
// Arguments:
//   obj = An Object list. No default. 
//   name = The attribute name to access. The name must be present in `obj`'s TOC.
// Example:
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   new_axle = obj_accessor_unset(axle, "length");
//   // new_axle == [["Axle", "diameter", "length"], 10, undef];
// EXTERNAL - 
//   list_set() (BOSL2);
function obj_accessor_unset(obj, name) = 
    list_set(obj, obj_toc_attr_id_by_name(obj, name), undef);


// ------------------------------------------------------------------------------------------------------------
// Subsection: Object Attribute Data Types
//   
// Constant: ATTRIBUTE_DATA_TYPES
// Description:
//   A list of known attribute data types. "Types" in this context are 
//   single-character symbols that indicate what the attribute is 
//   meant to hold. 
// Attributes:
//   s = literal strings. Example: `"a string"`. *(Note: Strings are always assigned with quotes and we show that here, but the quotes are not part of the string.)* 
//   i = integers. Example: `1`
//   b = booleans. Example: `true`
//   l = lists. There is no restriction on list length or content. Example: `[1, 2, "abc"]`
//   u = undefined. Example: `undef`
//   o = objects. Objects in this context lists that are expected to have a valid TOC as their first element. Example: `[["Object", ["attribute", "b"]], undef]`
ATTRIBUTE_DATA_TYPES = [
    "s",  // string
    "i",  // integer (numbers, both integers and floats)
    "b",  // boolean (true/false)
    "l",  // list (or vector)
    //"r",  // range
    "u",  // undefined
    "o",  // object (of the class 'o:{whatever}')
    ];


// Function: obj_type_is_valid()
// Description:
//   Given a type, returns `true` if the type is found within ATTRIBUTE_DATA_TYPES, or false otherwise. 
// Usage:
//   obj_type_is_valid(type);
// Arguments:
//   type = the type of data to check. No default. 
function obj_type_is_valid(type) = in_list(type, ATTRIBUTE_DATA_TYPES);


// Function: obj_type_check_value()
// Description:
//   Given a valid object, an attribute `name`, and a `value`, check to see if the 
//   value is the same data type as the attribute's type for that Object. If the 
//   provided value matches, `obj_type_check_value()` returns true. 
//   Returns false otherwise. 
// Usage:
//   obj_type_check_value(obj, name, value);
// Arguments:
//   obj = An Object list. No default. 
//   name = An attribute name that exists within `obj`. No default.
//   value = A value to compare against `name`'s data type. No default. 
// Todo: 
//   figure out if we care about enforcing object types (eg, `["attr-name", "o:Axle"]`)
function obj_type_check_value(obj, name, value) = 
    let(
        type_id = obj_toc_get_attr_type_by_name(obj, name)
    )
    assert(obj_type_is_valid(type_id), 
        str("obj_type_check_value(): Unknown type_id: ", type_id))
    (type_id == "o")
        ? is_list(value)
        :(type_id == "i") 
            ? is_num(value) 
            : (type_id == "s")
                ? is_string(value)
                : (type_id == "b")
                    ? is_bool(value)
                    : (type_id == "l")
                        ? is_list(value)
                        : (type_id == "u")
                            ? is_undef(value)
                            : false;


// ------------------------------------------------------------------------------------------------------------

// Section: Support Functions
//   These are pulled directly from the 507 Project. To keep warnings down, 
//   they're prefixed with an underscore (`_`), but otherwise are direct copies. 
//   . 
//   The remainder of the functions that this LibFile relies on are present in 
//   BOSL2, all from the set of functions that make managing lists in OpenSCAD easier. They are:
//   `flatten()`, `list_insert()`, `list_pad()`, `list_set()`, `list_shape()`, and `list_to_matrix()`.
// 
// Function: _defined()
// Description:
//   Given a variable, return true if the variable is defined. 
//   This doesn't differenate `true` vs `false` - `false` is still defined. 
//   `_defined()` tests to see if a string value is something other than `undef`, 
//   or a list value is something other than `[]` (an empty list). 
//   *Mnem: this tests if the var has a value.*
// Usage: 
//   _defined(value);
// Arguments:
//   value = The thing to test definition.
// Example(NORENDER):
//   _defined(undef);  // Returns: false
//   _defined(1);      // Returns: true
//   _defined(0);      // Returns: true
//   _defined(-1);     // Returns: true
//   _defined("a");    // Returns: true 
//   _defined([]);     // Returns: false
//   _defined(true);   // Returns: true
//   _defined(false);  // Returns: true
function _defined(a) = (is_list(a)) ? len(a) > 0 : !is_undef(a);


// Function: _first()
// Description:
//   Given a list of values, returns the first defined (as per `_defined()`) in the list.
//   Because we're using `_defined()` to test each value in the list, 
//   `false` is a valid candidate for return. 
//   .
//   If there's no suitable element that can be returned, `_first()` returns undef.  
// Usage:
//   _first(list);
// Arguments:
//   list = The list from which to examine for the first defined item. `list` can be comprised of any variable type that is testable by `_defined()`. 
// Example(NORENDER):
//   _first([undef, "a"]);       // Returns: "a"
//   _first([0, 1]);             // Returns: 0         (because 0 is defined)
//   _first([false, 1]);         // Returns: false     (because false is defined)
//   _first([[]], "a"]);         // Returns: "a"       (because an empty list is undefined)
//   _first([undef, [[]]);       // Returns: undef     (because there is no valid, defined element)
// See Also: _defined()
function _first(list) = [for (i = list) if (_defined(i)) i][0];


// Function: _defined_len()
// Description:
//   Given a list of values, returns the number of defined elements in that 
//   list. If there are no elements, or if all elements are undefined, returns `0`.
// Usage:
//   _defined_len(list);
// Arguments:
//   list = A list of items to count. `list` can be comprised of any variable type that is testable by `_defined()`. 
// Example(NORENDER):
//   _defined_len([0, 1, 2]);         // Returns: 3
//   _defined_len([undef, 1, 2]);     // Returns: 2
// See Also: _defined()
function _defined_len(list) = len([ for (i=list) if (_defined(i)) i]);

function _assert_assign_if_defined(a, b, msg) = (_defined(a)) 
    ? assert( (b) ? b : a, msg ) a
    : a;



