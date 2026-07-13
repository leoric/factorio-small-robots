SR = require("common")
SR.entered_file()
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
-- If you are the author of a mod that creates flying bots, and if you don't want
-- "SmallRobots" to scale your mods, please add the flag "SR_dont_scale_me" to your
-- prototype! Example:
--
-- my_bot = table.deepcopy(data.raw["construction-bot"]["construction-bot"])
-- my_bot.SR_dont_scale_me = true
------------------------------------------------------------------------------------

-- Fix for
SR.bot_ignore_patterns = {
  -- Prototypes created by "Rampant" and "Rampant, fixed"
  "-drone-rampant"
}

-- Scale the bots!
SR.writeDebug("Scaling bots!")
require("prototypes.scale_bots")


-- Remove ALT info (If the setting is off, unhide ALT info!)
SR.writeDebug("Hide ALT-info?")
require("prototypes.hide_alt_info")


-- Remove shadows
if SR.get_startup_setting("SmallRobots-remove-shadows") then
  SR.writeDebug("Remove shadows!")
  require("prototypes.hide_shadows")
end


------------------------------------------------------------------------------------
SR.entered_file("leave")
