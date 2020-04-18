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
                    [1] = {Text = "FeignDeath |cFF00FF00On", Tooltip = ""},
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
	UI.AddHeader("Cliped or Full Rotation")
	UI.AddToggle("Clipped Rotation", "Clipp Autoshots or not ", true)   
	UI.AddHeader("Shots")
	UI.AddToggle("Aimed Shot", "Aimed Shot", true)
	UI.AddToggle("Arcane if moving", "Casts Arcane when the player is moving instead of Aimed", true)
	UI.AddToggle("Multi Shot", "Will use Multishot", true)	
	UI.AddToggle("Arcane Shot", "Will use Arcanshot", true)
	UI.AddToggle("Serpent Sting", "Will use Serpent Sting", true)
	UI.AddToggle("Save Tranq Mana","Holds back 10% Mana for Tranqshot", true)
 
	
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
	UI.AddToggle("Allways HuntersMark", "ignores Time to die", true)
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
	UI.AddRange	("Seconds for PetAggro", "Seconds for PetAggro", 0, 3, 1, 0)
 	UI.AddRange	("Target HP <", "Target HP", 80, 100, 1, 100)   
	
	--Consumables Health
	UI.AddTab("Consumables")
	UI.AddHeader("Consumables")
	UI.AddToggle("Use Best HP Potion", "Check back for Potions and use best available one")
	UI.AddRange("Use Potion at #% HP", nil, 10, 100, 1, 50, true)

    --Consumables Mana
	
	UI.AddHeader("Mana Potions on Boss Targets")
	UI.AddToggle("Use Best Mana Potion", "Check back for Potions and use best available one") 
	UI.AddRange("Use Potion at #% Mana", nil, 10, 100, 1, 50, true)
    UI.AddToggle("Use Demonic or Dark Rune", "Uses Demonic or Dark Rune " ) 	
	UI.AddRange("Use Rune at #% Mana", nil, 10, 100, 1, 50, true)
 

	-- Not Working needs recode
	UI.AddTab("Testing")
	UI.AddHeader("Do not use this is not working")
	UI.AddToggle("Tranq Shot","Uses Tranq Shot if Enraged", true)
	UI.AddDropdown("Tranq Order", "Tranqshot every first,second or third frenzy", { 1, 2, 3}, 1)

end
