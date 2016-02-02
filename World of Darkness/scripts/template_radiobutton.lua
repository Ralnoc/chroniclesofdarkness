-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local buttonvalue = "";
local defaultvalue = false;
local sourcenode = nil;
local readonlyvalue = false;
local sourcenodename = "";

function onInit()
  setIcon(stateicons[1].off[1]);
  if source and source[1] then
    sourcenodename = source[1];
    window.getDatabaseNode().onChildUpdate = capture;
    capture();
  end
  if value and value[1] then
    buttonvalue = value[1];
  end
  if default then
    defaultvalue = true;
  end
  if window.getDatabaseNode() then
    readonlyvalue = window.getDatabaseNode().isStatic();
  end
  if readonly then
    readonlyvalue = true;
  end
  if defaultvalue and buttonvalue~="" and sourcenode and sourcenode.getValue()=="" then
    activate();
  end
  refresh();
end

function onClickDown(button, x, y)
  return (not readonlyvalue);
end

function onClickRelease()
  activate();
end

function activate()
  if not readonlyvalue and sourcenode and buttonvalue~="" and sourcenode.getValue()~=buttonvalue then
    sourcenode.setValue(buttonvalue);
  end
end

function refresh()
  if sourcenode and buttonvalue~="" and sourcenode.getValue()==buttonvalue then
    setIcon(stateicons[1].on[1]);
  else
    setIcon(stateicons[1].off[1]);
  end
end

function getResult()
  if sourcenode then
    return sourcenode.getValue();
  else
    return "";
  end
end

function getValue()
  return buttonvalue;
end

function setValue(value)
  buttonvalue = value;
  refresh();
end

function isReadOnly()
  return readonlyvalue;
end

function setReadOnly(state)
  if sourcenode and sourcenode.isStatic() then
    return;
  end
  if state then
    readonlyvalue = true;
  else
    readonlyvalue = false;
  end
end

function isDefault()
  return defaultvalue;
end

function capture()
  sourcenode = window.getDatabaseNode().createChild(sourcenodename,"string");
  if sourcenode then
    window.getDatabaseNode().onChildUpdate = function () end;
    sourcenode.onUpdate = refresh;
    refresh();
  end
end

