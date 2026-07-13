log("Entered file " .. debug.getinfo(1).source)
require("util")

local mod_data = require("__SmallRobots__/mod_data")
local common = require("__Pi-C_lib__/common")(mod_data)

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                            Variables and tables                                --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
--~ -- Get mod name and path to mod
--~ common.modName = script and script.mod_name or mod_name
--~ common.modName = "SmallRobots"
--~ common.modRoot = "__"..common.modName.."__"


------------------------------------------------------------------------------------
-- Scale bots of these prototype types
common.bot_types = { "construction-robot", "logistic-robot", "combat-robot" }

-- Table for the prototypes we have actually scaled. We care not just about the
-- *-robot prototypes, but also selected prototypes created by other mods as fake
-- bots (e.g. the spider-vehicle created by "Companion Drones").
common.scaled_prototypes = {}



------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                                LOCAL DEFINITIONS                               --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

--~ local function import_from_file(file_name)
  --~ for key, value in pairs(require(file_name)) do
    --~ common[key] = value
    --~ log(string.format("Added \"%s\": %s",
                      --~ key, type(value) == "function" and "function" or
                                                          --~ serpent.block(value)))
  --~ end
--~ end


--~ -- Load debugging functions
--~ import_from_file(common.modRoot..".libs.debugging")

--~ -- Load assertions
--~ import_from_file(common.modRoot..".libs.assertions")



------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                            Miscalleneous functions                             --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


--~ ------------------------------------------------------------------------------------
--~ -- Read startup settings
--~ common.get_startup_setting = function(setting)
  --~ return setting and settings.startup[setting] and settings.startup[setting].value
--~ end



--~ ------------------------------------------------------------------------------------
--~ -- Look for matching pattern at start of a string
--~ common.prefixed = function(look_in, find_at_start)
  --~ common.assert(look_in, "string", "string to check")
  --~ common.assert(find_at_start, "string", "search pattern")
  --~ return look_in:sub(1, #find_at_start) == find_at_start
--~ end


--~ ------------------------------------------------------------------------------------
--~ -- Look for matching pattern at start of a string
--~ common.number_from_string = function(look_in, find_pattern)
  --~ common.assert(look_in, "string", "string to check")
  --~ common.assert(find_at_start, "string", "search pattern")
  --~ return tonumber(look_in:match(find_pattern))
--~ end


--~ ------------------------------------------------------------------------------------
--~ --              Compare two values that may be either boolean or nil              --
--~ ------------------------------------------------------------------------------------
--~ common.states_differ = function(a, b)
  --~ return (not a ~= not b)
--~ end


--~ ------------------------------------------------------------------------------------
--~ --                       Check whether array contains value                       --
--~ ------------------------------------------------------------------------------------
--~ common.table_contains = function(tab, value)
  --~ local ret
  --~ for k, v in pairs(tab or {}) do
    --~ ret = (v == value)
    --~ if ret then
      --~ break
    --~ end
  --~ end

  --~ return ret
--~ end



------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                                String functions                                --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

--~ ------------------------------------------------------------------------------------
--~ -- Remove characters at beginning or end of a string
--~ common.trim_chars = function(remove_from, left, right)
  --~ -- common.entered_function({remove_from, left, right})

  --~ common.assert(remove_from, "string")
  --~ common.assert(left, "string")
  --~ right = (type(right) == "string") and right or left

  --~ -- "*" returns the longest possible match, "-" the shortest
  --~ local pattern = "^["..left.."]*(.-)["..right.."]*$"
  --~ local ret = remove_from:match(pattern)

  --~ -- common.entered_function("leave")
  --~ return ret
--~ end


--~ -- This may already exist if libs.debugging has been loaded
--~ if not common.enquote then
  --~ local quote = "\""

  --~ common.enquote = function(text)
    --~ return quote..text..quote
  --~ end
--~ end


--~ ------------------------------------------------------------------------------------
--~ ------------------------------------------------------------------------------------
--~ --                                Output functions                                --
--~ ------------------------------------------------------------------------------------
--~ ------------------------------------------------------------------------------------

--~ ------------------------------------------------------------------------------------
--~ -- Format position (long format)
--~ common.format_position = function(position)
  --~ common.entered_function({position})
  --~ position = common.normalize_position(position)
  --~ return string.format("x=%s, y=%s", position.x, position.y)
--~ end


--~ ------------------------------------------------------------------------------------
--~ -- Format position (short format)
--~ common.format_position_short = function(position)
  --~ common.entered_function({position})
  --~ position = common.normalize_position(position)
  --~ return position.x..", "..position.y
--~ end



------------------------------------------------------------------------------------
common.entered_file("leave")
return common
