-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

function onDeliverMessage(messagedata, mode)
  if ChatManager then
    messagedata = ChatManager.checkPortrait(messagedata, mode);
  end
  if User.isHost() then
    gmid, isgm = GmIdentityManager.getCurrent();

    if messagedata.hasdice then
      messagedata.sender = gmid;
      messagedata.font = "systemfont";
    elseif mode == "chat" then
      messagedata.sender = gmid;
      
      if isgm then
        messagedata.font = "dmfont";
      else
        messagedata.font = "npcchatfont";
      end
    elseif mode == "story" then
      messagedata.sender = "";
      messagedata.font = "narratorfont";
    elseif mode == "emote" then
      messagedata.text = gmid .. " " .. messagedata.text;
      messagedata.sender = "";
      messagedata.font = "emotefont";
    end
  end
  if not User.isHost() then
	local test1 = messagedata.text;
	
	 
   if string.match(test1,"%^%-%d+")or string.match(test1,"%^%+%d+")or string.match(test1,"[^%^%+%d+%s]|[^%^%-%d%s]|[^%^%+%d]") or string.sub(test1,1,1)=="^" then
		messagedata.text = " "..messagedata.text
   end
 	 
end
  return messagedata;
end

function onTab()
  ChatManager.doAutocomplete();
end

function onInit()
  ChatManager.registerEntryControl(self);
end
