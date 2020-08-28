local DMW = DMW
local Hunter = DMW.Rotations.HUNTER
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local Friend, Player, Pet, Buff, Debuff, GUID, Spell, Target, Talent, Item, GCD, Health, CDs, HUD, Enemy10Y, Enemy10YC, Enemy20Y, Enemy20YC, Enemy30Y, Enemy30YC, Enemy41Y, Enemy41YC, Enemy50Y, Enemy50YC, CTime
local ShotTime = GetTime()
local FeignDeathIndex = 0
local isFeign = false 

local EnrageNR = 0;
local TranqMana = 0;
local Markisup = false
local markedMobs = {}
local BossEnraged = false
local MyTranq = false
local EnrageStartTime = 0;
local EnrageStopTime = 0;

local BossName = nil;
local BossID = nil;
local fightingBoss = false;
local threatPercent = 0;

local quiverSpeed = 1.00;
local aimedCastTime = 3500;
local multiCastTime = 500;
local autoShotCastTime = 500;
local reloadTime = 3000;
local svreloadTime = 0;
local feignDeathStartTime = 0;
local castingAShot = false
local castingAimed = false
local AimedMacroDone = false
local isReloading = false
local reloadPercent = 100
local reloadEndTime
local reloadStarTime = 0
local reloadInMoment = 0
local aimednumber = 0
local ReadyCooldownCountValue = 0

local bagSlots = {20, 21, 22, 23};
local updateRequired = false;
local FHowlPetButton = nil
local ItemUsage = GetTime()

	--------------------------------------------------------------------------	

local function EnemiesAroundTarget()
	if Target
		then 
		return Target:GetEnemies(5)
	else
		return nil
	end
end
 
	--------------------------------------------------------------------------	

local function EnragedBoss()
	if Enemy50YC ~= nil
	and Enemy50YC >=1 
		then
		for _, Unit in ipairs(Enemy41Y) do
			if Unit:IsBoss()
			and (Unit:AuraByID(19451, true)	-- SpellIds from Enrage Magmadar,
			or Unit:AuraByID(23128, true)	-- Chromagus,
			or Unit:AuraByID(23342, true)	-- Flamegore,
			or Unit:AuraByID(26051, true)) 	-- Princess Huhuran
			-- or Unit:AuraByID(???, true)	-- Gluth???
				then						
				BossEnraged = true
				if Setting("Enraged by Unit:Aura") then print("Enraged by Unit:Aura") end
				return true
			end
		end
	end
	BossEnraged = false
	return false
end

	--------------------------------------------------------------------------	

local function Tranqorder()
	if Setting("Tranq Order") == 1
	and (EnrageNR == 1 or EnrageNR == 2 or EnrageNR == 3 or EnrageNR == 4 or EnrageNR == 5 or EnrageNR == 6 or EnrageNR == 7 or EnrageNR == 8 or EnrageNR == 9 or EnrageNR == 10 or EnrageNR == 11 or EnrageNR == 12 or EnrageNR == 13 or EnrageNR == 14 or EnrageNR == 15 or EnrageNR == 16 or EnrageNR == 17 or EnrageNR == 18 or EnrageNR == 19 or EnrageNR == 20)
		then
		MyTranq = true
		return true
	elseif Setting("Tranq Order") == 2
	and (EnrageNR ==2 or EnrageNR == 4 or EnrageNR == 6 or EnrageNR == 8 or EnrageNR == 10 or EnrageNR == 12 or EnrageNR == 14 or EnrageNR == 16 or EnrageNR == 18 or EnrageNR == 20)
		then
		MyTranq = true
		return true
	elseif Setting("Tranq Order") == 2
	and (EnrageNR == 3 or EnrageNR == 6 or EnrageNR == 9 or EnrageNR == 12 or EnrageNR == 15 or EnrageNR == 18 or EnrageNR == 21 or EnrageNR == 24 or EnrageNR == 27 or EnrageNR == 30)
		then
		MyTranq = true
		return true
	end
	MyTranq = false
	return false
end
	--------------------------------------------------------------------------	 
	
local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
	CTimer = Player.CombatTime
    Debuff = Player.Debuffs
	Health = Player.Health
	Pet = DMW.Player.Pet
    HP = Player.HP
    Power = Player.PowerPct
    Spell = Player.Spells
    Talent = Player.Talents
    Trait = Player.Traits
    Item = Player.Items
    Target = (Player.Target or false)
    HUD = DMW.Settings.profile.HUD
    CDs = Player:CDs()
	GCD = Player:GCD()
	Target5Y, Target5YC = EnemiesAroundTarget()
	Enemy10Y, Enemy10YC = Player:GetEnemies(10)
	Enemy41Y, Enemy41YC = Player:GetEnemies(41)
	Enemy50Y, Enemy50YC = Player:GetEnemies(50)
	BossEnraged = EnragedBoss()
	MyTranq = Tranqorder()


 end

	--------------------------------------------------------------------------	

--SpellId 26635 Berserking
local function GetBerserkingHaste()
	return math.min((1.30 - (UnitHealth("player") / UnitHealthMax("player"))) / 3, 0.3) + 1;
end

local helpfulRangeModifiers = {
	[3045] = 1.4, -- rapid fire
	[6150] = 1.3, -- quick shots
	[28866] = 1.2, -- naxx trinket
};

local harmfulRangeModifiers = {
	[89] = 1.45, -- cripple
	[19365] = 2.0, -- MC core hound debuff
	[17331] = 1.1, -- LBRS dagger proc
};

local sAimedShot = GetSpellInfo(19434);
local sMultiShot = GetSpellInfo(2643);
local sAutoShot = GetSpellInfo(75)


local castTime = 0;
local icon = 0;

local startTime = 0
local endTime = 0;

local dStart = 0;
local dPred = 0;

local quiver = {}    --Blizzard's API does not allow me to determine haste from quiver so I have to do it manually.
quiver[2101]  = 1.10 --Light Quiver
quiver[2102]  = 1.10 --Small Ammo Pouch
quiver[2662]  = 1.14 --Ribbly's Quiver
quiver[2663]  = 1.14 --Ribbly's Bandolier
quiver[3573]  = 1.10 --Hunting Quiver
quiver[3574]  = 1.10 --Hunting Ammo Sack
quiver[3604]  = 1.11 --Bandolier of the Night Watch
quiver[3605]  = 1.11 --Quiver of the Night Watch
quiver[5439]  = 1.10 --Small Quiver
quiver[5441]  = 1.10 --Small Shot Pouch
quiver[7278]  = 1.10 --Light Leather Quiver
quiver[7279]  = 1.10 --Small Leather Ammo Pouch
quiver[7371]  = 1.12 --Heavy Quiver
quiver[7372]  = 1.12 --Heavy Leather Ammo Pouch
quiver[8217]  = 1.13 --Quickdraw Quiver
quiver[8218]  = 1.13 --Thick Leather Ammo Pouch
quiver[11362] = 1.10 --Medium Quiver
quiver[11363] = 1.10 --Medium Shot Pouch
quiver[18714] = 1.15 --Ancient Sinew Wrapped Lamina
quiver[19319] = 1.15 --Harpy Hide Quiver
quiver[19320] = 1.15 --Gnoll-Skin Bandolier

--could use GetRangedHaste() but it updates too slowly
local function GetCurrentRangeHaste()
	
	local speed = quiverHaste;
	
	local stop = 0;
	for i = 1, 40 do
		if(stop ~= 1) then
			local spellId = select(10, UnitAura("player", i, "HELPFUL"))
			if(spellId == nil) then
				stop = stop + 1;
			else
				local coef = spellId == 26635 and (GetBerserkingHaste() or helpfulRangeModifiers[spellId]);
				if(coef) then
					speed = speed * coef;
				end
			end
		end
		
		if(stop < 2) then
			local spellId = select(10, UnitAura("player", i, "HARMFUL"))
			if(spellId == nil) then
				stop = stop + 2;
			else
				local div = harmfulRangeModifiers[spellId]
				if(div) then
					speed = speed / div;
				end
			end
		end
	
		if(stop == 3) then
			break;
		end
	end
	
	return speed;
end
 
	
local function GetQuiverInfo()
	quiverHaste = 1.0
	for i = 1, 4 do
		local invID = ContainerIDToInventoryID(i)  
		local bagID = GetInventoryItemID("player",invID)
		if (bagID ~= nil) then
			if (quiver[bagID]) then
				if (quiverHaste < quiver[bagID]) then
					quiverHaste = quiver[bagID]
				end
			end
		end
	end
	updateRequired = false;
end 

 
 local function CalculateShootTimes()

	autoShotTime = (autoShotCastTime / GetCurrentRangeHaste())
	multiShoTime = autoShotTime
	aimedShotTime = (aimedCastTime / GetCurrentRangeHaste())
	reloadTime = (UnitRangedDamage("player")*1000 - autoShotTime)
	if (svreloadTime ~= reloadTime) then --If reload time changed? This could happen for a variety of reasons including getting a new ranged weapon or on initialization
		svreloadTime = reloadTime
	end
	
	if castingAShot and endTime <= (GetTime() * 1000) then
		castingAShot = false
		castingAimed = false
		isReloading = true
	end
	
end

	--------------------------------------------------------------------------	
 
local function CombatLogEvent(...)
	local timeStamp, subEvent, _, sourceID, sourceName, _, _, targetID = ...;
	

	if(subEvent == "SPELL_CAST_START") then
	
		if(sourceID ~= UnitGUID("player")) then return end

		local spellName = select(13, ...);
				
	
		if(spellName == sAimedShot) then
			CalculateShootTimes()
			castTime = aimedShotTime;
			castingAShot = true
			isReloading = true
			castingAimed = true
			AimedMacroDone = false
			
		elseif(spellName == sMultiShot) then
			CalculateShootTimes()
			castTime = multiShoTime;
			castingAShot = true

			
		elseif(spellName == sAutoShot) then
			CalculateShootTimes()
			castTime = autoShotTime;
			castingAShot = true
			isReloading = false			
		else
			return;
		end
		

		
		if(updateRequired) then
			GetQuiverInfo()
		end
		
		castTime = castTime / GetCurrentRangeHaste();
		
		startTime = GetTime() * 1000;
		endTime = startTime + castTime;
		
		
	elseif(subEvent == "SPELL_CAST_SUCCESS") then
		if(sourceID ~= UnitGUID("player")) then return end
		
		local spellName = select(13, ...);
		

		
		if(spellName == sAimedShot or spellName == sMultiShot or spellName == sAutoShot) then
			CalculateShootTimes()
			castingAShot = false
			isReloading = true
			if spellName == sAutoShot then
				reloadStarTime = GetTime() * 1000
				reloadEndTime = (reloadStarTime + reloadTime)
			elseif spellName == sAimedShot then
				if DMW.Player.Target
				and DMW.Player.Target:IsBoss()
					then 
					aimednumber = aimednumber + 1
				end
				castingAimed = false
				AimedMacroDone = false
			end
			
		end

	elseif(subEvent == "SPELL_CAST_FAILED") then
		if(sourceID ~= UnitGUID("player")) then return end
		
		local spellName = select(13, ...);
		local why = select(15, ...);
		local realFail = false

		if why == ("Not yet recovered" or "Another action is in progress") then 
		realFail = false
		else 
		realFail = true

		end


	
		if realFail then
			if(spellName == sAimedShot or spellName == sMultiShot or spellName == sAutoShot) then
				CalculateShootTimes()
				castingAShot = false
				isReloading = true
				if spellname == sAutoShot then
					reloadStarTime = GetTime() * 1000
					reloadEndTime = (reloadStarTime + reloadTime)
				elseif spellName == sAimedShot then
					castingAimed = false
					AimedMacroDone = false
				end
			end
		end
		
	elseif(subEvent == "SPELL_AURA_APPLIED") then
		local spellId = select(12, ...)
		if (sourceName == "Magmadar" or sourceName == "Flamegor" or sourceName == "Chromaggus" or sourceName == "Princess Huhuran" or sourceName == "Gluth")
		and (spellId == 19451 or spellId == 23128 or spellId == 23342 or spellId == 26051)
			then
			EnrageStartTime = GetTime() * 1000
			EnrageNR = EnrageNR + 1
			BossEnraged = true
			if Setting("Enraged by Aura applied") then print("Enraged by Aura applied") end
		end	
		
	elseif(subEvent == "SPELL_AURA_REMOVED") then
		local spellId = select(12, ...)
		if (sourceName == "Magmadar" or sourceName == "Flamegor" or sourceName == "Chromaggus" or sourceName == "Princess Huhuran" or sourceName == "Gluth")
		and (spellId == 19451 or spellId == 23128 or spellId == 23342 or spellId == 26051)
		then
		EnrageStopTime = GetTime() * 1000
		BossEnraged = false
		end		
	end
	
	
--check if Target has Mark	
		if DMW.Player.Target ~= nil 
		and DMW.Player.Target.Distance < 50 then
			for i = 1, 40 do
				if UnitGUID("target") == nil then
					break				
				elseif DMW.Player.Target.ValidEnemy and UnitDebuff("target", i) == "Hunter's Mark" then
					markedMobs[UnitGUID("target")] = UnitGUID("target")
					break
				elseif DMW.Player.Target.ValidEnemy and UnitDebuff("target", i) ~= "Hunter's Mark" then
					markedMobs[UnitGUID("target")] = nil
				end
			end
		end
		
		if DMW.Player.Target ~= nil 
		and DMW.Player.Target.Distance < 50 then
			for k, v in pairs(markedMobs) do
				if v == UnitGUID("target") 
					then
					Markisup = true
					break
				elseif v ~= UnitGUID("target") then
					Markisup = false
				end
			end	
		end
		
		-- if DMW.Player.Target ~= nil 
		    -- and DMW.Player.Target.ValidEnemy 
		    -- and DMW.Player.Target.Distance < 50 
			-- and (DMW.Player.Target.Name == "Magmadar"
			-- or DMW.Player.Target.Name == "Flamegor"
			-- or DMW.Player.Target.Name == "Chromaggus"
			-- or DMW.Player.Target.Name == "Princess Huhuran"
			-- or DMW.Player.Target.Name == "Gluth")
			-- then
				-- for i = 1, 40 do
				
					-- local name, _, _, debuffType, duration, expirationTime, source, _, _, EnrageId = UnitBuff("target", i) 
			
					-- if (EnrageId == 23128 --frenzy Chromaggus
					-- or EnrageId == 19451 --frenzy Magmadar
					-- or EnrageId == 23342) --frenzy Flamegor 
					-- then 
							-- BossIsEnraged = true
							-- EnrageNR = EnrageNR + 1
							-- print("Enrage Start by UnitBuff")
							-- break
							
					-- else
						-- BossIsEnraged = false
					-- end
				-- end
		-- end
end
	
	--------------------------------------------------------------------------	
	
local function SpellInterrupted(source, castGUID, spellID)
	if(source ~= "player") then return end
	
	local spellName = GetSpellInfo(spellID);
	
		if(spellName == sAimedShot or spellName == sMultiShot or spellName == sAutoShot) then
			CalculateShootTimes()
			castingAShot = false
			isReloading = true
			if spellName == sAutoShot then
			reloadStarTime = GetTime() * 1000
			reloadEndTime = (reloadStarTime + reloadTime)
			elseif spellName == sAimedShot then
				castingAimed = false
				AimedMacroDone = false
			end
	end
end

local function OnStartAutorepeatSpell()
		Locals()
		castingAShot = true
		CalculateShootTimes()
		if Player.Combat and not castingAimed then
		reloadStarTime = GetTime() * 1000 + autoShotTime
		reloadEndTime = (reloadStarTime + reloadTime)
		end
end

local function OnStopAutorepeatSpell()
		if castingAimed then
		castingAShot = true
		else castingAShot = false
		end
end

	--------------------------------------------------------------------------	

local function ReloadPercentage()
	CalculateShootTimes()
	if isReloading then
		reloadInMoment = (GetTime() * 1000 - reloadStarTime)
		if (reloadInMoment < 0 or reloadInMoment > reloadTime)  then
		reloadInMoment = 0
		isReloading = false
		end
		reloadPercent = (100 * (GetTime() * 1000 - reloadStarTime) / reloadTime)
		if (reloadPercent > 100 or reloadPercent < 0) then
		reloadPercent = 0
		isReloading = false
		end
	end
end

------------------------------------------------------------------

local function trinkettoswapout1()
	
	if Setting("Swap out Slot1") == 2	
		then
		return Item.DevilsaurEye.ItemID -- , Item.DevilsaurEye.ItemName
	elseif Setting("Swap out Slot1") == 3	
		then
		return Item.JomGabbar.ItemID -- , Item.JomGabbar.ItemName
	elseif Setting("Swap out Slot1") == 4	
		then
		return Item.Earthstrike.ItemID -- , Item.Earthstrike.ItemName 
	elseif Setting("Swap out Slot1") == 5	
		then
		return Item.BadgeoftheSwarmguard.ItemID -- , Item.BadgeoftheSwarmguard.ItemName 
		end
end

local function trinkettoswapout2()
	
	if Setting("Swap out Slot2") == 2	
		then
		return Item.DevilsaurEyel.ItemID -- , Item.DevilsaurEye.ItemName  
	elseif Setting("Swap out Slot2") == 3	
		then
		return Item.JomGabbar.ItemID -- , Item.JomGabbar.ItemName 
	elseif Setting("Swap out Slot2") == 4	
		then
		return Item.Earthstrike.ItemID -- , Item.Earthstrike.ItemName 
	elseif Setting("Swap out Slot2") == 5	
		then
		return Item.BadgeoftheSwarmguard.ItemID -- , Item.BadgeoftheSwarmguard.ItemName 
		end				
end

------------------------------------------------------------------

local function trinkettoswap1()
	
	if Setting("Swap TrinketSlot 1") == 2	
		then
		return Item.RoyalSeal.ItemID  
	elseif Setting("Swap TrinketSlot 1") == 3	
		then
		return Item.BlackhandsB.ItemID 
	elseif Setting("Swap TrinketSlot 1") == 1	
		then
		return nil
		end
end

local function trinkettoswap2()
	
	if Setting("Swap TrinketSlot 2") == 2	
		then
		return Item.RoyalSeal.ItemID  
	elseif Setting("Swap TrinketSlot 2") == 3	
		then
		return Item.BlackhandsB.ItemID 
	elseif Setting("Swap TrinketSlot 2") == 1	
		then
		return nil	
	end
end

------------------------------------------------------------------

-- Getting the Encounter Name
local function ENCOUNTER_START(encounterID, name, difficulty, size)
	aimednumber = 0
	name = BossName
	BossID = encounterID
	fightingBoss = true
	
end
-- Removing the Encounter Name
local function ENCOUNTER_END(encounterID, name, difficulty, size)
	aimednumber = 0
	BossName = nil
	BossID = nil
	fightingBoss = false
end
------------------------------------------------------------------

local function Buffsniper()
local worldbufffound = false
	
	if (Setting("WCB") or Setting("Ony_Nef") or Setting("ZG"))
		then
		if Setting("WCB") 
		and not Setting("Ony_Nef")
		and not Setting("ZG")
		then
			
			for i = 1, 40 do
				if select(10, UnitAura("player", i)) == 16609 then
				worldbufffound = true
				break end
			end	
		elseif Setting("Ony_Nef")
		and not Setting("WCB") 
		and not Setting("ZG")
		then
			
			for i = 1, 40 do
				if select(10, UnitAura("player", i)) == 22888 then
				worldbufffound = true
				break end
			end	
		elseif Setting("ZG") 
		and not Setting("WCB") 
		and not Setting("Ony_Nef")		
		then
			
			for i = 1, 40 do
				if select(10, UnitAura("player", i)) == 24425 then
				worldbufffound = true
				break end
			end			
		end
		
		if worldbufffound then		
		DMW.Settings.profile.Rotation.WCB = false
		DMW.Settings.profile.Rotation.Ony_Nef = false
		DMW.Settings.profile.Rotation.ZG = false
		Logout()
		end
	end	
end

	--------------------------------------------------------------------------	

local function TranqshotMana()

	if Setting("Save Tranq Mana") 
	and BossID == 14020	-- Chromagus,
	or BossID == 11981	-- Flamegore,
	or BossID == 11982	-- Magmadar,
	or BossID == 15509	-- Princess Huhuran,
	or BossID == 15932	-- Gluth
	then
		TranqMana = 15
	else 
		TranqMana = 0
	end

end
 
	--------------------------------------------------------------------------	

local function Auto()
 --Autoshot
	if not IsAutoRepeatSpell(Spell.AutoShot.SpellName) 
	and (DMW.Time - ShotTime) > 0.5 
	and Target.Distance > 8 
	and not castingAShot
	and not castingAimed
	and not Player.Casting	
	and Spell.AutoShot:Cast(Target) 
	then
	StartAttack()
	ShotTime = DMW.Time
	return true
	end
  end

	--------------------------------------------------------------------------	

local function Defensive()
 --Aspect of the Monkey
	 if Setting("Aspect Of The Monkey") 
	 and Player.Combat  
	 and Player.HP < Setting("Aspect of the Monkey HP") 
	 and Player.PowerPct > 20  
	 and Target.Distance < 8 
	 and not Buff.AspectOfTheMonkey:Exist(Player)
	 and not castingAShot
	 and not Player.Casting
	 and Spell.AspectOfTheMonkey:Cast(Player) then
		return true 
	end
end

	--------------------------------------------------------------------------	

local function FeignSwap()
		
	-- if HUD.FeignDeath == 1 or HUD.FeignDeath == 2
	-- and Target 
	-- and Target.ValidEnemy
	-- and Player.Combat then
		-- threatPercent = select(3, Target:UnitDetailedThreatSituation())
		-- if threatPercent == nil then
			-- threatPercent = 0
		-- end
	-- end
	
	-- if HUD.FeignDeath == 1 
		 -- and Target 
		 -- and Target.ValidEnemy
		 -- and Player.Combat
		 -- and Player.IsTanking() --or threatPercent >= 115)
		 -- and Spell.FeignDeath:CD() == 0 
			-- then
				-- StopAttack() 
				-- SpellStopCasting()
				-- Spell.FeignDeath:Cast(Player)
				-- return true
	-- elseif HUD.FeignDeath == 2 
		 -- and Target 
		 -- and Target.ValidEnemy
		 -- and Player.Combat
		 -- and threatPercent >= Setting("% to FeignDeath")
		 -- and Spell.FeignDeath:CD() == 0 
			-- then
				-- StopAttack() 
				-- SpellStopCasting()
				-- Spell.FeignDeath:Cast(Player)
				-- return true
	-- end
			
			-- then
			-- StopAttack() 
			-- SpellStopCasting()
			-- PetPassiveMode()
			-- C_Timer.After(0.2, function() Spell.FeignDeath:Cast(Player) end )
			-- return true 
	-- end
	
	--Trinket Swap or Manual Cast Feign Death
	if Setting("Auto Swap Trinkets")
	and Player.IsFeign
	and not Player.Combat
	and (Item.DevilsaurEye:CD() > 1.6 or Item.Earthstrike:CD() > 1.6 or Item.JomGabbar:CD() > 1.6 or Item.BadgeoftheSwarmguard:CD() > 1.6) 
		then
		
		-- GetFeignDeathIndex()
		local slotId1, textureName1, checkRelic1 = GetInventorySlotInfo("Trinket0Slot")	--"Trinket0Slot" 1ter slot
		local slotId2, textureName2, checkRelic2 = GetInventorySlotInfo("Trinket1Slot")	--"Trinket1Slot" 2ter slot
		local swapfinished = false
		local swapfinishedslot1 = false
		local swapfinishedslot2 = false
		
			
			--if item equiped swap is finisched
			if Setting("Swap TrinketSlot 1") ~= 1
			and GetInventoryItemID("player", slotId1) == trinkettoswap1()
				then 
				swapfinishedslot1 = true
				
			--if setting is none swap is finisched	
			elseif Setting("Swap TrinketSlot 1") == 1
				then 
				swapfinishedslot1 = true
			end
	--------------------------------------------------------------------------			
			--if item equiped swap is finisched
			if Setting("Swap TrinketSlot 2") ~= 1
			and GetInventoryItemID("player", slotId2) == trinkettoswap2()
				then 
				swapfinishedslot2 = true
				
			--if setting is none swap is finisched	
			elseif Setting("Swap TrinketSlot 2") == 1
				then 
				swapfinishedslot2 = true
			end
	--------------------------------------------------------------------------	
	
			-- if both finisched then click away FD Buff
			if swapfinishedslot1
			and swapfinishedslot2
				then
				JumpOrAscendStart()
				return true
			end
			
	----------------------------------------------------------------------------
			
			if Setting("Swap TrinketSlot 1") ~= 1
				and not swapfinishedslot1
				and GetInventoryItemID("player", slotId1) ==  trinkettoswapout1()
				and (Item.DevilsaurEye:Equipped() or Item.JomGabbar:Equipped() or Item.Earthstrike:Equipped() or Item.BadgeoftheSwarmguard:Equipped())
				and not ReadyCooldown()
				then 
					EquipItemByName(trinkettoswap1(), slotId1)
					return true
			end
			
	----------------------------------------------------------------------------
			
			if Setting("Swap TrinketSlot 2") ~= 1
				and not swapfinishedslot2
				and GetInventoryItemID("player", slotId2) ==  trinkettoswapout2() 
				and (Item.DevilsaurEye:Equipped() or Item.JomGabbar:Equipped() or Item.Earthstrike:Equipped() or Item.BadgeoftheSwarmguard:Equipped())
				and not ReadyCooldown()
					then 
						EquipItemByName(trinkettoswap2(), slotId2)
						return true
			end
	
	
		return true
	end		

end

	--------------------------------------------------------------------------	

local function ReadyCooldown()
			ReadyCooldownCountValue = 0
			
			if Item.DevilsaurEye:Equipped() 
			and Item.DevilsaurEye:CD() == 0
			then 
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			end
			
			if Spell.RapidFire:Known()
			and Spell.RapidFire:CD() == 0
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Spell.BerserkingTroll:Known()
			and Spell.BerserkingTroll:CD() == 0 
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Spell.BloodFury:Known() 
			and Spell.BloodFury:CD() <= 1.6
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end

			if Item.Earthstrike:Equipped()
			and Item.Earthstrike:CD() <= 1.6	
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1 
			end	
			
			if Item.JomGabbar:Equipped() 
			and Item.JomGabbar:CD() <= 1.6	
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if Item.BadgeoftheSwarmguard:Equipped() 
			and Item.BadgeoftheSwarmguard:CD() <= 1.6	
			then
				ReadyCooldownCountValue = ReadyCooldownCountValue + 1
			end
			
			if ReadyCooldownCountValue > 0 
			then return true
			
			elseif ReadyCooldownCountValue == 0
			then return false
			end	
end

	--------------------------------------------------------------------------	

local function CoolDowns()

		if Item.DevilsaurEye:Equipped() 
		and Item.DevilsaurEye:CD() == 0
		then 
			if Item.DevilsaurEye:Use(Player) then return true end
			
		elseif Spell.RapidFire:Known()
			and Player.PowerPct >= 5
			and Spell.RapidFire:CD() == 0
			then
				if Spell.RapidFire:Cast(Player) then return true end
			
		elseif Item.Earthstrike:Equipped()
			and Item.Earthstrike:CD() <= 1.6
			then
				if Item.Earthstrike:Use(Player) then return true end
					
		elseif Item.JomGabbar:Equipped() 
			and Item.JomGabbar:CD() <= 1.6
			then
				if Item.JomGabbar:Use(Player) then return true end
				
		elseif Item.BadgeoftheSwarmguard:Equipped() 
			and Item.BadgeoftheSwarmguard:CD() <= 1.6
			then
				if Item.BadgeoftheSwarmguard:Use(Player) then return true end
				
		elseif Spell.BloodFury:Known() 
			and Spell.BloodFury:CD() <= 1.6
			and Player.PowerPct >= 5
			then
				if Spell.BloodFury:Cast(Player) then return true end
			
		elseif Spell.BerserkingTroll:Known()
			and Player.PowerPct >= 5
			and Spell.BerserkingTroll:CD() == 0 
			then
				if Spell.BerserkingTroll:Cast(Player) then return true end
		else return true
		end

end

	--------------------------------------------------------------------------	
 
 local function findPetButton()

			if GetPetActionInfo(1) == (GetSpellInfo(24597) or GetSpellInfo(24604) or GetSpellInfo(24605) or GetSpellInfo(24603))
			then 
				FHowlPetButton = 1
				return true
			elseif GetPetActionInfo(2) == (GetSpellInfo(24597) or GetSpellInfo(24604) or GetSpellInfo(24605) or GetSpellInfo(24603))
			then 
				FHowlPetButton = 2
				return true
			elseif GetPetActionInfo(3) == (GetSpellInfo(24597) or GetSpellInfo(24604) or GetSpellInfo(24605) or GetSpellInfo(24603))
			then 
				FHowlPetButton = 3
				return true
			elseif GetPetActionInfo(4) == (GetSpellInfo(24597) or GetSpellInfo(24604) or GetSpellInfo(24605) or GetSpellInfo(24603))
			then 
				FHowlPetButton = 4
				return true
			elseif GetPetActionInfo(5) == (GetSpellInfo(24597) or GetSpellInfo(24604) or GetSpellInfo(24605) or GetSpellInfo(24603))
			then 
				FHowlPetButton = 5
				return true
			elseif GetPetActionInfo(6) == (GetSpellInfo(24597) or GetSpellInfo(24604) or GetSpellInfo(24605) or GetSpellInfo(24603))
			then 
				FHowlPetButton = 6
				return true
			elseif GetPetActionInfo(7) == (GetSpellInfo(24597) or GetSpellInfo(24604) or GetSpellInfo(24605) or GetSpellInfo(24603))
			then 
				FHowlPetButton = 7
				return true
			elseif GetPetActionInfo(8) == (GetSpellInfo(24597) or GetSpellInfo(24604) or GetSpellInfo(24605) or GetSpellInfo(24603))
			then 
				FHowlPetButton = 8
				return true
			elseif GetPetActionInfo(9) == (GetSpellInfo(24597) or GetSpellInfo(24604) or GetSpellInfo(24605) or GetSpellInfo(24603))
			then 
				FHowlPetButton = 9
				return true
			elseif GetPetActionInfo(10) == (GetSpellInfo(24597) or GetSpellInfo(24604) or GetSpellInfo(24605) or GetSpellInfo(24603))
			then 
				FHowlPetButton = 10
				return true
			end
end		
 
	--------------------------------------------------------------------------	

local function AimedMacro()
		if castingAimed and not AimedMacroDone and Target and Target.ValidEnemy and not Target.Dead then 
				ClearTarget()
				C_Timer.After(0.1, function() TargetLastTarget() end )
				AimedMacroDone = true
				return true
		end

end
 
 	--------------------------------------------------------------------------	
 
--FuriousHowl by Pet
local function petbuff()
		Locals()
		if Setting("FuriousHowl if pulled back")
		and findPetButton()
		and Player.Combat
		and (GetPetActionCooldown(FHowlPetButton) == 0)
		and Setting("Pet Pullback at mend Pet HP")
		and (Pet.HP < Setting("Mend Pet HP") or HUD.PetAttack == 2) 
		and Pet and not Pet.Dead
		and CTimer > 5
		then
		        CastPetAction(FHowlPetButton)
		end
end

	--------------------------------------------------------------------------	

local function AutoTargetAndFacing()

-- Auto Face the Target
    if Setting("AutoFace")
		and Player.Combat 
		and Target
		and Target.ValidEnemy
		and Target.Distance <= 41
		and not UnitIsFacing("player", Target.Pointer,180) then
            FaceDirection(Target.Pointer, true)
			return true       
    end

-- Auto targets Enemy in Range
    if Setting("TargetMarkedMobs") 
	and Player.Combat
	and (not Target or not Target.ValidEnemy or Target.Dead or not ObjectIsFacing("Player", Target.Pointer, 120) 
	or IsSpellInRange("AutoShot", "target") == 0) 
		then
		for _, Unit in ipairs(Enemy41Y) do
	--------------------------------------------------------------------------	ranged		
			if GetRaidTargetIndex(Unit.Pointer) == 8
			and Unit.Distance > 8
				then 
				TargetUnit(Unit.Pointer)
				return true
			elseif GetRaidTargetIndex(Unit.Pointer) == 7
			and Unit.Distance > 8
				then 
				TargetUnit(Unit.Pointer)
				return true
			elseif GetRaidTargetIndex(Unit.Pointer) == 6
			and Unit.Distance > 8
				then 
				TargetUnit(Unit.Pointer)
				return true			
			elseif GetRaidTargetIndex(Unit.Pointer) == 5
			and Unit.Distance > 8
				then 
				TargetUnit(Unit.Pointer)
				return true	
			elseif GetRaidTargetIndex(Unit.Pointer) == 4
			and Unit.Distance > 8
				then 
				TargetUnit(Unit.Pointer)
				return true	
			elseif GetRaidTargetIndex(Unit.Pointer) == 3
				and Unit.Distance > 8
				then 
				TargetUnit(Unit.Pointer)
				return true					
			elseif GetRaidTargetIndex(Unit.Pointer) == 2
				and Unit.Distance > 8
				then 
				TargetUnit(Unit.Pointer)
				return true					
			elseif GetRaidTargetIndex(Unit.Pointer) == 1
				and Unit.Distance > 8
				then 
				TargetUnit(Unit.Pointer)
				return true	
	--------------------------------------------------------------------------	melee				
			elseif GetRaidTargetIndex(Unit.Pointer) == 8
			and Unit.Distance <= 8
				then 
				TargetUnit(Unit.Pointer)
				return true
			elseif GetRaidTargetIndex(Unit.Pointer) == 7
			and Unit.Distance <= 8
				then 
				TargetUnit(Unit.Pointer)
				return true
			elseif GetRaidTargetIndex(Unit.Pointer) == 6
			and Unit.Distance <= 8
				then 
				TargetUnit(Unit.Pointer)
				return true			
			elseif GetRaidTargetIndex(Unit.Pointer) == 5
			and Unit.Distance <= 8
				then 
				TargetUnit(Unit.Pointer)
				return true	
			elseif GetRaidTargetIndex(Unit.Pointer) == 4
			and Unit.Distance <= 8
				then 
				TargetUnit(Unit.Pointer)
				return true	
			elseif GetRaidTargetIndex(Unit.Pointer) == 3
				and Unit.Distance <= 8
				then 
				TargetUnit(Unit.Pointer)
				return true					
			elseif GetRaidTargetIndex(Unit.Pointer) == 2
				and Unit.Distance <= 8
				then 
				TargetUnit(Unit.Pointer)
				return true					
			elseif GetRaidTargetIndex(Unit.Pointer) == 1
				and Unit.Distance <= 8
				then 
				TargetUnit(Unit.Pointer)
				return true					
				
			end
		end
	end

end

	--------------------------------------------------------------------------	

local function Utility()
	Locals()
	
-- Pet management
	if Setting("Call Pet") 
	and (not Pet or Pet.Dead) 
	and not castingAShot
	and not Player.Casting
    and not castingAShot	
	and Spell.CallPet:Cast(Player) then
            return true 
	end

--Mend Pet
	if Setting("Mend Pet") 
	and Player.Combat 
	and not Player.Moving 
	and Pet and not Pet.Dead 
	and Pet.HP <= Setting("Mend Pet HP") 
	and Player.PowerPct > 30 
	and not castingAShot
	and not Player.Casting
	and not Spell.MendPet:LastCast() 
	and Spell.MendPet:Cast(Pet) then
        return true
	end

	-- Revive Pet	find a way to check if we dont have active pet or dismissed it . 
	--if Setting("Revive Pet") and (Pet.Dead) and Spell.RevivePet:Cast(Player) then
    --     return true 
	--end
	
-- Aspect of the Cheetah
	if Setting("Aspect Of The Cheetah") 
	and not Player.Combat 
	and Player.CombatLeftTime > 8 
	and not Spell.AspectOfTheHawk:LastCast() 
	and Player.Moving 
	and not Buff.AspectOfTheCheetah:Exist(Player) 
	and Spell.AspectOfTheCheetah:Cast(Player) then
		return true
	end

-- Trueshot Selfbuff

	if Setting("TrueShot Buff") 
	and not Player.Combat
	and not Player.Casting
    and not castingAShot	
	and not Buff.TrueshotAura:Exist(Player) 
	and Player.PowerPct > 80 
	and Spell.TrueshotAura:Cast(Player) then
		return true
	end
	
-- Sapper Charge
	if Setting("Use Sapper Charge")
	and Player.Combat
	and (DMW.Time - ItemUsage) > 1.5 
	and not Player.Casting
    and not castingAShot
	and Enemy10YC ~= nil
	and Enemy10YC >= Setting("Enemys 10Y")
	and GetItemCount(Item.GoblinSapperCharge.ItemID) >= 1
	and Item.GoblinSapperCharge:CD() == 0 
		then 
		Item.GoblinSapperCharge:Use(Player)
		ItemUsage = DMW.Time
		return true
	end

-- Granates and dynamite
	if Setting("Use Trowables") >= 1
	and Target
	and Player.Combat
	and (DMW.Time - ItemUsage) > 1.5 
	and not Player.Casting
    and not castingAShot
	and Target5YC ~= nil
	and Target5YC >= Setting("Enemys 5Y around Target")
	and Target.Facing
	then
		if Setting("Use Trowables") == 2
		then
			if GetItemCount(Item.DenseDynamite.ItemID) >= 1
			and Target.Distance <= 30
			and Item.DenseDynamite:CD() == 0 
			then 
				Item.DenseDynamite:UseGround(Target)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(Item.ThoriumGrenade.ItemID) >= 1
			and Target.Distance <= 45
			and Item.ThoriumGrenade:CD() == 0 
			then 
				Item.ThoriumGrenade:UseGround(Target)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(Item.EZThroDynamitII.ItemID) >= 1
			and Target.Distance <= 30
			and Item.EZThroDynamitII:CD() == 0 
			then 
				Item.EZThroDynamitII:UseGround(Target)
				ItemUsage = DMW.Time
				return true				
			elseif GetItemCount(Item.IronGrenade.ItemID) >= 1
			and Target.Distance <= 45
			and Item.IronGrenade:CD() == 0 
			then 
				Item.IronGrenade:UseGround(Target)
				ItemUsage = DMW.Time
				return true	
			end
			
		elseif Setting("Use Trowables") == 3
			and GetItemCount(Item.DenseDynamite.ItemID) >= 1
			and Target.Distance <= 30
			and Item.DenseDynamite:CD() == 0 
			then 
				Item.DenseDynamite:UseGround(Target)
				ItemUsage = DMW.Time
				return true
		elseif Setting("Use Trowables") == 4
			and GetItemCount(Item.EZThroDynamitII.ItemID) >= 1
			and Target.Distance <= 30
			and Item.EZThroDynamitII:CD() == 0 
			then 
				Item.EZThroDynamitII:UseGround(Target)
				ItemUsage = DMW.Time
				return true		
		elseif Setting("Use Trowables") == 5
			and GetItemCount(Item.ThoriumGrenade.ItemID) >= 1
			and Target.Distance <= 45
			and Item.ThoriumGrenade:CD() == 0 
			then 
				Item.ThoriumGrenade:UseGround(Target)
				ItemUsage = DMW.Time
				return true		
		elseif Setting("Use Trowables") == 6
			and GetItemCount(Item.IronGrenade.ItemID) >= 1
			and Target.Distance <= 45
			and Item.IronGrenade:CD() == 0 
			then 
				Item.IronGrenade:UseGround(Target)
				ItemUsage = DMW.Time
				return true			
		
		end
	end


-- Use best available Healf potion --
	if Setting("Use Best HP Potion") then
		if HP <= Setting("Use Potion at #% HP") and Player.Combat and not Player.Casting and not castingAShot and (DMW.Time - ItemUsage) > 1.5 then
			if GetItemCount(13446) >= 1 and GetItemCooldown(13446) == 0 then
				name = GetItemInfo(13446)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true 
			elseif GetItemCount(3928) >= 1 and GetItemCooldown(3928) == 0 then
				name = GetItemInfo(3928)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(1710) >= 1 and GetItemCooldown(1710) == 0 then
				name = GetItemInfo(1710)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(929) >= 1 and GetItemCooldown(929) == 0 then
				name = GetItemInfo(929)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(858) >= 1 and GetItemCooldown(858) == 0 then
				name = GetItemInfo(858)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(118) >= 1 and GetItemCooldown(118) == 0 then
				name = GetItemInfo(118)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			end
		end
	end
  
--Use "Healthstone" 
	if Setting("Healthstone")
	and Player.Combat
	and (DMW.Time - ItemUsage) > 1.5 
	and not Player.Casting
    and not castingAShot
    and HP < Setting("Use Healthstone at #% HP") 
    and (Item.MajorHealthstone:Use(Player) 
    or Item.GreaterHealthstone:Use(Player) 
    or Item.Healthstone:Use(Player) 
    or Item.LesserHealthstone:Use(Player) 
    or Item.MinorHealthstone:Use(Player)) 
	then
        ItemUsage = DMW.Time 
		return true
    end


	
-- Use Demonic or Dark Rune --
	if Setting("Use Demonic or Dark Rune") and Target and Target.ValidEnemy and Target.TTD > 6 and Target:IsBoss() and HP > 60 	and not Player.Casting and not castingAShot and (DMW.Time - ItemUsage) > 1.5 then
		if Power <= Setting("Use Rune at #% Mana") and Player.Combat then
			if GetItemCount(12662) >= 1 and GetItemCooldown(12662) == 0 then
				name = GetItemInfo(12662)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true 
			elseif GetItemCount(20520) >= 1 and GetItemCooldown(20520) == 0 then
				name = GetItemInfo(20520)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true	
			end
		end
	end	

-- Use best available Mana potion --
	if Setting("Use Best Mana Potion") and Target and Target.ValidEnemy and Target.TTD > 6 and Target:IsBoss() 	and not Player.Casting and not castingAShot and (DMW.Time - ItemUsage) > 1.5 then
		if Power <= Setting("Use Potion at #% Mana") and Player.Combat then
			if GetItemCount(13444) >= 1 and GetItemCooldown(13444) == 0 then
				name = GetItemInfo(13444)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true 
			elseif GetItemCount(13443) >= 1 and GetItemCooldown(13443) == 0 then
				name = GetItemInfo(13443)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(6149) >= 1 and GetItemCooldown(6149) == 0 then
				name = GetItemInfo(6149)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(3827) >= 1 and GetItemCooldown(3827) == 0 then
				name = GetItemInfo(3827)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(3385) >= 1 and GetItemCooldown(3385) == 0 then
				name = GetItemInfo(3385)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			elseif GetItemCount(2455) >= 1 and GetItemCooldown(2455) == 0 then
				name = GetItemInfo(2455)
				RunMacroText("/use " .. name)
				ItemUsage = DMW.Time
				return true
			end
		end
	end
 end

	--------------------------------------------------------------------------	
 
local function Shots()	
	Locals()

		
--Auto Shot		
						
		if  Target.Facing then 		
			Auto() 
		end		
		
--TranquilizingShot (if Boss goes Enrage)
		if Setting("Tranq Shot")
		    and Spell.TranquilizingShot:Known()
			and BossEnraged 
			and MyTranq
			and Target.Facing
			and Target:IsBoss()
	    	then 
				StopAttack() 
				SpellStopCasting()				
				if Spell.TranquilizingShot:Cast(Target) then
					return true
				end
		end	
	

--Concussive Shot  ( fix if mob targets you  or pet lost threat)
		if Setting("Concussiv Shot") 
	    	and Target.Distance < Setting("Concussiv Shot Distance") 
	    	and Target.Facing 
	    	and Target.Distance > 8
	    	and not castingAShot
	        and not Player.Casting
			and Player.PowerPct > TranqMana
	    	and not (Target.CreatureType == "Totem") 
	    	and Spell.ConcussiveShot:Cast(Target) then
			    return true
		end

--Serpent Sting
		if Setting("Serpent Sting") 
	    	and HUD.Serpent == 1 
	    	and Target.Facing 
	    	and not Player.Casting
	    	and not castingAShot
	    	and Target.Distance > 8  
	    	and Player.PowerPct > 6
			and Player.PowerPct > TranqMana			
	    	and Target.TTD > 5
	    	and not (Target.CreatureType == "Mechanical" or Target.CreatureType == "Elemental" or CreatureType == "Totem") 
	    	and not Debuff.SerpentSting:Exist(Target) 
	    	and Spell.SerpentSting:Cast(Target) then
                return true
        end


--Calculating Reload percentage before goeing throug Aimedshot

		
		-- print("------")
		-- print ("is reloading ")
		-- print (isReloading)
		-- print (castingAShot)
		-- print("------")
		-- print (reloadInMoment)
		
		
		if ReloadPercentage() then return true
		end

		
--Aimed shot Clipped Rotation		
		if Setting("Aimed Shot")
		    and Setting("Clipped Rotation") 
		    and Target.Facing 
			and Target.HealthMax >= 5000
		    and not Player.Casting
		    and Spell.AimedShot:IsReady()
		    and Target.Distance > 8 
		    and Player.PowerPct > 3
			and Player.PowerPct > TranqMana			
		    and Target.TTD > 4
		    and not (Target.CreatureType == "Totem") 
		    and not Player.Moving
			and not Player.Casting
			and not castingAShot
			and not castingAimed
			and reloadInMoment <= (reloadTime - 600) 
		    and Spell.AimedShot:Cast(Target) 		
		then	
			return true
			
		elseif Setting("Arcane if moving")
		    and Target.Facing 
		    and not Player.Casting
		    and Spell.ArcaneShot:IsReady()
		    and Target.Distance > 8 
		    and Player.PowerPct > 3
			and Player.PowerPct > TranqMana				
		    and not (Target.CreatureType == "Totem") 
		    and Player.Moving 
			and Spell.ArcaneShot:Cast(Target)
		then
                return true
        end	
		
--Aimed shot full Rotation
		if Setting("Aimed Shot") 
			and not Setting("Clipped Rotation") 
		    and Target.Facing 
			and Target.HealthMax >= 5000
		    and not Player.Casting
		    and Spell.AimedShot:IsReady()
		    and Target.Distance > 8 
		    and Player.PowerPct > 3
			and Player.PowerPct > TranqMana			
		    and Target.TTD > 4
		    and not (Target.CreatureType == "Totem") 
		    and not Player.Moving
			and not Player.Casting
			and not castingAShot
			and not castingAimed
			and reloadInMoment <= 200  
		    and Spell.AimedShot:Cast(Target) 		
		then
			return true
				
		elseif Setting("Arcane if moving")
		    and Target.Facing 
		    and not Player.Casting
		    and Spell.ArcaneShot:IsReady()
		    and Target.Distance > 8 
		    and Player.PowerPct > 3
			and Player.PowerPct > TranqMana				
		    and not (Target.CreatureType == "Totem") 
		    and Player.Moving 
			and Spell.ArcaneShot:Cast(Target)
		then
                return true
        end	

--Multi shot
		if Setting("Multi Shot")
		    and HUD.Multi == 1 
		    and Target.Facing 
		    and not Player.Casting
		    and Spell.MultiShot:IsReady()
			and Spell.AutoShot:LastCast()
		    and Target.Distance > 8 
		    and Player.PowerPct > 3
			and Player.PowerPct > TranqMana	
		    and Target.TTD > 2
		    and not (Target.CreatureType == "Totem") 
		    and not Player.Moving 
			and not castingAShot
			-- and reloadPercent <= 50
			and reloadInMoment <= (reloadTime - 600) 
		    and Spell.MultiShot:Cast(Target) then
                return true
        end		


--Arcane Shot	
		if Setting("Arcane Shot") 
	    	and Target.Facing 
	    	and not Player.Casting
	    	and Spell.ArcaneShot:IsReady()
	    	and Target.Distance > 8 
	    	and Player.PowerPct > 4
			and Player.PowerPct > TranqMana				
	    	and not (Target.CreatureType == "Totem")
			and not castingAShot			
	    	and Spell.ArcaneShot:Cast(Target) then
                return true
		end		
end  

	--------------------------------------------------------------------------	

local function huntermeleeattacks()	
	Locals()
--Melee
		if  Target.Distance < 6 and  Target.Facing  
			then
		    StartAttack()
		end			
--Raport Strike
		if Setting("RaptorStrike") and Target.Facing and  Target.Distance < 5 
		and  Target.TTD > 2 and Spell.RaptorStrike:Cast(Target) 
			then			
		end
--Mongoose Bite		
		if Setting("MongooseBite") and Target.Facing and  Target.Distance < 5  
		and Spell.MongooseBite:IsReady() and Spell.MongooseBite:Cast(Target) 
			then
		end
--Wing Clip 
		if Setting("WingClip") and  Target.Facing and  Target.Distance < 5 
		and not Debuff.WingClip:Exist(Target) and not (Target.CreatureType == "Totem") and Spell.WingClip:Cast(Target) 
			then
			return true
		elseif Setting("WingClipRank1") and  Target.Facing and  Target.Distance < 5 
		and not Debuff.WingClip:Exist(Target) and not (Target.CreatureType == "Totem") and Spell.WingClip:Cast(Target,1) 
			then
			return true
		end			
end	

	--------------------------------------------------------------------------	

function Hunter.Rotation()

	
    Locals()
	
	if Setting("Print ISEnraged")
	then
		print("Boss enraged:",BossEnraged)
	end
	
	if Setting("Print EnrageNR")
	then
		print("EnrageNR:",EnrageNR)
	end	
	
	if Setting("MyTranq")
	then
		print("MyTranq",MyTranq)
	end


	
		
	if AutoTargetAndFacing()then return true
	end

-- Feign death function also for Trinket swapping
	if FeignSwap()
		then return true
	end
	
--Burst Opener
		if Setting("Use Opener Rotation")
			then
			
			if aimednumber >= 1
				and Target
				and Target.Facing 
				and CDs
				and ReadyCooldown()
				and Spell.AimedShot:CD() <= 4
					then 
					if CoolDowns() 
						then return true 
					end
						
			elseif Setting("Use Opener Rotation")
			and Setting("FD in Opener Roration")
			and aimednumber >= 3
			and Spell.FeignDeath:CD() == 0
			and	(Item.DevilsaurEye:Equipped() or Item.Earthstrike:Equipped() or Item.JomGabbar:Equipped() or Item.BadgeoftheSwarmguard:Equipped())
			and (Item.DevilsaurEye:CD() > 1.6 or Item.Earthstrike:CD() > 1.6 or Item.JomGabbar:CD() > 1.6 or Item.BadgeoftheSwarmguard:CD() > 1.6) 
			-- and not Buff.Earthstrike:Exist(Player)
			-- and not Buff.JomGabbar:Exist(Player)
			-- and not Buff.BadgeoftheSwarmguard:Exist(Player)
			and not Buff.DevilsaurFury:Exist(Player)
			and not Buff.RapidFire:Exist(Player)
			and not Buff.BloodFury:Exist(Player)
			and not Buff.BerserkingTroll:Exist(Player)
			and not Player.Casting
			and not castingAShot
			and Player.Combat
			and not ReadyCooldown()
				then 
					PetPassiveMode()
					StopAttack() 
					SpellStopCasting()
					C_Timer.After(0.5, function() Spell.FeignDeath:Cast(Player) end)
					return true 
					
					
			end


		end

	if AimedMacro() then return true 
	end
	
	if TranqshotMana() then return true 
	end

	if Utility() then return true 
	end

-- and Target.ValidEnemy
	if Target and Target.ValidEnemy and Target.Distance < 41 then
		if Defensive() then
			return true
		end

--Aspect of the Hawk
		if Setting("Aspect of the Hawk")
			and (BossID == 15299 --viscidus
			or BossID == 15509) --huhuran
			and not Player.Casting 
			and not castingAShot 
			and not Buff.AspectOfTheWild:Exist(Player) 
			and Player.PowerPct > 30 
			and Spell.AspectOfTheWild:Cast(Player)
				then 
					return true 

		elseif Setting("Aspect of the Hawk") 
			and (not BossID == 15299 --viscidus
			or not BossID == 15509) --huhuran
			and not Player.Casting 
			and not castingAShot 
			and Target.Distance > 8 
			and (not Buff.AspectOfTheHawk:Exist(Player) or Buff.AspectOfTheMonkey:Exist(Player)) 
			and Player.PowerPct > 30 
			and Spell.AspectOfTheHawk:Cast(Player) 
				then 
					return true
			
		end	 
	
--Pet Auto		
        if Setting("Auto Pet Attack")
			and HUD.PetAttack == 1 
            and not Setting("Pet Pullback at mend Pet HP") 
            and Pet and not Pet.Dead 
            and not UnitIsUnit(Target.Pointer, "pettarget") 
            then
        PetAttack()
            elseif Setting("Auto Pet Attack")
                and Setting("Pet Pullback at mend Pet HP")
                and Pet and not Pet.Dead 
                --and not UnitIsUnit(Target.Pointer, "pettarget")
                and Pet.HP < Setting("Mend Pet HP")
                then
            PetPassiveMode()
                elseif Setting("Auto Pet Attack")
                and Setting("Pet Pullback at mend Pet HP")
				and HUD.PetAttack == 1
                and Pet and not Pet.Dead 
                and not UnitIsUnit(Target.Pointer, "pettarget")
                and Pet.HP > Setting("Send Pet back in")
                then
                PetAttack() 
        end
		

--Hunter's Mark RAID
		if (Setting("HuntersMark") or Setting("Allways HuntersMark"))
        and Target.Facing 
        and not Player.Casting
        and not castingAShot
		and Player.PowerPct > TranqMana 
		and Player.PowerPct > 10
        and Target.Distance <= 48
		and (Target.Health >= 20000 or Setting("Allways HuntersMark"))
        and (Target.TTD > 8 or Setting("Allways HuntersMark"))
		and (not Target.ObjectID == 15275 --Emperor Vek AQ;Lava Reaver;Lava Surger;Lava Elemental;Blackwing Spellbinder
		or not Target.ObjectID == 12100
		or not Target.ObjectID == 12101 
		or not Target.ObjectID == 12076
		or not Target.ObjectID == 12457) 
		and not Markisup
		and not Debuff.HuntersMark:Exist(Target) 
        and not (Target.CreatureType == "Totem")  
        and Spell.HuntersMark:Cast(Target) then
                return true
				
        end
		
		petbuff()

		
--Shots fired or Switch Meele	
		

		if Target.Facing 
		and not Setting("Wait until PetAggro")
		and Target.Distance < 41 
		and Target.Distance > 8 then
			Shots()
			return true
		
		elseif Target.Facing
		and Target.Distance < 41 
		and Target.Distance > 8	
		and Setting("Wait until PetAggro")
		and (Setting("Seconds for PetAggro") > 0 or Setting("Target HP <") < 100)
			then
			if Setting("Seconds for PetAggro") > 0
			and CTimer >= Setting("Seconds for PetAggro")
				then
				Shots()
				return true
			elseif Setting("Target HP <") < 100
			and Target.HP <= Setting("Target HP <")
				then
				Shots()
				return true
			end

		elseif Target.Facing 
		and Target.Distance <= 8 
		and Target.Distance >= 6 then
			StopAttack()
			return true
		
		elseif Target.Facing 
		and Target.Distance < 6 then
			huntermeleeattacks()
			return true
		end	
		
   	end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
eventFrame:RegisterEvent("UNIT_AURA");
eventFrame:RegisterEvent("ENCOUNTER_START");
eventFrame:RegisterEvent("ENCOUNTER_END");
eventFrame:RegisterEvent("START_AUTOREPEAT_SPELL");
eventFrame:RegisterEvent("STOP_AUTOREPEAT_SPELL");


eventFrame:SetScript("OnEvent", function(self, event, ...)
	if(event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
		CombatLogEvent(CombatLogGetCurrentEventInfo());
	elseif(event == "UNIT_SPELLCAST_INTERRUPTED") then
		SpellInterrupted(...);
	elseif event == "START_AUTOREPEAT_SPELL" then
        OnStartAutorepeatSpell();
    elseif event == "STOP_AUTOREPEAT_SPELL" then
        OnStopAutorepeatSpell();	
	elseif(event == "PLAYER_ENTERING_WORLD") then
		GetQuiverInfo();
		updateRequired = true;
	elseif(event == "ENCOUNTER_START") then
		ENCOUNTER_START(encounterID, name, difficulty, size)
	    EnrageNR = 0;
	elseif(event == "ENCOUNTER_END") then
		ENCOUNTER_END(encounterID, name, difficulty, size)
	    EnrageNR = 0;
	elseif (event == "UNIT_AURA") and DMW.UI.MinimapIcon then
		Buffsniper()
	end
end)