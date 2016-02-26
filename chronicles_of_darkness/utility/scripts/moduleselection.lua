-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bInitialized = false;

function onInit()
	local modules = Module.getModules();
	for _, v in ipairs(modules) do
		checkEntry(v);
	end
	
	Module.onModuleAdded = checkEntry;
	Module.onModuleUpdated = checkEntry;
	Module.onModuleRemoved = removeEntry;
	
	bInitialized = true;
end

function addEntry(name)
	local w = list.createWindow();
	if w then
		w.setEntryName(name);
	end
end

function checkEntry(name)
	for _,v in pairs(list.getWindows()) do
		if v.getEntryName() == name then
			v.update();
			list.applyFilter();
			return;
		end
	end
	addEntry(name);
end

function removeEntry(name)
	for _,v in pairs(list.getWindows()) do
		if v.getEntryName() == name then
			v.close();
			return;
		end
	end
end
