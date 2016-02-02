-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if User.isHost() and GameSystem.currencies then
		if coins.getWindowCount() == 0 then
			local nCoinTypes = #(GameSystem.currencies);
			for i = 1, #(GameSystem.currencies) do
				local w = coins.createWindow();
				w.description.setValue(GameSystem.currencies[i]);
			end
		end
	end
	
	OptionsManager.registerCallback("MIID", StateChanged);

	onLockChanged();
	DB.addHandler(DB.getPath(getDatabaseNode(), "locked"), "onUpdate", onLockChanged);
end

function onClose()
	OptionsManager.unregisterCallback("MIID", StateChanged);

	DB.removeHandler(DB.getPath(getDatabaseNode(), "locked"), "onUpdate", onLockChanged);
end

function StateChanged()
	for _,w in ipairs(items.getWindows()) do
		w.onIDChanged();
	end
	items.applySort();
end

function onDrop(x, y, draginfo)
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	if bReadOnly then
		return;
	end
	
	if draginfo.isType("number") then
		local w = coins.addEntry(true);
		if w then
			w.description.setValue(draginfo.getDescription());
			w.amount.setValue(draginfo.getNumberData());
			onLockChanged();
		end
		return true;

	elseif draginfo.isType("shortcut") then
		if ItemManager.handleDrop(items.getDatabaseNode(), draginfo) then
			onLockChanged();
		end
		return true;
	end
end

function onLockChanged()
	if header.subwindow then
		header.subwindow.update();
	end

	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	
	if bReadOnly then
		coins_iedit.setValue(0);
		items_iedit.setValue(0);
	end
	coins_iedit.setVisible(not bReadOnly);
	items_iedit.setVisible(not bReadOnly);

	coins.setReadOnly(bReadOnly);
	for _,w in pairs(coins.getWindows()) do
		w.amount.setReadOnly(bReadOnly);
		w.description.setReadOnly(bReadOnly);
	end

	items.setReadOnly(bReadOnly);
	for _,w in pairs(items.getWindows()) do
		if w.count then
			w.count.setReadOnly(bReadOnly);
		end
		w.name.setReadOnly(bReadOnly);
		w.nonid_name.setReadOnly(bReadOnly);
	end
end
