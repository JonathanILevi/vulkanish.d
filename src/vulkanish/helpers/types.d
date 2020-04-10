 module vulkanish.helpers.types;

import erupted;
import refedforeignptr;

import vulkanish.helpers.functions;

import std.traits;
import std.meta;
import std.string;
import std.conv;

alias Vsh(string name) = Vsh!(mixin("Vk"~name));
template Vsh(T) {
	version(GCDestroyAsst) {
		static if (T.stringof.endsWith("_handle*") && __traits(compiles, mixin("vkDestroy"~T.stringof["vk".length..$-"_handle*".length])))
			alias Vsh = ForeignPtr!T;
		else
			alias Vsh = T;
	}
	else {
		alias Vsh = T;
	}
}
alias VshScoped(string name, VkAllocationCallbacks* allocator = null) = VshScoped!(mixin("Vk"~name), allocator);
template VshScoped(T, VkAllocationCallbacks* allocator = null) {
	static assert (T.stringof.endsWith("_handle*") && __traits(compiles, mixin("vkDestroy"~T.stringof["vk".length..$-"_handle*".length])));
	alias destroy = vsh!("Destroy"~T.stringof["vk".length..$-"_handle*".length]);
	struct Scoped_ {
		T scopedPayload;
		alias scopedPayload this;
		Parameters!destroy[0..$-2] scopedArgs;
		VkAllocationCallbacks* scopedAllocator;
		this (Parameters!destroy[0..$-2] args, T payload) {
			scopedArgs = args;
			scopedPayload = payload;
		}
		~this() {
			if (scopedPayload) {
				destroy(scopedArgs,scopedPayload,allocator);
			}
		}
	}
	alias VshScoped = Scoped_;
}

