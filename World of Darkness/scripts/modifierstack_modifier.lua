-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

function onGainFocus()
  ModifierStack.setAdjustmentEdit(true);
end

function onLoseFocus()
  ModifierStack.setAdjustmentEdit(false);
end

function onWheel(notches)
  if not hasFocus() then
    ModifierStack.adjustFreeAdjustment(notches);
  end

  return true;
end

function onValueChanged()
  if hasFocus() then
    ModifierStack.setFreeAdjustment(getValue());
  end
end

function onClickDown(button, x, y)
  return true;
end

function onClickRelease(button, x, y)
  if button == 2 then
    ModifierStack.reset();
    return true;
  end
end

function onDoubleClick()
 local dielist = {};
  local description;
  local sum;
  -- get the modifier total and description
  description = ModifierStack.getDescription(true);
  sum = ModifierStack.getSum();
  -- reset the stack
  
ModifierStack.reset();
  -- build the die list
  for v=1,sum do
    table.insert(dielist,"d10");
  end
  if description ~= "" and sum <= 0 then
    if Input.isAltPressed() then
	ModifierStack.reset();
	ModifierStack.addSlot("Chance Roll",1);
	ChatManager.throwDice("dice",dielist,0,description);
	return true;
	end
  
  end
  
  
  -- throw the dice
  --ModifierStack.throwDice();
  ChatManager.throwDice("dice",dielist,0,description);
  return true;
end

function onInit()
  registerMenuItem("Throw Dice", "hand", 2);
end

function onMenuSelection(...)
  ModifierStack.throwDice();
end

function onDrop(x, y, draginfo)
  return window.base.onDrop(x, y, draginfo);
end

function onDrag(button, x, y, draginfo)
  -- Create a composite drag type so that a simple drag into the chat window won't use the modifiers twice
  draginfo.setType("modifierstack");
  draginfo.setNumberData(ModifierStack.getSum());

  local basedata = draginfo.createBaseData("number");
  basedata.setDescription(ModifierStack.getDescription());
  basedata.setNumberData(ModifierStack.getSum());
  return true;
end

function onDragEnd(draginfo)
  ModifierStack.reset();
end
