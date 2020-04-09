module vulkanish.helpers.internal;
 
import erupted;

void vshAssert(VkResult success) {
	assert(success == VK_SUCCESS);
}
void vshEnforce(VkResult success) {
	assert(success == VK_SUCCESS);
}

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

