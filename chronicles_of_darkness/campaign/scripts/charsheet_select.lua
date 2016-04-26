-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local portraitwidget = nil;

function onInit()
  local linename = window.getDatabaseNode().createChild("gameline","string").getValue();
  local gameline;
  if super and super.onInit then
    super.onInit();
  end
  -- set portrait, if available
  if window.getDatabaseNode() and window.getDatabaseNode().getName() then
    if getName() == "FullPortraitFrame" then
      -- full-sized portrait
      portraitwidget = window.FullPortraitFrame.addBitmapWidget("portrait_" .. window.getDatabaseNode().getName().. "_charlist");
    end
    if getName() == "SmallPortraitFrame" then
      -- small portrait
      portraitwidget = window.SmallPortraitFrame.addBitmapWidget("portrait_" .. window.getDatabaseNode().getName().. "_token");
    end
  end
  if portraitwidget and portraitwidget.getBitmap() and window.logo then
    window.logo.setVisible(false);
  end
  -- set gameline-related stuff
  if linename=="" then
    linename = LineManager.getDefaultName();
  end
  gameline = LineManager.getLine(linename);
  if gameline then
    setTooltipText(gameline.FullName);
  end
  if User.isHost() then
    setMenus();
  end
end

local menuentry;

function setMenus()
  local index = 1;
  local max = LineManager.lineCount+1;
  menuentry = {};
  resetMenuItems();
  -- add context menu for changing the game line
  for k,game in pairs(LineManager.getLines()) do
    local first,second,third = getMenuPosition(max,index);
    if third then
      registerMenuItem(game.FullName,game.CSLogo,first,second,third);
    elseif second then
      registerMenuItem(game.FullName,game.CSLogo,first,second);
    elseif first then
      registerMenuItem(game.FullName,game.CSLogo,first);
    end
    menuentry[index] = game.Name;
    index = index + 1;
  end
end

function onMenuSelection(first,second,third)
  local index = getMenuIndex(first,second,third);
  local linename = menuentry[index];
  if linename then
    local node = window.getDatabaseNode();
    local win = Interface.findWindow("charsheet",node.getNodeName());
    if win then
      win.setLine(linename);
    end
  end
end

function getMenuPosition(max,index)
  if max<8 or index <7 then
    -- first seven can fit on one level, starting at position 2, so can the first six of a longer list
    return index+1;
  elseif index==7 then
    -- if there are more than seven, and this is the seventh one, create a second level menu
    registerMenuItem("More...","more",8);
    -- add this item to the second level
    return 8,1;
  elseif index<10 then
    -- next two can fit on the second level, before the menu-back entry at position 4
    return 8,index-6;
  elseif max<14 or index<13 then
    -- next three fit after position 4,
    return 8,index-5;
  elseif index==13 then
    -- if there are more than thirteen, and this is the thirteenth one, create a third level menu
    registerMenuItem("More...","more",8,8);
    -- add this item to the third level
    return 8,8,1;
  elseif index<16 then
    -- next two can fit on the third level, before the menu-back entry at position 4
    return 8,8,index-12;
  elseif index<20 then
    -- next four fit after position 4,
    return 8,8,index-11;
  else
    -- can't deal with more than 19 entries
    return nil;
  end
end

function getMenuIndex(first,second,third)
  if third then
    local index = 12;
    if third>4 then
      return index+third-1;
    else
      return index+third;
    end
  elseif second then
    local index = 6;
    if second>4 then
      return index+second-1;
    else
      return index+second;
    end
  elseif first then
    return first-1;
  else
    return 0;
  end
end

function onDrag(button, x, y, dragdata)
  local base = nil;

  dragdata.setType("playercharacter");
  dragdata.setDatabaseNode(window.getDatabaseNode());
  dragdata.setTokenData("portrait_" .. window.getDatabaseNode().getName().. "_token");
  
  base = dragdata.createBaseData();
  base.setType("token");
  base.setTokenData("portrait_" .. window.getDatabaseNode().getName() .. "_token");

  return dragdata;
end
