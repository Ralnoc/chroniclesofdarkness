-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local groupid = 0;

function setGroup(grpid)
  groupid = grpid;
  updateMenus();
  -- a visual cue
  -- groupwidget.setText(grpid);
  -- if grpid>0 then
  --   groupwidget.setVisible(true);
  -- else
  --   groupwidget.setVisible(false);
  -- end
end

function updateMenus()
  resetMenuItems();
  if User.isHost() then
    if groupid>0 then
      registerMenuItem("Leave group","delete",4);
      registerMenuItem("Close group","closeremote",5);
    end
    registerMenuItem("Ring Bell", "bell", 1);
  else
    if User.isOwnedIdentity(identityname) then
      registerMenuItem("Activate", "turn", 5);
      registerMenuItem("Release", "erase", 4);
    end
  end
end

function createWidgets(name)
  identityname = name;

  portraitwidget = addBitmapWidget("portrait_" .. name .. "_charlist");

  namewidget = addTextWidget("sheetlabelsmall", "- Unnamed -");
  namewidget.setPosition("center", 0, 27);
  namewidget.setFrame("mini_name", 5, 2, 5, 2);
  namewidget.setMaxWidth(75);
  
  -- groupwidget = addTextWidget("sheetlabelsmall",0);
  -- groupwidget.setPosition("center", 29, -20);
  -- groupwidget.setFrame("tempmodmini", 3, 1, 6, 3);
  -- groupwidget.setVisible(false);
  
  typingwidget = addBitmapWidget("indicator_typing");
  typingwidget.setPosition("center", -23, -23);
  typingwidget.setVisible(false);
  idlingwidget = addBitmapWidget("indicator_idling");
  idlingwidget.setPosition("center", -23, -23);
  idlingwidget.setVisible(false);
  
  colorwidget = addBitmapWidget("indicator_pointer");
  colorwidget.setPosition("center", 31, 16);
  colorwidget.setVisible(false);

  updateMenus();
end

function stateChange(statename, state)
  if statename == "current" then
    if state then
      namewidget.setFont("sheetlabelsmallbold");
    else
      namewidget.setFont("sheetlabelsmall");
    end
  end
  
  if statename == "label" then
    if state ~= "" then
      namewidget.setText(state);
    else
      namewidget.setText("- Unnamed - ");
    end
  end
  
  if statename == "color" then
    colorwidget.setColor(User.getIdentityColor(identityname));
    colorwidget.setVisible(true);
  end
  
  if statename == "active" then
    typingwidget.setVisible(false);
    idlingwidget.setVisible(false);
  end
  
  if statename == "typing" then
    typingwidget.setVisible(true);
    idlingwidget.setVisible(false);
  end
  
  if statename == "idle" then
    typingwidget.setVisible(false);
    idlingwidget.setVisible(true);
  end
end

function onClickDown(button, x, y)
  return true;
end

function onClickRelease(button, x, y)
  if User.isHost() or User.isOwnedIdentity(identityname) then
    Interface.openWindow("charsheet", "charsheet." .. identityname);
  end
end

function onDrag(button, x, y, draginfo)
  if User.isHost() or User.isOwnedIdentity(identityname) then
    draginfo.setType("playercharacter");
    draginfo.setTokenData("portrait_" .. identityname .. "_token");
    draginfo.setDatabaseNode("charsheet." .. identityname);
    draginfo.setStringData(identityname);
    
    local base = draginfo.createBaseData();
    base.setType("token");
    base.setTokenData("portrait_" .. identityname .. "_token");
  
    return true;
  end
end

function onDrop(x, y, draginfo)
  if User.isHost() then
  
    -- joining a chat group
    if ChatGroup and draginfo.isType("playercharacter") then
      local sourceId = draginfo.getDatabaseNode().getName();
      ChatGroup.joinIdentity(sourceId,identityname);
      window.layoutControls();
      return true;
    end
    
    -- Portrait icon and number drop
    if draginfo.isType("number") then
      local msg = {};
      msg.text = draginfo.getDescription();
      msg.font = "systemfont";
      msg.icon = "portrait_" .. identityname .. "_targetportrait";
      msg.dice = {};
      msg.diemodifier = draginfo.getNumberData();
      msg.dicesecret = false;
      
      ChatManager.deliverMessage(msg);
      
      return true;
    end

    -- Send dropped string as whisper
    if draginfo.isType("string") then
      local msg = {};
      msg.text = draginfo.getStringData();
      msg.font = "msgfont";

      msg.sender = "<whisper>";
      ChatManager.deliverMessage(msg, User.getIdentityOwner(identityname));

      msg.sender = "-> " .. User.getIdentityLabel(identityname);
      ChatManager.addMessage(msg);

      return true;
    end
    
    -- Shortcut shared to single client
    if draginfo.isType("shortcut") then
      local win = Interface.openWindow(draginfo.getShortcutData());
      if win then
        win.share(User.getIdentityOwner(identityname));
      end
    
      return true;
    end
  end

  -- Portrait selection
  if draginfo.isType("portraitselection") then
    User.setPortrait(identityname, draginfo.getStringData());
    return true;
  end
end

function onMenuSelection(selection)
  if User.isOwnedIdentity(identityname) then
    if selection == 5 then
      User.setCurrentIdentity(identityname);
      if CampaignRegistry and CampaignRegistry.colortables and CampaignRegistry.colortables[identityname] then
        local colortable = CampaignRegistry.colortables[identityname];
        User.setCurrentIdentityColors(colortable.color or "000000", colortable.blacktext or false);
      end
    elseif selection == 4 then
      User.releaseIdentity(identityname);
    end
  end
  
  if User.isHost() then
    if selection == 1 then
      User.ringBell(User.getIdentityOwner(identityname));
    elseif selection == 4 then
      if ChatGroup then
        ChatGroup.clearGroup(identityname);
        setGroup(ChatGroup.getGroup(identityname));
        window.layoutControls();
      end
    elseif selection == 5 then
      if ChatGroup then
        window.closeGroup(groupid);
      end
    end
  end
end
