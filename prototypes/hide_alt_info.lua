SR.entered_file()
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                             HIDE OR UNHIDE ALT-INFO                            --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
local hide_alt = SR.get_startup_setting("SmallRobots-alt-off")



------------------------------------------------------------------------------------
--                                    Functions                                   --
------------------------------------------------------------------------------------
-- Returns the position in the table if the required flag is set, or nil otherwise
local function get_flag(flags, need)
  local pos

  if type(flags) == "table" and type(need) == "string" then
    for i = 1, table_size(flags) do
      if flags[i] == need then
        pos = i
        break
      end
    end
  end

  SR.entered_function("leave")
  return pos
end


------------------------------------------------------------------------------------
--                                 Call functions                                 --
------------------------------------------------------------------------------------
local robot, flag_set

SR.show("SR.scaled_prototypes", SR.scaled_prototypes)

for bot_type, bot_names in pairs(SR.scaled_prototypes) do
  for b, bot_name in pairs(bot_names) do
    robot = data.raw[bot_type][bot_name]
SR.show("robot", robot)
    if robot then
      -- Get position of "hide-alt-info" in robots.flags or nil it flag is not set
      flag_set = get_flag(robot.flags, "hide-alt-info")
      -- Hide/show info on ALT:
      -- Only set flag if it hasn't been set yet
      if hide_alt and not flag_set then
        SR.writeDebug("%s: Hiding ALT-info", {SR.argprint(bot_name)})
        table.insert(robot.flags, "hide-alt-info")
      -- Try to remove flag only if it actually has been set
      elseif flag_set and not hide_alt then
        SR.writeDebug("%s: Showing ALT-info", {SR.argprint(bot_name)})
        table.remove(robot.flags, flag_set)
      end
    end
  end
end



------------------------------------------------------------------------------------
SR.entered_file("leave")
