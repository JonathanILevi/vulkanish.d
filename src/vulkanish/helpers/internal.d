module vulkanish.helpers.internal;
 
import erupted;
import vulkanish.helpers.error;

import std.traits;
static if (!is(typeof(Unconst)))
	import core.internal.traits : Unconst;
import std.meta;
import std.string;

alias vshDestroy(string name) = vshDestroy!(functionMixin!("vkDestroy"~name));
template vshDestroy(alias f) {
	import std.traits;
	auto vshDestroy(Parameters!f[0..$-2] args) {
		return (Parameters!f[$-2] p) {
			f(args, p, null);
		};
	}
	auto vshDestroy(Parameters!f[0..$-2] args, const(VkAllocationCallbacks)* allocationCallback) {
		return (Parameters!f[$-2] p) {
			f(args, p, allocationCallback);
		};
	}
}
template functionMixin(string name) {
	import std.traits;
	auto functionMixin(Parameters!(mixin(name)) args) {
		return mixin(name)(args);
	}
}


template enforced(alias f) {
	import std.traits;
	static if (is(ReturnType!f == void))
		alias enforced = f;
	else
		alias enforced = (Parameters!f args){vshEnforce(f(args));};
}

template destroyer(string T) {
	static if (!is(typeof(functionMixin!("vkDestroy"~T))) && is(typeof(functionMixin!("vkDestroy"~T[1..$].find!isUpper))))
		alias destroyer = functionMixin!("vkDestroy"~T[1..$].find!isUpper);
	static if (!is(typeof(functionMixin!("vkDestroy"~T))) && is(typeof(functionMixin!("vkDestroy"~T[1..$].find!isUpper[0..$-1]))))
		alias destroyer = functionMixin!("vkDestroy"~T[1..$].find!isUpper[0..$-1]);
	else
		alias destroyer = functionMixin!("vkDestroy"~T);
}

template destroyer(T) {
	import std.traits;
	alias destroyer = destroyer!(__traits(identifier, PointerTarget!(T))["Vk".length..$-"_handle".length]);
}

template UnConstPtr(T) {
	static if (isPointer!T)
		alias UnConstPtr = Unconst!(PointerTarget!T);
	else
		alias UnConstPtr = Unconst!T;
}
template isCreateInfoTypeKHR(T) {
	static if (is(UnConstPtr!T == struct))
		enum isCreateInfoTypeKHR = __traits(identifier, UnConstPtr!T).endsWith("CreateInfoKHR");
	else
		enum isCreateInfoTypeKHR = false;
}
template isCreateInfoType(T) {
	static if (is(UnConstPtr!T == struct))
		enum isCreateInfoType = __traits(identifier, UnConstPtr!T).endsWith("CreateInfo") || isCreateInfoTypeKHR!T;
	else
		enum isCreateInfoType = false;
}
template createInfoName(T) if(isCreateInfoType!T) {
	static if(isCreateInfoTypeKHR!T)
		enum createInfoName = __traits(identifier, UnConstPtr!T)["Vk".length..$-"CreateInfoKHR".length] ~ "KHR";
	else
		enum createInfoName = __traits(identifier, UnConstPtr!T)["Vk".length..$-"CreateInfo".length];
}

template isHandleType(T) {
	static if (is(UnConstPtr!T == struct))
		enum isHandleType = __traits(identifier, UnConstPtr!T).endsWith("_handle");
	else
		enum isHandleType = false;
}
template handleName(T) if(isHandleType!T) {
	enum handleName = __traits(identifier, UnConstPtr!T)["Vk".length..$-"_handle".length];
}

unittest {
	assert(isCreateInfoType!(VkDeviceCreateInfo*));
}

////template destroyer(Ts...) {
////	static assert(Ts.length == 1);
////	alias T = Ts[0];
////	import std.traits;
////	import std.meta;
////	pragma(msg, T);
////	pragma(msg, typeof(T));
////	static if (is(typeof(T)==string)) {
////		static if (!is(typeof(functionMixin!("vkDestroy"~T))) && is(typeof(functionMixin!("vkDestroy"~T[1..$].find!isUpper))))
////			alias destroyer = functionMixin!("vkDestroy"~T[1..$].find!isUpper);
////		static if (!is(typeof(functionMixin!("vkDestroy"~T))) && is(typeof(functionMixin!("vkDestroy"~T[1..$].find!isUpper[0..$-1]))))
////			alias destroyer = functionMixin!("vkDestroy"~T[1..$].find!isUpper[0..$-1]);
////		else
////			alias destroyer = functionMixin!("vkDestroy"~T);
////	}
////	else {
////		alias destroyer = destroyer!((PointerTarget!(typeof(T)))["Vk".length..$-"_handle".length]);
////	}
////}


////module vulkanish.helpers.internal;
//// 
////import erupted;
////import foreignptr;
////
////import std.traits;
////import std.meta;
////
////void vshAssert(VkResult success) {
////	assert(success == VK_SUCCESS);
////}
////void vshEnforce(VkResult success) {
////	assert(success == VK_SUCCESS);
////}
////
////alias vshDestroy(string name) = vshDestroy!(functionMixin!("vkDestroy"~name));
////template vshDestroy(alias f) {
////	import std.traits;
////	auto vshDestroy(HoldPtrs...)(Parameters!f[0..$-2] args, HoldPtrs holdPtrs)
////	if (allSatisfy!(isForeignPtr,HoldPtrs))
////	{
////		return (Parameters!f[$-2] p) {
////			f(args, p, null);
////		};
////	}
////	auto vshDestroy(HoldPtrs...)(Parameters!f[0..$-2] args, const(VkAllocationCallbacks)* allocationCallback, HoldPtrs holdPtrs)
////	if (allSatisfy!(isForeignPtr,HoldPtrs))
////	{
////		return (Parameters!f[$-2] p) {
////			f(args, p, allocationCallback);
////		};
////	}
////}
////template functionMixin(string name) {
////	import std.traits;
////	auto functionMixin(Parameters!(mixin(name)) args) {
////		return mixin(name)(args);
////	}
////}
////
////
////template enforced(alias f) {
////	import std.traits;
////	static if (is(ReturnType!f == void))
////		alias enforced = f;
////	else
////		alias enforced = (Parameters!f args){vshEnforce(f(args));};
////}
////
////private
////template isForeignPtr(T) {
////	alias TT = TemplateOf!(T);
////	enum isForeignPtr = is(TT!(void*) == ForeignPtr!(void*));
////}

