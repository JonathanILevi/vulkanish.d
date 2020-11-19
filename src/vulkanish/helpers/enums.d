 module vulkanish.helpers.enums;

import erupted;
import foreignptr;

import std.traits;
import std.meta;
import std.string;
import std.conv;

alias VSH(string name) = Self!(mixin("VK_"~name));
alias VSH(alias E) = E;


private template Self(alias s) {
	alias Self = s;
}



