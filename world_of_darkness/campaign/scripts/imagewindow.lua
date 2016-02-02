-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	updateDisplay();

	registerMenuItem(Interface.getString("image_menu_size"), "imagesize", 3);
	registerMenuItem(Interface.getString("image_menu_sizeoriginal"), "imagesizeoriginal", 3, 2);
	registerMenuItem(Interface.getString("image_menu_sizevertical"), "imagesizevertical", 3, 4);
	registerMenuItem(Interface.getString("image_menu_sizehorizontal"), "imagesizehorizontal", 3, 5);
end

function onMenuSelection(item, subitem)
	if item == 3 then
		if subitem == 2 then
			local iw, ih = image.getImageSize();
			local w = iw + image.marginx[1];
			local h = ih + image.marginy[1];
			setSize(w, h);
			image.setViewpoint(0,0,1);
		elseif subitem == 4 then
			local iw, ih = image.getImageSize();
			local cw, ch = image.getSize();
			local w = cw + image.marginx[1];
			local h = ((ih/iw)*cw) + image.marginy[1];
			setSize(w, h);
			image.setViewpoint(0,0,0.1);
		elseif subitem == 5 then
			local iw, ih = image.getImageSize();
			local cw, ch = image.getSize();
			local w = ((iw/ih)*ch) + image.marginx[1];
			local h = ch + image.marginy[1];
			setSize(w, h);
			image.setViewpoint(0,0,0.1);
		end
	end
end
			
function updateDisplay()
	if toolbar.subwindow then
		toolbar.subwindow.update();
	end
end
