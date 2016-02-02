-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local copyrightmessage = {
  [1] = "World of Darkness for Fantasy Grounds II",
  [2] = "Copyright 2010 CCP hf. All rights reserved."
};

local versionmessage = "Version 0.23 (Build 110)";
local commandhandlers = {};

-- Command handlers
function registerCommandHandler(command,handler)
  commandhandlers[command] = handler;
end

function sendCommand(name,text)
  local msg = {};
  msg.sender = "/cmd "..name.." "..User.getUsername();
  msg.text = text;
  msg.font = "";
  deliverMessage(msg, "");
end

function executeCommand(message)
  local cmd = parseCommand(message);
  if cmd and cmd.name then
    local handler = commandhandlers[cmd.name];
    if handler then
      handler(cmd.name,cmd.text,cmd.sender);
      return true;
    end
  end
end

function parseCommand(msg)
  if msg and msg.sender then
    local sender = string.sub(msg.sender,1,-2);
    local cmd = {};
    local pos = 1;
    local first, last;
    -- command body
    cmd.text = msg.text;
    -- test word
    first, last = string.find(sender, "%s+", pos);
    if first then
      local test = string.sub(sender, pos, first-1);
      if test~="/cmd" then
        return nil;
      end
      pos = last+1;
    else
      return nil;
    end
    -- command name
    first, last = string.find(sender, "%s+", pos);
    if first then
      cmd.name = string.sub(sender, pos, first-1);
      cmd.sender = string.sub(sender, last+1);
    else
      cmd.name = string.sub(sender, pos);
      cmd.sender = "";
    end
    -- done
    return cmd;
  else
    return nil;
  end
end

-- Chat window registration for general purpose message dispatching

function registerControl(ctrl)
  control = ctrl;
  -- display the ruleset message
  for i,txt in ipairs(copyrightmessage) do
    addMessage({text = txt, font = "systemfont"});
  end
end

function registerEntryControl(ctrl)
  entrycontrol = ctrl;
  ctrl.onSlashCommand = onSlashCommand;
end

-- Generic message delivery
function deliverMessage(...)
  if control then
    control.deliverMessage(...);
  end
end

function addMessage(...)
  if control then
    control.addMessage(...);
  end
end

function checkPortrait(msg, mode)
  local identity;
  -- check preferences
  if PreferenceManager.load(Preferences.ChatPortraits.PrefName)~=Preferences.Yes then
    return msg;
  end
  -- ensure mode is a valid string
  mode = mode or "";
  -- only process 'chat' entries
  if mode~="chat" then
    return msg;
  end
  -- don't over-ride an existing icon
  if msg.icon then
    return msg;
  end
  -- treat GM differently
  if User.isHost() then
    msg.icon = "portrait_GM_chat";
    return msg;
  end
  -- find current identity
  identity = User.getCurrentIdentity();
  if (not identity) or (identity=="") then
    msg.icon = "portrait_chat";
  else
    msg.icon = "portrait_"..identity.."_chat";
  end
  return msg;
end

-- Dice rolling
function throwDice(...)
  if control then
    control.throwDice(...);
	
  end
end

-- Slash command dispatching
slashhandlers = {};

function registerSlashHandler(command, callback)
  slashhandlers[command] = callback;
end

function unregisterSlashHandler(command, callback)
  slashhandlers[command] = nil;
end

function onSlashCommand(command, parameters)
  local cmd = nil;
	for c, h in pairs(slashhandlers) do
	  if string.lower(c)==string.lower(command) then
	    -- exact match
			h(parameters);
			return;
		elseif string.find(string.lower(c), string.lower(command), 1, true) == 1 then
		  -- close match
		  cmd = h;
		end
	end
	if cmd then
	  cmd(parameters);
	end
end

-- Aliases
function doAutocomplete()
  local buffer = entrycontrol.getValue();
  local spacepos = string.find(string.reverse(buffer), " ", 1, true);
  
  local search = "";
  local remainder = buffer;
  
  if spacepos then
    search = string.sub(buffer, #buffer - spacepos + 2);
    remainder = string.sub(buffer, 1, #buffer - spacepos + 1);
  else
    search = buffer;
    remainder = "";
  end
  
  -- Check identities
  for k, v in ipairs(User.getAllActiveIdentities()) do
    local label = User.getIdentityLabel(v);
    if label and string.find(string.lower(label), string.lower(search), 1, true) == 1 then
      local replacement = remainder .. label;
      entrycontrol.setValue(replacement);
      entrycontrol.setCursorPosition(#replacement + 1);
      entrycontrol.setSelectionPosition(#replacement + 1);
      return;
    end
  end
end

-- Whispers
function handleWhisper(cmd,text,fromuser)
	local msg = {font="msgfont"};
	local seppos = 0;
	local touser = "";
	local toiden = "";
	local toname = "";
	local fromiden = "";
	local fromname = "";
	local message = "";
	-- check if whispering is enabled
	if PreferenceManager.load(Preferences.P2PWhisper.GMPref)==Preferences.No then
	  -- send a message back to the user
	  msg.font = "systemfont";
	  msg.sender = nil;
	  msg.text = "Player-to-player whispers have been disabled by the "..GmIdentityManager.gmid;
	  deliverMessage(msg, fromuser);
	  return;
	end
	-- parse text string
	seppos = string.find(text, "¦");
	fromiden = string.sub(text,1,seppos-1);
	fromname = User.getIdentityLabel(fromiden);
	text   = string.sub(text,seppos+1);
	seppos = string.find(text, "¦");
	toiden = string.sub(text,1,seppos-1);
	toname = User.getIdentityLabel(toiden);
	touser = User.getIdentityOwner(toiden);
	message= string.sub(text,seppos+1);
	-- create message to recipient
	msg.sender = "[w] " .. fromname;
	msg.text   = message;
	deliverMessage(msg, touser);
	-- create message from sender
	msg.sender = "[w] -> " .. toname;
	deliverMessage(msg, fromuser);
  -- echo to the GM?
	if PreferenceManager.load(Preferences.P2PWhisper.GMPref)==Preferences.P2PWhisper.Echo then
    msg.sender = nil;
	  msg.text = "[w] " .. fromname .. " -> " .. toname .. ":  " .. message;
 	  addMessage(msg);
 	end
 	-- done
end

function processWhisper(params)
	local sep = " ";
	local seppos;
	local test1 ="";
	if PreferenceManager.load(Preferences.P2PWhisper.SeparatorPref)==Preferences.Yes then
	  sep = ":";
	end
	seppos = string.find(params, sep, 1, true);
	-- check if we found a recipient
	if seppos then
		local toname = string.sub(params, 1, seppos-1);
		local seek = string.lower(toname);
		local message = string.sub(params, seppos+1);
		-- Find user
    local touser = nil;
    local toiden = nil;
    for k, v in ipairs(User.getAllActiveIdentities()) do
      local label = User.getIdentityLabel(v);
      if string.lower(label) == seek then
        -- Direct match
        touser = User.getIdentityOwner(v);
        if touser then
          toname = label;
          toiden = v;
          break;
        end
      elseif not touser and string.find(string.lower(label), seek, 1, true) == 1 then
        -- Partial match
        touser = User.getIdentityOwner(v);
        if touser then
          toiden = v;
          toname = label;
        end
      end
    end
		if touser then   
      if User.isHost() then
	      local msg = {font="msgfont"};
			  msg.text = message;
				msg.sender = "[w] "..GmIdentityManager.getCurrent();
				control.deliverMessage(msg, touser);
				msg.sender = "[w] -> " .. toname;
				control.addMessage(msg);
      else
        -- cannot be executed on the client, send it to the host as a remote command
        local fromiden = User.getCurrentIdentity();
        sendCommand("whisper",fromiden.."¦"..toiden.."¦"..message);
			end
			return;
		end
	  if User.isHost() then
	  
      local msg = {font="systemfont"};
			msg.text = "Recipient not found, usage: /w [recipient] [message]";
			addMessage(msg);
		else
		test1 = string.sub(msg.text, 1,5);
		if string.match(test1,"%^%-%d+")or string.match(test1,"%^%+%d+")then
		msg.text = " "..msg.text
        end
		
      ChatManager.processWhisperGM(params);
		end
		return;
	else
	  if User.isHost() then
      local msg = {font="systemfont"};
			msg.text = "Recipient not found, usage: /w [recipient] [message]";
			addMessage(msg);
	  else
	  test1 = string.sub(msg.text, 1,5);
	  if string.match(test1,"%^%-%d+")or string.match(test1,"%^%+%d+")then
		msg.text = " "..msg.text
        end
   	  ChatManager.processWhisperGM(params);
   	end
	end
end

function processWhisperGM(params)
	if not User.isHost() then
	  local msg = {font="msgfont"};
		msg.sender = "[w] " .. User.getIdentityLabel();
		msg.text = params;
		control.deliverMessage(msg, "");
		msg.sender = "[w] -> GM"
		control.addMessage(msg);
	end
	return
end

-- Dice
function getDieRevealFlag()
  if revealalldice then
    return true;
  end
  
  return false;
end

function processDie(params)
  if control then
    if User.isHost() then
      if params == "reveal" then
        revealalldice = true;

        local msg = {};
        msg.font = "systemfont";
        msg.text = "Revealing all die rolls";
        control.addMessage(msg);

        return;
      end
      if params == "hide" then
        revealalldice = false;

        local msg = {};
        msg.font = "systemfont";
        msg.text = "Hiding all die rolls";
        control.addMessage(msg);

        return;
      end
    end
  
    local diestring, descriptionstring = string.match(params, "%s*(%S+)%s*(.*)");
    
    if not diestring then
      local msg = {};
      msg.font = "systemfont";
      msg.text = "Usage: /die [dice] [description]";
      control.addMessage(msg);
      return;
    end
    
    local dice = {};
    local modifier = 0;
    
    for s, m, d in string.gmatch(diestring, "([%+%-]?)(%d*)(%w*)") do
      if m == "" and d == "" then
        break;
      end

      if d ~= "" then
        for i = 1, tonumber(m) or 1 do
          table.insert(dice, d);
          if d == "d100" then
            table.insert(dice, "d10");
          end
        end
      else
        if s == "-" then
          modifier = modifier - m;
        else
          modifier = modifier + m;
        end
      end
    end

    if #dice == 0 then
      local msg = {};
      
      msg.font = "systemfont";
      msg.text = descriptionstring;
      msg.dice = {};
      msg.diemodifier = modifier;
      msg.dicesecret = false;
      
      msg = checkPortrait(msg,"chat");

      if User.isHost() then
        msg.sender = GmIdentityManager.getCurrent();
      else
        msg.sender = User.getIdentityLabel();
      end
    
      deliverMessage(msg);
    else
      control.throwDice("dice", dice, modifier, descriptionstring);
    end
  end
end

-- Version info
function processVersion(...)
	addMessage({text = versionmessage, font = "systemfont"});
end

-- Initialization
function onInit()
  registerSlashHandler("/die", processDie);
  registerSlashHandler("/version", processVersion);
	registerSlashHandler("/w", processWhisper);
	if User.isHost() then
	  -- handle incoming whispers
    registerCommandHandler("whisper",handleWhisper);
  else
	  -- whisper to the GM
	  registerSlashHandler("/wg", processWhisperGM);
  end
end
