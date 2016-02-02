-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local notenode = nil;

function onInit()
  -- fetch the note db node
  notenode = DB.findNode("note");
  if notenode then
    -- remove any previous 'newnote' nodes
    if not User.isHost() then
      for k,node in pairs(notenode.getChildren()) do
        if node.isOwner() and node.getChild("newnote") then
          node.getChild("newnote").delete();
        end
      end
    end
    -- catch any additions to the list
    notenode.onChildAdded = onChildAdded;
    for k,node in pairs(notenode.getChildren()) do
      createWindow(node);
    end
    -- request a reshare, if needed
    NoteManager.reshare();
    -- refresh the list
    applyFilter();
  end
  -- add a menu option to create new notes
  registerMenuItem("New Note","insert",5);
end

function onChildAdded(parent, newchild)
  createWindow(newchild);
end

-- list filtering and sorting

function onFilter(win)
  local test = win.filter();
  local f = string.lower(window.filter.getValue());
  if test and not User.isHost() then
    local node = win.getDatabaseNode();
    if node and node.getChild("newnote") and node.getChild("newnote").getValue()==1 then
      if not Interface.findWindow("note",node) then
        Interface.openWindow("note",node);
      end
    end
  end
  if f == "" then
    return test;
  end
  if string.find(string.lower(win.name.getValue()), f, 0, true) then
    return test;
  end
  return false;
end

function onSortCompare(w1, w2)
  if w1.name.getValue() == "" then
    return true;
  elseif w2.name.getValue() == "" then
    return false;
  end
  return w1.name.getValue() > w2.name.getValue();
end

function onMenuSelection(entry)
  if entry and entry==5 then
    addNote();
    return true;
  end
end

-- add/delete notes to/from the list

function deleteNote(win)
  if win and win.getDatabaseNode() then
    win.getDatabaseNode().delete();
  end
end

function addNote()
  local node = nil;
  if not notenode then
    return nil;
  end
  -- create a new node (onChildAdded will automatically add it to the list)
  if User.isHost() then
    node = notenode.createChild();
    node.createChild("owner","string").setValue(User.getUsername());
    Interface.openWindow("note",node);
    return node;
  else
    -- send the command to the host to execute
    NoteManager.addNote();
    return nil;
  end
end

-- Host-only functions to allow items and strings to be dropped on the note list

function onDrop(x, y, draginfo)
  local source, class;
  if not User.isHost() then
    return;
  end
  if draginfo.isType("shortcut") then
    class = draginfo.getShortcutData();
  else
    class = draginfo.getType();
  end
  source = draginfo.getDatabaseNode();
  if class=="string" then
    local desc = draginfo.getDescription();
    local text = draginfo.getStringData();
    addString(text,desc);
    return true;
  end
end

function addString(text, name)
  local node = addNote();
  if node then
    node.createChild("name","string").setValue(name);
    node.createChild("text","string").setValue(text);
  end
end
