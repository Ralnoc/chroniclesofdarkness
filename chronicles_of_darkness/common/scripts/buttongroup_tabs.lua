-- Please see the license.html file included with this distribution for
-- attribution and copyright information.

-- TODO: Integrate this code into the buttongroup_tabs code so that ruleset can dynamically control charsheet tabs
local topWidget = nil;
local tabIndex = 1;
local tabWidgets = {};
local tabs = {};

function addTab(subwindow,icon,scroller)
	local index = #tabs + 1;
	local newtab = {};
	newtab.subwindow = subwindow;
	newtab.icon = icon;
	newtab.scroller = scroller;
	tabs[index] = newtab;
	if icon then
		tabWidgets[index] = addBitmapWidget(icon);
	end
	update();
end

function activateTab(index)
	local thistab;
	index = tonumber(index);
	if index<1 or index>#tabs then
		return;
	end

	-- Hide active tab, fade text labels
	thistab = tabs[tabIndex]
	if tabWidgets[tabIndex] then
		tabWidgets[tabIndex].setColor("80ffffff");
	end
	if window[thistab.subwindow] then
		window[thistab.subwindow].setVisible(false);
	end
	if thistab.scroller then
		window[thistab.scroller].setVisible(false);
	end

	-- Set new index
	tabIndex = index;
	thistab = tabs[tabIndex];

	-- Move helper graphic into position
	topWidget.setPosition("topleft", 8, 67*(tabIndex-1)+7);
	if tabIndex == 1 then
		topWidget.setVisible(false);
	else
		topWidget.setVisible(true);
	end

	-- Activate text label and subwindow
	if tabWidgets[tabIndex] then
		tabWidgets[tabIndex].setColor("ffffffff");
	end
	if window[thistab.subwindow] then
		window[thistab.subwindow].setVisible(true);
	end
	if thistab.scroller then
		window[thistab.scroller].setVisible(true);
	end

	-- Call the onActivate handler, if present
	if self.onActivate then
		self.onActivate(index);
	end

	-- Done
end

function onClickDown(button, x, y)
	local i = math.ceil(y/67);

	-- Make sure index is in range and activate selected
	if i > 0 and i < #tabs+1 then
		activateTab(i);
	end
end

function onDoubleClick(x, y)
	-- Emulate single click
	onClickDown(1, x, y);
end

function update()
	-- set the control height
	local h = #tabs * 67 + 22;
	setAnchoredHeight(h);
	-- position the tab icons
	for n, v in ipairs(tabs) do
		if tabWidgets[n] then
			tabWidgets[n].setPosition("topleft", 7, 67*(n-1)+41);
			tabWidgets[n].setColor("80ffffff");
		end
	end
end

function onInit()
	-- Create a helper graphic widget to indicate that the selected tab is on top
	topWidget = addBitmapWidget("tabtop");
	topWidget.setVisible(false);
	-- add all the static tabs
	if tab and tab[1] then
		for n, v in ipairs(tab) do
			if type(v)~="boolean" then
				local subwindow,icon,scroller;
				if v.subwindow and v.subwindow[1] then
					subwindow = v.subwindow[1];
				end
				if v.icon and v.icon[1] then
					icon = v.icon[1];
				end
				if v.scroller and v.scroller[1] then
					scroller = v.scroller[1];
				end
				addTab(subwindow,icon,scroller);
			end
		end
	end
	-- refresh the layout
	update();
	-- set the active tab, if there is one
	if activate then
		activateTab(activate[1]);
	end
end
