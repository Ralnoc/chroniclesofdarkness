-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	Comm.registerSlashHandler("rollon", processTableRoll);
	ActionsManager.registerResultHandler("table", onTableRoll);
end

function prepareTableDice(rRoll)
	local aFinalDice = {};
	
	local aNonStandardResults = {};
	for _,v in ipairs(rRoll.aDice) do
		if StringManager.contains(Interface.getDice(), v) then
			table.insert(aFinalDice, v);
		else
			local sDieSides = v:match("^[dD]([%dF]+)");
			if sDieSides then
				local nResult;
				if sDieSides == "F" then
					local nRandom = math.random(3);
					if nRandom == 1 then
						nResult = -1;
					elseif nRandom == 3 then
						nResult = 1;
					end
				else
					local nDieSides = tonumber(sDieSides) or 0;
					nResult = math.random(nDieSides);
				end
				rRoll.nMod = rRoll.nMod + nResult;
				table.insert(aNonStandardResults, string.format(" [%s=%d]", v, nResult));
			end
		end
	end
	
	rRoll.aDice = aFinalDice;
	if #aNonStandardResults > 0 then
		rRoll.sDesc = rRoll.sDesc .. table.concat(aNonStandardResults, "");
	end
end

function performRoll(draginfo, rActor, rTableRoll, bUseModStack)
	-- If dice or modifier not provided, then use the right one for this table
	if (not rTableRoll.aDice or #rTableRoll.aDice == 0) and not rTableRoll.nMod then
		rTableRoll.aDice, rTableRoll.nMod = getTableDice(rTableRoll.nodeTable);
	end

	local rRoll = {};
	rRoll.sType = "table";
	rRoll.sDesc = "[" .. Interface.getString("table_tag") .. "] " .. DB.getValue(rTableRoll.nodeTable, "name", "");
	if rTableRoll.nColumn and rTableRoll.nColumn > 0 then
		rRoll.sDesc = rRoll.sDesc .. " [" .. rTableRoll.nColumn .. " - " .. DB.getValue(rTableRoll.nodeTable, "labelcol" .. rTableRoll.nColumn) .. "]";
	end
	rRoll.sNodeTable = rTableRoll.nodeTable.getNodeName();

	rRoll.aDice = rTableRoll.aDice;
	rRoll.nMod = rTableRoll.nMod;
	prepareTableDice(rRoll);
	
	if rTableRoll.bSecret then
		rRoll.bSecret = rTableRoll.bSecret;
	elseif User.isHost() then
		rRoll.bSecret = (DB.getValue(rTableRoll.nodeTable, "hiderollresults", 0) == 1);
	end
	
	-- Add modifier stack
	if bUseModStack and not ModifierStack.isEmpty() then
		local sStackDesc, nStackMod = ModifierStack.getStack(true);
		rRoll.sDesc = rRoll.sDesc .. " [" .. sStackDesc .. "]";
		rRoll.nMod = rRoll.nMod + nStackMod;
	end
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

-- Determine die to roll for this table
function getTableDice(nodeTable)
	local aDice = DB.getValue(nodeTable, "dice", {});
	local nMod = 0;
	
	if #aDice == 0 then
		local nMax = 0;
		for _,v in pairs(DB.getChildren(nodeTable, "tablerows")) do
			local nEnd = DB.getValue(v, "torange", 0);
			if nEnd == 0 then
				nEnd = DB.getValue(v, "fromrange", 0);
			end
			nMax = math.max(nEnd, nMax);
		end
		
		if nMax == 2 then
			table.insert(aDice, "d2");
		elseif nMax == 3 then
			table.insert(aDice, "d3");
		elseif nMax == 4 then
			table.insert(aDice, "d4");
		elseif nMax == 6 then
			table.insert(aDice, "d6");
		elseif nMax == 8 then
			table.insert(aDice, "d8");
		elseif nMax == 10 then
			table.insert(aDice, "d10");
		elseif nMax == 12 then
			table.insert(aDice, "d12");
		elseif nMax == 20 then
			table.insert(aDice, "d20");
		elseif nMax == 100 then
			table.insert(aDice, "d100");
			table.insert(aDice, "d10");
		elseif nMax > 0 then
			table.insert(aDice, "d" .. nMax);
		end
		nMod = nMod + DB.getValue(nodeTable, "mod", 0);
	else
		nMod = DB.getValue(nodeTable, "mod", 0);
	end
	
	return aDice, nMod;
end

function findTableInDB(nodeRoot, sTable)
	for _,v in pairs(DB.getChildren(nodeRoot, "tables")) do
		if StringManager.trim(DB.getValue(v, "name", "")) == sTable then
			return v;
		end
	end
	
	return nil;
end

function findTable(sTable)
	local sFind = StringManager.trim(sTable);
	
	local nodeTable = findTableInDB(DB.getRoot(), sFind);
	if not nodeTable then
		local aModules = Module.getModules();
		for _,v in ipairs(aModules) do
			nodeTable = findTableInDB(DB.getRoot(v), sFind);
			if nodeTable then
				break;
			end
		end
	end
	
	return nodeTable;
end

function findColumn(nodeTable, sColumn)
	local nResultColumn = 0;

	if sColumn and sColumn ~= "" then
		local sFind = StringManager.trim(sColumn);
		local nColumns = DB.getValue(nodeTable, "resultscols", 0);
		for i = 1, nColumns do
			if StringManager.trim(DB.getValue(nodeTable, "labelcol" .. i, "")) == sFind then
				nResultColumn = i;
				break;
			end
		end
	end
	
	return nResultColumn;
end

function getResults(nodeTable, nTotal, nColumn)
	local nodeResults = nil;
	local nMin, nMax; 
	local nodeMin, nodeMax;
	for _,v in pairs(DB.getChildren(nodeTable, "tablerows")) do
		local nFrom = DB.getValue(v, "fromrange", 0);
		local nTo = DB.getValue(v, "torange", 0);
		if nTo == 0 then
			nTo = nFrom;
		end
		if (nTotal >= nFrom) and (nTotal <= nTo) then
			nodeResults = v.getChild("results");
			break;
		end
		if not nMin or nFrom < nMin then 
			nMin = nFrom;
			nodeMin = v.getChild("results");
		end
		if not nMax or nTo > nMax then
			nMax = nFrom;
			nodeMax = v.getChild("results");
		end
	end
	if not nodeResults then
		if nMin and nTotal < nMin then
			nodeResults = nodeMin;
		elseif nMax and nTotal > nMax then
			nodeResults = nodeMax;
		end
	end
	if not nodeResults then
		return nil;
	end
	
	local aChildren = nodeResults.getChildren();
	local aKeys = {};
	for k,_ in pairs(aChildren) do
		table.insert(aKeys, k);
	end
	table.sort(aKeys);
	
	local aResults = {};
	if nColumn > 0 then
		if not aKeys[nColumn] then
			return nil;
		end
		local rResult = {};
		rResult.sText = DB.getValue(aChildren[aKeys[nColumn]], "result", "");
		rResult.sClass, rResult.sRecord = DB.getValue(aChildren[aKeys[nColumn]], "resultlink");
		table.insert(aResults, rResult);
	else
		for k = 1, #aKeys do
			local rResult = {};
			rResult.sText = DB.getValue(aChildren[aKeys[k]], "result", "");
			rResult.sClass, rResult.sRecord = DB.getValue(aChildren[aKeys[k]], "resultlink");
			table.insert(aResults, rResult);
		end
	end
	
	return aResults;
end

function onTableRoll(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	local nTotal = ActionsManager.total(rRoll);
	
	local nodeTable = DB.findNode(rRoll.sNodeTable);
	if not nodeTable then
		rMessage.text = rMessage.text .. " = [" .. Interface.getString("table_error_tablematch") .. "]";
		Comm.addChatMessage(rMessage);
		return;
	end
	
	local nColumn = 0;
	local sPattern2 = "%[" .. Interface.getString("table_tag") .. "%] [^[]+%[(%d) %- ([^)]*)%]";
	local sColumn = string.match(rRoll.sDesc, sPattern2)
	if sColumn then
		nColumn = tonumber(sColumn) or 0;
	end
	
	local aResults = getResults(nodeTable, nTotal, nColumn);
	if not aResults then
		rMessage.text = rMessage.text .. " = [" .. Interface.getString("table_error_columnmatch") .. "]";
		Comm.addChatMessage(rMessage);
		return;
	end
	
	rMessage.shortcuts = {};
	local aResultText = {};
	local aCascade = {};
	
	for _,v in ipairs(aResults) do
		local nFirstMultiple = nil;
		local nMultiple = 1;
		if v.sText ~= "" then
			local sResult = v.sText;
			
			local sTag;
			local aMathResults = {};
			for nStartTag, sTag, nEndTag in v.sText:gmatch("()%[([^%]]+)%]()") do
				local bMult = false;
				local sPotentialRoll = sTag;
				if sPotentialRoll:match("x$") then
					sPotentialRoll = sPotentialRoll:sub(1, -2);
					bMult = true;
				end
				if StringManager.isDiceMathString(sPotentialRoll) then
					local nMathResult = StringManager.evalDiceMathExpression(sPotentialRoll);
					if bMult then
						nMultiple = nMathResult;
						if not nFirstMultiple then
							nFirstMultiple = nMultiple;
						end
						table.insert(aMathResults, { nStart = nStartTag, nEnd = nEndTag, vResult = "[" .. nMathResult .. "x]" });
					else
						table.insert(aMathResults, { nStart = nStartTag, nEnd = nEndTag, vResult = nMathResult });
					end
				else
					local nodeTable = findTable(sTag);
					if nodeTable then
						table.insert(aCascade, { link = nodeTable, mult = nMultiple });
					end
				end
			end
			for i = #aMathResults,1,-1 do
				sResult = sResult:sub(1, aMathResults[i].nStart - 1) .. aMathResults[i].vResult .. sResult:sub(aMathResults[i].nEnd);
			end
			
			table.insert(aResultText, sResult);
		end
		if v.sClass and v.sClass ~= "" then
			if v.sClass == "table" then
				nMultiple = math.max(nFirstMultiple or 1, 1);
				table.insert(aCascade, { link = DB.findNode(v.sRecord), mult = nMultiple });
			else
				table.insert(rMessage.shortcuts, { description = v.sText, class = v.sClass, recordname = v.sRecord });
			end
		end
	end
	local sResult = table.concat(aResultText, ", ");
	rMessage.text = rMessage.text .. " = " .. sResult;
	
	if rMessage.secret then
		Comm.addChatMessage(rMessage);
	else
		Comm.deliverChatMessage(rMessage);
	end

	for _,vCascade in ipairs(aCascade) do
		for i = 1, vCascade.mult do
			local rTableRoll = {};
			rTableRoll.nodeTable = vCascade.link;
			rTableRoll.bSecret = rRoll.bSecret;
			
			performRoll(nil, rSource, rTableRoll, false);
		end
	end
end

function processTableRoll(sCommand, sParams)
	local bError = false;
	local sFlag = "";
	local aTableName = {};
	local aColumnName = {};
	local aDiceString = {};
	local bHide = false;

	local aWords = StringManager.parseWords(sParams, "%(%)%[%]:");
	for k = 1, #aWords do
		if aWords[k] == "-c" or aWords[k] == "-d" then
			sFlag = aWords[k];
		elseif aWords[k] == "-hide" then
			sFlag = aWords[k];
			bHide = true;
		elseif aWords[k]:sub(1,1) == "-" then
			bError = true;
			break;
		else
			if sFlag == "" then
				table.insert(aTableName, aWords[k]);
			elseif sFlag == "-c" then
				table.insert(aColumnName, aWords[k]);
			elseif sFlag == "-d" then
				table.insert(aDiceString, aWords[k]);
			elseif sFlag == "-hide" then
				bError = true;
				break;
			end
		end
	end
	
	local sTable = table.concat(aTableName, " ");
	
	if bError or not sTable or sTable == "" then
		ChatManager.SystemMessage("Usage: /rollon tablename -c [column name] [-d dice] [-hide]");
		return;
	end
	

	local nodeTable = findTable(sTable);
	if not nodeTable then
		ChatManager.SystemMessage(Interface.getString("table_error_lookupfail") .. " (" .. sTable .. ")");
		return;
	end
	
	local rTableRoll = {};
	rTableRoll.nodeTable = nodeTable;
	if bHide then
		rTableRoll.bSecret = true;
	end
	
	rTableRoll.nColumn = findColumn(nodeTable, table.concat(aColumnName, " "));
	
	if #aDiceString > 0 then
		local sDice = table.concat(aDiceString, "");
		rTableRoll.aDice, rTableRoll.nMod = StringManager.convertStringToDice(sDice);
	else
		rTableRoll.aDice, rTableRoll.nMod = getTableDice(nodeTable);
	end
	
	performRoll(nil, nil, rTableRoll, false);
end

function createTable(nRows, nStep, bSpecial)
	local nodeTables = DB.createNode("tables");
	local nodeNewTable = nodeTables.createChild();
	local nodeTableRows = nodeNewTable.createChild("tablerows");
	
	if bSpecial then
		local nFrom = 0;
		local nTo = 0;
		
		for i = 1, nRows do
			local nodeRow = nodeTableRows.createChild();

			if i == 1 then
				nFrom = 1;
				nTo = 1;
			elseif i == nRows then
				nFrom = nTo + 1;
				nTo = nFrom;
			else
				if i == 2 then
					nFrom = (i * tonumber(nStep));
				else
					nFrom = nTo + 1;
				end
				nTo = nFrom + 1;
			end
			
			DB.setValue(nodeRow, "fromrange", "number", nFrom);
			DB.setValue(nodeRow, "torange", "number", nTo);
		end
	else
		for i = 1, nRows do
			local nodeRow = nodeTableRows.createChild();
			
			local nFrom = i;
			if nFrom ~= 1 then
				nFrom = (i * tonumber(nStep) + 1) - tonumber(nStep);
			end
			local nTo = i * tonumber(nStep);

			DB.setValue(nodeRow, "fromrange", "number", nFrom);
			DB.setValue(nodeRow, "torange", "number", nTo);
		end
	end
	
	Interface.openWindow("table", nodeNewTable);
end
