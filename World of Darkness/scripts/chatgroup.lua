-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local nextgroupid = 1;
local identities = {};

-- Group Tell: /group [name] [message]
function processGroup(params)
  if User.isHost() then
    -- process a message from the GM to each member of the group containing 'name'

    local spacepos = string.find(params, " ", 1, true);
    if spacepos then
      local name = string.lower(string.sub(params, 1, spacepos-1));
      local message = string.sub(params, spacepos+1);

      -- Find user
      local user = nil;
      local identity = nil;

      for k, v in ipairs(User.getAllActiveIdentities()) do
        local label = User.getIdentityLabel(v);
        if string.lower(label) == name then
          -- Direct match
          user = User.getIdentityOwner(v);
          if user then
            identity = v;
            break;
          end
        elseif not user and string.find(string.lower(label), name, 1, true) == 1 then
          -- Partial match
          user = User.getIdentityOwner(v);
          if user then
            identity = v;
          end
        end
      end

      if user then
        local gmid, isgm = GmIdentityManager.getCurrent();
        sendGroupMessage(identity,message,gmid);
      else
        ChatManager.addMessage({font="systemfont", text="Group chat recipient not found"});
      end

    else
      ChatManager.addMessage({font="systemfont", text="Usage: /group [name] [message]"});
    end
  else
    if params=="" then
      ChatManager.addMessage({font="systemfont", text="Usage: /group [message]"});
      return;
    end
    -- cannot be executed on the client, send it to the host as a remote command
    if ChatManager.sendCommand then
      local id = User.getCurrentIdentity();
      ChatManager.sendCommand("grouptell",id.."|"..params);
    else
      ChatManager.addMessage({font="systemfont", text="Unable to deliver message]"});
    end
  end
end

function handleGroupTell(cmd,params)
  -- client request to send a tell to the group
  local pos = string.find(params, "|", 1, true);
  local message, id;
  if not pos then
    return; -- fail silently
  end
  id = string.sub(params, 1, pos-1);
  message = string.sub(params, pos+1);
  sendGroupMessage(id,message,id);
end

function sendGroupMessage(toid, message, fromid)
  local msg = {font="groupfont"};
  local owners = {};
  local gmsend = false;
  -- find the group corresponding to the 'toid'
  local grpid = getGroup(toid);
  local list = getIdentities(grpid);
  if not list or grpid<1 then
    -- no one to send to
    local owner = User.getIdentityOwner(fromid);
    if owner then
      ChatManager.deliverMessage({font="systemfont", text=User.getIdentityLabel(fromid) .. " is not in a chat group."},owner);
    end
    return;
  end
  -- convert the sender identity (id-0001) into an identityLabel (Khazim)
  local sender = User.getIdentityLabel(fromid);
  msg.text = message;
  if sender then
    msg.sender = sender;
  else
    msg.sender = fromid;
  end
  -- iterate through the identities but only send to each client once
  for idname,ent in pairs(list) do
    local owner = User.getIdentityOwner(idname);
    if owner and not owners[owner] then
      owners[owner] = true;
      ChatManager.deliverMessage(msg,owner);
      gmsend = true;
    end
  end
  if gmsend then
    -- echo it to the GM chat box
    ChatManager.addMessage(msg);
  end
end

-- Initialization

local charlist = nil;

function onInit()
  if ChatManager and ChatManager.registerSlashHandler and ChatManager.registerCommandHandler then
    if User.isHost() then
      ChatManager.registerCommandHandler("grouptell", handleGroupTell);
    end
    ChatManager.registerSlashHandler("/group", processGroup);
  end
end

-- support routines

function joinIdentity(source,target)
  local grpid = getGroup(target);
  if grpid>0 then
    joinGroup(source,grpid);
  else
    createGroup({[1]=source,[2]=target});
  end
end

function joinGroup(identity,grpid)
  local owner = User.getIdentityOwner(identity);
  clearGroup(identity);
  identities[identity] = {["group"]=grpid};
  ChatManager.deliverMessage({font="systemfont", text=User.getIdentityLabel(identity) .. " has joined a chat group."},owner);
end

function createGroup(idlist)
  local groupid = nextgroupid;
  nextgroupid = nextgroupid + 1;
  for i,id in ipairs(idlist) do
    local owner = User.getIdentityOwner(id);
    clearGroup(id);
    identities[id] = {["group"]=groupid};
    ChatManager.deliverMessage({font="systemfont", text=User.getIdentityLabel(id) .. " has joined a chat group."},owner);
  end
  return groupid;
end

function getGroup(id)
  if identities[id] and identities[id].group then
    return identities[id].group;
  else
    -- return the empty group
    return -1;
  end
end

function getIdentities(group)
  local list = {};
  if not group then
    return identities;
  end
  for id,ent in pairs(identities) do
    if ent.group and ent.group==group then
      list[id]=ent;
    end
  end
  return list;
end

function clearGroup(id)
  if identities[id] and identities[id].group then
    local owner = User.getIdentityOwner(id);
    if owner and owner~="" then
      ChatManager.deliverMessage({font="systemfont", text=User.getIdentityLabel(id) .. " has left the chat group."},owner);
    end
    identities[id].group = 0;
  end
end

function dropGroup(group)
  for id,ent in pairs(identities) do
    if ent.group and ent.group==group then
      local owner = User.getIdentityOwner(id);
      ChatManager.deliverMessage({font="systemfont", text="The chat group has closed."},owner);
      ent.group = 0;
    end
  end
end
