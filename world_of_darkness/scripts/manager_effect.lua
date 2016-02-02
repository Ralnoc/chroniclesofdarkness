-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYEFF = "applyeff";

local nLocked = 0;

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYEFF, handleApplyEffect);
end

function handleApplyEffect(msgOOB)
	-- Get the combat tracker node
	local nodeCTEntry = DB.findNode(msgOOB.sTargetNode);
	if not nodeCTEntry then
		ChatManager.SystemMessage(Interface.getString("ct_error_effectapplyfail") .. " (" .. msgOOB.sTargetNode .. ")");
		return;
	end
	
	-- Reconstitute the effect details
	local rEffect = {};
	rEffect.sName = msgOOB.sName;
	rEffect.nGMOnly = tonumber(msgOOB.nGMOnly) or 0;
	
	-- Apply the damage
	addEffect(msgOOB.user, msgOOB.identity, nodeCTEntry, rEffect, true);
end

function notifyApply(rEffect, vTargets)
	-- Build OOB message to pass effect to host
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYEFF;
	if User.isHost() then
		msgOOB.user = "";
	else
		msgOOB.user = User.getUsername();
	end
	msgOOB.identity = User.getIdentityLabel();

	msgOOB.sName = rEffect.sName or "";
	msgOOB.nGMOnly = rEffect.nGMOnly or 0; 

	-- Send one message for each target
	if type(vTargets) == "table" then
		for _, v in pairs(vTargets) do
			msgOOB.sTargetNode = v;
			Comm.deliverOOBMessage(msgOOB, "");
		end
	else
		msgOOB.sTargetNode = vTargets;
		Comm.deliverOOBMessage(msgOOB, "");
	end
end

function setEffect(nodeEffect, rEffect)
	DB.setValue(nodeEffect, "label", "string", rEffect.sName);
	DB.setValue(nodeEffect, "isgmonly", "number", rEffect.nGMOnly);
end

function getEffect(nodeEffect)
	return { 
			sName = DB.getValue(nodeEffect, "label", ""), 
			nGMOnly = DB.getValue(nodeEffect, "isgmonly", 0)
			};
end

--
-- EFFECTS
--

function message(sMsg, nodeCTEntry, gmflag, sUser)
	-- ADD NAME OF CT ENTRY TO NOTIFICATION
	if nodeCTEntry then
		sMsg = sMsg .. " [on " .. DB.getValue(nodeCTEntry, "name", "") .. "]";
	end

	-- BUILD MESSAGE OBJECT
	local msg = {font = "msgfont", icon = "roll_effect", text = sMsg};
	
	-- DELIVER MESSAGE BASED ON TARGET AND GMFLAG
	if sUser then
		if sUser == "" then
			Comm.addChatMessage(msg);
		else
			Comm.deliverChatMessage(msg, sUser);
		end
	elseif gmflag then
		msg.secret = true;
		if User.isHost() then
			Comm.addChatMessage(msg);
		else
			Comm.deliverChatMessage(msg, User.getUsername());
		end
	else
		Comm.deliverChatMessage(msg);
	end
end

function getEffectsString(nodeCTEntry, bPublicOnly)
	-- Start with an empty effects list string
	local aOutputEffects = {};
	
	-- Iterate through each effect
	local aSorted = {};
	for _,nodeChild in pairs(DB.getChildren(nodeCTEntry, "effects")) do
		table.insert(aSorted, nodeChild);
	end
	table.sort(aSorted, function (a, b) return a.getName() < b.getName() end);
	for _,v in pairs(aSorted) do
		local sLabel = DB.getValue(v, "label", "");

		local bAddEffect = true;
		local bGMOnly = false;
		if sLabel == "" then
			bAddEffect = false;
		elseif DB.getValue(v, "isgmonly", 0) == 1 then
			if User.isHost() and not bPublicOnly then
				bGMOnly = true;
			else
				bAddEffect = false;
			end
		end

		if bAddEffect then
			local sOutputLabel = sLabel;
			if bGMOnly then
				sOutputLabel = "(" .. sOutputLabel .. ")";
			end

			table.insert(aOutputEffects, sOutputLabel);
		end
	end
	
	-- Return the final effect list string
	return table.concat(aOutputEffects, " | ");
end

function isGMEffect(nodeActor, nodeEffect)
	if nodeEffect and (DB.getValue(nodeEffect, "isgmonly", 0) == 1) then
		return true;
	end
	if nodeActor and CombatManager.isCTHidden(nodeActor) then
		return true;
	end
	return false;
end

function addEffect(sUser, sIdentity, nodeCT, rNewEffect, bShowMsg)
	-- VALIDATE
	if not nodeCT or not rNewEffect or not rNewEffect.sName then
		return;
	end
	
	-- GET EFFECTS LIST
	local nodeEffectsList = nodeCT.createChild("effects");
	if not nodeEffectsList then
		return;
	end
	
	-- CHECKS TO IGNORE NEW EFFECT (DUPLICATE)
	for k, v in pairs(nodeEffectsList.getChildren()) do
		-- CHECK FOR DUPLICATE EFFECT
		if (DB.getValue(v, "label", "") == rNewEffect.sName) then
			local sMsg = "Effect ['" .. rNewEffect.sName .. "'] ";
			sMsg = sMsg .. "-> [ALREADY EXISTS]";
			message(sMsg, nodeCT, false, sUser);
			return;
		end
	end
	
	-- WRITE EFFECT RECORD
	local nodeTargetEffect = nodeEffectsList.createChild();
	DB.setValue(nodeTargetEffect, "label", "string", rNewEffect.sName);
	DB.setValue(nodeTargetEffect, "isgmonly", "number", rNewEffect.nGMOnly);

	-- BUILD MESSAGE
	local msg = {font = "msgfont", icon = "roll_effect"};
	msg.text = "Effect ['" .. rNewEffect.sName .. "'] ";
	msg.text = msg.text .. "-> [to " .. DB.getValue(nodeCT, "name", "") .. "]";
	
	-- SEND MESSAGE
	if bShowMsg then
		if isGMEffect(nodeCT, nodeTargetEffect) then
			if sUser == "" then
				msg.secret = true;
				Comm.addChatMessage(msg);
			elseif sUser ~= "" then
				Comm.addChatMessage(msg);
				Comm.deliverChatMessage(msg, sUser);
			end
		else
			Comm.deliverChatMessage(msg);
		end
	end
end

--
--  HANDLE EFFECT LOCKING
--

function lock()
	nLocked = nLocked + 1;
end

function unlock()
	nLocked = nLocked - 1;
	if nLocked < 0 then
		nLocked = 0;
	end

	if nLocked == 0 then
	end
end
