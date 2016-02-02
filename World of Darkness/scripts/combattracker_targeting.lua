-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local widgets = {};
local empty = true;
local entry = nil;

function onInit()
  entry = window.windowlist.window;
end

function isEmpty()
  return empty;
end

function update(token)
  for k, v in ipairs(widgets) do
    v.destroy();
  end
  empty = true;
  
  local ids = token.getTargetingIdentities();
  
  local w, h = getSize();
  local spacing = w / #ids;
  if spacing > tonumber(iconspacing[1]) then
    spacing = iconspacing[1];
  end

  for i = #ids, 1, -1 do
    widgets[i] = addBitmapWidget("portrait_" .. ids[i] .. "_miniportrait");
    widgets[i].setPosition("right", -(iconspacing[1]/2 + (i-1)*spacing), 0);
    empty = false;
  end
  -- display the 'defensive' panel
  entry.setPanelDisplay("defensive",not isEmpty());
end