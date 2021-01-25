# DMWC-HunterMod
-Mod with additional functions (base frome Biggie)

* there is a DMWC fork in my git (pls use it or the rotation might not work correctily until it gets merged to main git)

## Supported Trinkets/Consumables

* DevilsaurEye
* Earthstrike
* JomGabbar
* BadgeoftheSwarmguard
* SapperCharges
* Nates and Dynamite(this needs additional work)
* Heal and Mana pots
* Demonic/Dark Runes

## Todo:
 
* back switch of trinkets on the second feign death
* ??? Tell me more

## Changelog

## 25.01.2021

* HunterMark fix
* changed some checks for dynamite (to not be executed every time)

## 07.12.2020

* removed Aimed Macro (not needed anymore)

## 09.09.2020

* removed testing Status from tranqshot part
* moved save tranq mana to tranqshot tap
* save tranq mana can be ticked cause it will auto activate if its a bossfight where tranq is needed

## 05.09.2020

* fixed tranqshot really ;-)

## 03.09.2020

* removed toggle Min.ready Colldowns cause of problems with the rotation
* fixed the tranqfunction!!! really now!!!
* removed the second enrage check (useless)
* Cooldowns at the same time as Quickshots proc will work now

## 31.08.2020

* changed fix mana % to actual cost of the spells
* save tranqmana is only active on tranqshotbosses
* save tranqmana now saves 3 times the tranqshotcost

## 29.08.2020

* reorder settings of the rotation
* added min ready cooldown count to use cds
* added CDs on quickshots proc toggle
* fixed that trinket swap function gets triggerd on manual FD
* added FD on aggro checkbox
* removed FD from HUD settings
* added toggle for LOG and Debug window
* added Number of hunters in Tranqrota
* fixed the tranqorder... dont know what i was thinking

## 28.08.2020

* alot of small code changes (noticed while raiding)
* fixes for item usage
* added healthstone usage with settings

## 27.08.2020

* added engineering items (sapper charge, nades, dynamite) !!! will work with my DMWC fork or after merge!!!
* added trinket swapping selectable...atm only once after burst rotation (missing buffID of Earthstrike, JomGabbar and BadgeoftheSwarmguard) 
* tried to make traqshot working correct(needs testing)
* added switches for melee attacks
* will use aspekt of the wild (hawk checked) wenn fighting huhuran or viscidus
* blacklisted Emperor Vek AQ,Lava Reaver,Lava Surger,Lava Elemental,Blackwing Spellbinder for hunters mark
* added my worldbuff sniper (will log you out after you get the buff, pls only chek one buff at a time)
* added Autofacing option
* added autotarget Raidmarks if in range for shots in order from skull to star after that for meele(https://wow.gamepedia.com/API_GetRaidTargetIndex)

## 20.04.2020

* small changes to hunters mark table and conditions for casting
* use the allways hunters mark if you want to ignore time to die and target health

## 18.04.2020

* added Error fix for C_Timer not working at Aimed Macro
* added a Allways HuntersMark checkbox, which will ignore Time to die
* fixed Hunters Mark

## 10.04.2020

* fixed AimedMacro
* blacklisted HunterMark immune Targets (gimme feedback about others plx)
* comment out the feign death petpullback part cause it was crashing the game

## 03.04.2020

* added delay and pet pullback when queued feign death happens for trinket swapping (Itemrack)
* minor changes
* Known BUGS: Hunters Mark immun Targets (BWL Spellbinders) are a problem (infinite recasting)

## 29.03.2020

* added Feign Death (incl. Main Switch, 90% Aggro or if Aggro)
* fixed wait for Pet Aggro with Target.HP (was not working)
* removed Hunters Mark main switch cause Mark is working since Update from 22.03.2020
* BUG: Tranq function recognizes the enrage but dont fires the shot (need to have a look)

## 22.03.2020

* added second aggro setting for farming with HP of the Target
* Fixed Hunters Mark, recognices also marks from other Hunters
* (unitbuff unitdebuff or unitaura ony working <50 yards since spyaddon range reduce)
* added hopefully working Frenzy/enrage recognition (This is now under Testing Tab; also only working within 50 yards)
* added hunter macro to reduce/fixe the aimeddelay bug from blizzard

## 15.03.2020

* Ground funktions and shots are working
* Clipped and Full Rotation are working
* Multi only when recharging
* restructuring Settings Tab (Not working things got seperated)
* Tranqshot is a mess and enrage recognition is not working -.-
* my code itself is a mess but it seems to work (needs a cleanup)

### Have Fun Testing ;)
