 module vulkanish.helpers.types;

import erupted;
import foreignptr;

import std.traits;
import std.meta;
import std.string;
import std.conv;

alias Vsh(string name) = Vsh!("Vk"~name));
template Vsh(T)
if (T.stringof.endswith("_handle*"))
{
	static assert (isCallable!(mixin("vkDestroy"~T.stringof["vk".length..$-"_handle*".length])));
	
	alias Vsh = ForeignPtr!T;
}



