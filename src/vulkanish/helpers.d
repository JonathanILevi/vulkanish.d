module vulkanish.helpers; 

import erupted;
import foreignptr;

import vulkanish.helpers.internal;
public import vulkanish.helpers.types;

import std.traits;
import std.meta;
import std.string;
import std.conv;

void vshAssert(VkResult success) {
	assert(success == VK_SUCCESS);
}
void vshEnforce(VkResult success) {
	assert(success == VK_SUCCESS);
}

alias vshEnumerate(string name) = vshEnumerate!(functionMixin!("vkEnumerate"~name));
template vshEnumerate(alias f_unenforced) {
	mixin enforceF(f_unenforced);
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

alias vshCreate(string name) = vk!(functionMixin!("vkCreate"~name),functionMixin!("vkDestroy"~name));
template vshCreate(alias f_unenforced, alias deconstruct) {
	mixin enforceF(f_unenforced);
	// Returns through last argument as pointer.
	static assert (isPointer!(Params[$-1]));
	Vk!(Params[0..$-1]) vshCreate(Params[0..$-1] args) {
		PointerTarget!(Params[$-1]) outPtr;
		f(args,&outPtr);
		return foreignPtr(outPtr, vshDestroy!deconstruct(args[0..Parameters!deconstruct.length-2],args[$-1]));
	}
	// Second to last argument allocator.
	static assert (is(Params[$-2] == const(VkAllocationCallbacks)*)) {
	Vk!(Params[0..$-1]) vshCreate(Params[0..$-2] args) {
		PointerTarget!(Params[$-1]) outPtr;
		f(args,null,&outPtr);
		static if (args[0..Parameters!deconstruct.length-2].length)
			return foreignPtr(vshDestroy!deconstruct(args[0..Parameters!deconstruct.length-2]))(outPtr);
		else
			return foreignPtr!(vshDestroy!deconstruct(args[0..Parameters!deconstruct.length-2]))(outPtr);
	}
}

alias vshCall(alias f) = vsh!f;
alias vsh(string name) = vsh!(functionMixin!("vk"~name));
template vsh(alias f_unenforced) {
	mixin enforceF(f_unenforced);
	auto vsh(Params args) {
		f(args);
	}
	//--- Second to last argument allocator.
	static if (is(Params[$-2] == const(VkAllocationCallbacks)*)) {
		// Given no allocator
		auto vsh(Params[0..$-2] args, Params[$-1] lastArg) {
			f(args,null,lastArg);
		}
	}
	//--- Returning through last argument as pointer.
	static if (isPointer!(Params[$-1])) {
		// Given no out ptr.
		auto vsh(Params[0..$-1] args) {
			PointerTarget!(Params[$-1]) outPtr;
			f(args,&outPtr);
			return outPtr;
		}
		//--- Second to last argument allocator.
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





