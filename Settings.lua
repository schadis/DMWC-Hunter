local DMW = DMW
DMW.Rotations.HUNTER = {}
local Hunter = DMW.Rotations.HUNTER
local UI = DMW.UI


function Hunter.Settings()
    -- UI.HUD.Options = {
    --     [1] = {
    --         Test = {
    --             [1] = {Text = "HUD Test |cFF00FF00On", Tooltip = ""},
    --             [2] = {Text = "HUD Test |cFFFFFF00Sort Of On", Tooltip = ""},
    --             [3] = {Text = "HUD Test |cffff0000Disabled", Tooltip = ""}
    --         }
    --     }
    -- }
 --   UI.AddHeader("General")
 
	UI.HUD.Options = 
	{
 
			[1]= {
               Serpent = {
                    [1] = {Text = "Serpent |cFF00FF00On", Tooltip = ""},
                    [2] = {Text = "Serpent |cffff0000Off", Tooltip = ""}
						 }
				},
    
 			[2]= {
               Multi = {
                    [1] = {Text = "Multi |cFF00FF00On", Tooltip = ""},
                    [2] = {Text = "Multi |cffff0000Off", Tooltip = ""}
						 }
				},
				
			[3]= {
               FeignDeath = {
                    [1] = {Text = "FeignDeath |cFF00FF00Aggro", Tooltip = ""},
					--[2] = {Text = "FeignDeath |cFF00FF00%Setting", Tooltip = ""},
                    [2] = {Text = "FeignDeath |cffff0000Off", Tooltip = ""}
						 }
				},		
					
			[4]= {
               PetAttack = {
                    [1] = {Text = "PetAttack |cFF00FF00On", Tooltip = ""},
                    [2] = {Text = "PetAttack |cffff0000Off", Tooltip = ""}
						 }
				}				
								
    }

	
--  UI.AddHeader("DPS")
	--UI.AddTab("DPS") not needed cause General is OK
	
	UI.AddToggle("AutoFace", "Makes you Face the Target all the Time", false)
	UI.AddToggle("TargetMarkedMobs", "Targets the next RaidTarget automaticly", false)
	UI.AddHeader("Cliped or Full Rotation")
	UI.AddToggle("Clipped Rotation", "Clipp Autoshots or not ", true)   
	UI.AddToggle("Use Opener Rotation","Uses Opener Rotation with Cooldowns", true)
	UI.AddToggle("FD in Opener Roration","Feigns in Opener Rotation for auto/manual/addon Trinket swapping", true)
	UI.AddToggle("Auto Swap Trinkets","Swap trinkets according to settings", false)
	UI.AddDropdown("Swap out Slot1", "Swap TrinketSlot 1 after use and FD to", {"None","DevilsaurEye","JomGabbar","Earthstrike","BadgeoftheSwarmguard"},1)
  	UI.AddDropdown("Swap out Slot2", "Swap TrinketSlot 2 after use and FD to", {"None","DevilsaurEye","JomGabbar","Earthstrike","BadgeoftheSwarmguard"},1)
	UI.AddDropdown("Swap TrinketSlot 1", "Swap TrinketSlot 1 after use and FD to", {"None","RoyalSeal","Blackhand's Breadth"},1)
	UI.AddDropdown("Swap TrinketSlot 2", "Swap TrinketSlot 2 after use and FD to", {"None","RoyalSeal","Blackhand's Breadth"},1)
	
	UI.AddHeader("FeignDeath")
	UI.AddRange("% to FeignDeath","at this % of Aggro FD will be cast", 80, 130, 1, 120)	
	
	UI.AddHeader("Shots")
	UI.AddToggle("Aimed Shot", "Aimed Shot", true)
	UI.AddToggle("Arcane if moving", "Casts Arcane when the player is moving instead of Aimed", true)
	UI.AddToggle("Multi Shot", "Will use Multishot", true)	
	UI.AddToggle("Arcane Shot", "Will use Arcanshot", true)
	UI.AddToggle("Serpent Sting", "Will use Serpent Sting", true)
	UI.AddToggle("Save Tranq Mana","Holds back 10% Mana for Tranqshot", true)

	UI.AddHeader("Melee")
	UI.AddToggle("RaptorStrike", "uses RaptorStrike", true)
	UI.AddToggle("MongooseBite", "uses MongooseBite", true)
	UI.AddToggle("WingClip", "uses WingClip", false)
	UI.AddToggle("WingClipRank1", "uses WingClipRank1", true)
	
	
--  Defensive
	UI.AddTab("Defensive")
	UI.AddHeader("Defensive")
	UI.AddToggle("Concussiv Shot", "Will use Concussiv Shot", true)
    UI.AddRange	("Concussiv Shot Distance", "Range < yards to cast Concussiv Shot", 8, 45, 1, 30)
	UI.AddToggle("Aspect Of The Monkey", "Use Aspect of the Monkey", true)
	UI.AddRange	("Aspect of the Monkey HP", "HP to cast AotM", 0, 100, 1, 75)
	
--  Utility
	UI.AddTab("Utility")
	UI.AddHeader("Utility")
	UI.AddToggle("HuntersMark", "HuntersMark", true)
	UI.AddToggle("Allways HuntersMark", "ignores HP of the target", true)
	UI.AddToggle("TrueShot Buff", "TrueShot Buff", true)
	UI.AddToggle("Aspect of the Hawk", "Will use AotH in combat", true)
	UI.AddToggle("Aspect Of The Cheetah", "Use Aspect of the Cheetah", true)
	UI.AddHeader("Pet Stuff")
	UI.AddToggle("Auto Pet Attack", "Auto cast pet attack on target", true)
	UI.AddToggle("Pet Pullback at mend Pet HP", "Pulls back the Pet at HP", true)
	UI.AddToggle("Call Pet", "Call active pet ", true)
	UI.AddToggle("FuriousHowl if pulled back","Casts FuriousHowl when passiv in fight", true)
	UI.AddToggle("Mend Pet", "Activate Mend Pet", false)
	UI.AddBlank()
	UI.AddRange ("Mend Pet HP", "Pet HP to cast Mend Pet", 0, 60, 1, 35)	
	UI.AddRange ("Send Pet back in", "only works with Pullback", 50, 100, 1, 70)
	UI.AddHeader("Wait with attack for Pet Aggro by Seconds or TargetHP")
	UI.AddToggle("Wait until PetAggro", "Has to be checked for the sliders to work", true)
	UI.AddBlank()
	UI.AddRange	("Seconds for PetAggro", "Seconds for PetAggro", 0, 3, 1, 0)
 	UI.AddRange	("Target HP <", "Target HP", 80, 100, 1, 100)   
	
	--Consumables Health
	UI.AddTab("Consumables")
	UI.AddHeader("Consumables")
	UI.AddToggle("Use Best HP Potion", "Check back for Potions and use best available one")
	UI.AddRange("Use Potion at #% HP", nil, 10, 100, 1, 50, true)
	UI.AddToggle("Healthstone", nil, true)
	UI.AddRange("Use Healthstone at #% HP", nil, 10, 100, 1, 50, true)
	
	UI.AddHeader("Engineering Stuff")
	UI.AddToggle("Use Sapper Charge", "uses Sapper according to Setting", false)
	UI.AddRange("Enemys 10Y", "Enemys in 10 Yards Sapper Range", 0, 15, 1, 35)
	UI.AddDropdown("Use Trowables", "Select the item to use", {"None","All","DenseDynamite","EZThroDynamitII","ThoriumGrenade","IronGrenade"},1)
	UI.AddRange("Enemys 5Y around Target", "Enemys in 5 around Target", 0, 15, 1, 8)

    --Consumables Mana
	UI.AddHeader("Mana Potions on Boss Targets")
	UI.AddToggle("Use Best Mana Potion", "Check back for Potions and use best available one") 
	UI.AddRange("Use Potion at #% Mana", nil, 10, 100, 1, 50, true)
    UI.AddToggle("Use Demonic or Dark Rune", "Uses Demonic or Dark Rune " ) 	
	UI.AddRange("Use Rune at #% Mana", nil, 10, 100, 1, 50, true)
 

	-- Testing Status
	UI.AddTab("Testing")
	UI.AddHeader("Do not use this is not working")
	UI.AddToggle("Tranq Shot","Uses Tranq Shot if Enraged", true)
	UI.AddDropdown("Tranq Order", "Tranqshot every first,second or third frenzy", { 1, 2, 3}, 1)
	
	-- Buff Sniper
	UI.AddTab("Buff Sniper")
	UI.AddHeader("If World buff drops log off")
	UI.AddHeader("Only select one")
	UI.AddToggle("WCB", "If Warchiefsblessing is on you log off", false)
	UI.AddToggle("Ony_Nef", "If Dragonslayer is on you log off", false)
	UI.AddToggle("ZG", "If Spirit of Zandalar is on you log off", false)
	
	--Debug Print
	UI.AddTab("Print")
	UI.AddToggle("Print ISEnraged", nil, true)
	UI.AddToggle("Print EnrageNR", nil, true)
	UI.AddToggle("MyTranq", nil, true)
	UI.AddToggle("Enraged by Aura applied", nil, true)
	UI.AddToggle("Enraged by Unit:Aura", nil, true)
	
	
end