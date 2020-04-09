 module vulkanish.helpers.types;

import erupted;
import refedforeignptr;

import std.traits;
import std.meta;
import std.string;
import std.conv;

alias Vsh(string name) = Vsh!(mixin("Vk"~name));
template Vsh(T) {
	static if (T.stringof.endsWith("_handle*") && __traits(compiles, mixin("vkDestroy"~T.stringof["vk".length..$-"_handle*".length]))) {
		alias Vsh = ForeignPtr!T;
	}
	else {
		alias Vsh = T;
	}
}

