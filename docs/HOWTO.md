# Section: Minimal Tooling To Add Objects To Your Model
Here's the simplest set of steps to get your LibFile "object-ified". 

## Subsection: 1. Pick a name
*tl;dr: pick a name. We'll use `Axle`.*

Pick a descriptive name for your object. If you're going to use this object to create lots of axles of varying sizes, 
then a good choice would be "Axle". 
Letters and numbers only, please, just to make things simple: we'll be using this name as an identifier, as a function, and as a 
set of prefixes to functions and lists.  

Keep in mind you'll want to name this something that's pretty clear on what 
it's identifying. Also remember that in OpenSCAD there's really only one immutable namespace and, once things 
are defined they can't really be *re*-defined, so you'll want this name to have a level of uniqueness to it.
"Wheelbase", "Crossbar", "ScrewThread" could be all good examples; "Gary", maybe not so much.

We'll use the notion of an Axle object throughout the rest of this section for example. 

## Subsection: 2. Define the model attributes
*tl;dr:* `Axle_attributes = ["diameter=i", "length=i"];`

Objects are based around the notion of attributes, and the accessing of them thus, and pretty much everything is built 
around the list of known attributes for your object. Start with a list of things that makes your model, that you find 
yourself passing around over and over, that are common to the things that make your model. That list is your attributes. 
For our purposes, we'll care most about the *length* of an axle, and its *diameter*: those two things are 
our Axle's attributes. 

It's easy to mix various data types into an object. A single object can have a variety of numbers (like for measurements and 
dimensions), strings (for labeling, identification, or style selection), booleans (to enable a particular model feature), 
or other objects. Because it's easy to mix them around, it's easy to mistake the type of value for a given attribute. 
*(Ask me how many times I've messed up referencing a number when I really wanted a list and getting a console error, go on.)*
So: attributes specify the *type* of data they'll accept. `[attribute_name=attribute_type]` is how those types are specified;
`attribute_type` is one of types found in `ATTRIBUTE_DATA_TYPES`, detailed below. In this example both the diameter and length 
are expected to be integers, so we'll use the `i` type.

Assign the collection of attributes and their types to a list, with a globally-unique name. A good practice would to have the name you 
picked above as part of the name of the list - for example, `Axle_attributes` - but this isn't really required. 
Just so long as it isn't mistakable for anything else anywhere else in your project. (Heck, you could even define your attributes 
inline to `Object()` and never worry about them again - keep reading to see how.)
. 
Define the list somewhere near the top of your .scad file, like so:
`Axle_attributes = ["diameter=i", "length=i"];`

**A word on attribute types:** ...should be provided, here. 

Of course once you've defined it up near line 3, you can't change it down below at line 378 (because OpenSCAD 
doesn't permit that), but that's all right - you really wouldn't *want* to change it mid-script, because then objects 
created later wouldn't have all the attributes built into it. 

## Subsection: 3. Create a constructor
*tl;dr:* `function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);`

Now we create a constructor: this is just a function that uses arguments passed to it to make a list we can pass around
and use elsewhere. For example, in python you'd do something like `MyObj = MyClass()`; in perl, you'd do something 
like `$obj = new MyClass();`; I understand in java you're probably just be better off farming goats or something?
I'm unclear. Regardless, you've got to be able to create new instances of your OpenSCAD Axle. 
`object_common_functions.scad` provides an `Object()` function for doing just this. Set it up in 
your .scad file like this:

`function Axle(vlist, mutate) = Object("Axle", Axle_attributes, vlist, mutate);`

...or even, if you wanted to not have your attributes list banging about afterwards:

`function Axle(vlist, mutate) = Object("Axle", ["diameter=i", "length=i"], vlist, mutate);`

In this example we'll create a function `Axle()` that'll take two arguments: `vlist` and `mutate`. 
The name `"Axle"` is the name we picked up in Step 1, and we use it for the name of the constructor 
function, and as the first argument we pass to `Object()`. `Axle_attributes` is the list of attributes we 
defined in Step 2. 

**The `vlist` argument** ("variable-list") is a list-of-lists of arguments with the attributes and their known values.
The `vlist` argument is meant to decouple ordering of arguments, placement of arguments, and required arguments to constructors. 
These attributes and their values can appear in any order, but they need to be a list of attribute-value pairs, and they can't repeat. 
They look like: `[[attr1, value1], [attr2, value2], [attrN, valueN]]`. 
Within `Object()`, the `vlist` list is used to populate the object's values.
`vlist` is structured as a two-dimensional list of attribute:value pairs both 
to ease construction of the object, and to make assembling attribute:value pair listings
straightforward. 

(That said, some implementations may find specifying the two-level `vlist` list 
argument to `Object()` clunky: specifying `[ ["attrname", value], ["attr2", value] ... ]` 
when none of these are expected to change in a simple .scad seems like overkill *(and, 
let's be honest: it's a lot of square brackets)*. To make this even easier, `vlist` 
itself may take two different forms. The first is the attribute:value
listing already defined, eg: `[["attr", "val"], ["attr2", "val2"]]`. The second is a 
running single-dimension list of attribute, value pairings, eg: 
`["attr", "val", "attr2", "val2"]`. In the second, flatter form, pairings *must* be 
adjacent and each specified attribute *must* have a paired value, in addition to the 
rules already put out for `vlist` above.)

**The `mutate` argument** is expected to be an already-instantiated object, on which to base unspecified attribute values. 
To make construction easier when you're dealing with multiple objects that only vary by one or two attributes, 
you can "mutate" them with the `mutate` argument. Pass an existing object of the same type to the constructor, and 
define any number of attribute values with `vlist`, and you'll get back a new object using the existing object 
as the base and the `vlist`-specified attributes substituted in. You could specify *no* attributes with `vlist`, and 
get back a duplicate object that's identical to the mutated one. 

Calling this new `Axle()` function defined above will return a new "axle" object:

`axle = Axle();`

This `axle` list will look a little weird, maybe a little opaque. The first element of this 
list is something called the *TOC*, for the table of contents. It's got the name of the object type (`"Axle"`) as its 
first element, followed by the list of attributes provided to `Axle()`, in the order that they were provided. 
After the TOC, the list will have the values for the attributes as provided (or set to `undef` if there was no value) in the 
same index as the attributes listed in the TOC. An empty Axle object, like the one we just made above, looks like: 

`[["Axle", ["diameter", "i"], ["length", "i"]], undef, undef]`

The zeroth (first) index postition of the object is the TOC; the zeroth index position of the TOC is the object 
name (in this case, "Axle"). The `one` index position of the object (the second element, undef) is the value of the `one` 
index position of the TOC; the `two` index (the third element, also undef) is the value of the `two` index of 
the TOC, and so on. In the above example, this object is empty: it has no values assigned. 
When values are provided to the `Axle()` constructor, they're present in the object list, in the same position 
that cooresponds to the attribute name in the TOC. 

`axle = Axle([["diameter", 10], ["length", 5]]);`

... would yield a list called `axle` that looks like:

`[["Axle", ["diameter", "i"], ["length", "i"]], 10, 5]`

The assigment of the object values into the object is done without regard of the order they're provided 
in `vlist`. `Axle([["diameter", 10], ["length", 5]])` will produce a list exactly the same as 
`Axle([["length", 5], ["diameter", 10]])`. In both of those calls you'll get back a new list that looks 
like `[["Axle", "diameter", "length"], 10, 5]`, because that's how the attributes were provided to `Object()`. 
Really, though - ordering within the object isn't important: you're not going to be extracting the values 
with the list's position index, that's what the accessors below are for.
. 
If an attribute name is passed that isn't defined in the object, via `Axle_attributes`, 
`Object()` will notice and stop: `Object("Axle", Axle_attributes, [["nope", 1]])` will throw an error, something akin to 
*"No id match for attribute 'nope' found for Axle. Available attribute names are ["diameter", "length"]"*, which I think 
we can all agree is a little bit useful, especially when you keep mis-typing the attribute name as "dimeter". 

## Subsection: 4. Create your object accessors
*tl;dr:* `function axle_diameter(axle, default, nv) = obj_accessor(axle, "diameter", default, nv);`

This LibFile provides a generic mutating accessor named `obj_accessor()`, which allows you to get and set attribute values 
in your object. You can call `obj_accessor()` directly as such - `obj_accessor(axle, "diameter")`
... and have the value of that Axle object's `diameter` attribute returned. Pass a `default` option, and if there isn't 
a `diameter` attribute already defined in the `axle` object, you'll get the value from `default`.  Pass a `nv` (new-value) option, and 
that attribute will be set to that of `nv`, and a whole new Axle object will be returned. 

This is great, but a little clunky. First of all, there's very little room for regular, repeatable mutation under 
certain conditions. Like say for example 
we want to get the diameter, but if it's not set we want to derive it from the length, like `length * 0.2`. You can't 
easily do that when calling `obj_accessor()` directly, even when using the `default` option. 

Instead, let's make two mutating accessors for the two Axle attributes: `axle_diameter()`, and 
`axle_length()`. They simplify calling `obj_accessor()` again and again by wrapping the calls with the additional 
`name` and `attribute_list` arguments already present. For our two attributes, we create the following two accessor 
functions:

`function axle_length(axle, default, nv) = obj_accessor(axle, "length", default, nv);`

`function axle_diameter(axle, default, nv) = obj_accessor(axle, "diameter", default, nv);`

These two functions take in an Axle object as their first argument, a default value as the second, and a new-value 
argument as the third. We could definitely set a default value for these functions if it made sense to do so: 
for example, if we usually had axles that were 5mm in diameter, we could say `function axle_diameter(axle, default=5, nv)...`
and that'd be great: any Axle objects that didn't have a `diameter` set would have `5` returned, and if you had an axle 
with a diameter of `6`, you'd get that `6` when you called `axle_diameter()`. 

*(I lament that objects cannot have the notion of "methods", such that accessors and other functions belong to the object, 
rather than global namespace functions existing that operate on whatever you give them. Alas.)* 

## Subsection: 5. Using Objects within your OpenSCAD Source: an axle module
Building on the basic steps above in the "Minimal Tooling" section, let's see how we can get those objects 
in use. 
Let's start with a basic axle module:

```
module axle(d, l) { 
    linear_extrude(l, center=true) circle(d); 
}

axle(5, 10);
```

Easy-peasy lemon-squeezy: this naive `axle()` module takes a `d` argument for the axle's diameter, and an `l` argument 
for the axle's length, uses the `d` to make a circle, then extrudes that circle to the correct length. Calling 
`axle(5, 10)` creates a cylinder that's 5mm in diameter and 10mm long. That's our "axle". 
Calling that over and over with different values is all right, though maybe not 
so much when you're using the notion of an axle in a larger model, or repeatedly creating axles across several models. 
Take the example above, and let's object-ify this `axle()` module:

```
include <object_common_functions.scad>

Axle_attributes = ["diameter=i", "length=i"];
function Axle(vlist=[], mutate=[]) = Object("Axle", Axle_attributes, vlist, mutate);

module axle(axle) { 
    linear_extrude(axle_length(axle), center=true) circle(axle_diameter(axle)); 
}

axle = Axle([["diameter", 5], ["length", 10]]);

axle(axle);
```

The module `axle()` now take a single argument - an Axle object - and uses that to extract the `diameter` and `length` 
attributes when needed. If there's other attributes in an Axle object, `axle()` doesn't care about them. If you extend 
the Axle object attribute list later on - say if you have a new module `curved_axle()` that takes a new `arc_degrees` 
attribute - you don't need to retool the `axle()` module if it doesn't need that attribute. And, once you've defined 
your `axle` object, you can pass it around to other modules that also need to incorporate this same Axle. 

# Section: Limitations of OpenSCAD Objects
If you're used to working with object-oriented programming in a reasonably modern language, the general   
idea of objects is probably already natural to you, and you're already looking at all this and thinking, 
"but wait, what about private encapsulated object data , or polymorphism, or inheritance, or class-specific 
methods, or, or, or?"  
Some of these things just aren't possible in OpenSCAD; calling functions by reference isn't a thing and there's 
really only one namespace into which we can put things, so making modules and functions "private" is a non-starter. 
OpenSCAD is declaritive, and changing variable values after assignment isn't a thing, so we lose out on things like 
easily inherited classes. I imagine one could produce a whole laundry list like this. 

## So... why?
This LibFile wasn't built to meet all those needs. It really only had a few things in mind:
1. **making spec'ing arguments for modules easier:** I stopped wanting to care about endless module arguments about the time I got to 4, and really annoyed after about 6. Passing arguments into modules via a list made a lot of sense, especially when the models were getting reused again and again. 
2. **making ordering of arguments a non-issue:** honestly once you get to about 5 arguments to a module, ordering is a pain. Openscad has named arguments you can specify in any order, but again, if you're looking at lots and lots of arguments to a module, that's still a lot of typing. 
3. **passing around collections of arguments to other modules and functions:** as it turns out, some models I'm working with really like to build around other models: a wheel that has an axle will want to know how big an opening to carve for that axle; rather than extract the value and provide it to the `pulley()` module, just give the `pulley()` module the axle object and let it figure out what it needs. 
4. **validating data types for use:** because after the first time I referenced a string value thinking it was an integer, I felt there was enough ambiguity to reliably avoid. 



