module vulkanish.helpers.gc_destroy_asst.functions; 

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


template vshCreate(T...)
////if ((T.length==1 && is(typeof(T[0])==string)) || (T.length==2 && isCallable!(T[0]) && isCallable!(T[1])))
{
	static if (T.length==1 && is(typeof(T[0])==string)) {
		enum name = T[0];
		alias f_unenforced = functionMixin!("vkCreate"~T[0]);
		alias deconstruct = functionMixin!("vkDestroy"~T[0]);
	}
	////else static if (T.length==2 && isCallable!(T[0]) && isCallable!(T[1])) {
	////	alias f_unenforced = T[0];
	////	alias deconstruct = T[1];
	////}
	else {
		static assert(false);
	}
	alias f = enforced!f_unenforced;
	alias Params = Parameters!f;
	static if (name == "Device")
		alias HoldPtrs = AliasSeq!(Vsh!"Instance");
	else
		alias HoldPtrs = AliasSeq!();
	// Returns through last argument as pointer.
	static assert (isPointer!(Params[$-1]));
	Vsh!(PointerTarget!(Params[$-1])) vshCreate(Parameters!f[0..$-1] args, HoldPtrs holdPtrs) {
		PointerTarget!(Params[$-1]) outPtr;
		f(args,&outPtr);
		return foreignPtr(vshDestroy!deconstruct(args[0..Parameters!deconstruct.length-2],args[$-1]), outPtr,holdPtrs);
	}
	// Second to last argument allocator.
	static assert (is(Params[$-2] == const(VkAllocationCallbacks)*));
	Vsh!(PointerTarget!(Params[$-1])) vshCreate(Params[0..$-2] args, HoldPtrs holdPtrs) {
		PointerTarget!(Params[$-1]) outPtr;
		f(args,null,&outPtr);
		static if (args[0..Parameters!deconstruct.length-2].length)
			return foreignPtr(vshDestroy!deconstruct(args[0..Parameters!deconstruct.length-2]), outPtr,holdPtrs);
		else
			return foreignPtr!(vshDestroy!deconstruct(args[0..Parameters!deconstruct.length-2]))(outPtr,holdPtrs);
	}
}
////alias vshCreate(string name) = vshCreate!(functionMixin!("vkCreate"~name), functionMixin!("vkDestroy"~name));
////template vshCreateImpl(alias f_unenforced, alias deconstruct)
////if (isCallable!f_unenforced && isCallable!deconstruct)
////{
////	alias f = enforced!f_unenforced;
////	alias Params = Parameters!f;
////	// Returns through last argument as pointer.
////	static assert (isPointer!(Params[$-1]));
////	Vsh!(PointerTarget!(Params[$-1])) vshCreate(Parameters!f[0..$-1] args) {
////		PointerTarget!(Params[$-1]) outPtr;
////		f(args,&outPtr);
////		return foreignPtr(outPtr, vshDestroy!deconstruct(args[0..Parameters!deconstruct.length-2],args[$-1]));
////	}
////	// Second to last argument allocator.
////	static assert (is(Params[$-2] == const(VkAllocationCallbacks)*));
////	Vsh!(PointerTarget!(Params[$-1])) vshCreate(Params[0..$-2] args) {
////		PointerTarget!(Params[$-1]) outPtr;
////		f(args,null,&outPtr);
////		static if (args[0..Parameters!deconstruct.length-2].length)
////			return foreignPtr(vshDestroy!deconstruct(args[0..Parameters!deconstruct.length-2]))(outPtr);
////		else
////			return foreignPtr!(vshDestroy!deconstruct(args[0..Parameters!deconstruct.length-2]))(outPtr);
////	}
////}

