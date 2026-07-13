-- Set scale factor for bots from Atomic robots fix (https://mods.factorio.com/mod/AtomicRobotsFixv)
--~ if mods["AtomicRobotsFixv"] then
if mods["AtomicRobotsFix2"] or mods["AtomicRobotsFix2Boost"] then
    data:extend({
      -- Start-up settings
      {
          type = "double-setting",
          name = "SmallRobots-atomicbots_robot-size",
          setting_type = "startup",
          default_value = 0.3,
          maximum_value = 1.0,
          minimum_value = 0.1,
          order = "start-[size]-b-[atomic-bots]"
      }
    })
end
