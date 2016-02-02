-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_TRANSFERITEM = "transferitem";

local aDeleteCopyFields = { "count", "locked", "location", "carried", "showonminisheet", "assign" };

--
-- HANDLERS
--

local fCustomCharAdd = nil;
function setCustomCharAdd(fCharAdd)
	fCustomCharAdd = fCharAdd;
end
function onCharAddEvent(nodeItem)
	if fCustomCharAdd then
		fCustomCharAdd(nodeItem);
	end
end

local fCustomCharRemove = nil;
function setCustomCharRemove(fCharRemove)
	fCustomCharRemove = fCharRemove;
end
function onCharRemoveEvent(nodeItem)
	if fCustomCharRemove then
		fCustomCharRemove(nodeItem);
	end
end

function addFieldToIgnore (sIgnore)
	if type(sIgnore) == "string" and sIgnore ~= "" then
		table.insert(aDeleteCopyFields, sIgnore);
	end
end

local aCustomTransferNotifyHandlers = {};
function addTransferNotificationHandler(f)
	table.insert(aCustomTransferNotifyHandlers, f);
end

--
-- INITIALIZATION
--

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_TRANSFERITEM, handleTransfer);
end

--
-- TRANSFER REQUEST
--

function notifyTransfer(sTargetInvRecord, sSourceClass, sSourceRecord, bTransferAll)
	for _,fHandler in ipairs(aCustomTransferNotifyHandlers) do
		if fHandler(sTargetInvRecord, sSourceClass, sSourceRecord, bTransferAll) then
			return;
		end
	end
	
	if not User.isHost() then
		local sSourceRecordType = getItemSourceType(sSourceRecord);
		local sTargetRecordType = getItemSourceType(sTargetInvRecord);
		if not StringManager.contains({"partysheet", "charsheet"}, sSourceRecordType) and StringManager.contains({"charsheet"}, sTargetRecordType) then
			addItemToList(sTargetInvRecord, sSourceClass, sSourceRecord, bTransferAll);
			return;
		end
	end
	
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_TRANSFERITEM;
	
	msgOOB.sTarget = sTargetInvRecord;
	msgOOB.sClass = sSourceClass;
	msgOOB.sSource = sSourceRecord;
	if bTransferAll then
		msgOOB.sTransferAll = "true";
	end

	Comm.deliverOOBMessage(msgOOB, "");
end

--
-- ACTIONS
--

function handleTransfer(msgOOB)
	addItemToList(msgOOB.sTarget, msgOOB.sClass, msgOOB.sSource, (msgOOB.sTransferAll == "true"));
end

function isItemClass(sClass)
	if sClass == "item" then
		return true;
	elseif ItemManager2 and ItemManager2.isItemClass then
		return ItemManager2.isItemClass(sClass);
	end
	
	return false;
end

function getIDState(nodeRecord, bIgnoreHost)
	if ItemManager2 and ItemManager2.getIDState then
		return ItemManager2.getIDState(nodeRecord, bIgnoreHost);
	end
	
	local bID = true;
	local bOptionID = OptionsManager.isOption("MIID", "on");
	if bOptionID and (bIgnoreHost or not User.isHost()) then
		bID = (DB.getValue(nodeRecord, "isidentified", 0) == 1);
	end
	
	return bID, bOptionID;
end

function getDisplayName(nodeItem, bIgnoreHost)
	local bID = getIDState(nodeItem, bIgnoreHost);
	if bID then
		return DB.getValue(nodeItem, "name", "");
	end
	
	local sName = DB.getValue(nodeItem, "nonid_name", "");
	if sName == "" then
		sName = Interface.getString("item_unidentified");
	end
	return sName;
end

function getSortName(nodeItem)
	local sName = getDisplayName(nodeItem);
	return sName:lower();
end

function handleDrop(nodeList, draginfo, bTransferAll)
	if draginfo.isType("shortcut") then
		local sClass,sRecord = draginfo.getShortcutData();
		if isItemClass(sClass) then
			notifyTransfer(nodeList.getNodeName(), sClass, sRecord, bTransferAll);
			return true;
		end
	end
	
	return nil;
end

function getItemSourceType(vNode)
	local sType = "";
	local nodeTemp = nil;
	if type(vNode) == "databasenode" then
		nodeTemp = vNode;
	elseif type(vNode) == "string" then
		nodeTemp = DB.findNode(vNode);
	end
	while nodeTemp do
		sType = nodeTemp.getName();
		nodeTemp = nodeTemp.getParent();
	end
	return sType;
end

function compareFields(node1, node2, bTop)
	if node1 == node2 then
		return false;
	end
	
	local bOptionID = OptionsManager.isOption("MIID", "on");
	
	for _,vChild1 in pairs(node1.getChildren()) do
		local sName = vChild1.getName();
		if bTop and StringManager.contains(aDeleteCopyFields, sName) then
			-- SKIP
		elseif bTop and not bOptionID and sName == "isidentified" then
			-- SKIP
		else
			local sType = vChild1.getType();
			local vChild2 = node2.getChild(sName);
			if vChild2 then
				if sType ~= vChild2.getType() then
					return false;
				end
				
				if sType == "node" then
					if not compareFields(vChild1, vChild2, false) then
						return false;
					end
				else
					if vChild1.getValue() ~= vChild2.getValue() then
						return false;
					end
				end
			else
				if sType == "number" and vChild1.getValue() == 0 then
					-- DEFAULT MATCH
				elseif sType == "string" and vChild1.getValue() == "" then
					-- DEFAULT MATCH
				else
					return false;
				end
			end
			
		end
	end
	
	return true;
end

-- NOTE: Assumed target and source base nodes 
-- (item = campaign, charsheet = char inventory, partysheet = party inventory, treasureparcels = parcel inventory)
function addItemToList(vList, sClass, vSource, bTransferAll, nTransferCount)
	-- Get the source item database node object
	local nodeSource = nil;
	if type(vSource) == "databasenode" then
		nodeSource = vSource;
	elseif type(vSource) == "string" then
		nodeSource = DB.findNode(vSource);
	end
	local nodeList = nil;
	if type(vList) == "databasenode" then
		nodeList = vList;
	elseif type(vList) == "string" then
		nodeList = DB.createNode(vList);
	end
	if not nodeSource or not nodeList then
		return nil;
	end
	
	-- Determine the source and target item location type
	local sSourceRecordType = getItemSourceType(nodeSource);
	local sTargetRecordType = getItemSourceType(nodeList);
	
	-- Make sure that the source and target locations are not the same character
	if sSourceRecordType == "charsheet" and sTargetRecordType == "charsheet" then
		if nodeSource.getParent().getNodeName() == nodeList.getNodeName() then
			return nil;
		end
	end
	
	-- Use a temporary location to create an item copy for manipulation, if the item type is supported
	local sTempPath;
	if nodeList.getParent() then
		sTempPath = nodeList.getParent().getPath("temp.item");
	else
		sTempPath = "temp.item";
	end
	DB.deleteNode(sTempPath);
	local nodeTemp = DB.createNode(sTempPath);
	local bCopy = false;
	if sClass == "item" then
		local bID = getIDState(nodeSource, true);
		DB.copyNode(nodeSource, nodeTemp);
		if bID then
			DB.setValue(nodeTemp, "isidentified", "number", 1);
		end
		bCopy = true;
	elseif ItemManager2 and ItemManager2.addItemToList2 then
		bCopy = ItemManager2.addItemToList2(sClass, nodeSource, nodeTemp, nodeList);
	end
	
	local nodeNew = nil;
	if bCopy then
		-- Remove fields that shouldn't be transferred
		for _,sField in ipairs(aDeleteCopyFields) do
			DB.deleteChild(nodeTemp, sField);
		end
		
		-- Determine target node for source item data.  
		-- If we already have an item with the same fields, then just append the item count.  
		-- Otherwise, create a new item and copy from the source item.
		local bAppend = false;
		if sTargetRecordType ~= "item" then
			for _,vItem in pairs(DB.getChildren(nodeList, "")) do
				if compareFields(vItem, nodeTemp, true) then
					nodeNew = vItem;
					bAppend = true;
					break;
				end
			end
		end
		if not nodeNew then
			nodeNew = DB.createChild(nodeList);
			DB.copyNode(nodeTemp, nodeNew);
		end
		
		-- Determine the source, target and item names
		local sSrcName, sTrgtName;
		if sSourceRecordType == "charsheet" then
			sSrcName = DB.getValue(nodeSource, "...name", "");
		elseif sSourceRecordType == "partysheet" then
			sSrcName = "PARTY";
		else
			sSrcName = "";
		end
		if sTargetRecordType == "charsheet" then
			sTrgtName = DB.getValue(nodeNew, "...name", "");
		elseif sTargetRecordType == "partysheet" then
			sTrgtName = "PARTY";
		else
			sTrgtName = "";
		end
		local sItemName = getDisplayName(nodeNew, true);
		
		-- Determine whether to copy all items at once or just one item at a time (based on source and target)
		local bCountN = false;
		if (sSourceRecordType == "treasureparcels" and sTargetRecordType == "partysheet") or
				(sSourceRecordType == "partysheet" and sTargetRecordType == "treasureparcels") or 
				(sSourceRecordType == "treasureparcels" and sTargetRecordType == "treasureparcels") then
			bCountN = true;
		elseif (sSourceRecordType == "partysheet" and sTargetRecordType == "charsheet") or
				(sSourceRecordType == "charsheet" and sTargetRecordType == "charsheet") or
				(sSourceRecordType == "charsheet" and sTargetRecordType == "partysheet") then
			if bTransferAll then
				bCountN = true;
			end
		end
		local nCount = 1;
		if bCountN or sTargetRecordType ~= "item" then
			if bCountN then
				nCount = DB.getValue(nodeSource, "count", 1);
			elseif nTransferCount then
				nCount = math.min(DB.getValue(nodeSource, "count", 1), nTransferCount);
			end
			if bAppend then
				local nAppendCount = math.max(DB.getValue(nodeNew, "count", 1), 1);
				DB.setValue(nodeNew, "count", "number", nCount + nAppendCount);
			else
				DB.setValue(nodeNew, "count", "number", nCount);
			end
		end
		
		-- If not adding to an existing record, then lock the new record and generate events
		if not bAppend then
			DB.setValue(nodeNew, "locked", "number", 1);
			if sTargetRecordType == "charsheet" then
				onCharAddEvent(nodeNew);
			end
		end

		-- Generate output message if transferring between characters or between party sheet and character
		if sSourceRecordType == "charsheet" and (sTargetRecordType == "partysheet" or sTargetRecordType == "charsheet") then
			local msg = {font = "msgfont", icon = "coins"};
			msg.text = "[" .. sSrcName .. "] -> [" .. sTrgtName .. "] : " .. sItemName;
			if nCount > 1 then
				msg.text = msg.text .. " (" .. nCount .. "x)";
			end
			Comm.deliverChatMessage(msg);

			local nCharCount = DB.getValue(nodeSource, "count", 0);
			if nCharCount <= nCount then
				onCharRemoveEvent(nodeSource);
				nodeSource.delete();
			else
				DB.setValue(nodeSource, "count", "number", nCharCount - nCount);
			end
		elseif sSourceRecordType == "partysheet" and sTargetRecordType == "charsheet" then
			local msg = {font = "msgfont", icon = "coins"};
			msg.text = "[" .. sSrcName .. "] -> [" .. sTrgtName .. "] : " .. sItemName;
			if nCount > 1 then
				msg.text = msg.text .. " (" .. nCount .. "x)";
			end
			Comm.deliverChatMessage(msg);

			local nPartyCount = DB.getValue(nodeSource, "count", 0);
			if nPartyCount <= nCount then
				nodeSource.delete();
			else
				DB.setValue(nodeSource, "count", "number", nPartyCount - nCount);
			end
		end
	end
	
	-- Clean up
	DB.deleteNode(sTempPath);

	return nodeNew;
end
