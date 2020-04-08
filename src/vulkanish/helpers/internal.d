module vulkanish.helpers.internal;
 


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


mixin template enforceF(alias f_unenforced) {
	alias Params = Parameters!f_unenforced;
	static if (is(ReturnType!f_unenforced == void))
		alias f = f_unenforced;
	else
		alias f = (Params args){vshEnforce(f_unenforced(args));};
}

 
