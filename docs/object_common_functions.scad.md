# LibFile: object\_common\_functions.scad

Functions for creating and accessing object-like lists.

**Note:** that throughout this file and elsewhere within the 507 (a separate project not yet linkable), we loosely refer to things as
objects. I *wish* they were real, blessed, official capital-O Objects,
and they're not. See docs/HOWTO.md on a quick-start minimum number of steps to get
this into your OpenSCAD modules.

Also, throughout the examples here we talk about an "Axle" model. This is described
also in the HOWTO.md doc. It's loosely based on an actual object class in the 507,
and used as a simple, contrived example.

To use, add the following lines to the beginning of your file:

    include <object_common_functions.scad>

## Table of Contents

1. [Section: Object Functions](#section-object-functions)
    1. [Subsection: Object Table-of-Contents Functions](#subsection-object-table-of-contents-functions)
    2. [Subsection: Object Base Accessors](#subsection-object-base-accessors)
    3. [Subsection: Object Attribute Data Types](#subsection-object-attribute-data-types)
    
    - [`Object()`](#function-object)
    - [`obj_is_obj()`](#function-obj_is_obj)
    - [`obj_is_valid()`](#function-obj_is_valid)
    - [`obj_debug_obj()`](#function-obj_debug_obj)
    - [`obj_build_toc()`](#function-obj_build_toc)
    - [`obj_toc()`](#function-obj_toc)
    - [`obj_toc_get_type()`](#function-obj_toc_get_type)
    - [`obj_toc_get_attributes()`](#function-obj_toc_get_attributes)
    - [`obj_toc_get_attr_names()`](#function-obj_toc_get_attr_names)
    - [`obj_toc_get_attr_types()`](#function-obj_toc_get_attr_types)
    - [`obj_toc_get_attr_defaults()`](#function-obj_toc_get_attr_defaults)
    - [`obj_toc_attr_len()`](#function-obj_toc_attr_len)
    - [`obj_toc_get_attr_type_by_name()`](#function-obj_toc_get_attr_type_by_name)
    - [`obj_toc_get_attr_type_by_id()`](#function-obj_toc_get_attr_type_by_id)
    - [`obj_toc_get_attr_default_by_name()`](#function-obj_toc_get_attr_default_by_name)
    - [`obj_toc_get_attr_default_by_id()`](#function-obj_toc_get_attr_default_by_id)
    - [`obj_toc_attr_id_by_name()`](#function-obj_toc_attr_id_by_name)
    - [`obj_toc_attr_name_by_id()`](#function-obj_toc_attr_name_by_id)
    - [`attr_arglist_to_vlist()`](#function-attr_arglist_to_vlist)
    - [`attr_type_default_from_string_or_pairs()`](#function-attr_type_default_from_string_or_pairs)
    - [`obj_get_values()`](#function-obj_get_values)
    - [`obj_has_value()`](#function-obj_has_value)
    - [`obj_has()`](#function-obj_has)
    - [`obj_accessor()`](#function-obj_accessor)
    - [`obj_accessor_get()`](#function-obj_accessor_get)
    - [`obj_accessor_set()`](#function-obj_accessor_set)
    - [`obj_accessor_unset()`](#function-obj_accessor_unset)
    - [`ATTRIBUTE_DATA_TYPES`](#constant-attribute_data_types)
    - [`obj_type_is_valid()`](#function-obj_type_is_valid)
    - [`obj_type_check_value()`](#function-obj_type_check_value)

2. [Section: Support Functions](#section-support-functions)
    - [`_defined()`](#function-_defined)
    - [`_first()`](#function-_first)
    - [`_defined_len()`](#function-_defined_len)


## Section: Object Functions

These functions assist the creating and usage of Object-like lists ("Objects").

### Function: Object()

**Usage:** 

- object\_list = Object("ObjectName", Obj\_attributes, vlist);
- object\_list = Object("ObjectName", Obj\_attributes, vlist, mutate=object\_list);

**Description:** 

Creates a list of values from either `vlist` or `mutate` arguments with the same indexing as
`obj_attrs`. This resulting list can be treated as a loose "object".
`vlist` listing is a variable list of `[attribute, value]` lists.
Attribute pairs can be in any order. Attribute pairs may not be repeated.
Unspecified attributes will be set to `undef`.
`Object()` returns a new list that should be treated as an opaque object.

Optionally, an existing, similar object can be provided via the `mutate` argument: that
existing list will be used as the original set of object attribute values, and any
new values provided in `vlist` will take precedence.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj_name`           | The "name" of the object (think "classname"), for example: `Axle`. No default.
`obj_attrs`          | The list of known attributes and their type for this object, eg: `["length=i", "style=s", "optional_attr=[]"]`. No default.

<abbr title="These args must be used by name, ie: name=value">By&nbsp;Name</abbr> | What it does
-------------------- | ------------
`vlist`              | Variable list of attributes and values: `[ ["length", 10], ["style", "none"] ]`; **or,** a list of running attribute value pairing: `["length", 10, "style", "none"]`.  No default.
`mutate`             | An existing Object of a similar `obj_name` type on which to pre-set values. Default: `[]`

**Example 1:** empty object creation:

    include <object_common_functions.scad>
    Axle_attributes = ["diameter=i", "length=i"];
    function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
    echo(Axle());
    // emits: ECHO: "[["Axle", ["diameter", "i"], ["length", "i"]], undef, undef]

<br clear="all" /><br/>

**Example 2:** pre-populating object attributes at creation:

    include <object_common_functions.scad>
    Axle_attributes = ["diameter=i", "length=i"];
    function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
    axle = Axle([["diameter", 10], ["length", 30]]);
    // axle == [["Axle", ["diameter", "i"], ["length", "i"]], 10, 30];

<br clear="all" /><br/>

**Example 3:** pre-populating again, but with a simpler `vlist`:

    include <object_common_functions.scad>
    Axle_attributes = ["diameter=i", "length=i"];
    function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
    axle2 = Axle(["diameter", 6]);
    // axle2 == [["Axle", ["diameter", "i"], ["length", "i"]], 6, undef];

<br clear="all" /><br/>

**Example 4:** showing how mutation works:

    include <object_common_functions.scad>
    Axle_attributes = ["diameter=i", "length=i"];
    function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);
    axle = Axle([["diameter", 10], ["length", 30]]);
    // axle == [["Axle", ["diameter", "i"], ["length", "i"]], 10, 30];
    axle2 = Axle([["length", 40]], mutate=axle);
    // axle2 == [["Axle", ["diameter", "i"], ["length", "i"]], 10, 40];

<br clear="all" /><br/>

---

### Function: obj\_is\_obj()

**Description:** 

Given a thing, returns true if that thing can be considered an Object, of any type.

To be considered an Object, a thing must: be a list; have a zeroth element defined;
have a length that is the same length as its zeroth element; and, whose sub-list
elements under its zeroth element have the same depth and count.

If the thing matches those requirements, `obj_is_obj()` returns `true`; otherwise, it will return `false`.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list (potentially). No default.


It is not an error to test for an object and have it return `false`.

---

### Function: obj\_is\_valid()

**Description:** 

Given an object, returns `true` if the object is "valid", and `false` otherwise. "Valid" in this
context means the object is an object (as per `obj_is_obj()`); and, has at least one attribute element; whose
attributes all have a valid type assigned; and, whose attributes with values all match their specified types.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.


It is not an error to test for an object and have it return `false`.

---

### Function: obj\_debug\_obj()

**Usage:** 

- obj\_debug\_obj(obj);
- obj\_debug\_obj(obj, &lt;show\_defaults=true&gt;, &lt;sub\_defaults=false&gt;);

**Description:** 

Given an object, return a string of debug layout information
of the object. Nested objects within the object will also
be expanded with a visual indent.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.

<abbr title="These args must be used by name, ie: name=value">By&nbsp;Name</abbr> | What it does
-------------------- | ------------
`show_defaults`      | If enabled, then TOC-provided defaults will be shown alongside the attribute data types. Default: `true`
`sub_defaults`       | If enabled, then TOC-provided defaults will be shown as the attribute's value, if the value is not set. Default: `false`


`obj_debug_obj()` does not output this debugging information anywhere: it's up
to the caller to do this.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([["diameter", 10]]);
    echo(obj_debug_obj(axle));
    // yields:
    //   ECHO: "0: _toc_: ["Axle", "diameter", "length"]
    //   1: diameter: 10 (i)
    //   2: length: undef (i)"

<br clear="all" /><br/>

---

## Subsection: Object Table-of-Contents Functions

These are functions specific to interacting with an Object's Table-of-Contents (TOC).
In general these aren't really functions you'd need in your day-to-day model. In particular,
functions without given examples probably should be shied away from.


### Function: obj\_build\_toc()

**Description:** 

Given an object name, an attribute-type set, and optionally an existing object to mutate from,
construct a table-of-contents (TOC) and return it.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj_name`           | The "name" of the object (think "classname"), for example: `Axle`. No default.
`obj_attrs`          | The list of known attributes and their type for this object, eg: `["length=i", "style=s", "optional_attr=[]"]`. No default.
`mutate`             | An existing Object of a similar `obj_name` type on which to pre-set values. No default.

---

### Function: obj\_toc()

**Usage:** 

- toc = obj\_toc(obj);

**Description:** 

Given an object, return that object's TOC.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.

---

### Function: obj\_toc\_get\_type()

**Usage:** 

- obj\_toc\_get\_type(obj);

**Description:** 

Given an object, return its "type" from its TOC. If there is no TOC, an error is raised.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([["diameter", 10]]);
    type = obj_toc_get_type(axle);
    // type == "Axle"

<br clear="all" /><br/>

---

### Function: obj\_toc\_get\_attributes()

**Usage:** 

- obj\_toc\_get\_attributes(obj);

**Description:** 

Given an object, return its list of attributes. This may differ from the list of
attributes in the object's TOC, because of the TOC itself.

`obj_toc_get_attributes()` returns the TOC index as an attribute pair
of a literal "TOC", and an attribute type of `o`; should look like `["_toc_", "o"]`.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([]);
    attrs = obj_toc_get_attributes(axle);
    // attrs == [["_toc_", "o"], ["diameter", "i"], ["length", "i"]];

<br clear="all" /><br/>

---

### Function: obj\_toc\_get\_attr\_names()

**Usage:** 

- obj\_toc\_get\_attr\_names(obj);

**Description:** 

Given an object, return its list of attribute names.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.

**Todo:** 

- honestly I'm not wild about the TOC being returned in the list of attributes.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([]);
    names = obj_toc_get_attr_names(axle);
    // names == ["_toc_", "diameter", "length"];

<br clear="all" /><br/>

---

### Function: obj\_toc\_get\_attr\_types()

**Usage:** 

- obj\_toc\_get\_attr\_types(obj);

**Description:** 

Given an object, return its list of attribute types. Types are
returned in the same order and index as their corresponding attributes.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.

**Todo:** 

- honestly I'm not even really sure *when* you'd use this.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([]);
    names = obj_toc_get_attr_types(axle);
    // names == ["o", "i", "i"];

<br clear="all" /><br/>

---

### Function: obj\_toc\_get\_attr\_defaults()

**Usage:** 

- obj\_toc\_get\_attr\_defaults(obj);

**Description:** 

Given an object, return its list of attribute default values. Default values are
returned in the same order and index as their corresponding attribute names.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.

**Todo:** 

- confirm, clarify example

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([]);
    values = obj_toc_get_attr_defaults(axle);
    // values == [20, 10];

<br clear="all" /><br/>

---

### Function: obj\_toc\_attr\_len()

**Usage:** 

- length = obj\_toc\_attr\_len(obj);

**Description:** 

Given an object, return the number of attributes defined for that object.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.

**Todo:** 

- I'm not super wild about the TOC being considered in this length

---

### Function: obj\_toc\_get\_attr\_type\_by\_name()

**Usage:** 

- type = obj\_toc\_get\_attr\_type\_by\_name(obj, name);

**Description:** 

Given an object and an attribute name, return the attribute data type
expected for that attribute.
Valid data types are listed in `ATTRIBUTE_DATA_TYPES`.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.
`name`               | The attribute name for whose data type you want. No default.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle();
    type = obj_toc_get_attr_type_by_name(axle, "diameter");
    // type == "i"

<br clear="all" /><br/>

---

### Function: obj\_toc\_get\_attr\_type\_by\_id()

**Usage:** 

- type = obj\_toc\_get\_attr\_type\_by\_id(obj, id);

**Description:** 

Given an object and an attribute id, return the attribute data type
expected for that attribute.
Valid data types are listed in `ATTRIBUTE_DATA_TYPES`.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.
`id`                 | The attribute id for whose data type you want. No default.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle();
    type = obj_toc_get_attr_type_by_id(axle, 1);
    // type == "i"

<br clear="all" /><br/>

---

### Function: obj\_toc\_get\_attr\_default\_by\_name()

**Usage:** 

- default\_value = obj\_toc\_get\_attr\_default\_by\_name(obj, name);

**Description:** 

Given an object and an attribute name, return the attribute's default value
expected for that attribute.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.
`name`               | The attribute name for whose default value you want. No default.

**Todo:** 

- confirm, clarify example

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([]);
    def = obj_toc_get_attr_default_by_name(axle, "style");
    // def == "axle"

<br clear="all" /><br/>

---

### Function: obj\_toc\_get\_attr\_default\_by\_id()

**Usage:** 

- default\_value = obj\_toc\_get\_attr\_default\_by\_id(obj, id);

**Description:** 

Given an object and an attribute id, return the attribute's default value
expected for that attribute.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.
`id`                 | The attribute id for whose default value you want. No default.

**Todo:** 

- confirm, clarify example

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([]);
    def = obj_toc_get_attr_default_by_id(axle, 4);
    // def == "axle"

<br clear="all" /><br/>

---

### Function: obj\_toc\_attr\_id\_by\_name()

**Usage:** 

- obj\_addr\_id\_by\_name(object, name);

**Description:** 

Tranlate function to convert attribute names to list index in the object's attribute TOC.
Given an object with a valid TOC and a `name` argument, looks up the `name` within the TOC
and returns the expected index of the attribute within the object list.

If `name` is not found within the TOC, or if no TOC is found at index `0`, an error is thrown.

Functionally the opposite of `obj_toc_attr_id_by_name()`.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([["diameter", 10], ["length", 30]]);
    // axle == [["Axle", ["diameter", "i"], ["length", "i"]], 10, 30];
    id = obj_toc_attr_id_by_name(axle, "diameter");
    // id == 1

<br clear="all" /><br/>

**Example 2:** 

    include <object_common_functions.scad>
    axle = Axle([]);
    // axle == [["Axle", ["diameter", "i"], ["length", "i"]], undef, undef];
    id = obj_toc_attr_id_by_name(axle, "not-found");
    // error is thrown

<br clear="all" /><br/>

---

### Function: obj\_toc\_attr\_name\_by\_id()

**Usage:** 

- obj\_toc\_attr\_name\_by\_id(object, id);

**Description:** 

Translate function to convert attribute IDs (indexed positions within the object list) to the object
attribute's name within the object's TOC. Given an object with a valid TOCC and an `id` argument,
returns the name at that `id` list index from the object's TOC.

If `id` is not found within the TOC, or if no TOC is found at index `0`, an error is thrown.

Functionally the opposite of `obj_toc_attr_id_by_name()`.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([["diameter", 10], ["length", 30]]);
    // axle == [["Axle", "diameter", "length"], 10, 30];
    name = obj_toc_attr_name_by_id(axle, 1);
    // name == "diameter"

<br clear="all" /><br/>

**Example 2:** 

    include <object_common_functions.scad>
    axle = Axle([]);
    // axle == [["Axle", "diameter", "length"], undef, undef];
    name = obj_toc_attr_name_by_id(axle, 3);
    // error is thrown

<br clear="all" /><br/>

---

### Function: attr\_arglist\_to\_vlist()

**Usage:** 

- vlist = attr\_arglist\_to\_vlist(flattened\_arglist);
- [["length", 10], ["height", 10]] = attr\_arglist\_to\_vlist(["length", 10, "height", 10, "wall", undef]);

**Description:** 

When you have an existing object and want named module arguments to
take precedence with a mutation, attr_arglist_to_vlist() simplifies that
process. Pass the arguments and their values as a flat list, and
attr_arglist_to_vlist() will return a vlist suitable for a new object.

**Example 1:** 

    include <object_common_functions.scad>
    module axle(axle, length=undef, height=undef) {
       vlist = attr_arglist_to_vlist(["length", length, "height", height]);
       //  for arguments that have a value, returns `[[attr, val]]`.
       localized_axle = Axle(vlist, mutate=axle);
       // localized_axle now has all the values of `axle`, except
       // for arguments to this module that are defined.
    }

<br clear="all" /><br/>

---

### Function: attr\_type\_default\_from\_string\_or\_pairs()

**Description:** 

Given either a list-pair of `[attribute, type, default]`, or a string of `attribute=type=default`,
return a tuple list-pair of `[attribute, type, default]`. `attribute` should be an attribute name
for an object list under construction. If `type` is gleanable, it should be one of
types listed in `ATTRIBUTE_DATA_TYPES`. If `type` is not gleanable, it will be set to `undef`.
If a `default` is provided, it must match the `type` gleaned.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`tuple`              | Either a string or list pair from which to construct the pairing.


Tuples of type `u` ("undefined") cannot have default values apart from `undef` specified.

Tuples of type `l` ("list") or `o` ("object") can have a default value set at object creation,
however they must be defined as a list-pair and not as a string.

**Todo:** 

- no real format or bounds checking is done on `tuple`, perhaps we should.

---

### Function: obj\_get\_values()

**Usage:** 

- obj\_get\_values(obj);

**Description:** 

Given an object, return the values of the attributes listed in its
TOC, as a list. This is functionally the same as doing `[for (i=[1:len(obj[0])-1]) obj[i]]`.
Values are returned in the order in which they're stored in the object.

`obj_get_values()` does not return the object's TOC, so `len(object) > len(obj_get_values(object))`.

`obj_get_values()` does not return values via the built-in accessor `obj_accessor()`, and no
value defaults or type checking is done on the values before they're returned.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([["diameter", 5], ["length", 10]]);
    values = obj_get_values(axle);
    // values == [5, 10];

<br clear="all" /><br/>

---

### Function: obj\_has\_value()

**Usage:** 

- obj\_has\_value(obj);

**Description:** 

Given an object, return `true` if any one of its attributes are defined. If no attributes
have a value defined, `obj_has_value()` returns `false`.

Note: `obj_has_value()` does not evaluate the values of an object using any accessors, there is no
conditional evaluation of the values done: objects that provide accessors with defaults
won't use those accessors here, and unset attribute values will be considered undefined.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([]);
    retr = obj_has_value(axle);
    // retr is `false`

<br clear="all" /><br/>

**Example 2:** 

    include <object_common_functions.scad>
    axle = Axle([["length", 20]]);
    retr = obj_has_value(axle);
    // retr is `true`

<br clear="all" /><br/>

---

### Function: obj\_has()

**Usage:** 

- bool = obj\_has(obj, name);

**Description:** 

Given an object `obj` and an accessor name `name`, return `true` if the object "can" access
that name, or `false` otherwise. An object need not have a specified value for the given name,
only the ability to access and refer to it; in other words, if the `name` exists in the Object's
TOC, then `obj_has()` will return true.

Essentially, this is a thinly wrapped `obj_toc_get_attr_names()`.

This might seem similar way to perl5's `can()` or python's `callable()`, but this is inaccurate:
`obj_has()` cannot test if the object is able to execute or call the given `name`; it can only
tell if the object has the given `name` as an attribute. The perl5 `exists()` or python `hasattr()`
functions would be more analagous to `obj_has()`.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.
`name`               | A string that may exist as an attribute for the Object. No default.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([["diameter", 10], ["length", 30]]);
    b = obj_has(axle, "diameter");
    // b == true

<br clear="all" /><br/>

**Example 2:** 

    include <object_common_functions.scad>
    axle = Axle([["diameter", 10], ["length", 30]]);
    b = obj_has(axle, "radius");
    // b == false

<br clear="all" /><br/>

---

## Subsection: Object Base Accessors

The attribute accessors. There's one mutatable accessor, `obj_accessor()`, that
can both `get` and `set` values by attribute name. There are also
two get- and set-specific accessors: `obj_accessor_get()` returns attributes in a
read-only manner; and, `obj_accessor_set()` returns a modifed object list after
setting the attribute to a new value. And, there is `obj_accessor_unset()`, to
set a named attribute explicitly to `undef` (essentially, a delete).

### Function: obj\_accessor()

**Usage:** 

- obj\_accessor(obj, name, &lt;default=undef&gt;, &lt;nv=undef&gt;);

**Usage:** to retrieve an attribute's value from an object:

- value = obj\_accessor(obj, name);
- value = obj\_accessor(obj, name, &lt;default=undef&gt;);

**Usage:** to set an attribute's value into an object:

- new\_object = obj\_accessor(obj, name, nv=new\_value);

**Description:** 

Basic accessor for object attributes. Given an object `obj` and an attribute name `name`, operates on that attribute.
The operation depends on what other options are passed. Calls to `obj_accessor()` with an `nv` (new-value) option
defined will create a new object based on `obj` with the new value set for `name`, and then will return that
new object (a "set" operation).

Calls to `obj_accessor()` without the `nv` option will look the current value of `name` up in the object and
return it (a "get" operation). "Get" operations can provide a `default` option, for when values aren't set.
The precedence order for "gets" is: `object-stored-value || default-option || object-toc-stored-default || undef`:
if the value of `name` in the object is not defined, the value of the `default` option passed to `obj_accessor()`
will be returned; if there is no `default` option provided, the object's TOC default will be returned; if there is no TOC default
for the object, `undef` will be returned.


**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.
`name`               | The attribute name to access. The name must be present in `obj`'s TOC. No default.

<abbr title="These args must be used by name, ie: name=value">By&nbsp;Name</abbr> | What it does
-------------------- | ------------
`default`            | If provided, and if there is no existing value for `name` in the object `obj`, returns the value of `default` instead.
`nv`                 | If provided, `accessor()` will update the value of the `name` attribute and return a new Object list. *The existing Object list is unmodified.*
`_consider_toc_default_values` | If enabled, TOC-stored defaults will be returned according to the mechanics above. If disabled with `false`, the TOC default for a given attribute will not be considered as a viable return value. Default: `true`


It's not an error to provide both `default` and `nv` in the same request, but doing so will yield a warning
nonetheless. If they're both present, `obj_accessor()` will act on the new value in `nv` and return a new object
list, and not evaluate or set the value from `default`.

It's not an error to provide a `nv` argument that is `undef`; however, if you're unknowningly passing `undef` with `nv`
expecting it to clear the attribute in that object, or because you thought it was set to a value, `obj_accessor()`
won't know what you meant to do and will act as if you wanted to "get" the value for that attribute. To explicitly
clear an object's attribute, use `obj_accessor_unset()`. To explicitly set an attribute to a new value, use
`obj_accessor_set()` (which will error out if `nv` is not defined).

**Todo:** 

- when getting an attribute without a value and a default is provided, do a type check on the default value before returning

**Example 1:** direct "get" call to `obj_accessor()`:

    include <object_common_functions.scad>
    axle = Axle(["length", 30]]);
    length = obj_accessor(axle, "length");
    // length == 30
    diameter = obj_accessor(axle, "diameter", default=10);
    // diameter == 10
    // (diameter is unset in the `axle` object, so the default of 10 is returned instead)

<br clear="all" /><br/>

**Example 2:** direct "set" calls to `obj_accessor()`:

    include <object_common_functions.scad>
    axle = Axle([["length", 30]]);
    new_axle = obj_accessor(axle, "length", nv=6);
    // new_axle's `length` value is now 6.
    // axle's `length` value is still 30.

<br clear="all" /><br/>

**Example 3:** gotcha when providing `undef` as a new-value:

    include <object_common_functions.scad>
    axle = Axle([["diameter", 10], ["length", 30]]);
    new_axle = obj_accessor(axle, "length", nv=undef);
    // new_axle == 6, because obj_accessor() didn't see a value for nv, and returned the "length" attribute instead.

<br clear="all" /><br/>

**Example 4:** providing a class-specific "glue" accessor:

    include <object_common_functions.scad>
    function axle_acc(axle, name, default=undef, nv=undef) = obj_accesor(axle, name, default, nv);
    // ..
    axle = Axle([["diameter", 10], ["length", 30]]);
    dia = axle_acc(axle, "diameter");
    // dia == 10

<br clear="all" /><br/>

**Example 5:** providing a class- and attribute-specific "glue" accessor:

    include <object_common_functions.scad>
    function axle_diameter(axle, default=undef, nv=undef) = obj_accessor(axle, "diameter", default=default, nv=nv);
    // ...
    axle = Axle([["diameter", 10], ["length", 30]]);
    diameter = axle_diameter(axle);
    // diameter == 10
    new_axle = axle_diameter(axle, nv=9);
    // new_axle == [9, 30]

<br clear="all" /><br/>

---

### Function: obj\_accessor\_get()

**Usage:** 

- obj\_accessor\_get(obj, name, &lt;default=undef&gt;);

**Description:** 

Basic "get" accessor for Objects. Given an object `obj` and attribute name `name`, `obj_accessor_get()` will look the current
value of `name` up in the object and return it (a "get" operation).

`obj_accessor_get()` is a simplified wrap around `obj_accessor()`, and the mechanics on how values are returned
are the same. "Get" operations can provide a `default` option, for when values aren't set.
The precedence order for "gets" is: `object-stored-value || default-option || object-toc-stored-default || undef`:
if the value of `name` in the object is not defined, the value of the `default` option passed to `obj_accessor_get()`
will be returned; if there is no `default` option provided, the object's TOC default will be returned; if there is no TOC default
for the object, `undef` will be returned.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.
`name`               | The attribute name to access. The name must be present in `obj`'s TOC.

<abbr title="These args must be used by name, ie: name=value">By&nbsp;Name</abbr> | What it does
-------------------- | ------------
`default`            | If provided, and if there is no existing value for `name` in the object `obj`, returns the value of `default` instead.
`_consider_toc_default_values` | If enabled, TOC-stored defaults will be returned according to the mechanics above. If disabled with `false`, the TOC default for a given attribute will not be considered as a viable return value. Default: `true`


Note that `obj_accessor_get()` will accept a `nv` option, to make writing accessor glue easier, but
that `nv` option won't be evaluated or used.

**Example 1:** direct calls to `obj_accessor_get()`:

    include <object_common_functions.scad>
    length = obj_accessor_get(axle, "length");

<br clear="all" /><br/>

**Example 2:** passing `nv` yields no change:

    include <object_common_functions.scad>
    retr = obj_accessor_get(axle, "length", nv=25);
    // retr == 30 (or, whatever the Axle's `length` previously was)

<br clear="all" /><br/>

**Example 3:** providing a class- and attribute-specific "glue" read-only accessor:

    include <object_common_functions.scad>
    function get_axle_length(axle, default=undef) = obj_accesor_get(axle, "length", default=default);
    // ..
    axle = Axle([["diameter", 10], ["length", 30]]);
    length = get_axle_length(axle);
    // length == 30

<br clear="all" /><br/>

---

### Function: obj\_accessor\_set()

**Usage:** 

- obj\_accessor\_set(obj, name, nv);

**Description:** 

Basic "set" accessor for Objects. Given an object `obj`, an attribute name `name`, and a new value `nv` for that
attribute, `obj_accessor_set()` will
return a new Object list with the updated value for that attribute. **The existing list is unmodified,** and
a wholly new Object with the new value is returned instead.

It is an error to call `obj_accessor_set()` without a new value (`nv`) passed. If the value of `name` needs to be
removed, use `obj_accessor_unset()` instead.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.
`name`               | The attribute name to access. The name must be present in `obj`'s TOC.
`nv`                 | If provided, `obj_accessor_set()` will update the value of the `name` attribute and return a new Object list. *The existing Object list is unmodified.*


Note that `obj_accessor_set()` will accept a `default` option, to make writing accessor
glue easier, but it won't be evaluated or used.

**Example 1:** direct call to `obj_accessor_set()`

    include <object_common_functions.scad>
    new_axle = obj_accessor_set(axle, "length", nv=20);
    // new_axle's `length` attribute is now 20

<br clear="all" /><br/>

**Example 2:** providing a class- and attribute-specific "glue" write-only accessor:

    include <object_common_functions.scad>
    function set_axle_length(axle, nv) = obj_accessor_set(axle, "length", nv);
    // ..
    axle = Axle([["diameter", 10], ["length", 30]]);
    new_axle = set_axle_length(axle, 40);
    // new_axle == [["Axle", "diameter", "length"], 10, 40];

<br clear="all" /><br/>

**Example 3:** gotchas when setting undefined values with `obj_accessor()`:

    include <object_common_functions.scad>
    // Setting no value in `nv` will *not* do what you want!
    function set_axle_length(axle, nv=undef) = obj_accessor(axle, "length", nv);
    axle = Axle([["diameter", 10], ["length", 30]]);
    new_axle = set_axle_length(axle);
    // new_axle == 30  //<--- This is the `length` value, NOT a new object.
    // Because the `nv` option wasn't provided, the call arrived into `obj_accessor()` as `undef`, and
    // was treated as a "get".

<br clear="all" /><br/>

---

### Function: obj\_accessor\_unset()

**Usage:** 

- obj\_accessor\_unset(obj, name);

**Description:** 

Basic "delete" accessor for Objects. A new Object will be returned
with the un-set attribute value. **The existing Object list is unmodified,** and a
wholly new Object list with the unset value is returned instead.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.
`name`               | The attribute name to access. The name must be present in `obj`'s TOC.

**Example 1:** 

    include <object_common_functions.scad>
    axle = Axle([["diameter", 10], ["length", 30]]);
    new_axle = obj_accessor_unset(axle, "length");
    // new_axle == [["Axle", "diameter", "length"], 10, undef];

<br clear="all" /><br/>

---

## Subsection: Object Attribute Data Types



### Constant: ATTRIBUTE\_DATA\_TYPES

**Description:** 

A list of known attribute data types. "Types" in this context are
single-character symbols that indicate what the attribute is
meant to hold.

**Attributes:** 

Attribute Name | What It Represents
-------------- | ------------------
`s`                  | literal strings. Example: `"a string"`. *(Note: Strings are always assigned with quotes and we show that here, but the quotes are not part of the string.)*
`i`                  | integers. Example: `1`
`b`                  | booleans. Example: `true`
`l`                  | lists. There is no restriction on list length or content. Example: `[1, 2, "abc"]`
`u`                  | undefined. Example: `undef`
`o`                  | objects. Objects in this context lists that are expected to have a valid TOC as their first element. Example: `[["Object", ["attribute", "b"]], undef]`

---

### Function: obj\_type\_is\_valid()

**Usage:** 

- obj\_type\_is\_valid(type);

**Description:** 

Given a type, returns `true` if the type is found within ATTRIBUTE_DATA_TYPES, or false otherwise.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`type`               | the type of data to check. No default.

---

### Function: obj\_type\_check\_value()

**Usage:** 

- obj\_type\_check\_value(obj, name, value);

**Description:** 

Given a valid object, an attribute `name`, and a `value`, check to see if the
value is the same data type as the attribute's type for that Object. If the
provided value matches, `obj_type_check_value()` returns true.
Returns false otherwise.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`obj`                | An Object list. No default.
`name`               | An attribute name that exists within `obj`. No default.
`value`              | A value to compare against `name`'s data type. No default.

**Todo:** 

- figure out if we care about enforcing object types (eg, `["attr-name", "o:Axle"]`)

---

## Section: Support Functions

These are pulled directly from the 507 Project. To keep warnings down,
they're prefixed with an underscore (`_`), but otherwise are direct copies.

The remainder of the functions that this LibFile relies on are present in
BOSL2, all from the set of functions that make managing lists in OpenSCAD easier. They are:
`flatten()`, `in_list()`, `list_insert()`, `list_pad()`, `list_set()`, `list_shape()`, and `list_to_matrix()`.

### Function: \_defined()

**Usage:** 

- \_defined(value);

**Description:** 

Given a variable, return true if the variable is defined.
This doesn't differenate `true` vs `false` - `false` is still defined.
`_defined()` tests to see if a string value is something other than `undef`,
or a list value is something other than `[]` (an empty list).
*Mnem: this tests if the var has a value.*

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`value`              | The thing to test definition.

**Example 1:** 

    include <object_common_functions.scad>
    _defined(undef);  // Returns: false
    _defined(1);      // Returns: true
    _defined(0);      // Returns: true
    _defined(-1);     // Returns: true
    _defined("a");    // Returns: true
    _defined([]);     // Returns: false
    _defined(true);   // Returns: true
    _defined(false);  // Returns: true

<br clear="all" /><br/>

---

### Function: \_first()

**Usage:** 

- \_first(list);

**Description:** 

Given a list of values, returns the first defined (as per `_defined()`) in the list.
Because we're using `_defined()` to test each value in the list,
`false` is a valid candidate for return.

If there's no suitable element that can be returned, `_first()` returns undef.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`list`               | The list from which to examine for the first defined item. `list` can be comprised of any variable type that is testable by `_defined()`.

**Example 1:** 

    include <object_common_functions.scad>
    _first([undef, "a"]);       // Returns: "a"
    _first([0, 1]);             // Returns: 0         (because 0 is defined)
    _first([false, 1]);         // Returns: false     (because false is defined)
    _first([[]], "a"]);         // Returns: "a"       (because an empty list is undefined)
    _first([undef, [[]]);       // Returns: undef     (because there is no valid, defined element)

<br clear="all" /><br/>

**See Also:** [\_defined()](#function-_defined)

---

### Function: \_defined\_len()

**Usage:** 

- \_defined\_len(list);

**Description:** 

Given a list of values, returns the number of defined elements in that
list. If there are no elements, or if all elements are undefined, returns `0`.

**Arguments:** 

<abbr title="These args can be used by position or by name.">By&nbsp;Position</abbr> | What it does
-------------------- | ------------
`list`               | A list of items to count. `list` can be comprised of any variable type that is testable by `_defined()`.

**Example 1:** 

    include <object_common_functions.scad>
    _defined_len([0, 1, 2]);         // Returns: 3
    _defined_len([undef, 1, 2]);     // Returns: 2

<br clear="all" /><br/>

**See Also:** [\_defined()](#function-_defined)

---

