SR.entered_file()
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                            REMOVE SHADOW ANIMATIONS                            --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

local shadow_anims = {
  -- combat-robot, construction-robot, logistic-robot
  "shadow_idle",
  "shadow_in_motion",

  -- construction-robot
  "shadow_working",

  -- logistic-robot
  "shadow_idle_with_cargo",
  "shadow_in_motion_with_cargo",

  -- "Companion Drones": spider-vehicle
  "shadow_base_animation",
  "shadow_animation",
}

-- Width and height of the empty image. Make this a variable so we can replace the
-- image with a bigger one if there should ever be a mod that will use more than
-- 64 directions!
local empty_image_size = 8


------------------------------------------------------------------------------------
--                                    Functions                                   --
------------------------------------------------------------------------------------
-- We use an empty image measuring 8x8 pixels. That's enough for a direction_count
-- up to 64 in the animation without shadows.
local function make_empty_shadow(direction_count, repeat_count)
  SR.entered_function({direction_count, repeat_count})

  if not direction_count or direction_count == 0 then
    SR.writeDebugNewBlock("Setting direction_count to default!")
    direction_count = 1
  end
  if not repeat_count or repeat_count == 0 then
    SR.writeDebugNewBlock("Setting repeat_count to default value!")
    repeat_count = 1
  end
SR.show("direction_count", direction_count)
SR.show("repeat_count", repeat_count)

  -- How many lines do we need to represent all pictures in the grid?
  -- (Range: 1 … empty_image_size)
  local lines       = math.ceil(direction_count / empty_image_size)
SR.show("lines", lines)

  -- How many pictures can we fit into one line? (Range: 1 … empty_image_size)
  local per_line    = direction_count / lines
SR.show("per_line", per_line)

  local anim = {
    direction_count = direction_count,
    draw_as_shadow = true,
    filename = "__SmallRobots__/empty.png",
    frame_count = 1,
    height = empty_image_size / lines,
    line_length = per_line,
    priority = "very-low",
    width = empty_image_size / per_line,
    repeat_count = repeat_count
  }
  anim.hr_version = table.deepcopy(anim)
SR.show("anim", anim)

  SR.entered_function("leave")
  return anim
end




local function remove_shadows(bot)
  SR.entered_function({SR.argprint(bot)})

  local anim_root = (bot.type == "spider-vehicle") and bot.graphics_set or bot
  local no_shadow, directions, repeat_count

  for a, animation in pairs(shadow_anims) do
    SR.writeDebugNewBlock("Does animation \"%s\" exist?", {animation})
    if anim_root[animation] then
      SR.writeDebug("Yes: %s", {anim_root[animation]})
      -- Shadow animation and no-shadow animation must have the same direction and
      -- frame count. If the no-shadow animation has more frames than the shadow
      -- animation, repeat_count can be used to keep both versions in sync.
      no_shadow = animation:match("shadow_(.+)")
SR.show("no_shadow", no_shadow)
SR.writeDebug("anim_root[%s]: %s", {SR.enquote(no_shadow), anim_root[no_shadow]})

      if anim_root[no_shadow] then
SR.writeDebug("Using values from animation %s", {SR.enquote(no_shadow)})
        directions = anim_root[no_shadow].direction_count or
                      anim_root[animation].direction_count
        repeat_count = anim_root[no_shadow].frame_count
      else
SR.writeDebug("Using values from animation %s", {SR.enquote(animation)})
        directions = anim_root[animation].direction_count
        repeat_count = anim_root[animation].frame_count
      end
SR.show("directions", directions)
SR.show("repeat_count", repeat_count)

      -- Modify animation
      SR.writeDebug("Trying to create empty animation %s.", {SR.enquote(animation)})
      anim_root[animation] = make_empty_shadow(directions, repeat_count)

    -- No such animation
    else
      SR.writeDebug("No!")
    end
  end

  SR.entered_function("leave")
end



------------------------------------------------------------------------------------
--                                 Call functions                                 --
------------------------------------------------------------------------------------
SR.show("SR.scaled_prototypes", SR.scaled_prototypes)
local robot
for bot_type, bot_names in pairs(SR.scaled_prototypes) do
  SR.writeDebugNewBlock("Checking bot type %s!", {SR.argprint(bot_type)})
  for b, bot_name in pairs(bot_names) do
    robot = data.raw[bot_type][bot_name]
    if robot then
      SR.writeDebug("Removing shadows from %s!", {SR.argprint(robot)})
      remove_shadows(robot)
    end
  end
end



------------------------------------------------------------------------------------
SR.entered_file("leave")
