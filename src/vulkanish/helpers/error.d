 module vulkanish.helpers.error;

import erupted;
import std.traits;
import std.meta;

class AnyVshError : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}
class VshErrorErrorCode : AnyVshError {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}
class VshErrorSuccessCode : AnyVshError {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}
template VshErrorBase(VkResult errorCode) {
	static if (errorCode < 0)
		alias VshErrorBase = VshErrorErrorCode;
	else
		alias VshErrorBase = VshErrorSuccessCode;
}
static foreach (i, code; NoDuplicates!(EnumMembers!VkResult)) {
	mixin("class VshError_"~__traits(allMembers, VkResult)[i][3..$]~" : VshErrorBase!"~__traits(allMembers, VkResult)[i]~"{
		this(string msg=\"\", string file = __FILE__, size_t line = __LINE__) {
			super(\"Vulkan Error: "~__traits(allMembers, VkResult)[i]~": \"~msg, file, line);
		}
	}");
}
template VshError(VkResult errorCode) {
	static foreach (i, code; NoDuplicates!(EnumMembers!VkResult))
		static if (errorCode == code)
			mixin("alias VshError = VshError_"~__traits(allMembers, VkResult)[i][3..$]~";");
}

void vshAssert(VkResult errorCode) {
	version(assert) {
		if (errorCode == VK_SUCCESS)
			return;
		final switch (errorCode) {
			static foreach (i, code; NoDuplicates!(EnumMembers!VkResult))
				case code:
					throw new VshError!code;
		}
	}
}
void vshEnforce(VkResult errorCode) {
	if (errorCode == VK_SUCCESS)
		return;
	final switch (errorCode) {
		static foreach (i, code; NoDuplicates!(EnumMembers!VkResult))
			case code:
				throw new VshError!code();
	}
}