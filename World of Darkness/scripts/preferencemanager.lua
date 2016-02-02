-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

-- Preferences store values between sessions that change the default behaviour of the ruleset, and of extensions.
-- 
-- A preference is first registered, which describes its type, name, default values etc, and can then be accessed.
--
-- There are two basic types of preference, global and local preferences. Global preferences are set by the host
-- and effect all sessions (they reside in db.xml) whereas local preferences are created for each user and reside
-- in the campaign registry.
--
-- Preferences are grouped for ease, and each group has its own page in the preferences list.
--
-- The functions exposed by the preference manager are:
--
-- register(prefdata)         registers a pref, it fails if the pref already exists
-- registerGroup(groupdata)   registers a preference group (used only for tabbed preference lists)
-- check(prefname)            tests whether a pref is defined
-- load(prefname)             returns the current value of a pref
-- save(prefname, prefvalue)  stores the value of a pref
-- reset(prefname)            restores a default value to a pref
-- getList()                  returns the internal list of registered preferences
-- getGroupList()             returns the internal list of registered preference groups
--
-- Most parameters are strings (prefname) or the data type of the pref itself (prefvalue), but the register function
-- takes a more complex structure (prefdata) which is explained below.
--
-- Pref data is a table containing the following fields:
--
-- group, string *
-- name, string (unique) *
-- helptext, string
-- global, boolean
-- datatype, string * +
-- label, string *
-- gmonly, boolean
-- defvalue, type = datatype
-- control, string or function
--
-- * Required attribute
-- + datatype can be "string", "number" or "table"
-- 
-- The 'control' field contains either the name of a template, or a function which can be invoked to return a new
-- control associated with the preference. In both cases the control should be unbound, and have getValue() and
-- setValue() methods which accept the datatype of the preference (so the checkbox template is inadequate, for example).
-- It should also expose a registerValueChanged function which takes a function as a parameter, to be called whenever
-- the control value is changed, and passes the control itself as the only parameter.
--
-- A control creation function is invoked with the parent window as the first parameter and the new control
-- name as the second parameter.
--
-- If the control field is absent, a default control will be used depending on the preference data type ("string" or "number").
--
-- Preference group data comprises:
-- 
-- name, string (unique) *
-- tabname, string (unique) *
--
-- It is anticipated that this structure may be extended in future to affect the layout of the preference control.

local preflist = {};
local grouplist = {};

-- ##################### External Functions - can be called by other code #########################################

function register(prefdata)
  local prefvalue = nil;
  local prefname = nil;
  local rulesetName = User.getRulesetName();
  local userName = User.getUsername();

  if not prefdata then
    return false;
  end
  if not prefdata.name or not prefdata.group or not prefdata.datatype or not prefdata.label then
    return false;
  end
  if preflist[prefdata.name] then
    return false;
  end
  preflist[prefdata.name] = prefdata;
  prefname = prefdata.name;
  
  -- get the value (or the default)
  prefvalue = load(prefname);

  -- save this value (ensures the global registry records the most recent value, and any default is saved)
  if User.isHost() or not (prefdata.gmonly or prefdata.global) then
    save(prefname, prefvalue);
  end

  return true;  
end

function registerGroup(groupdata)
  if not groupdata then
    return false;
  end
  if not groupdata.name or not groupdata.tabname then
    return false;
  end
  table.insert(grouplist,groupdata);
  return true;
end

function check(prefname)
  if preflist[prefname] then
    return true;
  else
    return false;
  end
end

function load(prefname)
  local rulesetName = User.getRulesetName();
  local userName = User.getUsername();
  local prefdata = preflist[prefname];
  local prefvalue = nil;
  
  if not prefdata then
    return nil;
  end
  
  -- fetch the current value from the registry or db.xml
  if prefdata.global then
    -- fetch from the db.xml (creating if it does not already exist)
    prefnode = DB.createNode("preference");
    if prefnode then
      prefvalue = getChildNodeValue(prefnode, prefname);
      if type(prefvalue)~=prefdata.datatype then
        prefvalue = nil;
      end
    end
  else
    -- fetch from the CampaignRegistry (creating preferences table if it does not already exist)
    if CampaignRegistry then
      if not CampaignRegistry.preferences then
        CampaignRegistry.preferences = {};
      end
      if not CampaignRegistry.preferences[userName] then
        CampaignRegistry.preferences[userName] = {};
      end
      prefvalue = CampaignRegistry.preferences[userName][prefname];
      if type(prefvalue)~=prefdata.datatype then
        prefvalue = nil;
      end
    end
  end

  -- if not found, look in the global registry (the 'last used' value for use as a default for new campaigns)
  if not prefvalue then
    if GlobalRegistry then
      if not GlobalRegistry[rulesetName] then
        GlobalRegistry[rulesetName] = {};
      end
      if not GlobalRegistry[rulesetName].preferences then
        GlobalRegistry[rulesetName].preferences = {};
      end
      if not GlobalRegistry[rulesetName].preferences[userName] then
        GlobalRegistry[rulesetName].preferences[userName] = {};
      end
      prefvalue = GlobalRegistry[rulesetName].preferences[userName][prefname];
      if type(prefvalue)~=prefdata.datatype then
        prefvalue = nil;
      end
    end
  end
  
  -- as a last resort, use the default value, if any
  if not prefvalue then
    prefvalue = prefdata.defvalue;
  end
  
  return prefvalue;
end

function save(prefname, prefvalue)
  local rulesetName = User.getRulesetName();
  local userName = User.getUsername();
  local prefdata = preflist[prefname];
  if not prefdata then
    return false;
  end
  
  if type(prefvalue)~=prefdata.datatype then
    return false;
  end;
  
  if prefdata.global then
    -- store in the db.xml (creating if it does not already exist)
    prefnode = DB.createNode("preference");
    if prefnode then
      setChildNodeValue(prefnode, prefname, prefvalue);
    end
  else
    -- store in the CampaignRegistry (creating preferences table if it does not already exist)
    if CampaignRegistry then
      if not CampaignRegistry.preferences then
        CampaignRegistry.preferences = {};
      end
      if not CampaignRegistry.preferences[userName] then
        CampaignRegistry.preferences[userName] = {};
      end
      CampaignRegistry.preferences[userName][prefname] = prefvalue;
    end
  end
  
  -- also store in the global registry (the 'last used' value for use as a default for new campaigns)
  if GlobalRegistry then
    if not GlobalRegistry[rulesetName] then
      GlobalRegistry[rulesetName] = {};
    end
    if not GlobalRegistry[rulesetName].preferences then
      GlobalRegistry[rulesetName].preferences = {};
    end
    if not GlobalRegistry[rulesetName].preferences[userName] then
      GlobalRegistry[rulesetName].preferences[userName] = {};
    end
    GlobalRegistry[rulesetName].preferences[userName][prefname] = prefvalue;
  end

  return true;
end

function reset(prefname)
  local prefdata = preflist[prefname];
  if prefdata then
    save(prefname,prefdata.defvalue);
  end
end

function getList()
  return preflist;
end

function getGroupList()
  return grouplist;
end

-- ##################### Internal Functions - used within this script ############################################

-- User login and logout

function onLogin(username, activated)
  local node = DB.createNode("preference");
  if node then
    if activated then
      node.addHolder(username, false);
    else
      node.removeHolder(username);
    end
  end
end

-- Initialization

function onInit()
  if super and super.onInit then
    super.onInit();
  end
  if User.isHost() then
    User.onLogin = onLogin;
  end
end

-- Internal support routines

function setChildNodeValue(prefNode, prefName, prefValue)
  if prefNode and prefValue then
    local prefType = type(prefValue);
    if prefType == "string" or prefType == "number" then
      local node = prefNode.createChild(prefName, prefType);
      if node then
        node.setValue(prefValue);
      end
    elseif prefType == "table" then
      local node = prefNode.createChild(prefName);
      if node then
        for k,v in pairs(prefValue) do
          setChildNodeValue(node, k, v);
        end
      end
    end
  end
end

function getChildNodeValue(prefNode, prefName)
  local returnValue = nil;
  if prefNode then
    if prefNode.getChild(prefName) then
      if prefNode.getChild(prefName).getType() == "node" then
        returnValue = {};
        for k, v in pairs(prefNode.getChild(prefName).getChildren()) do
          if v.getType() == "string"
          or v.getType() == "number" then
            returnValue[k] = v.getValue();
          elseif v.getType() == "node" then
            returnValue[k] = getChildNodeValue(prefNode.getChild(prefName), k);
          end
        end
      else
        returnValue = prefNode.getChild(prefName).getValue();
      end
    end
  end
  return returnValue;
end
