-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local groupboxes = {};

function closeGroup(grpid)
  if ChatGroup then
    local list = ChatGroup.getIdentities(grpid);
    for idname,ent in pairs(list) do
      ChatGroup.clearGroup(idname);
    end
    layoutControls();
  end
end

function findControlForIdentity(identity)
  return self["ctrl_" .. identity];
end

function getWidgetForGroup(groupid)
  local name = "grp_" .. groupid;
  if not groupboxes[name] then
    groupboxes[name] = groups.addBitmapWidget("");
  end
  return groupboxes[name];
end

function controlSortCmp(t1, t2)
  if ChatGroup then
    local g1, g2;
    g1 = ChatGroup.getGroup(t1.name);
    g2 = ChatGroup.getGroup(t2.name);
    if g1~=g2 then
      return g1 < g2;
    end
  end
  return t1.name < t2.name;
end

function layoutControls()
  local identitylist = {};
  
  for key, val in pairs(User.getAllActiveIdentities()) do
    local ctl = findControlForIdentity(val);
    if ChatGroup and User.isHost() then
      local grpid = ChatGroup.getGroup(val);
      ctl.setGroup(grpid);
    end
    table.insert(identitylist, { name = val, control = ctl });
  end
  
  table.sort(identitylist, controlSortCmp);

  for key, val in pairs(identitylist) do
    val.control.sendToBack();
  end
  anchor.sendToBack();
  groups.sendToBack();

  -- create any grouping controls
  if ChatGroup and User.isHost() then
    local first = 0;
    local n = 0;
    local grpid = -1;
    -- delete any existing group boxes
    for k,widget in pairs(groupboxes) do
      widget.destroy();
      groupboxes[k] = nil;
    end
    -- create the new group boxes
    for key, val in pairs(identitylist) do
      local id = val.name;
      local newgrp = ChatGroup.getGroup(id);
      if newgrp~=grpid then
        if grpid>0 then
          -- create a groupbox control for the old group
          local count = n - first;
          local start = #identitylist - first - count;
          local widget = getWidgetForGroup(grpid);
          widget.setPosition("topleft",7+start*78,10);
          widget.setFrame("groupbox",0,0,count*78,65);
          widget.sendToBack();
        end
        -- start a group
        grpid = newgrp;
        first = n;
      end
      n = n + 1;
    end
    -- any unfinished groups?
    if grpid>0 then
      -- create a groupbox control for the old group
      local count = n - first;
      local start = #identitylist - first - count;
      local widget = getWidgetForGroup(grpid);
      widget.setPosition("topleft",7+start*78,10);
      widget.setFrame("groupbox",0,0,count*78,65);
      widget.sendToBack();
    end
  end
  
end

function onLogin(username, activated)
end

function onUserStateChange(username, statename, state)
  if username ~= "" and User.getCurrentIdentity(username) then
    local ctrl = findControlForIdentity(User.getCurrentIdentity(username));
    if ctrl then
      ctrl.stateChange(statename, state);
    end
  end
end

function onIdentityActivation(identity, username, activated)
  if activated then
    if not findControlForIdentity(identity) then
      createControl("characterlist_entry", "ctrl_" .. identity);
      userctrl = findControlForIdentity(identity);
      userctrl.createWidgets(identity);
    end
  else
    findControlForIdentity(identity).destroy();
    if User.isHost() and ChatGroup then
      ChatGroup.clearGroup(identity);
    end
  end
  layoutControls();
end

function onIdentityStateChange(identity, username, statename, state)
  local ctrl = findControlForIdentity(identity);
  if ctrl then
    ctrl.stateChange(statename, state);
  end
end

function onInit()
  User.onLogin = onLogin;
  User.onUserStateChange = onUserStateChange;
  User.onIdentityActivation = onIdentityActivation;
  User.onIdentityStateChange = onIdentityStateChange;
end
