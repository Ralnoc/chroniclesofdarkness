-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

Yes  = "Yes";
No   = "No";

-- Preference Constants

DblClickDots = {};
DblClickDots.PrefName  = "DblClickDots";

CombatTracker = {};
CombatTracker.ShowNPCPref   = "CombatTrackerShowNPC";
CombatTracker.ShowStatsPref = "CombatTrackerShowStats";
CombatTracker.Toggle        = "Toggle";

MouseScrollerKey = {};
MouseScrollerKey.PrefName  = "BaseMouseScrollerKey";
MouseScrollerKey.None  = "None";
MouseScrollerKey.Ctrl  = "CTRL";
MouseScrollerKey.Alt   = "ALT";
MouseScrollerKey.Shift = "SHIFT";

P2PWhisper = {};
P2PWhisper.SeparatorPref = "P2PWhisperSeparator";
P2PWhisper.GMPref        = "P2PWhisperGM";
P2PWhisper.Echo          = "Echo";

AutoNumber = {};
AutoNumber.PrefName = "AutoNumber";
AutoNumber.Random   = "Random";

BellOnTurn = {};
BellOnTurn.PrefName = "BellOnTurn";

TrackGMId = {};
TrackGMId.PrefName  = "TrackGMId";

ChatPortraits = {};
ChatPortraits.PrefName  = "ChatPortraits";

CloseBox = {};
CloseBox.PrefName  = "CloseBox";

ShowTotals = {};
ShowTotals.PrefName = "ShowTotals";

-- Register preferences

function onInit()
  -- preference groups
  PreferenceManager.registerGroup({name="General Preferences", tabname="tab_general"});
  PreferenceManager.registerGroup({name="GM Preferences", tabname="tab_gm"});
  PreferenceManager.registerGroup({name="Combat Tracker", tabname="tab_combat"});
  -- combat tracker prefs
  PreferenceManager.register({name=CombatTracker.ShowNPCPref,
                              group="Combat Tracker",
                              label="Show NPCs on clients:",
                              helptext="Show NPCs on the client tracker",
                              datatype="string",
                              defvalue=CombatTracker.Toggle,
                              gmonly=true,
                              global=true,
                              control="ShowNPCPref"});
  -- show other PCs' hits, wounds etc on client combat tracker
  PreferenceManager.register({name=CombatTracker.ShowStatsPref,
                              group="Combat Tracker",
                              label="Show PC stats on clients:",
                              helptext="Show health and willpower on the client tracker",
                              datatype="string",
                              defvalue=No,
                              gmonly=true,
                              global=true,
                              control="YesNoPref"});
  -- amend gm id to reflect current combat tracker entry
  PreferenceManager.register({name=TrackGMId.PrefName,
                              group="Combat Tracker",
                              label="Tracker changes GM id:",
                              helptext="GM assumes id of NPC combatants automatically",
                              datatype="string",
                              defvalue=No,
                              gmonly=true,
                              control="YesNoPref"});
  -- auto-number tracker entries
  PreferenceManager.register({name=AutoNumber.PrefName,
                              group="Combat Tracker",
                              label="Auto-number NPCs:",
                              helptext="Auto-number new tracker entries with the same name",
                              datatype="string",
                              defvalue=Yes,
                              gmonly=true,
                              control="AutoNumberPref"});
  -- ring bell on player combat turn
  PreferenceManager.register({name=BellOnTurn.PrefName,
                              group="Combat Tracker",
                              label="Bell on PC turn:",
                              helptext="Ring bell on player's combat turn",
                              datatype="string",
                              defvalue=No,
                              gmonly=true,
                              control="YesNoPref"});
  -- mouse scroller key
  PreferenceManager.register({name=MouseScrollerKey.PrefName,
                              group="General Preferences",
                              label="Mouse Scroller Key:",
                              helptext="If defined, allows the mouse wheel to change numbers",
                              datatype="string",
                              defvalue=MouseScrollerKey.None,
                              control="ScrollKeyPref"});
  -- enable double-clicking for dot controls
  PreferenceManager.register({name=DblClickDots.PrefName,
                              group="General Preferences",
                              label="Double-click dots:",
                              helptext="Double-click a dot control to add dice to the pool",
                              datatype="string",
                              defvalue=No,
                              control="YesNoPref"});
  -- player-to-play whispers
  PreferenceManager.register({name=P2PWhisper.SeparatorPref,
                              group="General Preferences",
                              label="Use ':' for whispers:",
                              helptext="Use ':' instead of ' ' to delimit whisper recipients",
                              datatype="string",
                              defvalue=No,
                              control="YesNoPref"});
  PreferenceManager.register({name=P2PWhisper.GMPref,
                              group="GM Preferences",
                              label="Allow P2P whispers:",
                              helptext="'Echo' allows whispers, but copies it to GM chat",
                              datatype="string",
                              defvalue=P2PWhisper.Echo,
                              gmonly=true,
                              control="P2PWhisperPref"});
  -- show character portraits in chat
  PreferenceManager.register({name=ChatPortraits.PrefName,
                              group="GM Preferences",
                              label="Show portraits in chat:",
                              helptext="Shows a mini portrait in the chat window",
                              datatype="string",
                              defvalue=No,
                              gmonly=true,
                              global=true,
                              control="YesNoPref"});
  -- close box
  PreferenceManager.register({name=CloseBox.PrefName,
                              group="General Preferences",
                              label="Show window close box:",
                              helptext="Show a close box (x) on each window",
                              datatype="string",
                              defvalue=Yes,
                              control="YesNoPref"});
  --[[ die roll totals: not implemented, as totals don't mean much in WoD
  PreferenceManager.register({name=ShowTotals.PrefName,
                              group="GM Preferences",
                              label="Show die roll totals:",
                              helptext="Add die roll totals to chat window messages",
                              datatype="string",
                              defvalue=No,
                              gmonly=true,
                              global=true,
                              control="YesNoPref"}); ]]
end
