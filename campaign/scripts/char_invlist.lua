-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sortLocked = false;

function setSortLock(isLocked)
	sortLocked = isLocked;
end

function onInit()
	OptionsManager.registerCallback("MIID", StateChanged);

	onEncumbranceChanged();

	registerMenuItem(Interface.getString("list_menu_createitem"), "insert", 5);

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "*.carried"), "onUpdate", onCarriedChanged);
	DB.addHandler(DB.getPath(node, "*.weight"), "onUpdate", onEncumbranceChanged);
	DB.addHandler(DB.getPath(node, "*.count"), "onUpdate", onEncumbranceChanged);
	DB.addHandler(DB.getPath(node), "onChildDeleted", onEncumbranceChanged);
end

function onClose()
	OptionsManager.unregisterCallback("MIID", StateChanged);

	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "*.carried"), "onUpdate", onCarriedChanged);
	DB.removeHandler(DB.getPath(node, "*.weight"), "onUpdate", onEncumbranceChanged);
	DB.removeHandler(DB.getPath(node, "*.count"), "onUpdate", onEncumbranceChanged);
	DB.removeHandler(DB.getPath(node), "onChildDeleted", onEncumbranceChanged);
end

function onMenuSelection(selection)
	if selection == 5 then
		addEntry(true);
	end
end

function StateChanged()
	for _,w in ipairs(getWindows()) do
		w.onIDChanged();
	end
	applySort();
end

function onCarriedChanged(nodeCarried)
	local nodeChar = DB.getChild(nodeCarried, "....");
	if nodeChar then
		local nodeCarriedItem = DB.getChild(nodeCarried, "..");

		local nCarried = nodeCarried.getValue();
		local sCarriedItem = ItemManager.getDisplayName(nodeCarriedItem);
		if sCarriedItem ~= "" then
			for _,vItem in pairs(DB.getChildren(nodeChar, "inventorylist")) do
				if vItem ~= nodeCarriedItem then
					local sLoc = DB.getValue(vItem, "location", "");
					if sLoc == sCarriedItem then
						DB.setValue(vItem, "carried", "number", nCarried);
					end
				end
			end
		end
	end
	
	onEncumbranceChanged();
end

function onEncumbranceChanged()
	if CharManager.updateEncumbrance then
		CharManager.updateEncumbrance(window.getDatabaseNode());
	end
end

function onListChanged()
	update();
	updateContainers();
end

function update()
	local bEditMode = (window.inventorylist_iedit.getValue() == 1);
	window.idelete_header.setVisible(bEditMode);
	for _,w in ipairs(getWindows()) do
		w.idelete.setVisibility(bEditMode);
	end
end

function addEntry(bFocus)
	local w = createWindow();
	if w then
		w.isidentified.setValue(1);
		if bFocus then
			w.name.setFocus();
		end
	end
	return w;
end

function onClickDown(button, x, y)
	return true;
end

function onClickRelease(button, x, y)
	if not getNextWindow(nil) then
		addEntry(true);
	end
	return true;
end

function onSortCompare(w1, w2)
	if sortLocked then
		return false;
	end

	local n1 = w1.getDatabaseNode();
	local n2 = w2.getDatabaseNode();
	
	local sName1 = ItemManager.getSortName(n1);
	local sName2 = ItemManager.getSortName(n2);
	local sLoc1 = DB.getValue(n1, "location", ""):lower();
	local sLoc2 = DB.getValue(n2, "location", ""):lower();
	
	-- Check for empty name (sort to end of list)
	if sName1 == "" then
		if sName2 == "" then
			return nil;
		end
		return true;
	elseif sName2 == "" then
		return false;
	end
	
	-- If different containers, then figure out containment
	if sLoc1 ~= sLoc2 then
		-- Check for containment
		if sLoc1 == sName2 then
			return true;
		end
		if sLoc2 == sName1 then
			return false;
		end
	
		if sLoc1 == "" then
			return sName1 > sLoc2;
		elseif sLoc2 == "" then
			return sLoc1 > sName2;
		else
			return sLoc1 > sLoc2;
		end
	end

	-- If same container, then sort by name or node id
	if sName1 ~= sName2 then
		return sName1 > sName2;
	end
end

function updateContainers()
	local containermapping = {};

	for _,w in ipairs(getWindows()) do
		if w.name and w.location then
			local entry = {};
			entry.name = w.name.getValue();
			entry.location = w.location.getValue();
			entry.window = w;
			table.insert(containermapping, entry);
		end
	end
	
	local lastcontainer = 1;
	for n, w in ipairs(containermapping) do
		if n > 1 and string.lower(w.location) == string.lower(containermapping[lastcontainer].name) and w.location ~= "" then
			-- Item in a container
			w.window.name.setAnchor("left", nil, "left", "absolute", 45);
		else
			-- Top level item
			w.window.name.setAnchor("left", nil, "left", "absolute", 35);
			lastcontainer = n;
		end
	end
end

function onDrop(x, y, draginfo)
	return CampaignDataManager.handlePCDrop(window.getDatabaseNode(), draginfo, "items");
end
