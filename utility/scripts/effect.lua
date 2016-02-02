-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function actionDrag(draginfo)
	local rEffect = EffectManager.getEffect(getDatabaseNode());
	return ActionEffect.performRoll(draginfo, nil, rEffect);
end

function action()
	local rEffect = EffectManager.getEffect(getDatabaseNode());
	local rRoll = ActionEffect.getRoll(nil, nil, rEffect);
	if not rRoll then
		return true;
	end
	
	rRoll.sType = "effect";

	local rTarget = nil;
	if User.isHost() then
		rTarget = ActorManager.getActorFromCT(CombatManager.getActiveCT());
	else
		rTarget = ActorManager.getActor("pc", CombatManager.getCTFromNode("charsheet." .. User.getCurrentIdentity()));
	end
	
	ActionsManager.resolveAction(nil, rTarget, rRoll);
	return true;
end

function onGainFocus()
	window.setFrame("rowshade");
end

function onLoseFocus()
	window.setFrame(nil);
end
