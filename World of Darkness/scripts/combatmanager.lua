-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

-- static variables

local panellist = {};
local panelid  = {};
local count = 0;

function onInit()
  -- register the default panels
  -- register("active","combatpanel_active","indicator_sword");
  register("defensive","combatpanel_defensive","indicator_shield");
  register("effects","combatpanel_effects","indicator_effect");
  register("notes","combatpanel_notes","indicator_casterprep",true);
end

-- panel manager for the combat tracker

function register(name, class, icon, gmonly)
  local paneldata = {};
  local id = 0;
  -- check we have valid parameters
  if not name or not class or not icon then
    return false;
  end
  -- check if the entry already exists
  if panelid[name] then
    id = panelid[name];
  else
    count = count + 1;
    id = count;
    panelid[name] = id;
  end
  -- create the data structure
  paneldata.name = name;
  paneldata.icon = icon;
  paneldata.windowclass = class;
  paneldata.gmonly = gmonly or false;
  -- add/update the entry
  panellist[id] = paneldata;
  return true;  
end

function getPanels()
  return panellist;
end

-- copy an encounter onto the combat tracker

function addEncounterToTracker(source)
  local tracker;
  if not User.isHost() or not source then
    return;
  end
  tracker = Interface.openWindow("combattracker","combattracker");
  if not tracker then
    return;
  end
  tracker.list.addEncounter(source);
  -- done
end
