-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

function applyModifierStackToRoll(draginfo)
  -- check if the stack should be applied (d10s only)
  if draginfo.getDieList() then
    for k,die in pairs(draginfo.getDieList()) do
      if die.type~="d10" then
        return false;
      end
    end
  end
  -- description
  if draginfo.getDescription() == "" then
    draginfo.setDescription(ModifierStack.getDescription());
  else
    local moddesc = ModifierStack.getDescription(true);
    local desc = draginfo.getDescription();
    local originalnumber = draginfo.getNumberData();
    local numstr = tostring(originalnumber);
    if originalnumber > 0 then
      numstr = "+" .. originalnumber;
    end
    if numstr ~= "0" then
      desc = desc .. " " .. numstr;
    end
    if moddesc ~= "" then
      desc = desc .. " (" .. moddesc .. ")";
    end
    draginfo.setDescription(desc);
  end
  -- dice pool
  if ModifierStack.getSum()==0 then
    -- clear the stack
    ModifierStack.reset();
    return false;
  else
    local newlist = {};
    local custom = nil;
    -- build the new list of dice
    for i=1,ModifierStack.getSum() do
      table.insert(newlist,"d10");
    end
    -- save the current description and results
    if draginfo.getDieList() then
      custom = {};
      custom.type = "dice pool";
      custom.dieList = draginfo.getDieList();
    end
    -- clear the stack
    ModifierStack.reset();
    -- roll the remaining dice
    throwDice("dice",newlist,0,draginfo.getDescription(),custom);
    return true;
  end
end

function onDiceLanded(draginfo)
local rerolls = 0;
local tense = "RollAgain";
local drama = "";
local chance = "";

  if ChatManager.getDieRevealFlag() then
  
    draginfo.revealDice(true);
  end
  
  if draginfo.isType("dice") then
  local rev = {};
    rev.dice = draginfo.getDieList();
    local dielist = draginfo.getDieList();
    local description = draginfo.getDescription();
    local custom = draginfo.getCustomData();
    local successes = 0;
	

	--needs to be set to a key
	if Input.isAltPressed() then
	print("yo");
	rev.dicesecret = false;
	end

	
	
	
	
    -- only process further if d10s thrown
    for v,die in pairs(dielist) do
      if die.type~="d10" then
        -- not a d10, stop the special treatment
        return;
		elseif die.result > 9  then
		          if string.find(description,"Reroll") then
				  print("1");
		             successes = successes + 1;
	                 rerolls = rerolls + 1;
				  elseif string.find(description,"Chance") then
				  print("2");
				  chance= "chance";
				     successes = successes + 1;
	                 rerolls = rerolls + 1;
				  elseif string.find(description,"Risk") then
				  print("3");
				     
				         chance = "Risk";
					 
		             successes = successes + 1;
	                 rerolls = rerolls + 1;
				  elseif string.find(description,"9-Again") then
				     chance = "9-Again";
					 
		             successes = successes + 1;
	                 rerolls = rerolls + 1;
				  else
				     successes = successes + 1;
	                 rerolls = rerolls + 1;
	              end
		elseif die.result > 8 and string.find(description, "Risk") then
                      
				         chance = "Risk";
					  
				     successes = successes + 1;
	                 rerolls = rerolls + 1;
		elseif die.result > 8 and string.find(description,"9-Again") then
                  
					     chance ="9-Again";			 		
				     successes = successes + 1;
	                 rerolls = rerolls + 1;
					 
				  
		elseif die.result >=8 and die.result < 10 then
		            
		    if string.find(description,"Reroll") then
			   print("B");
	           successes = successes + 1;
			end
			if string.find(description,"Chance") then
			   print("C");
			--do nothing
			end
			if die.result >= 8 then
			   if string.find(description,"Reroll") then
			   --do nothing
			   elseif string.find(description,"Chance") then
			   --do nonting
			   elseif string.find(description,"9-Again") then
                  successes = successes + 1;
			   else
		print("D");
			   successes = successes + 1;
			   end
			end
			
	    elseif die.result == 1 then
              if string.find(description,"Chance") then
                  drama = "Dramatic Failure";
			   end
        end
	  -- if not string.find(description,"Reroll|Chance") and die.result > 9 then
		--    rerolls = rerolls + 1;
	   --end
	  -- if string.find(description, "Chance") and die.result == 1 then
	  -- tense = "Dramatic Failure";
	   --end
	  
	  
    end
    if applyModifierStackToRoll(draginfo) then
      -- More rolling required, suspend processing of this roll
      return true;
    end
    -- add any nested custom data
    if custom and custom.type and custom.type=="dice pool" then
      for v,die in pairs(custom.dieList) do
        table.insert(dielist,die);
		if die.result > 9  then
		          if string.find(description,"Reroll") then
				  print("1");
		             successes = successes + 1;
	                 rerolls = rerolls + 1;
				  elseif string.find(description,"Chance") then
				  print("2");
				  chance= "chance";
				     successes = successes + 1;
	                 rerolls = rerolls + 1;
				  elseif string.find(description,"Risk") then
				  print("3");
				     
				         chance = "Risk";
					 
		             successes = successes + 1;
	                 rerolls = rerolls + 1;
				  elseif string.find(description,"9-Again") then
				     chance = "9-Again";
					 
		             successes = successes + 1;
	                 rerolls = rerolls + 1;
				  else
				     successes = successes + 1;
	                 rerolls = rerolls + 1;
	              end
		elseif die.result > 8 and string.find(description, "Risk") then
                      
				         chance = "Risk";
					  
				     successes = successes + 1;
	                 rerolls = rerolls + 1;
		elseif die.result > 8 and string.find(description,"9-Again") then
                  
					     chance ="9-Again";			 		
				     successes = successes + 1;
	                 rerolls = rerolls + 1;
					 
		elseif die.result >=8 and die.result < 10 then
		            
		    if string.find(description,"Reroll") then
			   print("B");
	           successes = successes + 1;
			end
			if string.find(description,"Chance") then
			   print("C");
			--do nothing
			end
			if string.find(description,"9-Again") then
			successes = successes + 1;
			end
			
			if die.result >= 8 then
			   if string.find(description,"Reroll") then
			   --do nothing
			   elseif string.find(description,"Chance") then
			   --do nonting
			   elseif string.find(description,"9-Again") then
			   --do nothing
			   else
		print("D");
			   successes = successes + 1;
			   end
			end
			
	    elseif die.result == 1 then
              if string.find(description,"Chance") then
                  drama = "Dramatic Failure";
			   end
        end
      end
    end
	if successes == 0 then
	    if string.find(description, "Risk :") then
	      drama = "Dramatic Failiure";
		end
	
	end
	
	if rerolls >= 1 then
	   if chance == "chance" then
	       ModifierStack.addSlot("Chance again",tonumber(rerolls));
		   chance = "";
		elseif chance == "Risk" then
		    ModifierStack.addSlot("Risk (9 again)", tonumber(rerolls));
			chance = "";
		elseif chance == "9-Again" then
		ModifierStack.addSlot("9-Again", tonumber(rerolls));
		    chance = '';
		else
	      ModifierStack.addSlot("Reroll",tonumber(rerolls));
	   end
	
	end
    -- sort the results
    table.sort(dielist,diecomp);
    -- create a custom delivery message
    local msg = {font="systemfont"};
    local append;
	
	
		
	    if rerolls==0 then
	      tense ="";
	      rerolls ="";
		
	    elseif rerolls > 1 then
	      tense = "RollAgains";
	      rerolls = " you get "..rerolls.." "..tense;
	    else
	      tense = "RollAgain";
	      rerolls = " you get "..rerolls.." "..tense;
		
	   end
	 
    if successes==1 then
      append = "1 success";
    else
      append = successes .. " successes";
    end
    if description=="" then
      msg.text = append.." "..rerolls;
    else
      msg.text = description.." ("..append.." "..rerolls..drama..")";
    end
    msg.dice = dielist;
    if User.isHost() then
			msg.sender = GmIdentityManager.getCurrent();
		else
			msg.sender = User.getIdentityLabel();
    end
    --[[ add an optional total to the end of the message: NOT MEANINGFUL IN WoD
    if PreferenceManager.load(Preferences.ShowTotals.PrefName)==Preferences.Yes then
      local total = entry.diemodifier;
      for k,die in ipairs(entry.dice) do
        if die.result then
          total = total + die.result;
        end
      end
      if total~= 0 then
        local text = entry.text or "";
        if text=="" then
          entry.text = "["..total.."]";
        else
          entry.text = text.." ["..total.."]";
        end
      end
    end ]]
    -- add the optional portrait
    if ChatManager then
      msg = ChatManager.checkPortrait(msg,"");
    end
    -- send the custom message
	--if tonumber(rerolls) > 0 then
	--ModifierStack.setFreeAdjustment(tonumber(rerolls));
	--end
	if Input.isAltPressed() then
	
	msg.dicesecret = false;
	end
    deliverMessage(msg);
    return true;
  end
end

function diecomp(d1,d2)
  return d1.result>d2.result;
end

function onDrop(x, y, draginfo)
  if draginfo.getType() == "number" then
    applyModifierStackToRoll(draginfo);
  end
end

function moduleActivationRequested(module)
  local msg = {};
  msg.text = "Players have requested permission to load '" .. module .. "'";
  msg.font = "systemfont";
  msg.icon = "indicator_moduleloaded";
  addMessage(msg);
end

function moduleUnloadedReference(module)
  local msg = {};
  msg.text = "Could not open sheet with data from unloaded module '" .. module .. "'";
  msg.font = "systemfont";
  addMessage(msg);
end

function onReceiveMessage(msg)
  if ChatManager and ChatManager.executeCommand then
  
  print("function init");
local test1 = msg.text;
local modnum = {};
local descriptor ="";
test1 = test1.." ";
	if string.sub(test1,1,1) == " " then
	print("1");
	 --do nothing passing tothe screen
	 else
	      
		if string.match(test1,"^%^[%-%+%d+]*")or string.match(test1,"^%^%+%d+")or string.match(test1,"[^%^%+%d+]|[^%^%-%d]|[^%^%+%d]")then
		print("2");
		  if not string.match(test1,"%s%a") then
		      test1 = test1.." ";
			 print("3");
		  end  
		  print("4");
		      modnum = strsplit( "%s",test1);
		       
           for i = 2, table.getn (modnum) do
               descriptor = descriptor.." " ..modnum[i];
           end
          modnum[1] = string.sub(modnum[1],2);		   	
		  if string.find(modnum[1],"%a") or string.find(modnum[1],"%s") or string.find(modnum[1],"[_&*()^%$#@!~?.,:;`={}]")then	
		  print("5");
		  --pass this to the screen
		  else
		  ModifierStack.addSlot(descriptor..":",tonumber(modnum[1]));
           return true;
          end  
	    end
	 end  
  
  
  
  
    return ChatManager.executeCommand(msg);
  end
 
end

function strsplit(delimiter, text)
  local list = {};
  local pos = 1 ;
  if string.find("", delimiter, 1) then
    error("delimiter matches empty string!");
  end
  while 1 do
    local first, last = string.find(text, delimiter, pos);
    if first then 
      table.insert(list, string.sub(text, pos, first-1));
      pos = last+1;
    else
      table.insert(list, string.sub(text, pos));
      break;
    end
  end
  return list;
end


function onInit()
  ChatManager.registerControl(self);
  
  if User.isHost() then
    Module.onActivationRequested = moduleActivationRequested;
  end

  Module.onUnloadedReference = moduleUnloadedReference;
end

function onClose()
  ChatManager.registerControl(nil);
end
