 module vulkanish.helpers.enums;

import erupted;
import foreignptr;

import std.traits;
import std.meta;
import std.string;
import std.conv;

alias VSH(string name) = VSH!(mixin("VK_"~name));
template VSH(alias E) {
	alias VSH = E;
}



