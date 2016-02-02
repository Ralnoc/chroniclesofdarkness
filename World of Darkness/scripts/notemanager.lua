-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local notenode = nil;     -- Host only
local hostuser = "";      -- Host only

local clientstale = true; -- Client only

function onInit()
  if User.isHost() then
    notenode = DB.createNode("note");
    hostuser = User.getUsername();
    notenode.onChildUpdate = refreshOwner;
    notenode.addHolder(hostuser,true);
    User.onLogin = onLogin;
    if ChatManager and ChatManager.registerCommandHandler then
      ChatManager.registerCommandHandler("note",handleNoteCommand);
    end
  end
end

-- Command handling: client requests new note or wants the list re-shared

function handleNoteCommand(name,text,sender)
  if User.isHost() and notenode then
    if text=="new" then
      local owner = sender;
      local node = notenode.createChild();
      for k, o in ipairs(notenode.getHolders()) do
        node.addHolder(o, false);
      end
      node.addHolder(owner,true);
      node.createChild("newnote","number").setValue(1);
      node.createChild("owner","string").setValue(owner);
    elseif text=="reshare" then
      DoReshare();
    end
  end
end

function addNote()
  if ChatManager and ChatManager.sendCommand and not User.isHost() then
    ChatManager.sendCommand("note", "new");
  end
end

function reshare()
  if clientstale and ChatManager and ChatManager.sendCommand and not User.isHost() then
    ChatManager.sendCommand("note", "reshare");
    -- only need to do this once, disable it in future
    clientstale = false;
  end
end

-- User login and logout

function onLogin(username, activated)
  -- catch any stupid error
  if not notenode then
    return;
  end
  -- revoke ownership if the user is logging off
  if not activated then
    notenode.removeHolder(username);
    return;
  end
  -- ensure the user is a holder of the note list
  notenode.addHolder(username,false);
  -- reassert the Host as the owner of the note list
  notenode.addHolder(hostuser,true);
  -- refresh which users own which notes
  for k,node in pairs(notenode.getChildren()) do
    -- add this user as a holder
    node.addHolder(username, false);
    -- reassert the real ownership
    refreshOwner(node);
  end
end

function refreshOwner(source)
  if not source or not source.getChild("owner") then
    return;
  end
  if source.getChild("owner").getValue()==source.getOwner() then
    return;
  end
  if source.getChild("owner").getValue()=="" then
    source.getChild("owner").setValue(source.getOwner());
  else
    source.addHolder(source.getChild("owner").getValue(),true);
  end
end

-- force a client ownership update

function DoReshare()
  for k,node in pairs(notenode.getChildren()) do
    local name, text, owner, ispublic;
    -- update the name
    name = node.createChild("name","string").getValue();
    node.getChild("name").setValue(name);
    -- update the text
    text = node.createChild("text","string").getValue();
    node.getChild("text").setValue(text);
    -- update the owner
    owner = node.createChild("owner","string").getValue();
    node.getChild("owner").setValue(owner);
    -- update the public flag
    ispublic = node.createChild("ispublic","number").getValue();
    node.getChild("ispublic").setValue(ispublic);
  end
end
