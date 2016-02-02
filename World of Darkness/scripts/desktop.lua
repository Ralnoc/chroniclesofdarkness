-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

function onInit()
  if User.isLocal() then
    DesktopManager.registerStackShortcut("button_characters_ghost", "button_characters", "button_characters_down", "Characters", "identityselection");
    DesktopManager.registerStackShortcut("button_pointer_ghost", "button_pointer", "button_pointer_down", "Colors", "pointerselection");
    DesktopManager.registerStackShortcut("button_portraits_ghost", "button_portraits", "button_portraits_down", "Portraits", "portraitselection");
    DesktopManager.registerStackShortcut("button_modules_ghost", "button_modules", "button_modules_down", "Modules", "moduleselection");
    DesktopManager.registerStackShortcut("button_prefs_ghost", "button_prefs", "button_prefs_down", "Preferences", "preflist");

    DesktopManager.registerDockShortcut("button_library_ghost", "button_library", "button_library_down", "Library", "library");
  else
    if User.isHost() then
      DesktopManager.registerStackShortcut("button_light_ghost", "button_light", "button_light_down", "Lighting", "lightingselection");
      DesktopManager.registerStackShortcut("button_pointer_ghost", "button_pointer", "button_pointer_down", "Colors", "pointerselection");
      DesktopManager.registerStackShortcut("button_tracker_ghost", "button_tracker", "button_tracker_down", "Combat tracker", "combattracker", "combattracker");
      DesktopManager.registerStackShortcut("button_characters_ghost", "button_characters", "button_characters_down", "Characters", "charactersheetlist", "charsheet");
      DesktopManager.registerStackShortcut("button_modules_ghost", "button_modules", "button_modules_down", "Modules", "moduleselection");
      DesktopManager.registerStackShortcut("button_prefs_ghost", "button_prefs", "button_prefs_down", "Preferences", "preflist");
      DesktopManager.registerStackShortcut("button_effects_ghost", "button_effects", "button_effects_down", "Effects", "effectlist", "effect");
      
      DesktopManager.registerDockShortcut("button_book_ghost", "button_book", "button_book_down", "Story", "storylist", "story");
      DesktopManager.registerDockShortcut("button_encounters_ghost", "button_encounters", "button_encounters_down", "Encounters", "encounterlist", "encounter");
      DesktopManager.registerDockShortcut("button_maps_ghost", "button_maps", "button_maps_down", "Maps & Images", "imagelist", "image");
      DesktopManager.registerDockShortcut("button_people_ghost", "button_people", "button_people_down", "Antagonists", "npclist", "npc");
      DesktopManager.registerDockShortcut("button_itemchest_ghost", "button_itemchest", "button_itemchest_down", "Items", "itemlist", "item");
			DesktopManager.registerDockShortcut("button_notes_ghost", "button_notes", "button_notes_down", "Notes", "notelist", "note");
      DesktopManager.registerDockShortcut("button_library_ghost", "button_library", "button_library_down", "Library", "library");
      
      DesktopManager.registerDockShortcut("button_tokencase_ghost", "button_tokencase", "button_tokencase_down", "Tokens", "tokenbag", nil, true);
    else
      DesktopManager.registerStackShortcut("button_portraits_ghost", "button_portraits", "button_portraits_down", "Portraits", "portraitselection");
      DesktopManager.registerStackShortcut("button_pointer_ghost", "button_pointer", "button_pointer_down", "Colors", "pointerselection");
      DesktopManager.registerStackShortcut("button_characters_ghost", "button_characters", "button_characters_down", "Characters", "identityselection");
      DesktopManager.registerStackShortcut("button_modules_ghost", "button_modules", "button_modules_down", "Modules", "moduleselection");
      DesktopManager.registerStackShortcut("button_prefs_ghost", "button_prefs", "button_prefs_down", "Preferences", "preflist");
      
			DesktopManager.registerDockShortcut("button_notes_ghost", "button_notes", "button_notes_down", "Notes", "notelist", "note");
      DesktopManager.registerDockShortcut("button_library_ghost", "button_library", "button_library_down", "Library", "library");
      
      DesktopManager.registerDockShortcut("button_tokencase_ghost", "button_tokencase", "button_tokencase_down", "Tokens", "tokenbag", nil, true);
    end
  end
end