const std = @import("std");
const vk = @import("vulkan");

const validationLayers = [_][]const u8 {
    "VK_LAYER_KHRONOS_validation",
};

const Errors = error {
    CantEnumerateInstanceLayerProperties,
    OutOfMemory,
};

pub fn chechValidationLayerSupport() Errors!bool {
    var layerCount: u32 = 0;
    var vkResult = vk.vkEnumerateInstanceLayerProperties(&layerCount, null);
    if (vkResult != vk.VK_SUCCESS)
        return Errors.CantEnumerateInstanceLayerProperties;
    
    // TODO optimize
    var availableLayers = try std.ArrayList(vk.VkLayerProperties)
        .initCapacity(std.heap.page_allocator, layerCount);
    defer availableLayers.deinit(std.heap.page_allocator);

    vkResult = vk.vkEnumerateInstanceLayerProperties(&layerCount, availableLayers.items.ptr);
    if (vkResult != vk.VK_SUCCESS)
        return Errors.CantEnumerateInstanceLayerProperties;

    for (validationLayers) |layerName| {
        var layerFound = false;

        for (availableLayers.items) |*layerProperties| {
            if (std.mem.eql(u8, &layerProperties.layerName, layerName)) {
                layerFound = true;
                break;
            }
        }

        if (!layerFound)
            return false;
    }

    return true;
}