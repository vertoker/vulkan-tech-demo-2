const std = @import("std");
const vk = @import("vulkan");

const vkExtensions = @import("extensions.zig");

const Errors = error {
    ValidationLayersNotAvailable,
    FailedToCreateVkInstance,

    CantEnumerateInstanceLayerProperties,
    OutOfMemory,
};

pub fn create(enableValidationLayers: bool) Errors!vk.VkInstance {
    if (enableValidationLayers and try !vkExtensions.chechValidationLayerSupport())
        return Errors.ValidationLayersNotAvailable;

    const appInfo: vk.VkApplicationInfo = .{};
    appInfo.sType = vk.VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = "vulkan-tect-demo-2 app";
    appInfo.applicationVersion = vk.VK_MAKE_API_VERSION(1, 0, 0, 0);
    appInfo.pEngineName = "vulkan-tech-demo-2 engine";
    appInfo.engineVersion = vk.VK_MAKE_API_VERSION(1, 0, 0, 0);

    const createInfo: vk.VkInstanceCreateInfo = .{};
    createInfo.sType = vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo = &appInfo;

    if (enableValidationLayers) {
        // createInfo.enabledLayerCount =
    }

    const instance: vk.VkInstance = undefined;
    if (!vk.vkCreateInstance(&createInfo, null, &instance)) {
        return Errors.FailedToCreateVkInstance;
    }

    // hasGflwRequiredInstanceExtensions

    std.log.info("VkInstance created: app_name={s}, engine_name={s}",
        .{appInfo.pApplicationName, appInfo.pEngineName});
    return instance;
}

pub fn destroy(instance: vk.VkInstance) void {
    vk.vkDestroyInstance(instance, null);
}