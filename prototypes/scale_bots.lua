SR.entered_file()
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--                     SCALE PROTOTYPES OF REAL AND FAKE BOTS                     --
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

require("math2d")

-- Bounding boxes we must scale
local bounding_boxes = {
  "collision_box",
  "drawing_box",
  "hit_visualization_box",
  "map_generator_bounding_box",
  "selection_box",
  "sticker_box",
}

-- Table for dying_explosions used by the different bot prototypes
local used_explosions = {}

-- Table for particles created by trigger effects. This is the dying animation of
-- the vanilla bots.
local used_particles = {}

-- Table for corpses used by fake bots (e.g. spider-vehicle from "Companion Drones")
local used_corpses = {}

-- Read scale factor settings
local scale_factor = SR.get_startup_setting("SmallRobots-robot-size") / 100
local atomicbots_scale_factor = SR.get_startup_setting("SmallRobots-atomicbots_robot-size") or 1


------------------------------------------------------------------------------------
--                                    Functions                                   --
------------------------------------------------------------------------------------

-- Apply scale_factor to both parts of a position. As we don't want to mess with
-- other mods, we will return the scaled position in the original format (either as
-- dictionary: {x = 1, y = 1}, or as array: {1, 1}).
local function scale_position(position, scale, hr)
  SR.entered_function({position, scale, hr})

  -- Make sure position is in correct format
  position = position or { x = 0, y = 0}
  if type(position) ~= "table" or table_size(position) ~= 2 then
    error(serpent.line(position) .. " is not a valid position!")
  end

  scale = scale or 1

  -- Is this for the HR version?
  hr = hr and 1/scale_factor or 1

  local x = (position.x or position[1]) * scale * hr
  local y = (position.y or position[2]) * scale * hr

  SR.entered_function("leave")
  return (position.x and position.y) and { x = x, y = y} or {x, y}
end


-- Apply scale_factor to both parts of a vector.
local function scale_vector(vector, scale, hr)
  SR.entered_function({vector, scale, hr})

  -- Make sure vector is in correct format
  vector = vector or {0, 0}
  if type(vector) ~= "table" or table_size(vector) ~= 2 then
    error(serpent.line(vector) .. " is not a valid vector!")
  end

  scale = scale or 1

  -- Is this for the HR version?
  hr = hr and 1/scale_factor or 1

  local x = vector[1] * scale * hr
  local y = vector[2] * scale * hr

  SR.entered_function("leave")
  return {x, y}
end


-- Get the center position of a box
local function get_center(box)
  SR.entered_function({box})

  local lt = box.left_top or box[1]
  local rb = box.right_bottom or box[2]

  local x = lt.x + (rb.x - lt.x) / 2
  local y = lt.y + (rb.y - lt.y) / 2

  SR.entered_function("leave")
  return {x = x, y = y}
end


-- Get the dimensions of a box
local function get_box_size(box)
  SR.entered_function({box})

  local lt = box.left_top or box[1]
  local rb = box.right_bottom or box[2]

  local x = rb.x - lt.x
  local y = rb.y - lt.y

  SR.entered_function("leave")
  return {x = x, y = y}
end


-- While we're working with a box, it's more convenient to use the format {left_top,
-- right_bottom} rather than {left_top = left_top, right_bottom = right_bottom}.
-- We also check if left_top and right_bottom are both at position {0, 0}. Returns
-- normalized box and boolean value for is_zero check.
local function normalize_box(box)
  SR.entered_function({box})

  local n_box, is_zero
  if box then
    local lt = box.left_top or box[1]
    local rb = box.right_bottom or box[2]
    n_box = {
      {x = lt.x or lt[1], y = lt.y or lt[2]},
      {x = rb.x or rb[1], y = rb.y or rb[2]},
    }
    is_zero = n_box[1].x == 0 and n_box[1].y == 0 and
              n_box[2].x == 0 and n_box[1].y == 0
  end

  SR.entered_function("leave")
  return n_box, is_zero
end


-- It seems other mods assume boxes to always have the format
-- {{x, y}, {x, y}}, or either of
-- {left_top = {x = x, y = y}, right_bottom = {x = x, y = y}}or { {x, y}, {x, y}}
-- Our format {{x = x, y = y}, {x = x, y = y}} breaks these assumptions (although
-- it is technically correct, as a box is an array of 2 positions, and positions may
-- be given in the long or the short form), so mods that are loaded after us and try
-- to modify boxes we've just changed will crash.
-- Let's play nice and store the boxes in the one format that seems to be the most
-- common denominator: { {x, y}. {x, y}}!
local function final_box_format(box)
  SR.entered_function({box})

  local ret

  if box then
    local lt = box.left_top or box[1]
    local rb = box.right_bottom or box[2]
    ret = {
      {lt.x or lt[1], lt.y or lt[2]},
      {rb.x or rb[1], rb.y or rb[2]},
    }
  end

  SR.entered_function("leave")
  return ret
end


-- Move towards {0, 0}: direction = -1. Move away from {0, 0}: direction = 1
local function move_box(box, move_by, direction)
  SR.entered_function({box, move_by, direction})

  direction = direction or 1
  if direction ~= 1 and direction ~= -1 then
    error(tostring(direction).." is not a valid direction! (1 or -1)")
  end

  return box and move_by and {
    { x = box[1].x + direction * move_by.x, y = box[1].y + direction * move_by.y },
    { x = box[2].x + direction * move_by.x, y = box[2].y + direction * move_by.y },
  }
end


-- Add a vector ({x, y}) to a position ({x = x, y = y})
local function shift_position(position, shift)
  SR.entered_function({position, shift})
  if type(position) ~= "table" or table_size(position) ~=2 or
      type(position.x) ~= "number" or type(position.y) ~= "number" then
    SR.arg_err(position, "position")
  end

  shift = shift or {0, 0}
  if type(shift) ~= "table" or table_size(shift) ~=2 or
      type(shift[1]) ~= "number" or type(shift[2]) ~= "number" then

    SR.arg_err(shift, "position")
  end
SR.show("shift", shift)
  position = {
    x = (position.x or position[1]) + shift[1],
    y = (position.y or position[2]) + shift[2],
  }
SR.show("position after shift", position)
  return position
end


-- Add one vector ({x, y}) to another
local function shift_vector(vector, shift)
  SR.entered_function({vector, shift})
  if type(vector) ~= "table" or table_size(vector) ~=2 or
      type(vector[1]) ~= "number" or type(vector[2]) ~= "number" then
    SR.arg_err(vector, "vector")
  end

  shift = shift or {0, 0}
  if type(shift) ~= "table" or table_size(vector) ~=2 or
      type(vector[1]) ~= "number" or type(vector[2]) ~= "number" then

    SR.arg_err(shift, "vector")
  end
SR.show("shift", shift)
  vector = { vector[1] + shift[1], vector[2] + shift[2] }
SR.show("vector after shift", vector)
  return vector
end


-- Apply scale_factor to bounding boxes (collision_box etc.)
local function scale_bounding_boxes(prototype, scale)
  SR.entered_function({prototype, scale})

  -- Scaling the bounding box will move it, so it won't be centered around the image
  -- anymore. To avoid this, move the center of the box to {0, 0} before scaling and
  -- move it back again after scaling.
  -- (See https://forums.factorio.com/viewtopic.php?p=580382#p580382)
  local zero_box, move_box_by, must_move_box, direction, r_bottom, shift

  -- We first scale all boxes, then the graphics. If we want to look up properties of
  -- a specific box when scaling the graphics, we must store the properties of all
  -- boxes now, and return them to the calling function.
  local box_data = {}

  -- Scale all boxes set in the prototype, unless it's an empty box ({{0,0}, {0,0}})
  local b_data
  for b, box in pairs(bounding_boxes) do
    if prototype[box] then
      SR.writeDebug("Scaling %s!", {box})

      -- Make sure prototype[box] has format {{x = x, y = y}, {x = x, y = y}}. If
      -- both positions are {0, 0}, zero_box will be true and we can skip this box.
      prototype[box], zero_box = normalize_box(prototype[box])
      if not zero_box then
        -- We store the data of all boxes we've scaled. Not only is this useful for
        -- debugging, we'll also use the value final_shift of the selection_box when
        -- scaling the graphics!
        box_data[box] = {}
        b_data = box_data[box]

SR.writeDebug("Original box: %s", {prototype[box]}, "line")
        b_data.old_box = prototype[box]
        b_data.old_size = get_box_size(prototype[box])

        -- We must move the box by the vector from its center to {0, 0}, so moving the
        -- box means substracting the center position from left top and right bottom.
        move_box_by = get_center(prototype[box])
SR.writeDebug("move_box_by: %s", {move_box_by}, "line")
        b_data.old_center = move_box_by

        -- If the center already is at position {0, 0}, we can skip moving the box!
        must_move_box = move_box_by.x ~= 0 or move_box_by.y ~= 0
        if must_move_box then
          -- For a scale > 1, we move the box towards {0, 0} (subtract), scale the
          -- positions of the corners, and move the box back (add). For scales < 1, we
          -- revert the process (add, scale, subtract).
          direction = -1
SR.writeDebug("Moving box in direction: %s", {direction}, "line")
          prototype[box] = move_box(prototype[box], move_box_by, direction)
SR.writeDebug("Box after moving towards {0, 0}: %s", {prototype[box]}, "line")
        end

        -- Apply scale
        prototype[box] = {
          scale_position(prototype[box][1], scale),
          scale_position(prototype[box][2], scale),
        }
SR.writeDebug("Box after scaling: %s", {prototype[box]}, "line")
        -- Move box back to center of scaled box
        if must_move_box then
          direction = direction * -1
SR.writeDebug("Moving box back!")
          prototype[box] = move_box(prototype[box], move_box_by, direction)
SR.writeDebug("Scaled and moved box: %s", {prototype[box]}, "line")
SR.writeDebug("New center: %s", {get_center(prototype[box])}, "line")

          -- Depending on the position of the right-bottom corner, move the box down
          r_bottom = prototype[box][2]
          move_box_by = ( (r_bottom.y < -0.5) and {x = 0, y = -0.5 - r_bottom.y}) or
                        ( (r_bottom.y > 0.5) and {x = 0, y = 0.5 - r_bottom.y})
SR.show("move_box_by", move_box_by)
          if move_box_by then
SR.writeDebug("Must move box by %s to adjust bottom line position!" ,
              {move_box_by}, "line")
            prototype[box] = move_box(prototype[box], move_box_by)

            -- Store the final_shift! Convert it from position to vector, if this is
            -- the selection_box, we'll need this to shift the graphics!
            b_data.final_shift = {move_box_by.x, move_box_by.y}
          end
        end
        b_data.new_box = prototype[box]
        b_data.new_size = get_box_size(prototype[box])
        b_data.new_center = get_center(prototype[box])

        -- Enlarge the selection box a bit if its size is less than {0.5, 0.5}
        if box == "selection_box" and
                  b_data.new_size.x < 1 and b_data.new_size.y < 1 then
          SR.writeDebug("Must enlarge %s (current size: %s)", {box, b_data.new_size})

          shift = .1
          prototype[box][1] = shift_position(prototype[box][1], {-shift, -shift})
          prototype[box][2] = shift_position(prototype[box][2], {shift, shift})

          b_data.new_box = prototype[box]
          b_data.new_size = get_box_size(prototype[box])
          b_data.new_center = get_center(prototype[box])
        end
      end

      -- For compatibility with mods like AAI Programmable Vehicles and IR3, which
      -- expect boxes to be in the format {{x, y}, {x, y}}
      prototype[box] = final_box_format(prototype[box])
SR.show("prototype["..box.."]", prototype[box])
    end
  end
  SR.entered_function("leave")
  return box_data
end


-- Modify scale factor and shift of the image and its HR version (if necessary)
local function scale_image(img, scale, shift)
  SR.entered_function({img, scale, shift})

  if not img.scaled then
    -- Set scale (defaults to 1 if not explicitly set)
    img.scale = (img.scale or 1) * scale
    SR.writeDebug("Set scale_factor of image %s to %s.",
                  {SR.enquote(img.filename), img.scale})

    if img.hr_version then
      img.hr_version.scale = (img.hr_version.scale or .5) * scale
      SR.writeDebug("Set scale_factor of HR image %s to %s.",
                    {SR.enquote(img.hr_version.filename), img.hr_version.scale})
    end

    -- Set shift
    img.shift = scale_vector(img.shift, scale)
    SR.show("Scaled shift", img.shift)
    if shift then
      img.shift = shift_vector(img.shift, shift)
      SR.show("Shifted shift", img.shift)
    end
    if img.hr_version then
      img.hr_version.shift = scale_vector(img.hr_version.shift, scale, "HR")
      SR.show("Scaled HR shift", img.hr_version.shift)
      if shift then
        img.hr_version.shift = shift_vector(img.hr_version.shift, shift)
        SR.show("Shifted HR shift", img.hr_version.shift)
      end
    end

    -- Mark picture as scaled -- otherwise it will be scaled each time it's used!
    img.scaled = true
    if img.hr_version then
      img.hr_version.scaled = true
    end
  end
  SR.entered_function("leave")
end


-- Look for pictures in the provided table and scale them
local function recurse(tab, scale, shift)
  --~ SR.entered_function({tab, scale})

  local function is_picture(p)
    return p.filename and string.match(p.filename:lower(), "^.+%.png")
  end

  -- Top level may already contain an image
  if is_picture(tab) then
    SR.writeDebug("Found image %s at top level!", {SR.enquote(tab.filename)})
    scale_image(tab, scale, shift)
  end

  for p, picture in pairs(tab) do
    if type(picture) == "table" then
      if is_picture(picture) then
        scale_image(picture, scale, shift)
      else
        recurse(picture, scale, shift)
      end
    end
  end

  --~ SR.entered_function("leave")
end



local function get_scale_factor(robot)
  SR.entered_function({robot})

  -- Don't overwrite scale_factor, or bots will become successively smaller!
  local scale = scale_factor

SR.show("Normal scale factor", scale)
  -- Apply scale factor for Atomic Robots?
  if robot and robot.name and robot.name:find("atomic%-[^%-]+%-robot") then
SR.show("atomicbots_scale_factor", atomicbots_scale_factor)
    scale = scale * atomicbots_scale_factor
    SR.writeDebug("Atomic robot: %s!", {robot.name})
  end
SR.show("Final scale factor", scale)
  SR.entered_function("leave")
  return scale
end



-- Store corpses
local function add_corpses_to_list(prototype, scale)
  SR.entered_function({prototype, scale})

  if prototype then
    SR.show("prototype.corpse", SR.argprint(prototype.corpse))
    -- If we're lucky, we may find one or more corpse name(s) in prototype.corpse
    local corpses = (type(prototype.corpse) == "string") and {prototype.corpse} or
                                                              prototype.corpse
SR.show("corpses", corpses)

    -- If no corpse name has been set explicitly, there may be a corpse named like
    -- the prototype, with a suffix "-remnants" which is used by default.
    if not corpses then
      local remnants = prototype.name.."-remnants"
SR.writeDebug("Looking for fallback corpse %s!", {SR.argprint(remnants)})
      corpses = data.raw.corpse[remnants] and {remnants}
SR.show("corpses", corpses)
    end

    -- Add corpse(s) to list if not stored yet
    for c, corpse in pairs(corpses or {}) do
      used_corpses[corpse] = scale
      SR.writeDebug("Set scale for %s to %s!", {SR.argprint(corpse), scale})
    end
  end

  SR.entered_function("leave")
end


-- Store dying_explosions
local function add_explosions_to_list(prototype, scale)
  SR.entered_function({prototype, scale})

  SR.show("explosions", prototype.dying_explosion)

  -- If we've got a string, it's the name of a Prototype/Explosion.
  local t = type(prototype.dying_explosion)
  if t == "string" then
    SR.writeDebug("Found string!")
    used_explosions[prototype.dying_explosion] = scale
    SR.writeDebug("Set scale for %s to %s!",
                  {SR.argprint(prototype.dying_explosion), scale})

  -- We've got a table: single ExplosionDefinition or array of ExplosionDefinitions?
  elseif t == "table" then
    SR.writeDebug("Found table!")
    local explosions = prototype.dying_explosion

    -- Single ExplosionDefinition
    if explosions.name then
  SR.writeDebug("Single definition!")
      explosions = {explosions}
    end

    -- Add new explosions to list, and scale offsets
    for e, explosion in pairs(explosions) do
  SR.show(e, explosion)
      if explosion.offset then
        SR.writeDebug("Must scale offset of %s!", {SR.argprint(explosion)})
        prototype.dying_explosion[e].offset = scale_vector(explosion.offset, scale)
      end
      used_explosions[explosion.name] = scale
      SR.writeDebug("Set scale for %s to %s!", {SR.argprint(explosion), scale})
    end
  end

  SR.entered_function("leave")
end


-- Deal with explosions created by a trigger effect
local function check_create_entity_effect(effect, scale)
  SR.entered_function({effect, scale})

  local created_entity = effect.entity_name

  if data.raw.explosion[created_entity] then
    -- Add to list of explosions we must scale
    used_explosions[created_entity] = scale
    SR.writeDebug("Set scale for %s to %s!", {SR.argprint(created_entity), scale})

    -- Modify scalable properties of effect definition
    if effect.offset_deviation then
      effect.offset_deviation = {
        scale_position(effect.offset_deviation[1], scale),
        scale_position(effect.offset_deviation[2], scale),
      }
      SR.show("Scaled offset_deviation", effect.offset_deviation)
    end

    if effect.offsets then
      for o, offset in pairs(effect.offsets) do
SR.writeDebug("Scaling offset %s!", {o})
        effect.offsets[o] = scale_vector(offset, scale)
      end
    end
  end

  SR.entered_function("leave")
end


-- Deal with particles created by a trigger effect. For vanilla bots, this is the
-- crashing animation!
local function check_create_particle_effect(effect, scale)
  SR.entered_function({effect, scale})

  local particle_name = effect.particle_name
  if data.raw["optimized-particle"][particle_name] then
    -- Add to list of particles we must scale
    used_particles[particle_name] = scale
    SR.writeDebug("Set scale for %s to %s!", {SR.argprint(particle_name), scale})

    -- Modify scalable properties of effect definition
    effect.initial_height = effect.initial_height * scale
    if effect.offset_deviation then
      effect.offset_deviation = {
        scale_position(effect.offset_deviation[1], scale),
        scale_position(effect.offset_deviation[2], scale),
      }
SR.show("Scaled offset_deviation", effect.offset_deviation)
    end

    if effect.offsets then
      for o, offset in pairs(effect.offsets) do
SR.writeDebug("Scaling offset %s!", {o})
        --~ effect.offsets[o] = scale_position(offset, scale)
        effect.offsets[o] = scale_vector(offset, scale)
      end
    end

    effect.initial_height_deviation = (effect.initial_height_deviation or 0) * scale
SR.show("Scaled initial_height_deviation", effect.initial_height_deviation)
    effect.tail_length = (effect.tail_length or 0) * scale
SR.show("Scaled tail_length", effect.tail_length)
    effect.tail_length_deviation = (effect.tail_length_deviation or 0) * scale
SR.show("Scaled tail_length_deviation", effect.tail_length_deviation)
    effect.tail_width = (effect.tail_width or 1) * scale
SR.show("Scaled tail_width", effect.tail_width)
  end

  SR.entered_function("leave")
end


-- Store trigger effects
local function check_trigger_effects(prototype, scale)
  SR.entered_function({prototype, scale})

  --~ local effects, effect, e_name, e_type, created_prototype
  local e_name, e_type

  for p, prefix in pairs({"damaged_trigger", "dying_trigger", "created"}) do
    e_name = prefix.."_effect"

    if prototype[e_name] then
SR.writeDebug("%s has %s!", {prototype.name, e_name})
      -- Single prototype[e_name] or array of prototype[e_name]s?
      e_type = prototype[e_name].type
SR.show("e_type", e_type)
      -- Single prototype[e_name]
      if e_type then
        SR.writeDebug("Single effect!")

        SR.show("Effect type", e_type)
        if e_type == "create-prototype" or e_type == "create-explosion" then
          check_create_entity_effect(prototype[e_name], scale)
        elseif e_type == "create-partice" then
          check_create_particle_effect(prototype[e_name], scale)
        end

      -- Array of prototype[e_name]s
      elseif not prototype[e_name].type then
        SR.writeDebug("Array of effects!")
        for e, effect in pairs(prototype[e_name]) do
          e_type = effect.type
SR.show("Type of effect "..e, e_type)
          if e_type == "create-prototype" or e_type == "create-explosion" then
            check_create_entity_effect(effect, scale)

          elseif e_type == "create-particle" then
            check_create_particle_effect(effect, scale)
          end
        end
      end
    end
  end

  SR.entered_function("leave")
end



local function scale_prototype(proto)
  SR.entered_function({proto})

  if proto and not proto.SR_dont_scale_me then
    -- Add prototype to list of scaled prototypes, we will need it when checking
    -- ALT-info and removing shadows!
    SR.scaled_prototypes[proto.type] = SR.scaled_prototypes[proto.type] or {}
    table.insert(SR.scaled_prototypes[proto.type], proto.name)
    SR.writeDebug("Stored %s in list of scaled prototypes!", {SR.argprint(proto)})

    -- Adjust scale if prototype is from "Atomic protos"!
    local scale = get_scale_factor(proto)

    -- If the scale factor for this bot is 1, we can leave immediately!
    if scale == 1 then
      SR.entered_function({}, "leave", "Nothing to do (scale: 1)")
      return
    end

    -- Scale bounding boxes
    SR.writeDebug("Scaling bounding boxes of %s (%g%%)",
                  {SR.argprint(proto.name), scale * 100})
    local box_data = scale_bounding_boxes(proto, scale)
for b, bd in pairs(box_data) do
SR.writeDebug("%s (%s), scale factor: %s", {b, SR.argprint(proto), scale})
    for k, v in pairs(bd) do
      SR.writeDebug("%s:\t%s", {k, v}, "line")
    end
SR.writeDebug("")
end

    -- If we scaled down the boxes, we must shift down the graphics after scaling!
    local shift = box_data.selection_box and box_data.selection_box.final_shift

    -- Scale the graphics!
    SR.writeDebug("Scaling graphics for %s (%g%%)", {SR.argprint(proto), scale*100})
    recurse(proto, scale, shift)

    -- Find corpses
    SR.writeDebug("Looking for corpses of %s", {SR.argprint(proto)})
    add_corpses_to_list(proto, scale)

    -- Find explosions
    SR.writeDebug("Looking for dying explosion(s) of %s", {SR.argprint(proto)})
    add_explosions_to_list(proto, scale)

    -- Check trigger effects
    SR.writeDebug("Looking for trigger effects of %s", {SR.argprint(proto)})
    check_trigger_effects(proto, scale)

    -- Adjust prototypes of fake bots
    if proto.type == "spider-vehicle" and proto.height then
      proto.height = proto.height * scale
    end
  end
  SR.entered_function("leave")
end


------------------------------------------------------------------------------------
--                                 Call functions                                 --
------------------------------------------------------------------------------------
-- Scale bot prototypes
--~ for b, bot_type in ipairs(SR.bot_types) do
  --~ local bots = data.raw[bot_type]
  --~ if bots then
    --~ for name, robot in pairs(bots) do
      --~ -- Scale graphics
      --~ scale_prototype(robot)
    --~ end
  --~ end
--~ end
local bots, ignore
for b, bot_type in ipairs(SR.bot_types) do
  bots = data.raw[bot_type]

  if bots then
    for name, robot in pairs(bots) do

      ignore = false
      for p, pattern in pairs(SR.bot_ignore_patterns or {}) do
        if name:find(pattern, 1, true) or name:find(pattern) then
          SR.writeDebug("Ignoring blacklisted %s!", {SR.argprint(robot)})
          ignore = true
          break
        end
      end

      if not ignore then
        SR.writeDebug("Must scale %s!", {SR.argprint(robot)})
        -- Scale graphics
        scale_prototype(robot)
      end
    end
  end
end


-- Scale companion drones?
if mods["Companion_Drones"] then
  local drone = data.raw["spider-vehicle"]["companion"]
  if drone then
    SR.writeDebug("Trying to scale %s!", {SR.argprint(drone)})
    scale_prototype(drone)
  end
end
--~ local test = data.raw["logistic-robot"]["logistic-robot"]
--~ scale_prototype(test)

--~ local test = data.raw["construction-robot"]["atomic-construction-robot"]
--~ scale_prototype(test)

SR.show("used_corpses", used_corpses)
SR.show("used_explosions", used_explosions)
SR.show("used_particles", used_particles)
SR.show("SR.scaled_prototypes", SR.scaled_prototypes)

-- Scale explosions
local used_explosion, s, s_deviation, si, si_deviation
for explosion, scale in pairs(used_explosions) do
  used_explosion = data.raw.explosion[explosion]
  if used_explosion then
    SR.show("Scaling explosion", used_explosion.name)
    recurse(used_explosion, scale)

    scale_bounding_boxes(used_explosion, scale)

    si = (used_explosion.scale_initial or 1) * scale
    used_explosion.scale_initial = si

    si_deviation = (used_explosion.scale_initial_deviation or 0) * scale
    used_explosion.scale_initial_deviation = si_deviation

    s = (used_explosion.scale or 1) * scale
    used_explosion.scale = s

    s_deviation = (used_explosion.scale_deviation or 0) * scale
    used_explosion.scale_deviation = s_deviation
  end
end

-- Scale particles
local used_particle
for particle, scale in pairs(used_particles) do
  used_particle = data.raw["optimized-particle"][particle]
  if used_particle then
    SR.show("Scaling particle", used_particle.name)
    recurse(used_particle, scale)

    scale_bounding_boxes(used_particle, scale)
  end
end

-- Scale corpses
local used_corpse
for corpse, scale in pairs(used_corpses) do
  used_corpse = data.raw.corpse[corpse]
  if used_corpse then
    SR.writeDebug("Scaling factor for %s: %s", {SR.argprint(corpse), scale})
    recurse(used_corpse, scale)

    SR.writeDebug("Scaling bounding boxes of %s!", {SR.argprint(corpse)})
    scale_bounding_boxes(used_corpse, scale)
  end
end

------------------------------------------------------------------------------------
SR.entered_file("leave")
