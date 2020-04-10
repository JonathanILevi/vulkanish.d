module vulkanish.helpers.functions; 

import erupted;
import refedforeignptr;

import vulkanish.helpers.internal;
import vulkanish.helpers.types;
import vulkanish.helpers.enums;

import std.traits;
import std.meta;
import std.string;
import std.conv;
import std.typecons;

version(GCDestroyAsst) {
	public import vulkanish.helpers.gc_destroy_asst.functions;
}

alias vshEnumerateAlt(string name) = vshEnumerate!(functionMixin!("vk"~name));
alias vshEnumerate(string name) = vshEnumerate!(functionMixin!("vkEnumerate"~name));
template vshEnumerate(alias f_unenforced)
////if (isCallable!f_unenforced)
{
	static assert(isCallable!f_unenforced);
	alias f = enforced!f_unenforced;
	alias Params = Parameters!f;
	PointerTarget!(Params[$-1])[] vshEnumerate(Params[0..$-2] args) {
		uint count;
		f(args, &count, null);
		if (count == 0)
			return [];
		auto outArray = new PointerTarget!(Params[$-1])[count];
 		f(args, &count, outArray.ptr);
		return outArray;
	}
}


alias vshCall(alias f) = vsh!f;
alias vsh(string name) = vsh!(functionMixin!("vk"~name));
template vsh(alias f_unenforced)
////if (isCallable!f_unenforced)
{
	static assert(isCallable!f_unenforced);
	alias f = enforced!f_unenforced;
	alias Params = Parameters!f;
	auto vsh(Params args) {
		f(args);
	}
	// Second to last argument allocator.
	static if (is(Params[$-2] == const(VkAllocationCallbacks)*)) {
		// Given no allocator
		auto vsh(Params[0..$-2] args, Params[$-1] lastArg) {
			f(args,null,lastArg);
		}
	}
	// Last argument allocator.
	static if (is(Params[$-1] == const(VkAllocationCallbacks)*)) {
		// Given no allocator
		auto vsh(Params[0..$-1] args) {
			f(args,null);
		}
	}
	// Returning through last argument as pointer.
	else static if (isPointer!(Params[$-1])) {
		// Given no out ptr.
		auto vsh(Params[0..$-1] args) {
			PointerTarget!(Params[$-1]) outPtr;
			f(args,&outPtr);
			return outPtr;
		}
		// Second to last argument allocator.
		static if (is(Params[$-2] == const(VkAllocationCallbacks)*)) {
			// Given no allocator nor out ptr.
			auto vsh(Params[0..$-2] args) {
				PointerTarget!(Params[$-1]) outPtr;
				f(args,null,&outPtr);
				return outPtr;
			}
		}
	}
}

version(NoDestroyAsst) {
	alias vshCreate(string name) = vsh!("Create"~name);
	alias vshDestroy(string name) = vsh!("Destroy"~name);
}





