-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

function onDrop(x, y, draginfo)
  if draginfo.isType("token") then
    local prototype = draginfo.getTokenData();

    -- Check for duplicates
    for k,v in ipairs(getWindows()) do
      if v.token.getPrototype() == prototype then
        return true;
      end
    end
    
    local w = createWindow();
    w.token.setPrototype(prototype);
    
    return true;
  end
end