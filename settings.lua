data:extend({
    -- Start-up settings
    {
        -- Set scale factor for all bots
        type = "int-setting",
        name = "SmallRobots-robot-size",
        setting_type = "startup",
        default_value = 50,
        maximum_value = 250,
        minimum_value = 25,
        order = "start-[size]-a-[all]"
    },
    {
        -- Set "hide-alt-info" for all bots
        type = "bool-setting",
        name = "SmallRobots-alt-off",
        setting_type = "startup",
        default_value = false,
        --~ allowed_values = {"true", "false"},
        order = "startup-[alt-off]-a-[all]"
    },
    {
        -- Remove "shadow-X" animations of all bots
        type = "bool-setting",
        name = "SmallRobots-remove-shadows",
        setting_type = "startup",
        default_value = false,
        --~ allowed_values = {"true", "false"},
        order = "startup-[remove-shadows]-a-[all]"
    },
    -- Per-player settings
})
