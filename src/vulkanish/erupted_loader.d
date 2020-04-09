module vulkanish.erupted_loader;

public import erupted.vulkan_lib_loader; 
public import erupted.functions : loadInstanceLevelFunctions, loadDeviceLevelFunctions;

auto loadGlobalLevelFunctions(void* ptr) {
	import std.traits;
	erupted.vulkan_lib_loader.loadGlobalLevelFunctions(cast(Parameters!(erupted.vulkan_lib_loader.loadGlobalLevelFunctions)[0]) ptr);
}
