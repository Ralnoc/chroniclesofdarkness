-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local entry = nil;
local state = false;
local activenode = nil;

function onInit()
  entry = window;
  activewidget = addBitmapWidget(activeicon[1]);
  activewidget.setVisible(false);
  if User.isHost() then
    activenode = window.getDatabaseNode().createChild("active","number");
    if activenode.getValue()~=0 then
      state = true;
      update();
    end
  end
end

function setState(s)
  state = s;
  if User.isHost() then
    if s then
      activenode.setValue(1);
    else
      activenode.setValue(0);
    end
  end
  update();
end

function update()
  if User.isHost() or window.getDatabaseNode().isOwner() then
    activewidget.setVisible(state);
    if User.isHost() then
      entry.token.setActive(state);
    end
    -- show the 'active' panel
    entry.setPanelDisplay("active",state);
  end
end

function getState()
  return state;
end

function onClickDown(button, x, y)
  if User.isHost() then
    return true;
  end
end

function onClickRelease(button, x, y)
  if User.isHost() and not state then
    entry.windowlist.requestActivation(entry);
  end
end

function onDrag(button, x, y, draginfo)
  if User.isHost() then
    draginfo.setType("combattrackeractivation");
    draginfo.setIcon(activeicon[1]);
    activewidget.setVisible(false);
    return true;
  end
end

function onDragEnd(draginfo)
  if User.isHost() and state then
    activewidget.setVisible(true);
  end
end

function onDrop(x, y, draginfo)
  if User.isHost() and draginfo.isType("combattrackeractivation") then
    entry.windowlist.requestActivation(window);
  end
end
