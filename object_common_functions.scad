// LibFile: object_common_functions.scad
//   Functions for creating and accessing object-like lists. 
//   .
//   **Note:** throughout this LibFile, we refer to things as Objects.
//   I *wish* they were real, blessed, official capital-O Objects,
//   and they're not. See [this project's HOWTO wiki](https://github.com/jon-gilbert/openscad_objects/wiki/HOWTO) 
//   for a quick-start, minimum number of steps to get this into your OpenSCAD modules. 
//
// FileSummary: Functions for creating and accessing object-like lists.
// Includes:
//   include <object_common_functions.scad>

include <BOSL2/std.scad>


// Section: Object Functions
//   .
//
// Subsection: Base Object Functions & Usage
//   These functions assist the creating and usage of object-like lists: "Objects".
//   .
//   Objects have two basic parts: a list of attributes, their types, and default 
//   values; and, a list of values for those attributes.
//   ```openscad
//   object = [
//      TOC,
//      value_1,
//      value_N
//      ];
//   ```
//   The list of attributes, their data types, and their default values are all stored in the 
//   first element in the Object list: this is the table-of-contents (or "TOC"). The TOC is 
//   itself a list, and each element in the TOC list is an attribute defintion. 
//   After the TOC, each element in the Object list is the value of the attributes listed in the 
//   definition. 
//   .
//   The functions in this section deal with creating the Object, and with its validity. 
//
// Function: Object()
// Synopsis: Create a generic Object
// Usage:
//   object = Object(name, attrs);
//   object = Object(name, attrs, <vlist=vlist>, <mutate=object>);
// Description:
//   Given an Object name as a string `name`, a list of attributes `attrs`, 
//   optionally a list of variable-listed values `vlist`, and optionally an existing 
//   Object to model against `mutate`, create and return an Object-like list `object`.
//   This Object will be a list that is `len(attrs) + 1` elements long: the first element
//   will be a table-of-contents element containing the names and data types of each attribute;
//   the remaining elements will be the values assigned to those attributes. 
//   .
//   **Defining what attributes the Object has with `attrs`:**
//   The `attrs` argument is a list of attribute names, and optionally data types and defaults, 
//   upon which the Object will be modeled. Each element in `attrs` is either a string or a list.
//   In string form, the attribute's defining format is:
//   `name[=data_type[=default]]`, where `name` is the name of the attribute; and, `data_type` is 
//   one of the supported data types listed below in `ATTRIBUTE_DATA_TYPES`; and, `default` is 
//   a default value for that attribute. 
//   ```openscad
//   Object_Attributes = [
//      "a1=s",            // defines "a1", a string attribute
//      "a2=i=10"          // defines "a2", an integer attribute, with a default of 10
//   ];
//   ```
//   When using the list form to define attributes, the attribute's defining format is a three-element list: 
//   `[name, data_type, default]`. The three elements directly map to those in the string 
//   format. Using a list format is required when the `default` is not easily represented in a 
//   simple string (such as when the default is a list itself, or an object, or a pre-defined 
//   constant such as `PI` or `CENTER`). 
//   ```openscad
//   Object_Attributes = [
//      ["a1", "s"],             // defines "a1", a string attribute
//      ["a2", "i", 10],         // defines "a2", an integer attribute, with a default of 10
//      ["a3", "l", [1, 2, 3]],  // defines "a3", a list attribute, with a default list
//   ];
//   ```
//   .
//   **Pre-populating Objects with values with `vlist`:** 
//   The `vlist` listing argument to `Object()` is a variable list of `[attribute, value]` lists. 
//   Attribute pairs given in `vlist` can be in any order. Attribute pairs may not be repeated. 
//   Unspecified attributes will be set to `undef`. 
//   .
//   **Modelling Objects from other Objects with `mutate`:**
//   Optionally, an existing, similar Object can be provided via the `mutate` argument: that 
//   existing Object list will be used as the original set of Object attribute values, with any 
//   new values provided in `vlist` taking precedence.
// Arguments:
//   name = The "name" of the object (think "classname"). No default. 
//   attrs = The list of known attributes, and optionally their type and default for this object. No default. 
//   ---
//   vlist = Variable list of attributes and values: `[ ["length", 10], ["style", "none"] ]`; **or,** a list of running attribute value pairing: `["length", 10, "style", "none"]`. Default: `[]` (which will produce an Object with no values).
//   mutate = An existing Object of a similar `name` type on which to pre-set values. Default: `[]`
// Continues:
//   `Object()` returns a list that should be treated as an opaque object: reading values directly 
//   from the `object` list, or modifying them manually into a new list, is not entirely safe.
// Example(NORENDER): empty object creation: this is an empty object that has no values assigned to its attributes:
//   obj = Object("Obj", ["attr1=i", "attr2=s", "attr3=b=true"]);
//   echo(obj);
//   // emits: ECHO: [["Obj", ["attr1", "i", undef], ["attr2", "s", undef], ["attr3", "b", true]], undef, undef, undef]
// Example(NORENDER): same empty object creation, but with the object shown with `obj_debug_obj()`. Note that while `attr3` has a default value set, all of the attributes are still undefined:
//   obj = Object("Obj", ["attr1=i", "attr2=s", "attr3=b=true"]);
//   echo(obj_debug_obj(obj));
//   // emits: ECHO: "0: _toc_: Obj
//   // 1: attr1 (i: undef): undef
//   // 2: attr2 (s: undef): undef
//   // 3: attr3 (b: true): undef"
// Example(NORENDER): pre-populating object attributes at creation. Note the values set for `attr2` and `attr3`:
//   o = Object("Obj", ["attr1=i", "attr2=s", "attr3=b=true"], [["attr2", "hello"], ["attr3", false]]);
//   echo(obj_debug_obj(o));
//   // emits: ECHO: "0: _toc_: Obj
//   // 1: attr1 (i: undef): undef
//   // 2: attr2 (s: undef): hello
//   // 3: attr3 (b: true): false"
// Example(NORENDER): pre-populating just as above, with the same attributes and values, but with a simpler `vlist`:
//   o = Object("Obj", ["attr1=i", "attr2=s", "attr3=b=true"], ["attr2", "hello", "attr3", false]);
//   echo(obj_debug_obj(o));
//   // emits: ECHO: "0: _toc_: Obj
//   // 1: attr1 (i: undef): undef
//   // 2: attr2 (s: undef): hello
//   // 3: attr3 (b: true): false"
// Example(NORENDER): using `mutate` will carry values from a previous Object into a new one, with `vlist` values taking precedence:
//   O_attrs = ["attr1=i", "attr2=s", "attr3=b=true"];
//   o = Object("Obj", O_attrs, [["attr2", "hello"], ["attr3", false]]);
//   echo(obj_debug_obj(o));
//   o2 = Object("Obj", O_attrs, vlist=["attr1", 12], mutate=o);
//   echo(obj_debug_obj(o2));
//   // emits:
//   // ECHO: "0: _toc_: Obj
//   // 1: attr1 (i: undef): undef
//   // 2: attr2 (s: undef): hello
//   // 3: attr3 (b: true): false"
//   // ECHO: "0: _toc_: Obj
//   // 1: attr1 (i: undef): 12
//   // 2: attr2 (s: undef): hello
//   // 3: attr3 (b: true): false"
// Example(NORENDER): when using `mutate`, you can specify an empty `attrs` list: the attributes will be carried over from the mutated Object:
//   O_attrs = ["attr1=i", "attr2=s", "attr3=b=true"];
//   o = Object("Obj", O_attrs, [["attr2", "hello"], ["attr3", false]]);
//   echo(obj_debug_obj(o));
//   o2 = Object("Obj", [], vlist=["attr1", 12], mutate=o);       // <-- an empty `attrs` list specified
//   echo(obj_debug_obj(o2));
//   // emits:
//   // ECHO: "0: _toc_: Obj
//   // 1: attr1 (i: undef): undef
//   // 2: attr2 (s: undef): hello
//   // 3: attr3 (b: true): false"
//   // ECHO: "0: _toc_: Obj
//   // 1: attr1 (i: undef): 12
//   // 2: attr2 (s: undef): hello
//   // 3: attr3 (b: true): false"
//
// See Also: obj_debug_obj(), ATTRIBUTE_DATA_TYPES
// EXTERNAL - 
//    is_list(), list_insert(), list_shape(), list_pad(), list_set() (BOSL2); 
function Object(name, attrs=[], vlist=[], mutate=[]) =
    assert(is_list(attrs), str(name, " argument 'attrs' must be a list"))
    assert(is_list(vlist), str(name, " argument 'vlist' must be a list"))
    let(_ = _assert_assign_if_defined(mutate, obj_is_obj(mutate), 
        str(name, " argument 'mutate' must be an Object")))
    let(
        // build the TOC. The TOC ends up looking like:
        //   ["Name", ["attr1", "type1"], ["attr2", "type2"] ... ]
        // If no type is specified in the attrs or in mutate, each 
        // attribute's `type` will be "undef". 
        obj_toc = obj_toc_build(name, attrs, mutate),
        
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
// Synopsis: Test to see if a given value could be an Object
// Usage:
//   bool = obj_is_obj(obj);
// Description: 
//   Given a thing, possibly an Object, returns true if that thing can be considered an Object, of any type. 
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
// Example(NORENDER): a positive test for an Object with `obj_is_obj()`:
//   obj = Object("Obj", ["attr=i"]);
//   echo(obj_is_obj(obj));
//   // emits: ECHO: true
// Example(NORENDER): a false test for an Object:
//   echo(obj_is_obj(1));
//   // emits: ECHO: false
function obj_is_obj(obj) = 
    (is_list(obj))                                          // "Object base type must be a list")
        && (_defined(obj[0]))                               // "First element in object list must be defined"
        && (is_list(obj[0]))                                // "First element in object list must be a list"
        && (len(obj[0]) == len(obj))                        // "Objects must have the same number of elements and attributes in its TOC")
        && (list_shape(list_tail(obj_toc_get_attributes(obj), 1), 1) == 3);  // "Attributes and type pairing within the TOC must be consistent, and must be 2")


// Function: obj_is_valid()
// Synopsis: Deeply test an Object to ensure its data types are consistent
// Usage:
//   bool = obj_is_valid(obj);
// Description:
//   Given an object `obj`, returns `true` if the object is "valid", and `false` otherwise. "Valid" in this 
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
// Synopsis: Given an Object, return a single string that describes the Object 
// Usage:
//   string = obj_debug_obj(obj);
//   string = obj_debug_obj(obj, <show_defaults=true>, <sub_defaults=false>);
// Description: 
//   Given an object `obj`, return a string `string` of debug layout information 
//   of the object. Nested objects within the object will also 
//   be expanded with a visual indent.
// Arguments:
//   obj = An Object list. No default. 
//   ---
//   show_defaults = If enabled, then TOC-provided defaults will be shown alongside the attribute data types. Default: `true`
//   sub_defaults = If enabled, then TOC-provided defaults will be shown as the attribute's value, if the value is not set. Default: `false`
// Continues:
//   `obj_debug_obj()` does not output this debugging information anywhere: it's up 
//   to the caller to do this. 
// Example(NORENDER):
//   O_attrs = ["attr1=i", "attr2=s", "attr3=b=true"];
//   o = Object("Obj", O_attrs, [["attr2", "hello"], ["attr3", false]]);
//   echo(obj_debug_obj(o));
//   // emits:
//   // ECHO: "0: _toc_: Obj
//   // 1: attr1 (i: undef): undef
//   // 2: attr2 (s: undef): hello
//   // 3: attr3 (b: true): false"
function obj_debug_obj(obj, ws="", sub_defaults=false, show_defaults=true) =
    let(
        debug_data_toc = str(ws, "0: _toc_: ", obj_toc_get_type(obj)),
        debug_data = [
            for( i=[1:obj_toc_attr_len(obj)] ) 
                str(ws, 
                    // attribute id name: "1: x"
                    i, ": ", obj_toc_attr_name_by_id(obj, i), 

                    // attribute type & default value: " (s: x)"
                    " (", obj_toc_get_attr_types(obj)[i], 
                        (show_defaults)
                            ? str(": ", obj_toc_get_attr_default_by_id(obj, i))
                            : "",
                    "): ", 

                    // attribute value; if it's an object, recurse 
                    // into obj_debug_obj()
                    (obj_toc_get_attr_types(obj)[i] == "o" 
                            && _defined(obj_accessor_get(obj, 
                                obj_toc_attr_name_by_id(obj, i), 
                                _consider_toc_default_values=sub_defaults)))
                        ? str("\n", 
                            obj_debug_obj(
                                obj_accessor_get(obj, 
                                    obj_toc_attr_name_by_id(obj, i)), 
                                ws=str(ws, "   "), 
                                sub_defaults=sub_defaults)
                            )
                        : obj_accessor_get(obj, 
                            obj_toc_attr_name_by_id(obj, i), 
                            _consider_toc_default_values=sub_defaults)
                    )
            ],
        full_data = list_insert(debug_data, [0], [debug_data_toc])
    )
    str_join(full_data, "\n");


// Function: obj_has()
// Synopsis: Test to see if an Object has a particular attribute
// Usage:
//   bool = obj_has(obj, name);
// Description:
//   Given an object `obj` and an accessor name `name`, return `true` if the object "can" access 
//   that name, or `false` otherwise. An object need not have a specified value for the given name, 
//   only the ability to access and refer to it; in other words, if the `name` exists in the Object's 
//   TOC, then `obj_has()` will return true. 
//   .
//   Essentially, this is a thinly wrapped `obj_toc_get_attr_names()`.
//   .
//   This might seem similar way to perl5's `can()` or python's `callable()`, but this is inaccurate: 
//   `obj_has()` cannot test if the object is able to execute or call the given `name`; it can only 
//   tell if the object has the given `name` as an attribute. The perl5 `exists()` or python `hasattr()` 
//   functions would be more analagous to `obj_has()`. 
// Arguments:
//   obj = An Object list. No default.
//   name = A string that may exist as an attribute for the Object. No default.
// Example(NORENDER):
//   obj = Object("ExampleObj", ["a1=i=10", "a2=i", "a3=i=13"], ["a1", 10, "a2", 12, "a3", 23]);
//   b = obj_has(obj, "a1");
//   // b == true
// Example(NORENDER):
//   obj = Object("ExampleObj", ["a1=i=10", "a2=i", "a3=i=13"], ["a1", 10, "a2", 12, "a3", 23]);
//   b = obj_has(obj, "radius");
//   // b == false
function obj_has(obj, name) = in_list(name, obj_toc_get_attr_names(obj));


// Function: obj_has_value()
// Synopsis: Test to see if an Object has any data in it
// Usage:
//   bool = obj_has_value(obj);
// Description:
//   Given an object `obj`, return `true` if any one of its attributes are defined. If no attributes 
//   have a value defined, `obj_has_value()` returns `false`. 
//   .
//   `obj_has_value()` does not evaluate the values of an object using any accessors, there is no 
//   conditional evaluation of the values done: objects that provide accessors with defaults 
//   won't use those accessors here, and unset attribute values will be considered undefined. 
// Arguments:
//   obj = An Object list. No default. 
// Example(NORENDER):
//   obj = Object("ExampleObj", ["a1=i=10", "a2=i", "a3=i=13"], ["a1", 10, "a2", 12, "a3", 23]);
//   retr = obj_has_value(obj);
//   // retr == `true`
// Example(NORENDER):
//   obj = Object("ExampleObj", ["a1=i=10", "a2=i", "a3=i=13"]);
//   retr = obj_has_value(obj);
//   // retr == `false`
function obj_has_value(obj) = (_defined_len(obj_get_values(obj)) > 0) ? true : false;


// Function: obj_get_names()
// Synopsis: Get a list of all the attribute names in the Object
// Usage:
//   names = obj_get_names(obj);
// Description:
//   Given an object `obj`, return the names of the attributes listed in its TOC as a 
//   list `names`. Names are returned in the order in which they are stored in the Object.
//   .
//   `obj_get_names()` does not return the Object's TOC.
// Arguments:
//   obj = An Object list. No default. 
// Example(NORENDER):
//   obj = Object("ExampleObj", ["a1=i", "a2=i", "a3=i"], ["a1", 10, "a2", 12, "a3", 23]);
//   names = obj_get_names(obj);
//   // names == ["a1", "a2", "a3"];
function obj_get_names(obj) = slice(obj_toc_get_attr_names(obj), 1);


// Function: obj_get_values()
// Synopsis: Get a list of all the values in the Object
// Usage:
//   values = obj_get_values(obj);
// Description:
//   Given an object `obj`, return the values of the attributes listed in its 
//   TOC as a list `values`. This is functionally the same as doing `[for (i=[1:len(obj[0])-1]) obj[i]]`.
//   Values are returned in the order in which they are stored in the object. 
//   .
//   `obj_get_values()` does not return the object's TOC, so `len(object) > len(obj_get_values(object))`. 
//   .
//   `obj_get_values()` does not return values via the built-in accessor `obj_accessor()`, and no 
//   value defaults or type checking is done on the values before they're returned. 
// Arguments:
//   obj = An Object list. No default. 
// Example(NORENDER):
//   obj = Object("ExampleObj", ["a1=i", "a2=i", "a3=i"], ["a1", 10, "a2", 12, "a3", 23]);
//   values = obj_get_values(obj);
//   // values == [10, 12, 23];
/// NOTE: Resist the urge to change `obj_get_values()` to use a wrapped accessor without reexamining `obj_has_value()`
function obj_get_values(obj) = slice(obj, 1);


// Function: obj_get_values_by_attrs()
// Synopsis: Get a list of values from the Object in arbitrary order
// Usage:
//   values = obj_get_values_by_attrs(obj, names);
// Description:
//   Given an object `obj` and a list of attribute names `names`, return the values for those 
//   attributes as a list `values`. Values are returned in the order in which they are 
//   specified in `names`. 
//   If the attributes have no value set, and there is a list of optional defaults `defaults`, 
//   returns the value at the same position as the attribute appears in `names`. 
// Arguments:
//   obj = An Object list. No default. 
//   names = A list of attribute names. No default.
//   ---
//   defaults = A list of default values that positionally map to the attributes in `names`. No default.
// Continues:
//   It is not an error to specify an attribute name multiple times. A `defaults` list that 
//   isn't as long as a `names` list will be padded to be the same length with `undef` elements; however, a 
//   `defaults` list that is *longer* than a `names` list will have its extraneous elements 
//   ignored.
//   .
//   There is no type comparison for the `defaults` list given to `obj_get_values_by_attrs()`
//   against the attributes in `obj`.
// Example(NORENDER):
//   Axle_attributes = ["diameter=i", "length=i"];
//   function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
//   axle = Axle([["diameter", 5], ["length", 10]]);
//   values = obj_get_values_by_attrs(axle, ["length", "diameter"]);
//   // values == [10, 5]
// Example(NORENDER): only one attribute is specified in `names`, and only one value is returned in `values`:
//   Axle_attributes = ["diameter=i", "length=i"];
//   function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
//   axle = Axle([["diameter", 5], ["length", 10]]);
//   values = obj_get_values_by_attrs(axle, ["length"]);
//   // values == [10]
// Example(NORENDER): with no values set in the object, no value is returned for the attributes:
//   Axle_attributes = ["diameter=i=5", "length=i=20"];
//   function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
//   axle = Axle();
//   values = obj_get_values_by_attrs(axle, ["length", "diameter"]);
//   // values == [undef, undef]
// Example(NORENDER): with no value set in the object for "length", the value from `defaults` is returned instead:
//   Axle_attributes = ["diameter=i=5", "length=i=20"];
//   function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
//   axle = Axle(["diameter", 3);
//   values = obj_get_values_by_attrs(axle, ["length", "diameter"], defaults=[12, 12]);
//   // values == [12, 3]
function obj_get_values_by_attrs(obj, names, defaults=[]) =
    let(
        _defaults = list_pad(defaults, len(names), undef)
    )
    [ for (i=idx(names)) obj_accessor_get(obj, names[i], default=_defaults[i]) ];


// Function: obj_get_defaults()
// Synopsis: Get a list of all the attribute defaults in the Object
// Usage:
//   defaults = obj_get_defaults(obj);
// Description:
//   Given an Object `obj`, return the defaults values of the attributes listed in its
//   TOC as a list `defaults`. Defaults are returned in the order in which they are 
//   stored in the Object. If an attribute has no default set, its position in the 
//   `defaults` list will be `undef`.
// Arguments:
//   obj = An Object list. No default. 
// Example(NORENDER):
//   obj = Object("ExampleObj", ["a1=i=10", "a2=i", "a3=i=13"], ["a1", 10, "a2", 12, "a3", 23]);
//   defaults = obj_get_names(obj);
//   // defaults == [10, undef, 13];
function obj_get_defaults(obj) = obj_toc_get_attr_defaults(obj);


// ------------------------------------------------------------------------------------------------------------
// Subsection: Object Accessors
//   These are the Object attribute accessors; functions that "get" and "set" the 
//   attribute values in the Object. 
//   .
//   "Getting" an attribute's value from Object is pretty easy: take the attribute 
//   name, look it up in the TOC to get its index, and use that index to get the 
//   entry from the Object. If there's no value within the Object and a 
//   default is available, return that instead. Works pretty much like every 
//   other OO model out there, easy-peasy. 
//   ```openscad
//      axle = Object("Axle", 
//                    [["diameter", "i"], ["length", "i"]], 
//                    [["diameter", 10],  ["length", undef]]
//                    );
//      echo( obj_accessor_get(axle, "diameter") );
//      // ECHO: 10
//   ```
//   .
//   "Setting" an attribute's value is a little more interesting, because OpenSCAD 
//   doesn't let you change a variable after it's been declared: in other languages, 
//   the data for a class or object may be altered and is liable to change, but in 
//   OpenSCAD you can't do that. So: instead of returning the new value, or 
//   a "you changed this value" success flag, setting an attribute's value returns 
//   _an entirely new Object_. The new Object has the newly-set attribute value, 
//   and the original Object is unmodified.
//   ```openscad
//      axle = Object("Axle", 
//                    [["diameter", "i"], ["length", "i"]], 
//                    [["diameter", 10],  ["length", undef]]
//                    );
//      echo( obj_accessor_get(axle, "length") );
//      // ECHO: undef
//      axle2 = obj_accessor_set(axle, "length", nv=30);
//      echo( obj_accessor_get(axle2, "length") );
//      // ECHO: 30
//   ```
//   .
//   There's one mutable accessor, `obj_accessor()`, that 
//   can both `get` and `set` values by attribute name. There are also 
//   two get- and set-specific accessors: `obj_accessor_get()` returns attributes in a 
//   read-only manner; and, `obj_accessor_set()` returns a modifed object list after 
//   setting the attribute to a new value. And, there is `obj_accessor_unset()`, to 
//   set a named attribute explicitly to `undef` (essentially, a delete).
//
// Function: obj_accessor()
// Synopsis: Generic read/write attribute accessor
// Usage:
//   obj_accessor(obj, name, <default=undef>, <nv=undef>);
// Usage: to retrieve an attribute's value from an object:
//   value = obj_accessor(obj, name);
//   value = obj_accessor(obj, name, <default=undef>);
// Usage: to set an attribute's value into an object:
//   new_object = obj_accessor(obj, name, nv=new_value);
// Description:
//   Basic accessor for object attributes. Given an object `obj` and an attribute name `name`, operates on that attribute. 
//   The operation depends on what other options are passed. Calls to `obj_accessor()` with an `nv` (new-value) option 
//   defined will create a new object based on `obj` with the new value set for `name`, and then will return that 
//   modified object list as `new_object` (a "set" operation). 
//   .
//   Calls to `obj_accessor()` without the `nv` option will look the current value of `name` up in the object and 
//   return it (a "get" operation). "Get" operations can provide a `default` option, for when values aren't set. 
//   The precedence order for "gets" is: `object-stored-value || default-option || object-toc-stored-default || undef`:
//   if the value of `name` in the object is not defined, the value of the `default` option passed to `obj_accessor()`
//   will be returned; if there is no `default` option provided, the object's TOC default will be returned; if there is no TOC default
//   for the object, `undef` will be returned. 
// Arguments:
//   obj = An Object list. No default. 
//   name = The attribute name to access. The name must be present in `obj`'s TOC. No default. 
//   ---
//   default = If provided, and if there is no existing value for `name` in the object `obj`, returns the value of `default` instead. 
//   nv = If provided, `obj_accessor()` will update the value of the `name` attribute and return a new Object list. *The existing Object list is unmodified.*
//   _consider_toc_default_values = If enabled, TOC-stored defaults will be returned according to the mechanics above. If disabled with `false`, the TOC default for a given attribute will not be considered as a viable return value. Default: `true`
// Continues:
//   It's not an error to provide both `default` and `nv` in the same request, but doing so will yield a warning 
//   nonetheless. If they're both present, `obj_accessor()` will act on the new value in `nv` and return a new object 
//   list, and will neither evaluate nor set the value from `default`. 
//   .
//   It's not an error to provide a `nv` argument that is `undef`; however, if you're unknowningly passing `undef` with `nv` 
//   expecting it to clear the attribute in that object, or because you thought it was set to a value, `obj_accessor()` 
//   won't know what you meant to do and will act as if you wanted to "get" the value for that attribute. To explicitly 
//   clear an object's attribute, use `obj_accessor_unset()`. To explicitly set an attribute to a new value, use 
//   `obj_accessor_set()` (which will error out if `nv` is not defined). 
// Example(NORENDER): direct "get" call to `obj_accessor()`:
//   obj = Object("ExampleObj", ["a1=i", "a2=i"], ["a1", 30]);
//   a1 = obj_accessor(obj, "a1");
//   // a1 == 30
//   a2 = obj_accessor(obj, "a2", default=10);
//   // a2 == undef 
//   // (because `a2` is not set in `obj`, and there is no Object default, there is no value to return.)
//   a2_2 = obj_accessor(obj, "a2", default=10);
//   // a2_2 == 10
//   // (`a2` is still unset in the `obj` object, but `default` was provided to `obj_accessor()`, so that default of 10 is returned instead)
// Example(NORENDER): direct "set" calls to `obj_accessor()`:
//   obj = Object("ExampleObj", ["a1=i", "a2=i"], ["a1", 30]);
//   obj2 = obj_accessor(obj, "a1", nv=6);
//   // obj2 is a new object, of the same type as `obj`; its `a1` value is now 6. 
//   // obj's `a1` value is still 30.
// Example(NORENDER): gotcha when providing `undef` as a new-value:
//   obj = Object("ExampleObj", ["a1=i", "a2=i"], ["a1", 10, "a2", 30]);
//   obj2 = obj_accessor(obj, "a1", nv=undef);
//   // obj2 == 10, because `obj_accessor()` didn't see a value for `nv`: instead of changing `a1`, the value of `a1` was returned.
// Todo: 
//   when getting an attribute without a value and a default is provided, do a type check on the default value before returning
// EXTERNAL - 
//   list_set() (BOSL2);
function obj_accessor(obj, name, default=undef, nv=undef, _consider_toc_default_values=true) = 
    let(
        _ = (_defined(default) && _defined(nv))
            ? echo(str("WARNING: obj_accessor(): ",
                obj_toc_get_type(obj), ": both 'default' and 'nv' are specified for '", 
                name, "', but only 'nv' takes effect."))
            : undef,
        id = (_defined(obj) && _defined(name)) 
            ? obj_toc_attr_id_by_name(obj, name) 
            : undef,
        type = (_defined(id))
            ? obj_toc_get_attr_type_by_id(obj, id)
            : undef,
        toc_default = (_defined(id) && _consider_toc_default_values)
            ? obj_toc_get_attr_default_by_id(obj, id)
            : (type == "l")
                ? []
                : undef,
        current_value_ = (_defined(id))
            ? _first([obj[id], default, toc_default, undef])
            : default,
        current_value = (_defined(type) && type == "l" && !_defined(current_value_))
            ? []
            : current_value_
    )        
    (_defined(nv))
        ? (id == 0)
            ? assert(false, str("obj_accessor(): ", obj_toc_get_type(obj), 
                ": Can't use obj_accessor() to change the TOC."))
            : (obj_type_check_value(obj, name, nv))
                ? list_set(obj, id, nv)
                : assert(false, str("obj_accessor(): new value for '", name, 
                    "' doesn't match that attribute's type of '"))
        : current_value;


// Function: obj_accessor_get()
// Synopsis: Generic read-only attribute accessor
// Usage:
//   value = obj_accessor_get(obj, name, <default=undef>);
// Description:
//   Basic "get" accessor for Objects. Given an object `obj` and attribute name `name`, `obj_accessor_get()` will look the current 
//   value of `name` up in the object and return it as `value` (a "get" operation). 
//   .
//   `obj_accessor_get()` is a simplified wrap around `obj_accessor()`, and the mechanics on how values are returned 
//   are the same. "Get" operations can provide a `default` option, for when values aren't set. 
//   The precedence order for "gets" is: `object-stored-value || default-option || object-toc-stored-default || undef`:
//   if the value of `name` in the object is not defined, the value of the `default` option passed to `obj_accessor_get()`
//   will be returned; if there is no `default` option provided, the object's TOC default will be returned; if there is no TOC default
//   for the object, `undef` will be returned. 
// Arguments:
//   obj = An Object list. No default. 
//   name = The attribute name to access. The name must be present in `obj`'s TOC. No default.
//   ---
//   default = If provided, and if there is no existing value for `name` in the object `obj`, returns the value of `default` instead. 
//   _consider_toc_default_values = If enabled, TOC-stored defaults will be returned according to the mechanics above. If disabled with `false`, the TOC default for a given attribute will not be considered as a viable return value. Default: `true`
// Continues:
//   Note that `obj_accessor_get()` will accept a `nv` option, to make writing accessor glue easier, but 
//   that `nv` option won't be evaluated or used. 
// Example(NORENDER): direct calls to `obj_accessor_get()`:
//   obj = Object("ExampleObj", ["a1=i", "a2=i"], ["a1", 30]);
//   value = obj_accessor_get(obj, "a1");
//   // value == 30
// Example(NORENDER): passing `nv` yields no change:
//   obj = Object("ExampleObj", ["a1=i", "a2=i"], ["a1", 30]);
//   value = obj_accessor_get(obj, "a1", nv=25);
//   // value == 30  (the `nv` option is ignored)
// See Also: obj_accessor()
function obj_accessor_get(obj, name, nv=undef, default=undef, _consider_toc_default_values=true) = 
    let(
        _ = (_defined(nv))
            ? echo(str("WARNING: obj_accessor_get(): ", 
                obj_toc_get_type(obj),
                ": 'nv' argument provided to read-only ",
                "obj_accessor_get(), and will be ignored."))
            : undef
    )
    obj_accessor(obj, name, default=default, _consider_toc_default_values=_consider_toc_default_values);


// Function: obj_accessor_set()
// Synopsis: Generic write-only attribute accessor
// Usage:
//   new_object = obj_accessor_set(obj, name, nv);
// Description:
//   Basic "set" accessor for Objects. Given an object `obj`, an attribute name `name`, and a new value `nv` for that 
//   attribute, `obj_accessor_set()` will return a new Object list with the updated value for that attribute as `new_object`.
//   **The existing Object list is unmodified,** and a wholly new Object with the new value is returned instead. 
// Arguments:
//   obj = An Object list. No default. 
//   name = The attribute name to access. The name must be present in `obj`'s TOC. No default.
//   nv = The new value to set as the new attribute. No default.
// Continues:
//   Unlike `obj_accessor()`, it is an error to call `obj_accessor_set()` without a new value (`nv`) passed. 
//   If the value of the attribute `name` needs to be removed, use `obj_accessor_unset()` instead. 
//   .
//   Note that `obj_accessor_set()` will accept a `default` option, to make writing accessor 
//   glue easier, but it will be neither evaluated nor used. 
// Example(NORENDER): direct call to `obj_accessor_set()`
//   obj = Object("ExampleObj", ["a1=i", "a2=i"], ["a1", 30]);
//   new_obj = obj_accessor_set(obj, "a1", nv=20);
//   // new_obj's `a1` attribute is now 20
// Example(NORENDER): providing a class- and attribute-specific "glue" write-only accessor:
//   function set_axle_length(axle, nv) = obj_accessor_set(axle, "length", nv);
//   // ..
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   new_axle = set_axle_length(axle, 40);
//   // new_axle == [["Axle", "diameter", "length"], 10, 40];
// Example(NORENDER): gotchas when setting undefined values with `obj_accessor()`:
//   // Setting no value in `nv` will *not* do what you want!
//   function set_axle_length(axle, nv=undef) = obj_accessor(axle, "length", nv);
//   axle = Axle([["diameter", 10], ["length", 30]]);
//   new_axle = set_axle_length(axle);
//   // new_axle == 30  //<--- This is the `length` value, NOT a new object. 
//   // Because the `nv` option wasn't provided, the call arrived into `obj_accessor()` as `undef`, and 
//   // was treated as a "get". 
// See Also: obj_accessor()
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
// Synopsis: Generic attribute deleter
// Usage:
//   new_obj = obj_accessor_unset(obj, name);
// Description:
//   Basic "delete" accessor for Objects. Given an Object `obj` and an attribute 
//   name `name`, a new Object will be returned 
//   with the un-set attribute value. **The existing Object list is unmodified,** and a 
//   wholly new Object list with the unset value is returned instead. 
// Arguments:
//   obj = An Object list. No default. 
//   name = The attribute name to access. The name must be present in `obj`'s TOC. No default.
// Example(NORENDER):
//   obj = Object("ExampleObj", ["a1=i", "a2=i"], ["a1", 30]);
//   new_obj = obj_accessor_unset(obj, "a1");
//   // new_obj's `a1` attribute is now unset
//   echo(obj_accessor_get(new_obj, "a1"));
//   // emits: ECHO: undef
// EXTERNAL - 
//   list_set() (BOSL2);
function obj_accessor_unset(obj, name) = 
    list_set(obj, obj_toc_attr_id_by_name(obj, name), undef);


// Subsection: Managing Lists of Objects
//   These are functions to help manage lists or collections of Objects. In most cases,
//   standard list manipulation functions work fine, but when you need to select or act
//   on a subset of Objects based on their attribute values, turn here.
//
// Function: obj_select()
// Synopsis: Select Objects from a list based on their position in that list
// Usage:
//   list = obj_select(obj_list, idxs);
// Description:
//   Given a list of objects `obj_list` and a list of element indexes `idxs`, returns the
//   objects in `obj_list` identified by their index position `idx` as a new list `list`.
//   .
//   The Objects need not be all of the same object type.
// Arguments:
//   obj_list = A list of Objects
//   idxs = A list of positional index integers
// Continues:
//   It's probably a really bad idea to give a list of `idxs` that doesn't match the
//   length of `obj_list`.
// Todo:
//   turns out this is just a very thinly wrapped select(). Is there a reason to keep this?
function obj_select(obj_list, idxs) =
    [ for (i=idxs) obj_list[i] ];
    //select(obj_list, idxs);


// Function: obj_select_by_attr_defined()
// Synopsis: Select Objects from a list if they have a particular attribute defined
// Usage:
//   list = obj_select_by_attr_defined(obj_list, attr);
// Description:
//   Given a list of Objects `obj_list` and an attribute name `attr`, return 
//   all the Objects in `obj_list` that have the attribute `attr` defined as a list `list`.
//   The Objects are returned in the order they appear in `obj_list`.
//   The returned `list` of Objects may not be the same length as `obj_list`. The returned
//   list `list` may have no elements in it.
//   .
//   The list of Objects given need not be all of the same type.
// Arguments:
//   obj_list = A list of Objects
//   attr = An attribute name
function obj_select_by_attr_defined(obj_list, attr) =
    list_remove_values(
        [ for (obj=obj_list) (obj_has(obj, attr) && _defined( obj_accessor_get(obj, attr))) ? obj : undef ],
        undef,
        all=true);


// Function: obj_select_by_attr_value()
// Synopsis: Select Objects from a list based on the value of a specified attribute
// Usage:
//   list = obj_select_by_attr_value(obj_list, attr, value);
// Description:
//   Given an list of Objects `obj_list`, an attribute name `attr`, and a comparison value `value`, return
//   all Objects in `obj_list` whose value for `attr` matches `value` as a list `list`.
//   The Objects are returned in the order they appear in `obj_list`.
//   .
//   The Objects in `obj_list` need not be all of the same type.
// Arguments:
//   obj_list = A list of Objects
//   attr = An attribute name
//   value = A comparison value
function obj_select_by_attr_value(obj_list, attr, value) =
    let( reduced_obj_list = obj_select_by_attr_defined(obj_list, attr) )
    list_remove_values(
        [ for (obj=reduced_obj_list) (obj_accessor_get(obj, attr) == value) ? obj : undef ],
        undef,
        all=true);


// Function: obj_sort_by_attribute()
// Synopsis: Sort a list of Objects based on a specified attribute
// Usage:
//   list = obj_sort_by_attribute(obj_list, attr);
// Description:
//   Given a list of Objects `obj_list` and an attribute name `attr`, sort the list
//   of objects by the value of their attribute `attr` and return that list.
//   .
//   Objects listed in `obj_list` need not be all of the same type.
// Arguments:
//   obj_list = A list of Objects
//   attr = An attribute name
function obj_sort_by_attribute(obj_list, attr) =
    let(
        value_list = obj_select_values_from_obj_list(obj_list, attr),
        idxs = sortidx( value_list )
    ) (len(obj_list) == 1)
        ? obj_list
        : (len(value_list) == 0)
            ? []
            : obj_select(obj_list, idxs);


// Function: obj_select_values_from_obj_list()
// Synopsis: Get a list of values for one attribute out of a list of Objects
// Usage:
//   list = obj_select_values_from_obj_list(obj_list, attr);
//   list = obj_select_values_from_obj_list(obj_list, attr, <default=undef>);
// Description:
//   Given a list of Objects `obj_list` and an attribute name `attr`, return
//   a list of all the values of `attr` in the Objects in `obj_list`. The
//   values are returned in the order they appear in `obj_list`.
//   .
//   The Objects in `obj_list` need not be all the same type.
// Arguments:
//   obj_list = A list of Objects
//   attr = An attribute name
//   ---
//   default = A value to be used as a default for Objects that do not have their attribute `attr` set. Default: `undef`
function obj_select_values_from_obj_list(obj_list, attr, default=undef) =
    [ for (obj=obj_list) (obj_has(obj, attr)) 
        ? obj_accessor_get(obj, attr, default=default) 
        : undef ];


// Function: obj_regroup_list_by_attr()
// Synopsis: Group a list of Objects based on a specified attribute
// Usage:
//   list = obj_regroup_list_by_attr(obj_list, attr);
// Description:
//   Given a list of Objects `obj_list` and an attribute name `attr`, 
//   return a list of groups of the Objects in `obj_list` grouped
//   by defined and unique values of `attr`. 
//   .
//   The groupings of Objects are returned in no particular order. 
//   .
//   Objects listed in `obj_list` need not be all of the same type.
// Arguments:
//   obj_list = A list of Objects
//   attr = An attribute name
// Continues:
//   If an Object within `obj_list` has the attribute `attr` but 
//   it is neither defined nor has a default value, it will not 
//   be grouped. Grouping Objects with an `undef` value for the 
//   attribute is something that'd be *nice*; however, the 
//   functions `obj_regroup_list_by_attr()` depends on do not 
//   today support selecting Objects on an undefined attribute.
function obj_regroup_list_by_attr(obj_list, attr) = 
    let(
        unique_attrs = unique(
            list_remove_values(
                obj_select_values_from_obj_list(
                    obj_list,
                    attr),
                undef,
                all=true))
    ) [ for (v=unique_attrs) obj_select_by_attr_value(obj_list, attr, v) ];


// Function: obj_select_by_attrs_values()
// Synopsis: Select Objects from a list based on one or more sets of attribute-value pairs
// Usage:
//   list = obj_select_by_attrs_values(obj_list, arglist);
// Description:
//   Given a list of Objects `obj_list` and a list of selectors `arglist`, 
//   recursively examine `obj_list` to select items that match each selector, and 
//   return those elements as `list`. The elements in `list` are returned in 
//   the order they appear in `obj_list`. 
//   . 
//   For `obj_select_by_attrs_values()`, the `arglist` list of selectors is a collection of `[attr, value]` 
//   lists that are used to exclude items from `obj_list`. `attr` is the object attribute
//   to examine, and `value` is the value that it must match in order to be returned. 
//   In brief, `obj_select_by_attrs_values()` is calling `obj_select_by_attr_value()` 
//   for each pairing in `arglist` against the same `obj_list` over and over, ideally 
//   reducing the number of elements in `obj_list` to get the desired set. *(You could 
//   probably achieve the same by getting the results of `obj_select_by_attr_value()`
//   for each selector, and then calculating the intersection of all those results; 
//   however, `obj_select_by_attrs_values()` is probably going to be faster, since 
//   `obj_list` is likely to be shortened for each recurively-examined selector.)*
//   .
//   The Objects in `obj_list` need not be all the same type, however they all 
//   need to support the `arglist` selectors.
// Arguments:
//   obj_list = A list of Objects
//   arglist = A list of `[attr, value]` lists, where: `attr` is an attribute name; and, `value` is a comparison value
// See Also: obj_select_by_attr_value()
function obj_select_by_attrs_values(obj_list, arglist) = _rec_obj_select_by_attrs_values(obj_list, arglist);

function _rec_obj_select_by_attrs_values(obj_list, arglist, _id=0, _max=undef) =
    assert(_defined(obj_list))
    assert(_defined(arglist))
    assert(is_list(arglist))
    let(
        max_ = (_defined(_max)) 
            ? _max 
            : max([ for (i=obj_list) obj_toc_attr_len(i) ])
    )
    assert(_id < max_ + 1)
    let(
        current_selector = arglist[0],

        adjusted_list = obj_select_by_attr_value(
            obj_list, 
            current_selector[0], 
            current_selector[1]),

        arglist_remainder = (len(arglist) == 1)
            ? []
            : (len(arglist) > 2)
                ? select(arglist, 1)
                : [list(arglist[1])]
    ) 
    (len(arglist_remainder) > 0)
        ? _rec_obj_select_by_attrs_values(
            adjusted_list, 
            arglist_remainder, 
            _id=_id+1, 
            _max=max_)
        : adjusted_list;


// Function: obj_list_debug_obj()
// Synopsis: Run `obj_debug_obj()` against a list of Objects
// Usage:
//   list = obj_list_debug_obj(obj_list);
// Description:
//   Given a list of Objects `obj_list`, run `obj_debug_obj()` on each 
//   Object, and return their output as a list. 
// Arguments:
//   obj_list = A list of Objects
function obj_list_debug_obj(obj_list) = [ for (obj=obj_list) obj_debug_obj(obj) ];


// ------------------------------------------------------------------------------------------------------------
// Subsection: Object Attribute Data Types
//   
// Constant: ATTRIBUTE_DATA_TYPES
// Synopsis: Known data types
// Description:
//   A list of known attribute data types. "Types" in this context are 
//   single-character symbols that indicate what the attribute is 
//   meant to hold. 
// Type IDs: The following data type IDs are known:
//   s = literal strings. Example: `"a string"`. *(Note: Strings are always assigned with quotes and we show that here, but as elsewhere in OpenSCAD the quotes are not part of the string.)* 
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


// Function: obj_data_type_is_valid()
// Synopsis: Test to see if the attribute of a given Object data type is valid
// Usage:
//   bool = obj_data_type_is_valid(obj, name);
// Description:
//   Given an Object `obj` and the name of an attribute within that Object `name`, 
//   return `true` if the defined data type for that attribute is valid, or 
//   `false` otherwise. 
// Arguments:
//   obj = An Object list. No default. 
//   name = An attribute name that exists within `obj`. No default.
function obj_data_type_is_valid(obj, name) = data_type_is_valid(obj_toc_get_attr_type_by_name(obj, name));


// Function: data_type_is_valid()
// Synopsis: Test to see if a given data type is valid
// Usage:
//   data_type_is_valid(type);
// Description:
//   Given a type, returns `true` if the type is found within ATTRIBUTE_DATA_TYPES, or false otherwise. 
// Arguments:
//   type = the type of data to check. No default. 
function data_type_is_valid(type) = in_list(type, ATTRIBUTE_DATA_TYPES);


// Function: obj_type_check_value()
// Synopsis: Test if a specified Object attribute matches its data type
// Usage:
//   bool = obj_type_check_value(obj, name);
//   bool = obj_type_check_value(obj, name, <value=value>);
// Description:
//   Given a valid Object `obj` and the name of an attribute that exists in that Object `name`, 
//   return `true` if the value stored in the Object's attribute matches the data type 
//   set for that attribute, or `false` otherwise. 
//   .
//   A specific data value `value` may be optionally provided, and `obj_test_check_value()` 
//   will check that value against the attribute's data type, rather than whatever 
//   is in the Object. 
// Arguments:
//   obj = An Object list. No default. 
//   name = An attribute name that exists within `obj`. No default.
//   ---
//   value = A value to compare against `name`'s data type. Default: `undef` (meaning the Object's attribute value will be checked)
// See Also: test_value_type()
// Todo: 
//   figure out if we care about enforcing object types (eg, `["attr-name", "o:Axle"]`)
//   re-implement a proper range type
function obj_type_check_value(obj, name, value=undef) = 
    let(
        type_id = obj_toc_get_attr_type_by_name(obj, name),
        value_ = _first([value, obj_accessor_get(obj, name)])
    ) test_value_type(type_id, value_);


// Function: test_value_type()
// Synopsis: Test if a data value matches its data type
// Usage:
//   bool = test_value_type(type_id, value);
// Description:
//   Given a valid data type `type_id` and a data value `value`, 
//   return `true` if the value matches the data type, or false otherwise.
// Arguments:
//   type_id = A valid data type ID. No default.
//   value = A data value. No default.
// Continues:
//   It is an error to specify a data type ID that does not exist within 
//   ATTRIBUTE_DATA_TYPES.
// See Also: ATTRIBUTE_DATA_TYPES
function test_value_type(type_id, value) = 
    assert(data_type_is_valid(type_id), 
        str("test_value_type(): Unknown type_id: ", type_id))
    (type_id == "o")
        ? is_list(value)
        : (type_id == "i")
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


/// --------------------------------------------------------------------------------------------------------------------------------
/// Subsection: Object Table-of-Contents Functions
///   These are functions specific to interacting with an Object's Table-of-Contents (TOC). 
///   ```openscad
///   object = [
///      TOC,
///      value_1,
///      value_N
///      ];
///   ```
///   The TOC is a list of attributes that belong to the object, the attribute's data types, 
///   and their default values. The TOC is the first element in the Object: 
///   it's a list, and it must be the same length as the entire Object. The attributes listed in the 
///   TOC must be ordered the same as the attribute values in the Object.
///   .
///   For example, if you had an Axle Object with two attributes ("length" and "diameter"), 
///   the TOC would have three elements within it: the Object type, and a default value and
///   data type for both of the attributes. 
///   ```openscad
///   object = [
///      // element 0: this list is the table-of-contents
///      [
///         ["Axle"],                // The Object's name
///         ["length",   "i", 10],   // attribute 1: the 'length' attribute: an int, with a default of 10
///         ["diameter", "i", 10]    // attribute 2: the 'diameter' attribute: an int, with a default of 10
///      ], 
///      undef,   // data element 1: the value of the 'length' attribute, currently unset 
///      undef    // data element 2: the value of the 'diameter' attribute, currently unset 
///      ];
///   ``` 
///   There are two attributes listed in the above example TOC, and there are two 
///   attribute values in the Object. In this above example, the attributes are currently 
///   unset, but they'll always be present. 
///   .
///   In general the functions in the TOC section aren't really functions you'd need in your 
///   day-to-day modeling.
///
/// Function: obj_toc_build()
/// Synopsis: Construct a TOC
/// Description: 
///   Given an Object name `name`, an attribute-type set list `attrs`, and optionally an existing object to mutate from `mutate`,
///   construct a table-of-contents (TOC) and return it. 
/// Arguments:
///   name = The "name" of the object (think "classname"). No default. 
///   attrs = The list of known attributes and their type for this object, eg: `["length=i", "style=s", "optional_attr=[]"]`. No default. 
///   ---
///   mutate = An existing Object of a similar `name` type on which to pre-set values. No default. 
function obj_toc_build(name, attrs, mutate) = 
    assert(_defined(attrs) || _defined(mutate), 
        "obj_toc_build: at least one of either attrs or mutate must be provided")
    let(
        toc_attrs_with_type = (len(attrs) > 0)
            ? [ for ( i=[0:len(attrs) - 1] ) attr_type_default_from_string_or_pairs(attrs[i]) ]
            : []
    )
    (obj_is_obj(mutate)) 
        ? obj_toc(mutate)
        : list_insert(toc_attrs_with_type, [0], [name]);


/// Function: obj_toc()
/// Synopsis: Get an Object's TOC
/// Usage:
///   toc = obj_toc(obj);
/// Description:
///   Given an object `obj`, return that object's TOC as a list `toc`. 
/// Arguments:
///   obj = An Object list. No default. 
function obj_toc(obj) = obj[0];


/// Function: obj_toc_get_type()
/// Synopsis: Get an Object's type from its TOC
/// Usage:
///   type = obj_toc_get_type(obj);
/// Description: 
///   Given an object, return its "type" (or "name") from its TOC. If there is no TOC, an error is raised. 
/// Arguments:
///   obj = An Object list. No default. 
/// Example(NORENDER):
///   obj = Object("ExampleObject", ["diameter=i=10"]);
///   type = obj_toc_get_type(obj);
///   // type == "ExampleObject"
function obj_toc_get_type(obj) = 
    (_defined(obj[0][0])) 
        ? obj[0][0] 
        : assert(false, str("obj_toc_get_type(): passed value has no object type:", obj));


/// Function: obj_toc_get_attributes()
/// Synopsis: Get the list of attributes
/// Usage:
///   obj_toc_get_attributes(obj);
/// Description:
///   Given an object, return its list of attributes. This may differ from the list of 
///   attributes in the object's TOC, because of the TOC itself.
///   .
///   `obj_toc_get_attributes()` returns the TOC index as an attribute pair 
///   of a literal "TOC", and an attribute type of `o`; should look like `["_toc_", "o"]`. 
/// Arguments:
///   obj = An Object list. No default. 
/// Example(NORENDER):
///   O_attrs = ["attr1=i", "attr2=s", "attr3=b=true"];
///   obj = Object("Obj", O_attrs, [["attr2", "hello"], ["attr3", false]]);
///   attrs = obj_toc_get_attributes(obj);
///   // attrs == ECHO: [["_toc_", "o"], ["attr1", "i", undef], ["attr2", "s", undef], ["attr3", "b", true]]
/// Todo:
///   I am not wild about the TOC being returned as an attribute
/// See Also: obj_get_names()
function obj_toc_get_attributes(obj) = 
    list_insert( 
        slice(obj[0], 1),
        [0], [["_toc_", "o"]]
    );


/// Function: obj_toc_get_attr_names()
/// Synopsis: Get the list of attribute names
/// Usage:
///   names = obj_toc_get_attr_names(obj);
/// Description:
///   Given an object `obj`, return its attribute names as a list `names`. 
/// Arguments:
///   obj = An Object list. No default.
/// Example(NORENDER):
///   obj = Object("ExampleObject", ["attr1=i", "attr2=i", "attr3=i"]);
///   names = obj_toc_get_attr_names(obj);
///   // names == ["_toc_", "attr1", "attr2", "attr3"]
/// Todo: 
///   honestly I'm not wild about the TOC being returned in the list of attributes. 
function obj_toc_get_attr_names(obj) = [ for (i=obj_toc_get_attributes(obj)) i[0] ];


/// Function: obj_toc_get_attr_types()
/// Synopsis: Get the list of attribute types
/// Usage:
///   types = obj_toc_get_attr_types(obj);
/// Description:
///   Given an object `obj`, return its attributes' types as a list `types`. Types are 
///   returned in the same order and index as their corresponding attributes. 
/// Arguments:
///   obj = An Object list. No default.
/// Example(NORENDER):
///   obj = Object("ExampleObj", ["attr1=o", "attr2=i", "attr3=i"]);
///   types = obj_toc_get_attr_types(obj);
///   // types == ["o", "i", "i"];
/// Todo: 
///   honestly I'm not even really sure *when* you'd use this.
function obj_toc_get_attr_types(obj) = [ for (i=obj_toc_get_attributes(obj)) i[1] ];


/// Function: obj_toc_get_attr_defaults()
/// Synopsis: Get the list of attribute default values
/// Usage:
///   defaults = obj_toc_get_attr_defaults(obj);
/// Description: 
///   Given an object `obj`, return its attributes' default values as a list `defaults`. 
///   Default values are returned in the same order and index as their corresponding 
///   attribute names.
/// Arguments:
///   obj = An Object list. No default.
/// Example(NORENDER):
///   obj = Object("ExampleObj", ["a1=i=20", "a2=i=10"]);
///   values = obj_toc_get_attr_defaults(obj);
///   // values == [20, 10];
/// Todo: 
///   confirm, clarify example
function obj_toc_get_attr_defaults(obj) = [ for (i=obj_toc_get_attributes(obj)) i[2] ];


/// Function: obj_toc_attr_len()
/// Synopsis: Get the number of attributes in an Object
/// Usage:
///   num = obj_toc_attr_len(obj);
/// Description:
///   Given an object `obj`, return the number of attributes defined for that object `num`. 
/// Arguments:
///   obj = An Object list. No default.
/// Todo: 
///   I'm not super wild about the TOC being considered in this length (wait... *is* it being considered?)
function obj_toc_attr_len(obj) = len(obj[0]) - 1;


/// Function: obj_toc_get_attr_type_by_name()
/// Synopsis: Get a data type for a particular attribute by name
/// Usage:
///   type = obj_toc_get_attr_type_by_name(obj, name);
/// Description:
///   Given an object `obj` and an attribute name `name`, return the attribute data type 
///   expected for that attribute. 
///   Valid data types are listed in `ATTRIBUTE_DATA_TYPES`.
/// Arguments:
///   obj = An Object list. No default. 
///   name = The attribute name for whose data type you want. No default.
/// Example(NORENDER):
///   obj = Object("ExampleObj", ["a1=i=10", "a2=i=10"]);
///   type = obj_toc_get_attr_type_by_name(obj, "a1");
///   // type == "i"
function obj_toc_get_attr_type_by_name(obj, name) = obj_toc_get_attr_type_by_id(obj, obj_toc_attr_id_by_name(obj, name)); 


/// Function: obj_toc_get_attr_type_by_id()
/// Synopsis: Get a data type for a particular attribute by ID 
/// Usage:
///   type = obj_toc_get_attr_type_by_id(obj, id);
/// Description:
///   Given an object `obj` and a numerical attribute ID `id`, return the attribute data type 
///   expected for that attribute as `type` 
///   Valid data types are listed in `ATTRIBUTE_DATA_TYPES`.
/// Arguments:
///   obj = An Object list. No default. 
///   id = The attribute ID for whose data type you want. No default.
/// Example(NORENDER):
///   obj = Object("ExampleObj", ["a1=i=10", "a2=i=10"]);
///   type = obj_toc_get_attr_type_by_id(obj, 1);
///   // type == "i"
function obj_toc_get_attr_type_by_id(obj, id) = obj_toc_get_attr_types(obj)[ id ];


/// Function: obj_toc_get_attr_default_by_name()
/// Synopsis: Get an attribute's default value by name
/// Usage:
///   default = obj_toc_get_attr_default_by_name(obj, name);
/// Description:
///   Given an object `obj` and an attribute name `name`, return the attribute's default value 
///   expected for that attribute as `default`.
/// Arguments:
///   obj = An Object list. No default.
///   name = The attribute name for whose default value you want. No default.
/// Example(NORENDER):
///   obj = Object("ExampleObj", ["a1=i=10", "a2=i=20"]);
///   default = obj_toc_get_attr_default_by_name(obj, "a1");
///   // default == 10
/// Todo: 
///   confirm example
function obj_toc_get_attr_default_by_name(obj, name) = obj_toc_get_attr_default_by_id(obj, obj_toc_attr_id_by_name(obj, name));


/// Function: obj_toc_get_attr_default_by_id()
/// Synopsis: Get an attribute's default value by ID
/// Usage:
///   default = obj_toc_get_attr_default_by_id(obj, id);
/// Description:
///   Given an object `obj` and a numerical attribute ID `id`, return the attribute's default value
///   expected for that attribute as `default`.
/// Arguments:
///   obj = An Object list. No default.
///   id = The attribute id for whose default value you want. No default.
/// Example(NORENDER):
///   obj = Object("ExampleObj", ["a1=i=10", "a2=i=20"]);
///   default = obj_toc_get_attr_default_by_id(obj, 2);
///   // default == 20
/// Todo: 
///   confirm, clarify example
function obj_toc_get_attr_default_by_id(obj, id) = obj_toc_get_attr_defaults(obj)[ id ];


/// Function: obj_toc_attr_id_by_name()
/// Synopsis: Translate an attribute's name into an ID
/// Usage:
///   id = obj_addr_id_by_name(object, name);
/// Description:
///   Tranlate function to convert attribute names to list index in the object's attribute TOC. 
///   Given an object `obj` with a valid TOC, and an attribute name `name`, looks up the `name` within the TOC 
///   and returns the expected index number of the attribute within the object list. 
///   .
///   Functionally this is the opposite of `obj_toc_attr_id_by_name()`. 
/// Arguments:
///   obj = An Object list. No default.
///   name = The attribute name for whose default value you want. No default.
/// Continues:
///   It is an error to specify a `name` that isn't present within the TOC. It is an error to specify 
///   an Object without a valid TOC, or to pass a non-Object value as `obj` (such as a number).
/// Example(NORENDER):
///   axle = Axle([["diameter", 10], ["length", 30]]);
///   // axle == [["Axle", ["diameter", "i"], ["length", "i"]], 10, 30];
///   id = obj_toc_attr_id_by_name(axle, "diameter");
///   // id == 1
/// Example(NORENDER):
///   axle = Axle([]);
///   // axle == [["Axle", ["diameter", "i"], ["length", "i"]], undef, undef];
///   id = obj_toc_attr_id_by_name(axle, "not-found");
///   // error is thrown
/// EXTERNAL - 
///   is_list() (BOSL2);
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


/// Function: obj_toc_attr_name_by_id()
/// Synopsis: Translate an attribute's ID into a name
/// Usage:
///   name = obj_toc_attr_name_by_id(object, id);
/// Description:
///   Translate function to convert attribute IDs (indexed positions within the object list) to the object 
///   attribute's name within the object's TOC. Given an object with a valid TOC `obj`, and a numerical attribute
///   ID `id`, returns the name at that `id` list index from the object's TOC as `name`.
///   .
///   Functionally this is the opposite of `obj_toc_attr_id_by_name()`. 
/// Arguments:
///   obj = An Object list. No default.
///   id = The attribute id for whose default value you want. No default.
/// Continues:
///   It is an error to specify an `id` that exceeds the attribute length within the TOC. It is an error to specify 
///   an Object without a valid TOC, or to pass a non-Object value as `obj` (such as a number).
/// Example(NORENDER):
///   axle = Axle([["diameter", 10], ["length", 30]]);
///   // axle == [["Axle", "diameter", "length"], 10, 30];
///   name = obj_toc_attr_name_by_id(axle, 1);
///   // name == "diameter"
/// Example(NORENDER):
///   axle = Axle([]);
///   // axle == [["Axle", "diameter", "length"], undef, undef];
///   name = obj_toc_attr_name_by_id(axle, 3);
///   // error is thrown
/// EXTERNAL - 
///   is_list() (BOSL2); 
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


/// Function: attr_arglist_to_vlist()
/// Synopsis: Convert a single list of arguments into a vlist
/// Usage:
///   vlist = attr_arglist_to_vlist(flattened_arglist);
///   [["length", 10], ["height", 10]] = attr_arglist_to_vlist(["length", 10, "height", 10, "wall", undef]);
/// Description:
///   When you have an existing object and want named module arguments to 
///   take precedence with a mutation, attr_arglist_to_vlist() simplifies that 
///   process. Pass the arguments and their values as a flat list, and 
///   attr_arglist_to_vlist() will return a vlist suitable for a new object. 
/// Example(NORENDER):
///   module axle(axle, length=undef, height=undef) {
///      vlist = attr_arglist_to_vlist(["length", length, "height", height]);
///      //  for arguments that have a value, returns `[[attr, val]]`. 
///      localized_axle = Axle(vlist, mutate=axle);
///      // localized_axle now has all the values of `axle`, except 
///      // for arguments to this module that are defined. 
///   }
/// EXTERNAL - 
///   list_to_matrix() (BOSL2);
function attr_arglist_to_vlist(list) = [ for (i=list_to_matrix(list, 2)) if (_defined(i[1])) i ];
    

/// Function: attr_type_default_from_string_or_pairs()
/// Synopsis: Create an identifying tuple of attribute info
/// Description:
///   Given either a list-pair of `[attribute, type, default]`, or a string of `attribute=type=default`, 
///   return a tuple list-pair of `[attribute, type, default]`. `attribute` should be an attribute name 
///   for an object list under construction. If `type` is gleanable, it should be one of 
///   types listed in `ATTRIBUTE_DATA_TYPES`. If `type` is not gleanable, it will be set to `undef`. 
///   If a `default` is provided, it must match the `type` gleaned. 
/// Arguments:
///   tuple = Either a string or list pair from which to construct the pairing. 
/// Continues:
///   Tuples of type `u` ("undefined") cannot have default values apart from `undef` specified. 
///   .
///   Tuples of type `l` ("list") or `o` ("object") can have a default value set at object creation, 
///   however they must be defined as a list-pair and not as a string. 
/// Todo:
///   no real format or bounds checking is done on `tuple`, perhaps we should.
function attr_type_default_from_string_or_pairs(tuple) = 
    let(
        elems = (is_list(tuple)) ? tuple : str_split(tuple, "="),

        attr_name = elems[0],

        attr_type = (_defined(elems[1]) && data_type_is_valid(elems[1]))
            ? elems[1] 
            : undef,

        _attr_default = _attr_type_default_from_string_recast(
            attr_type, 
            (is_list(tuple) || len(elems) < 3)
                ? elems[2]
                : str_join(select(elems, 2, -1), "=")
            ),

        attr_default = (attr_type == "u")
            ? undef 
            : (_defined(attr_type) && _defined(_attr_default) && test_value_type(attr_type, _attr_default))
                ? _attr_default
                : (attr_type == "l" && !_defined(_attr_default))
                    ? []  // Special case for using empty lists as a default
                    : undef
        )
    assert(_defined(attr_name),
        str("attr_type_default_from_string_or_pairs(): No attribute ",
            "name gleanable from '", tuple, "'"))
    [attr_name, attr_type, attr_default];


function _attr_type_default_from_string_recast(type, value_as_string) = 
    let(
        v = (test_value_type(type, value_as_string)) 
            ? value_as_string
            : (type == "b")
                ? (value_as_string == "true")
                    ? true
                    : (value_as_string == "false")
                        ? false
                        : undef
                : (type == "i")
                    ? parse_float(value_as_string)
                    : (type == "u")
                        ? undef
                        : (type == "s")
                            ? value_as_string
                            : (type == "l" || type == "o")
                                ? []     // non-defined default type list, needs to be returned as empty list
                                : undef  // fall-through. 
    ) v;



// ------------------------------------------------------------------------------------------------------------
// Section: Support Functions
//   These are pulled directly from the 507 Project. To keep warnings down, 
//   they're prefixed with an underscore (`_`), but otherwise are direct copies. 
//   . 
//   The remainder of the functions that this LibFile relies on are present in 
//   BOSL2, all from the set of functions that make managing lists in OpenSCAD easier. They are:
//   `flatten()`, `in_list()`, `list_insert()`, `list_pad()`, `list_set()`, `list_shape()`, and `list_to_matrix()`.
//
// Function: _defined()
// Synopsis: Good all-purpose "is this variable defined?" function
// Usage:
//   _defined(value);
// Description:
//   Given a variable, return true if the variable is defined. 
//   This doesn't differenate `true` vs `false` - `false` is still defined. 
//   `_defined()` tests to see if a string value is something other than `undef`, 
//   or a list value is something other than `[]` (an empty list). 
//   *Mnem: this tests if the var has a value.*
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
// Synopsis: Return the first "defined" value in a list
// Usage:
//   _first(list);
// Description:
//   Given a list of values, returns the first defined (as per `_defined()`) in the list.
//   Because we're using `_defined()` to test each value in the list, 
//   `false` is a valid candidate for return. 
//   .
//   If there's no suitable element that can be returned, `_first()` returns undef.  
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
// Synopsis: Return the number of defined elements in a list
// Usage:
//   _defined_len(list);
// Description:
//   Given a list of values, returns the number of defined elements in that 
//   list. If there are no elements, or if all elements are undefined, returns `0`.
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



