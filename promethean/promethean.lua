-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20

-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above license, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.

-- Copyright 2009 SmiteWorks Ltd.

local GameLine =
{ Name= "Promethean",
  FullName = "Promethean: The Created",
  MoralityTitle = "Humanity",
  FactionTitle = "Lineage",
  GroupTitle = "Refinement",
  CSLogo = "promethean_button",
  FullLogo = nil,
  Skills =
  { [1] = {Name="Academics", Type="Mental", Untrained=-3},
    [2] = {Name="Computer", Type="Mental", Untrained=-3},
    [3] = {Name="Crafts", Type="Mental", Untrained=-3},
    [4] = {Name="Investigation", Type="Mental", Untrained=-3},
    [5] = {Name="Medicine", Type="Mental", Untrained=-3},
    [6] = {Name="Occult", Type="Mental", Untrained=-3},
    [7] = {Name="Politics", Type="Mental", Untrained=-3},
    [8] = {Name="Science", Type="Mental", Untrained=-3},
    [9] = {Name="Athletics", Type="Physical", Untrained=-1},
    [10] = {Name="Brawl", Type="Physical", Untrained=-1},
    [11] = {Name="Drive", Type="Physical", Untrained=-1},
    [12] = {Name="Firearms", Type="Physical", Untrained=-1},
    [13] = {Name="Larceny", Type="Physical", Untrained=-1},
    [14] = {Name="Stealth", Type="Physical", Untrained=-1},
    [15] = {Name="Survival", Type="Physical", Untrained=-1},
    [16] = {Name="Weaponry", Type="Physical", Untrained=-1},
    [17] = {Name="Animal Ken", Type="Social", Untrained=-1},
    [18] = {Name="Empathy", Type="Social", Untrained=-1},
    [19] = {Name="Expression", Type="Social", Untrained=-1},
    [20] = {Name="Intimidation", Type="Social", Untrained=-1},
    [21] = {Name="Persuasion", Type="Social", Untrained=-1},
    [22] = {Name="Socialize", Type="Social", Untrained=-1},
    [23] = {Name="Streetwise", Type="Social", Untrained=-1},
    [24] = {Name="Subterfuge", Type="Social", Untrained=-1}
  },
  CharSheet =
  { Frame = "promethean_sheet",
    TabControl = "charsheet_tabs",
    Tabs = 
    { [1] = {Name="main", Template="promethean_main", Icon="tab_main"},
      [2] = {Name="other", Template="charsheet_other", Icon="tab_other"},
      [3] = {Name="special", Template="promethean_special", Icon="tab_special"},
      [4] = {Name="notes", Template="charsheet_notes", Icon="tab_notes"},
      Activate = 1
    }
  },
  NPCSheet = nil,
  CombatPanels = nil
};

function onInit()
  LineManager.register(GameLine,false);
end

