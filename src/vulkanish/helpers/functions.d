module vulkanish.helpers.functions;

import std.traits;
static if (!is(typeof(Unconst)))
	import core.internal.traits : Unconst;

import erupted;
import refedforeignptr;

import vulkanish.helpers.internal;
import vulkanish.helpers.error;
import vulkanish.helpers.types;
import vulkanish.helpers.enums;

import std.meta;
import std.string;
import std.conv;
import std.typecons;

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
	
	////template hasAltType(T) {
	////	static if (isPointer!T && is(Unconst!(PointerTarget!T) == struct))
	////		enum hasAltType = __traits(identifier, Unconst!(PointerTarget!T)).endsWith("CreateInfo");
	////	else
	////		enum hasAltType = false;
	////}
	////template AltType(T) {
	////	static if (hasAltType!T)
	////		alias AltType = PointerTarget!T;
	////	else
	////		alias AltType = T;
	////}
	////template altArg(T)(T arg) {
	////	
	////}
	////mixin forParams!Params;
	////static if (anySatisfy!(hasAltType,Params))
	////	mixin forParams!(staticMap!(AltType,Params));
	////mixin template forParams(Params...) {
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
	else static if (isPointer!(Params[$-1]) && __traits(compiles, {PointerTarget!(Params[$-1]) outPtr;})) {
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
	////}
}

template vshDestroy(Ts...) if (Ts.length>0 && isHandleType!(Ts[$-1])) {
	enum name = handleName!(Ts[$-1]);
	alias f = functionMixin!("vkDestroy"~name);
	
	auto vshDestroy(Ts args, const(VkAllocationCallbacks)* allocator) {
		f(args,allocator);
	}
	auto vshDestroy(Ts args) {
		f(args,null);
	}
}
template vshDestroyRange(Ts...) if (Ts.length>0 && isHandleType!(ForeachType!(Ts[$-1]))) {
	enum name = handleName!(ForeachType!(Ts[$-1]));
	alias f = functionMixin!("vkDestroy"~name);
	import std.algorithm;
	
	auto vshDestroyRange(Ts args, const(VkAllocationCallbacks)* allocator) {
		args[$-1].each!(h=>f(args[0..$-1],h,allocator));
	}
	auto vshDestroyRange(Ts args) {
		args[$-1].each!(h=>f(args[0..$-1],h,null));
	}
}
template vshFrees(Ts...) if (Ts.length>0 && isHandleType!(ForeachType!(Ts[$-1]))) {
	enum name = handleName!(ForeachType!(Ts[$-1]));
	alias f = functionMixin!("vkFree"~name~"s");
	
	auto vshFrees(Ts args) {
		f(args[0..$-1], cast(uint) args[$-1].length, args[$-1].ptr);
	}
}

template vshCreate(Ts...) if (Ts.length>0 && isCreateInfoType!(Ts[$-1])) {
	enum name = createInfoName!(Ts[$-1]);
	static if (is(typeof(functionMixin!("vkCreate"~name~"s"))))
		alias f_unenforced = functionMixin!("vkCreate"~name~"s");
	else
		alias f_unenforced = functionMixin!("vkCreate"~name);
	alias f = enforced!f_unenforced;
	alias Params = Parameters!f;
	
	////auto vshCreate(Ts args, const(VkAllocationCallbacks)* allocator, Params[$-1]* outPtr) {
	////	f(args, allocator, outPtr);
	////}
	////// Second to last argument allocator.
	////static if (is(Params[$-2] == const(VkAllocationCallbacks)*)) {
	////	// Given no allocator
	////	auto vshCreate(Ts args, Vsh!(createInfoName!(Ts[$-1]))* outPtr) {
	////		f(args,null,outPtr);
	////	}
	////}
	////// Last argument allocator.
	////static if (is(Params[$-1] == const(VkAllocationCallbacks)*)) {
	////	// Given no allocator
	////	auto vsh(Ts args) {
	////		f(args,null);
	////	}
	////}
	// Returning through last argument as pointer.
	//// static if (isPointer!(Params[$-1]) && __traits(compiles, {PointerTarget!(Params[$-1]) outPtr;})) {
		// Given no out ptr.
		auto vshCreate(Ts args, const(VkAllocationCallbacks)* allocator) {
			PointerTarget!(Params[$-1]) outPtr;
			f(args, allocator, &outPtr);
			return outPtr;
		}
		// Second to last argument allocator.
		////static if (is(Params[$-2] == const(VkAllocationCallbacks)*)) {
			// Given no allocator nor out ptr.
			auto vshCreate(Ts args) {
				PointerTarget!(Params[$-1]) outPtr;
				f(args,null,&outPtr);
				return outPtr;
			}
		////}
	////}
}

template vshCreateScoped(Ts...)
////if ((Ts.length==1 && is(typeof(Ts[0])==string)) || (Ts.length==2 && isCallable!(Ts[0]) && isCallable!(Ts[1])))
{
	static if (Ts.length==1 && is(typeof(Ts[0])==string)) {
		enum name = Ts[0];
		alias f_unenforced = functionMixin!("vkCreate"~Ts[0]);
		import std.algorithm;
		import std.uni;
		alias destroy = destroyer!(Ts[0]);
		///static if (!is(typeof(functionMixin!("vkDestroy"~Ts[0]))) && is(typeof(functionMixin!("vkDestroy"~Ts[0][1..$].find!isUpper))))
		///	alias destroy = functionMixin!("vkDestroy"~Ts[0][1..$].find!isUpper);
		///static if (!is(typeof(functionMixin!("vkDestroy"~Ts[0]))) && is(typeof(functionMixin!("vkDestroy"~Ts[0][1..$].find!isUpper[0..$-1]))))
		///	alias destroy = functionMixin!("vkDestroy"~Ts[0][1..$].find!isUpper[0..$-1]);
		///else
		///	alias destroy = functionMixin!("vkDestroy"~Ts[0]);
	}
	else static if (Ts.length==1) {
		alias f_unenforced = Ts[0];
		alias destroy = destroyer!(T[0]);
	}
	else static if (Ts.length==2 && isCallable!(Ts[0]) && isCallable!(Ts[1])) {
		alias f_unenforced = Ts[0];
		alias destroy = Ts[1];
	}
	else {
		static assert(false);
	}
	alias f = enforced!f_unenforced;
	alias Params = Parameters!f;
	alias T = PointerTarget!(Params[$-1]);
	alias ScopedT = VshScoped!T;
	// Returns through last argument as pointer.
	static assert (isPointer!(Params[$-1]));
	ScopedT vshCreateScoped(Parameters!f[0..$-1] args) {
		T outPtr;
		f(args, &outPtr);
		return ScopedT(args[0..Parameters!(ScopedT.__ctor).length-1], outPtr);
	}
	// Second to last argument allocator.
	static assert (is(Params[$-2] == const(VkAllocationCallbacks)*));
	ScopedT vshCreateScoped(Params[0..$-2] args) {
		T outPtr;
		f(args, null, &outPtr);
		return ScopedT(args[0..Parameters!(ScopedT.__ctor).length-1], outPtr);
	}
}

string vshScopedDestroy(string v, string args="") {
	if (args.strip!="")
		args ~= ',';
	return "scope (exit) if ("~v~" != null) {
		import vulkanish.helpers.functions;
		vshDestroy("~args~v~");
		////import vulkanish.helpers.internal:destroyer;
		////import vulkanish.helpers.functions:vsh;
		////vsh!(destroyer!(typeof("~v~")))("~args~v~");
	}";
}
string vshScopedDestroyRange(string v, string args="") {
	if (args.strip!="")
		args ~= ',';
	return "scope (exit) {
		import vulkanish.helpers.functions;
		vshDestroyRange("~args~v~");
		////import vulkanish.helpers.internal:destroyer;
		////import vulkanish.helpers.functions:vsh;
		////import std.algorithm:each;
		////"~v~".each!(h=>vshDestroy("~args~"h));
		////"~v~".each!(h=>vsh!(destroyer!(typeof(h)))("~args~"h));
	}";
}
string vshScopedFrees(string v, string args="") {
	if (args.strip!="")
		args ~= ',';
	return "scope (exit) if ("~v~" != []) {
		import vulkanish.helpers.functions;
		vshFrees("~args~v~");
	}";
}





