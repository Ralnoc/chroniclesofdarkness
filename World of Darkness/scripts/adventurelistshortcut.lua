-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

function onIntegrityChange()
	if window.getDatabaseNode().isIntact() then
		resetMenuItems();
		integritywidget.setBitmap("indicator_intactmodule");
	else
		registerMenuItem("Revert Changes", "shuffle", 8);
		integritywidget.setBitmap("indicator_nonintactmodule");
	end
end

function onInit()
	if window.getDatabaseNode().getModule() then
		integritywidget = addBitmapWidget("indicator_intactmodule");
		integritywidget.setPosition("center", 3, 0);
		integritywidget.setVisible(true);
		
		setTooltipText(window.getDatabaseNode().getModule());
		
		window.getDatabaseNode().onIntegrityChange = onIntegrityChange;
		onIntegrityChange();
	end
end

function onMenuSelection(selection)
	if selection == 8 then
		window.getDatabaseNode().revert();
	end
end
