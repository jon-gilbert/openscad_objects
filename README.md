# openscad_objects
Functions for creating and accessing object-like lists in OpenSCAD

This library was made to address a set number of issues within OpenSCAD:

1. **passing around collections of arguments to other modules and functions.** As it turns out, some models I'm working with really like to build around other models: a wheel that has an axle will want to know how big an opening to carve for that axle; rather than extract the value and provide it to that wheel module, just give the wheel module the axle object and let it figure out what it needs. `openscad_objects` lets you group common sets of variables together into an easy-to-reference and easy-to-pass-as-an-argument set of data.
2. **validating data types for use.** Because after the first time I referenced a string value thinking it was an integer, I felt there was enough ambiguity to reliably avoid. `openscad_objects` provides functionality to compare data values with data types when storing them together into an object, so that you know you're not accidentally storing a string when you need an integer. 
3. **making spec'ing arguments for modules easier.** I stopped wanting to care about endless module arguments about the time I got to 4, and really annoyed after about 6. Passing arguments into modules via a list made a lot of sense, especially when the models were getting reused again and again. By collapsing a common, related group of variables into a single grouped object, writing modules that needed all of those variables becomes easier. 
4. **making ordering of arguments a non-issue.** honestly once you get to about 5 arguments to a module, ordering is a pain. OpenSCAD has named arguments you can specify in any order, but again, if you're looking at lots and lots of arguments to a module, that's still a lot of typing. Setting the arguments that describe a particular shape _once_, and then reusing those arguments, is a game-saver. 
5. **providing default values when none are set.** When you've got a wide variety of arguments grouped together for model reuse, you sometimes (often?) get an attribute that changes occasionally, but not always. `openscad_objects` provides a default value facility for attributes within an object, giving you the flexibility when you need it, but reducing repetitive value declaration when you don't. 

## Howto
See [HOWTO](https://github.com/jon-gilbert/openscad_objects/wiki/HOWTO) for a quick, high-level guide on implementing Objects into your OpenSCAD module

## Reference Documentation
All of the object functions are documented within [object_common_functions.scad](https://github.com/jon-gilbert/openscad_objects/wiki/object_common_functions.scad), with indexing at [AlphaIndex](https://github.com/jon-gilbert/openscad_objects/wiki/AlphaIndex) & [TOC](https://github.com/jon-gilbert/openscad_objects/wiki/TOC).

## Caveats
As limitations are documented, you'll find them under [Caveats & Limitations](https://github.com/jon-gilbert/openscad_objects/wiki/Caveats-&-Limitations).

## Installing
Until we get packaging up and running here, the simpliest way to install this is to download the most recent zip from Github, and copy the `object_common_functions.scad` file into your OpenSCAD library directory. 

You'll need the most-excellent BOSL2 framework to get this working; see https://github.com/revarbat/BOSL2 for instructions on how to download and incorporate it. 

## "I need help!"
A lot of this project might be generously considered "works for me", and I'm entirely not sure what'll happen when you use it for *you*. That's ok! If something doesn't seem to work right, a GitHub issue is perhaps the best way to let me know. 
