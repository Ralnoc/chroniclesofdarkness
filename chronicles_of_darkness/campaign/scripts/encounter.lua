-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onLockChanged();
	DB.addHandler(DB.getPath(getDatabaseNode(), "locked"), "onUpdate", onLockChanged);
end

function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "locked"), "onUpdate", onLockChanged);
end

function onLockChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	
	if bReadOnly then
		npcs_iedit.setValue(0);
	end
	npcs_iedit.setVisible(not bReadOnly);

	npcs.setReadOnly(bReadOnly);
	for _,w in pairs(npcs.getWindows()) do
		w.count.setReadOnly(bReadOnly);
		w.token.setReadOnly(bReadOnly);
		w.name.setReadOnly(bReadOnly);
	end
end
