-- Copyright 2008 Digital Adventures LLC.


function onDrop(x, y, draginfo)
  local source = nil;
  if draginfo.isType("npc") then
    source = draginfo.getDatabaseNode();
  elseif draginfo.isType("shortcut") then
    local class = draginfo.getShortcutData();
    if class == "npc" then
      source = draginfo.getDatabaseNode();
    end
  end
  if source then
    addNpc(source);
    return true;
  end
end

function addNpc(source)
  local newentry = createWindow();
  local newnode = newentry.getDatabaseNode();

  -- Token
  if source.getChild("token") then newnode.createChild("token","token").setValue(source.getChild("token").getValue()) end;
  
  -- Name
  if source.getChild("name") and not istemplate then
    newnode.createChild("name","string").setValue(source.getChild("name").getValue());
  else
    newnode.createChild("name","string").setValue("");
  end;
  
  -- General fields
  if source.getChild("move") then newnode.createChild("move","string").setValue(source.getChild("move").getValue()) end;
  if source.getChild("armor") then newnode.createChild("armor","string").setValue(source.getChild("armor").getValue()) end;
  if source.getChild("notes") then newnode.createChild("notes","string").setValue(source.getChild("notes").getValue()) end;
  
  return newentry;
end
