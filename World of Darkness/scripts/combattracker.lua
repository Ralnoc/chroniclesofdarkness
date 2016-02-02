-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

function onInit()
  if not User.isHost() then
    return;
  end
  Interface.onHotkeyActivated = onHotkey;
  -- Restore token info
  for i,win in ipairs(getWindows()) do
    local tokenrefnode = win.getDatabaseNode().createChild("tokenrefnode","string").getValue();
    local tokenrefid = win.getDatabaseNode().createChild("tokenrefid","string").getValue();
    if tokenrefnode~="" and tokenrefid~="" then
      local imageinstance = win.token.populateFromImageNode(tokenrefnode, tokenrefid);
      if imageinstance then
        win.token.acquireReference(imageinstance);
      end
    end
    win.token.updateUnderlay();
  end
  -- create an empty entry if there are none
  if (#getWindows() == 0) then
    createWindow();
  end
  -- done
end

function onClose()
  if not User.isHost() then
    return;
  end
  -- Save token info
  for i,win in ipairs(getWindows()) do
    if win.token.ref and win.token.ref.getContainerNode() then
      win.getDatabaseNode().createChild("tokenrefnode","string").setValue(win.token.ref.getContainerNode().getNodeName());
      win.getDatabaseNode().createChild("tokenrefid","string").setValue(win.token.ref.getId());
    end
  end
end

function onHotkey(draginfo)
  if not User.isHost() then
    return;
  end
  if draginfo.isType("combattrackernextactor") then
    nextActor();
    return true;
  end
  if draginfo.isType("combattrackernextround") then
    nextRound();
    return true;
  end
end

function clearAllNpcs()
  local nodes = {};
  for i,win in ipairs(getWindows()) do
    if win.getType()=="npc" then
      table.insert(nodes,win.getDatabaseNode());
    end
  end
  for i,node in ipairs(nodes) do
    node.delete();
  end
end

function clearAllEffects()
  local nodes = {};
  for i,win in ipairs(getWindows()) do
    local panel = win.getPanel("effects");
    if panel then
      for j,effect in ipairs(panel.effects.getWindows()) do
        table.insert(nodes,effect.getDatabaseNode());
      end
    end
  end
  for i,node in ipairs(nodes) do
    node.delete();
  end
end

function forceUpdate()
  for i,win in ipairs(getWindows()) do
    local val = win.name.getValue();
    win.name.setValue(val);
  end
end

function addPc(source, token)
  local newentry = createWindow();
  local newnode = newentry.getDatabaseNode();
  local owner = source.getOwner();
  -- set the owner flag
  if owner then
    newnode.addHolder(owner,true);
  end
  -- Shortcut
  newentry.link.setValue("charsheet", source.getNodeName());
  newentry.link.setVisible(true);
  -- Token
  if token then
    newentry.token.setPrototype(token);
  end
  -- FoF
  newentry.friendfoe.setState("friend");
  -- Linked fields
  newentry.name.setLink(source.getChild("name"),true);
  newentry.health.setLink(source.createChild("health"),false);
  newentry.willpower.setLink(source.createChild("willpower"),false);
  newentry.initiative.setLink(source.createChild("initiative","number"),false);
  -- Populate the panels
  for k,pnl in pairs(newentry.panels.getWindows()) do
    pnl.populate(source,"pc");
    -- link any linked fields
    if pnl.setLinks then
      pnl.setLinks(source,"pc");
    end
  end
  -- set the entry type
  newentry.setType("pc");
  -- done
  return newentry;
end

function addNpc(source)
  local newentry = createWindow();
  local newnode = newentry.getDatabaseNode();
  -- hide the npc by default
  newentry.shownpc.setState(false);
  -- Shortcut
  newentry.link.setValue("npc", source.getNodeName());
  newentry.link.setVisible(true);
  -- Token
  if source.getChild("token") then
    newentry.token.setPrototype(source.getChild("token").getValue());
  end
  -- FoF
  if source.getChild("fof") then
    newentry.friendfoe.setState(source.getChild("fof").getValue());
  elseif source.getChild("alignment") then
    local alignment = source.getChild("alignment").getValue();
    if string.find(string.lower(alignment), "good", 0, true) then
      newentry.friendfoe.setState("friend");
    elseif string.find(string.lower(alignment), "evil", 0, true) then
      newentry.friendfoe.setState("foe");
    else
      newentry.friendfoe.setState("neutral");
    end
  else
    newentry.friendfoe.setState("neutral");
  end
  -- Name, append a sequence number
  if source.getChild("name") then
    local newname = getNPCName(source.getChild("name").getValue());
    newentry.name.setValue(newname);
  end
  -- Health, Willpower, Initiative
  if source.getChild("health") then
    local node = newentry.getDatabaseNode().createChild("health");
    node.createChild("dots","number").setValue(source.createChild("health.dots","number").getValue());
    node.createChild("bashing","number").setValue(source.createChild("health.bashing","number").getValue());
    node.createChild("lethal","number").setValue(source.createChild("health.lethal","number").getValue());
    node.createChild("aggrevated","number").setValue(source.createChild("health.aggrevated","number").getValue());
  end
  if source.getChild("willpower") then
    local node = newentry.getDatabaseNode().createChild("willpower");
    node.createChild("dots","number").setValue(source.createChild("willpower.dots","number").getValue());
    node.createChild("spent","number").setValue(source.createChild("willpower.spent","number").getValue());
  end
  if source.getChild("initiative") then
    newentry.initiative.setValue(source.getChild("initiative").getValue());
  end
  -- Populate the panels
  for k,pnl in pairs(newentry.panels.getWindows()) do
    pnl.populate(source,"npc");
    -- link any linked fields
    if pnl.setLinks then
      pnl.setLinks(source,"npc");
    end
  end
  -- set the entry type
  newentry.setType("npc");
  -- done
  return newentry;
end

function addEncounter(source)
  if source.getChild("list") then
    for k,node in pairs(source.getChild("list").getChildren()) do
      local num = 1;
      if node.getChild("number") then
        num = node.getChild("number").getValue();
      end
      for i=1,num do
        addNpc(node);
      end
    end
  end
end

function getNPCName(fullname)
  local name,number = string.match(fullname,"^%s*(%S.-)%s*#?(%d*)%s*$");
  if PreferenceManager.load(Preferences.AutoNumber.PrefName)==Preferences.No then
    return fullname;
  end
  if name and name~="" then
    -- look for matches
    number = getNextNumber(name);
    if number==1 then
      fullname = name;
    else
      fullname = name.." #"..number;
    end
  end
  return fullname;
end

function getNextNumber(matchname)
  if PreferenceManager.load(Preferences.AutoNumber.PrefName)==Preferences.AutoNumber.Random then
    local success;
    local guessname;
    local number;
    repeat
      number = math.random(100);
      guessname = matchname.." #"..number;
      success = true;
      for i,win in ipairs(getWindows()) do
        local fullname = win.name.getValue();
        if string.lower(fullname)==string.lower(guessname) then
          success = false;
        end
      end
    until success;
    return number;
  else
    local max = 0;
    local count = 0;
    matchname = string.lower(matchname);
    for i,win in ipairs(getWindows()) do
      local fullname = win.name.getValue();
      local name,number = string.match(fullname,"^%s*(%S.-)%s*#?(%d*)%s*$");
      if name and string.lower(name)==matchname then
        count = count + 1;
        if number and number~="" then
          max = math.max(max,number);
        end
      end
    end
    return math.max(count,max)+1;
  end
end

function onDrop(x, y, draginfo)
  if not User.isHost() then
    return;
  end
  if draginfo.isType("playercharacter") then
    local token = draginfo.getTokenData();
    local source = draginfo.getDatabaseNode();
    if source then
      addPc(source, token);
      return true;
    end
  elseif draginfo.isType("shortcut") then
    local class = draginfo.getShortcutData();
    local source = draginfo.getDatabaseNode();
    if class=="npc" then
      addNpc(source);
      return true;
    elseif class=="encounter" then
      addEncounter(source);
      return true;
    end
  end
end

function onFilter(win)
  local togglenode = win.getDatabaseNode().createChild("shownpc","number");
  -- always visible to GM
  if User.isHost() then
    return true;
  end
  -- own entry is always visible
  if win.getDatabaseNode().isOwner() then
    return true;
  end
  -- show all PCs
  if win.getType()=="pc" then
    return true;
  end
  -- check if GM is permitting NPCs to be visible to clients
  if PreferenceManager.load(Preferences.CombatTracker.ShowNPCPref)==Preferences.Yes then
    -- always yes
    return true;
  elseif  PreferenceManager.load(Preferences.CombatTracker.ShowNPCPref)==Preferences.No then
    -- always no
    return false;
  end
  -- check per entry, depending on 'shownpc' value
  if togglenode then
    return (togglenode.getValue()~=0);
  end
  -- all else fails, hide it
  return false;
end

function onSortCompare(w1, w2)
  return w1.initiative.getValue() < w2.initiative.getValue();
end;

function getActiveEntry()
  for i,v in ipairs(getWindows()) do
    if v.isActive() then
      return v;
    end
  end
  return nil;
end

function requestActivation(entry)
  for i,v in ipairs(getWindows()) do
    v.setActive(false);
  end
  entry.setActive(true);
end

function nextActor()
  local entry = getNextWindow(getActiveEntry());
  if entry then
    requestActivation(entry);
    for i,v in ipairs(getWindows()) do
      local pnl = v.getPanel("effects");
      if pnl and pnl.progressEffects then
        pnl.progressEffects(entry);
      end
    end
  else
    nextRound();
  end
end

function nextRound()
  local entry = getNextWindow(nil);
  if entry then
    requestActivation(entry);
    for i,v in ipairs(getWindows()) do
      local pnl = v.getPanel("effects");
      if pnl and pnl.progressEffects then
        pnl.progressEffects(entry);
      end
    end
  end
  window.roundcounter.setValue(window.roundcounter.getValue() + 1);
  for i,v in ipairs(getWindows()) do
    local pnl = v.getPanel("effects");
    if pnl and pnl.progressEffects then
      pnl.progressEffects(nil);
    end
  end
end
