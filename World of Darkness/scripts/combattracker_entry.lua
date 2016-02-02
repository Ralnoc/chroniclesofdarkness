-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local initialised = false;
local panellist = {};

local togglenode = nil;
local typenode   = nil;
local activenode = nil;

function onInit()
  local node = getDatabaseNode();
  local target = getTargetNode();
  
  togglenode = node.createChild("shownpc","number");
  typenode   = node.createChild("entrytype","string");
  activenode = node.createChild("active","number");
  if togglenode then
    togglenode.onUpdate = checkVisibility;
  end
  if typenode then
    typenode.onUpdate = checkVisibility;
  end
  if activenode then
    activenode.onUpdate = checkVisibility;
  end
  if not (togglenode and typenode and activenode) then
    -- capture any changes to the database
    node.onChildUpdate = capture;
  end

  -- PC special tasks
  if target and getType()=="pc" then
    -- set the owner flag
    if User.isHost() then
      local owner = target.getOwner();
      if owner then
        node.addHolder(owner,true);
      end
    end
    if node.isOwner() then
      -- set linked fields
      name.setLink(target.createChild("name","string"),true);
      -- add other linked fields here, most will *not* be read-only
      health.setLink(target.createChild("health"),false);
      willpower.setLink(target.createChild("willpower"),false);
      initiative.setLink(target.createChild("initiative","number"),false);
    end
  end

  -- Panels
  for i,pnl in ipairs(CombatManager.getPanels()) do
    if (User.isHost() or not pnl.gmonly) then
      -- add the panel window
      local win = panels.createWindowWithClass(pnl.windowclass,node.getNodeName());
      -- add the control icon
      local btn = createControl("panelbutton",pnl.name.."_button");
      btn.setAnchor("left","midanchor","right","relative",-1);
      btn.setTarget(win);
      btn.setIcon(pnl.icon);
      -- save the panel
      panellist[pnl.name] = win;
      -- link any linked fields
      if win.setLinks then
        win.setLinks(target,getType());
      end
    end
  end
  
  -- set visibility
  checkVisibility();
  
  -- menu item
  if User.isHost() then
    registerMenuItem("Delete Item", "delete", 6);
  end

  -- we are now ready to roll
  initialised = true;
end

function capture()
  local node = getDatabaseNode();
  if not togglenode then
    togglenode = node.createChild("shownpc","number");
    if togglenode then
      togglenode.onUpdate = checkVisibility;
      checkVisibility();
    end
  end
  if not typenode then
    typenode = node.createChild("entrytype","string");
    if typenode then
      typenode.onUpdate = checkVisibility;
      checkVisibility();
    end
  end
  if not activenode then
    activenode = node.createChild("active","number");
    if activenode then
      activenode.onUpdate = checkVisibility;
      checkVisibility();
    end
  end
  if togglenode and typenode and activenode then
    -- disable the event handler
    node.onChildUpdate = function () end;
  end
end

function onMenuSelection(item)
	if item == 6 then
	  delete();
  end
end

function delete()
  -- remove token from map if an npc
  if getType()=="npc" then
    token.deleteReference();
  end
  -- advance tracker, if this entry is active
  if isActive() then
    windowlist.nextActor();
  end
  -- delete database node (also closes window)
  getDatabaseNode().delete();
end

function setPanelDisplay(name, state)
  if panellist[name] then
    panellist[name].setDisplay(state);
  end
end

function getPanel(name)
  if panellist[name] then
    return panellist[name];
  end
  return nil;
end

function getTargetNode()
  return link.getTargetDatabaseNode();
end

function checkVisibility()
  local tp = getType();
  if User.isHost() then
    -- database node holding the target of the tracker entry (charsheet or npc sheet)
    local target = getTargetNode();
    -- link visibility and target object
    if target then
      link.setVisible(true);
    else
      link.setVisible(false);
    end
    -- GM-only items
    friendfoe.setVisible(true);
    identity.setVisible(true);
    -- health values (hits/wounds)
    healthlabel.setVisible(true);
    health.setVisible(true);
    willpowerlabel.setVisible(true);
    willpower.setVisible(true);
    -- show/hide NPC button
    if tp=="npc" then
      shownpc.setVisible(true);
      name.setAnchor("top","token","top","absolute",7);
    else
      shownpc.setVisible(false);
      name.setAnchor("top","token","top","absolute",4);
    end
  else
    local isowner = getDatabaseNode().isOwner();
    -- only show this entry if visible to the client
    if windowlist then
      windowlist.applyFilter();
    end
    -- link visibility and target object
    link.setVisible(false);
    -- GM-only items
    friendfoe.setVisible(false);
    identity.setVisible(false);
    -- owner-only items
    for name,win in pairs(panellist) do
      local btn = self[name.."_button"];
      if btn then
        btn.setVisible(isowner);
      end
    end
    -- health values (hits/wounds)
    if PreferenceManager.load(Preferences.CombatTracker.ShowStatsPref)==Preferences.Yes and tp=="pc" then
      healthlabel.setVisible(true);
      health.setVisible(true);
      willpowerlabel.setVisible(true);
      willpower.setVisible(true);
    else
      healthlabel.setVisible(isowner);
      health.setVisible(isowner);
      willpowerlabel.setVisible(isowner);
      willpower.setVisible(isowner);
    end
    -- show/hide NPC button
    shownpc.setVisible(false);
    name.setAnchor("top","token","top","absolute",4);
    -- update the active flag
    if activenode and activenode.getValue()~=0 then
      active.setState(true);
    else
      active.setState(false);
    end
  end
  -- done
end

function setSpacerState()
  if not spacer then
    -- not yet initialised
    return;
  end
  if #(panels.getWindows())~=0 then
    spacer.setVisible(true);
  else
    spacer.setVisible(false);
  end
end

-- FoF State

function getFoF()
  return friendfoe.getState();
end

function setFoF(state)
  friendfoe.setState(state);
end

-- Activity state

function isActive()
  return active.getState();
end

function setActive(state)
  active.setState(state);
  if state then
    if getType() == "pc" then
      -- Turn notification
      local msg = {};
      msg.text = name.getValue();
      msg.font = "narratorfont";
      msg.icon = "indicator_flag";
      ChatManager.deliverMessage(msg);
		  -- ring bell on player's turn?
	    -- ring bell on player's turn?
		  if PreferenceManager.load(Preferences.BellOnTurn.PrefName)==Preferences.Yes then
        local usernode = getTargetNode()
        if usernode then
          User.ringBell(usernode.getOwner());
        end
	    end
		else
		  -- assume GM id on NPC's turn?
		  if PreferenceManager.load(Preferences.TrackGMId.PrefName)==Preferences.Yes then
        GmIdentityManager.addIdentity(name.getValue());
		  end
		end
  end
end

-- Type 

function setType(t)
  local node = getDatabaseNode().createChild("entrytype","string");
  if node then
    node.setValue(t);
    checkVisibility();
  end
end

function getType()
  local node = getDatabaseNode().createChild("entrytype","string");
  if node then
    return node.getValue();
  else
    return "";
  end
end

-- Observers to support effects linked here

local observers = {};

function addObserver(o)
  table.insert(observers, o);
end

function removeObserver(o)
  for i = 1, #observers do
    if observers[i] == o then
      table.remove(observers, i);
      break;
    end
  end
end

function onClose()
  if not User.isHost() then
    return;
  end
  for k, v in ipairs(observers) do
    v.observedClosed(self);
  end
end

function nameChanged()
  if not User.isHost() then
    return;
  end
  for k, v in ipairs(observers) do
    v.observedNameChanged(self);
  end
end
