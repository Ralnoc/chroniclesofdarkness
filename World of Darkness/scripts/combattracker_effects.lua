-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local disablecheck = false;
local entry = nil;

function onInit()
  entry = window.windowlist.window;
end

function checkForEmpty()
  if not disablecheck then
    local found = false;
    for k, v in ipairs(getWindows()) do
      if v.label.getValue() == "" then
        found = true;
        break;
      end
    end
    if not found then
      disablecheck = true;
      local w = createWindow();
      disablecheck = false;
    end
  end
end

function onDrop(x,y,dragdata)
  if dragdata.isType("effect") then
    local win = createWindow();
    local tracker = window.windowlist.window.windowlist;
		local casterentry = tracker.getActiveEntry();
    win.label.setValue(dragdata.getDescription());
    dragdata.setSlot(1);
    win.duration.setValue(dragdata.getNumberData());
    dragdata.setSlot(2);
    win.adjustment.setValue(dragdata.getNumberData());
		if casterentry then
			win.caster.setSource(casterentry);
		end
  end
end

function onListRearranged()
  checkForEmpty();
end

function progressEffects(source)
  for k, v in ipairs(getWindows()) do
    if v.caster.getSource() == source then
      local oldvalue = v.duration.getValue();
      local newvalue = oldvalue + v.adjustment.getValue()
      v.duration.setValue(newvalue);
      
      if newvalue == 0 and newvalue ~= oldvalue then
        local msg = {};
        msg.text = "'" .. v.label.getValue() .. "' on " .. entry.name.getValue() .. " expired";
        msg.font = "systemfont";
        msg.icon = "indicator_effect";
        
        ChatManager.addMessage(msg);
        
        v.close();
      end
    end
  end
end
