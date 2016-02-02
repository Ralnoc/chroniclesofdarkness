-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

ref = nil;

local entry = nil;

function onInit()
  if super and super.onInit then
    super.onInit();
  end
  if User.isHost() then
    entry = window;
  else
    setHoverCursor("arrow");
  end
end

function refDeleted(deleted)
  ref = nil;
end

function refTargeted(targeted)
  local pnl = entry.getPanel("defensive");
  if pnl and pnl.targeting then
    pnl.targeting.update(ref);
  end
end

function setActive(status)
  if ref then
    ref.setActive(status);
  end
end

function setName(name)
  if ref then
    ref.setName(name);
  end
end

function updateUnderlay()
  if ref then
    ref.removeAllUnderlays();
    if entry.getFoF() == "friend" then
      ref.addUnderlay(0.5, "2f00ff00");
    elseif entry.getFoF() == "foe" then
      ref.addUnderlay(0.5, "2fff0000");
    elseif entry.getFoF() == "neutral" then
      ref.addUnderlay(0.5, "2fffff00");
    end
  end
end

function updateVisibility()
  if ref then
    if window.shownpc.getState() or window.getType() == "pc" then
      ref.setVisible(true);
    else
      ref.setVisible(false);
    end
  end
end

function acquireReference(dropref)
  if dropref then
    if ref and ref ~= dropref then
      ref.delete();
    end

    ref = dropref;
    
    ref.onDelete = refDeleted;
    ref.onTargetUpdate = refTargeted;

    ref.setActivable(true);
    ref.setTargetable(true);

    if entry.getType() == "pc" then
      ref.setVisible(true);
    else
      ref.setModifiable(false);
    end
      
    ref.setActive(entry.active.getState());
    ref.setName(entry.name.getValue());

    updateUnderlay();
    
    scale = ref.getScale();
    
    return true;
  end
end

function deleteReference()
  if ref then
    ref.delete();
    ref = nil;
  end
end

function onDrop(x, y, draginfo)
  if User.isHost() and draginfo.isType("token") then
    local prototype, dropref = draginfo.getTokenData();
    setPrototype(prototype);
    return acquireReference(dropref);
  end
end

function onDrag(...)
  if not User.isHost() then
    return false;
  end
end

function onDragEnd(draginfo)
  if User.isHost() then
    local prototype, dropref = draginfo.getTokenData();
    return acquireReference(dropref);
  end
end

function onClickDown(button, x, y)
  if User.isHost() then
    return true;
  end
end

function onClickRelease(button, x, y)
  if ref then
    if button == 1 then
      if ref.isActive() then
        ref.setActive(false);
      else
        ref.setActive(true);
      end
    else
      ref.setScale(1.0)
      scale = 0;
      if scaleWidget then
        scaleWidget.setVisible(false);
      end
    end
  end
  
  return true;
end

function onWheel(notches)
  if User.isHost() and ref then
    if not scaleWidget then    
      scaleWidget = addTextWidget("sheetlabelsmall", "0");
      scaleWidget.setFrame("tempmodmini", 4, 1, 6, 3);
      scaleWidget.setPosition("topright", -2, 2);
    end
  
    if Input.isControlPressed() then
      scale = math.floor(scale + notches);
      if scale < 1 then
        scale = 1;
      end
    else
      scale = scale + notches*0.1;
  
      if scale < 0.1 then
        scale = 0.1;
      end
    end
    
    if scale == 1 then
      ref.setScale(1.0);
      scaleWidget.setVisible(false);
    else
      ref.setScale(scale);
      scaleWidget.setVisible(true);
      scaleWidget.setText(scale);
    end
  end
    
  return true;
end
