-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Export structures
local aProperties = {};
local aNodes = {};
local aTokens = {};

function getIndexState(window)
	if window and window.index and window.index.getValue() == 1 then
		return true;
	else
		return false;
	end
end

function addExportNode(node, sExportClass, sExportLabel)
	-- Create node entry
	local nodeentrytable = {};
	
	nodeentrytable.import = node.getNodeName();
	if node.getCategory() then
		nodeentrytable.category = node.getCategory();
		nodeentrytable.category.mergeid = aProperties.mergeid;
	end
	
	aNodes[node.getNodeName()] = nodeentrytable;
	
	-- Create library index
	local sLibraryNode = "library." .. aProperties.namecompact;
	if not aNodes[sLibraryNode] then
		local aLibraryIndex = {};
		aLibraryIndex.createstring = { name = aProperties.namecompact, categoryname = aProperties.category };
		aLibraryIndex.static = true;
		
		aNodes[sLibraryNode] = aLibraryIndex;
	end
	
	-- Create library entry and class list index
	local sLibraryEntry = sLibraryNode .. ".entries." .. sExportClass;
	local sClassList = "lists." .. sExportClass;
	if not aNodes[sLibraryEntry] then
		local aLibraryEntry = {};
		aLibraryEntry.createstring = { name = sExportLabel };
		aLibraryEntry.createlink = { librarylink = { class = "referenceindexsorted", recordname = sClassList } };
		
		aNodes[sLibraryEntry] = aLibraryEntry;
	end
	if not aNodes[sClassList] then
		local aClassList = {};
		aClassList.createstring = { name = sExportLabel };
		
		aNodes[sClassList] = aClassList;
	end
	
	-- Create class list entry
	local sClassEntry = sClassList .. ".index." .. node.getName();
	
	local aClassEntry = {};
	aClassEntry.createlink = { listlink = { class = sExportClass, recordname = node.getNodeName() } };
	aClassEntry.createstring = { name = DB.getValue(node, "name", "") };
	
	aNodes[sClassEntry] = aClassEntry;
end

function performExport()
	-- Reset data
	aProperties = {};
	aNodes = {};
	aTokens = {};

	-- Global properties
	aProperties.name = name.getValue();
	aProperties.namecompact = string.lower(string.gsub(aProperties.name, "%W", ""));
	aProperties.category = category.getValue();
	aProperties.file = file.getValue();
	aProperties.author = author.getValue();
	aProperties.thumbnail = thumbnail.getValue();
	aProperties.mergeid = mergeid.getValue();

	-- Pre checks
	if aProperties.name == "" then
		ChatManager.SystemMessage(Interface.getString("export_error_name"));
		name.setFocus(true);
		return;
	end
	if aProperties.file == "" then
		ChatManager.SystemMessage(Interface.getString("export_error_file"));
		file.setFocus(true);
		return;
	end
	
	-- Loop through categories
	for _, cw in ipairs(list.getWindows()) do
		-- Construct export lists
		if cw.all.getValue() == 1 then
			-- Add all child nodes
			local sourcenode = DB.findNode(cw.exportsource);
			if sourcenode then
				for _, nv in pairs(sourcenode.getChildren()) do
					if nv.getType() == "node" then
						addExportNode(nv, cw.exportclass, cw.label.getValue());
					end
				end
			end
		else
			-- Loop through entries in category
			for _, ew in ipairs(cw.entries.getWindows()) do
				addExportNode(ew.getDatabaseNode(), cw.exportclass, cw.label.getValue());
			end
		end
	end
	
	-- Tokens
	for _, tw in ipairs(tokens.getWindows()) do
		table.insert(aTokens, tw.token.getPrototype());
	end
	
	-- Export
	local bRet = Module.export(aProperties.name, aProperties.category, aProperties.author, aProperties.file, aProperties.thumbnail,	aNodes, aTokens);
	
	if bRet then
		ChatManager.SystemMessage(Interface.getString("export_message_success"));
	else
		ChatManager.SystemMessage(Interface.getString("export_message_failure"));
	end
end
