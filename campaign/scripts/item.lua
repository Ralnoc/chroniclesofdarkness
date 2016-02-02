-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onLockChanged();

	OptionsManager.registerCallback("MIID", StateChanged);

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "locked"), "onUpdate", onLockChanged);
	DB.addHandler(DB.getPath(node, "isidentified"), "onUpdate", onIDChanged);
end

function onClose()
	OptionsManager.unregisterCallback("MIID", StateChanged);

	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "locked"), "onUpdate", onLockChanged);
	DB.removeHandler(DB.getPath(node, "isidentified"), "onUpdate", onIDChanged);
end

function onLockChanged()
	StateChanged();
end

function onIDChanged()
	StateChanged();
end

function StateChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	if main.subwindow then
		main.subwindow.update();
	end
end
