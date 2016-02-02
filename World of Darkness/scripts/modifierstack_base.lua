-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

slots = {};

function resetCounters()
  for k, v in ipairs(slots) do
    v.destroy();
  end
  
  slots = {};
end

function addCounter()
  local widget = addBitmapWidget(counters[1].icon[1]);
  widget.setPosition("topleft", counters[1].offset[1].x[1] + counters[1].spacing[1] * #slots, counters[1].offset[1].y[1]);
  table.insert(slots, widget);
end

function onHoverUpdate(x, y)
  ModifierStack.hoverDisplay(getCounterAt(x, y));
end

function onHover(oncontrol)
  if not oncontrol then
    ModifierStack.hoverDisplay(0);
  end
end

function getCounterAt(x, y)
  for i = 1, #slots do
    local slotcenterx = counters[1].offset[1].x[1] + counters[1].spacing[1] * (i-1);
    local slotcentery = counters[1].offset[1].y[1];
    
    local size = tonumber(counters[1].hoversize[1]);
    
    if math.abs(slotcenterx - x) <= size and math.abs(slotcenterx - x) <= size then
      return i;
    end
  end
  
  return 0;
end

function onClickDown(button, x, y)
  return true;
end

function onClickRelease(button, x, y)
  local n = getCounterAt(x, y);
  if n ~= 0 then
    ModifierStack.removeSlot(n);
  end
end

function onDoubleClick()
  ModifierStack.throwDice();
  return true;
end

function onInit()
  registerMenuItem("Throw Dice", "hand", 2);
end

function onMenuSelection(...)
  ModifierStack.throwDice();
end

function onDrop(x, y, draginfo)
  if draginfo.isType("number") then
    ModifierStack.addSlot(draginfo.getDescription(), draginfo.getNumberData());
    return true;
  elseif draginfo.isType("dice") then
    local count = 0;
    local desc = draginfo.getDescription();
    for v,die in pairs(draginfo.getDieList()) do
      if die.type=="d10" then
        count = count + 1;
      else
        return;
      end
    end
    if desc=="" then
      if count==1 then
        desc = "Die";
      else
        desc = "Dice";
      end
    end
    ModifierStack.addSlot(desc, count);
    return true;
  end
end
