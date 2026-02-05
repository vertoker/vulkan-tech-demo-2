const std = @import("std");
const vk = @import("vulkan");
const glfw = @import("glfw");

const Allocator = std.mem.Allocator;

const validationLayers = [_][]const u8 {
    "VK_LAYER_KHRONOS_validation",
};

pub const VkContext = struct {
    pub const Self = @This();

    vkb: vk.BaseWrapper,
    validation_layers: [][]const u8,

    pub fn init(
        // allocator: Allocator,
    ) !VkContext {
        var self: VkContext = undefined;
        self.vkb = vk.BaseWrapper.load(glfw.glfwGetInstanceProcAddress);
        // self.validation_layers = ;
    }
};

pub fn create(enableValidationLayers: bool) !vk.Instance {
    // const vkb = vk.BaseWrapper.load(glfw.glfwGetInstanceProcAddress);

    if (enableValidationLayers) {
        const support = try chechValidationLayerSupport();
        if (!support) return error.ValidationLayersNotAvailable;
    }

    var appInfo: vk.ApplicationInfo = .{
        .p_application_name = "vulkan-tect-demo-2 app",
        .application_version = vk.makeApiVersion(1, 0, 0, 0).toU32(),
        .p_engine_name = "vulkan-tech-demo-2 engine",
        .engine_version = vk.makeApiVersion(1, 0, 0, 0).toU32(),
        .api_version = vk.makeApiVersion(1, 0, 0, 0).toU32(),
    };

    var createInfo: vk.InstanceCreateInfo = .{
        .p_application_info = &appInfo,
    };

    if (enableValidationLayers) {
        // createInfo.enabledLayerCount =
    }

    var instance: vk.Instance = undefined;
    if (vk.createInstance(&createInfo, null, &instance) != vk.VK_SUCCESS) {
        return error.FailedToCreateVkInstance;
    }

    // hasGflwRequiredInstanceExtensions

    std.log.info("VkInstance created: app_name={s}, engine_name={s}",
        .{appInfo.pApplicationName, appInfo.pEngineName});
    return instance;
}

pub fn destroy(instance: vk.Instance) void {
    vk.destroyInstance(instance, null);
}

fn checkLayerSupport(vkb: *const vk.BaseWrapper, alloc: Allocator) !bool {
    const available_layers = try vkb.enumerateInstanceLayerPropertiesAlloc(alloc);
    defer alloc.free(available_layers);

    // for (required_layer_names) |required_layer| {
        // for (available_layers) |layer| {
            // if (std.mem.eql(u8, std.mem.span(required_layer),
            // std.mem.sliceTo(&layer.layer_name, 0))) {
                // break;
            // }
        // } else {
            // return false;
        // }
    // }
    return true;
}

pub fn chechValidationLayerSupport(vkb: *const vk.BaseWrapper) !bool {

    var layerCount: u32 = 0;
    var vkResult = try vkb.enumerateInstanceLayerProperties(&layerCount, null);
    if (vkResult != vk.Result.success)
        return error.CantEnumerateInstanceLayerProperties;

    // TODO optimize
    var availableLayers = try std.ArrayList(vk.LayerProperties)
    .initCapacity(std.heap.page_allocator, layerCount);
    defer availableLayers.deinit(std.heap.page_allocator);

    vkResult = try vkb.enumerateInstanceLayerProperties(&layerCount, availableLayers.items.ptr);
    if (vkResult != vk.Result.success)
        return error.CantEnumerateInstanceLayerProperties;

    for (validationLayers) |layerName| {
        var layerFound = false;

        for (availableLayers.items) |*layerProperties| {
            if (std.mem.eql(u8, &layerProperties.layer_name, layerName)) {
                layerFound = true;
                break;
            }
        }

        if (!layerFound)
            return false;
    }

    return true;
}