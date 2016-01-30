if GetObjectName(GetMyHero()) ~= "Kindred" then return end

require('Inspired')

KindredM = Menu("Kindred", "Kindred")
KindredM:SubMenu("Combo", "Combo")
KindredM.Combo:Boolean("Q", "Use Q", true)
KindredM.Combo:Boolean("QM", "Use Q to mouse", true)
KindredM.Combo:Boolean("W", "Use W", true)
KindredM.Combo:Boolean("E", "Use E", true)
KindredM.Combo:Boolean("R", "Use R", true)

KindredM:SubMenu("JungleClear", "JungleClear")
KindredM.JungleClear:Boolean("Q", "Use Q", true)
KindredM.JungleClear:Boolean("QM", "Use Q to mouse", true)
KindredM.JungleClear:Boolean("W", "Use W", true)
KindredM.JungleClear:Boolean("E", "Use E", false)

KindredM:SubMenu("LaneClear", "LaneClear")
KindredM.LaneClear:Boolean("Q", "Use Q", false)
KindredM.LaneClear:Boolean("QM", "Use Q to mouse", false)
KindredM.LaneClear:Boolean("W", "Use W", false)
KindredM.LaneClear:Boolean("E", "Use E", false)

KindredM:SubMenu("Misc", "Misc")
KindredM.Misc:Boolean("Item","Use items", true)
KindredM.Misc:Boolean("Autolvl", "Auto level", false)
KindredM.Misc:Key("Flee", "Flee with Q to mouse", string.byte("G"))

OnTick(function(myHero)
   local target = GetCurrentTarget()
   
-----Call items function------
	UseItems(target)
			
---COMBO---
	if IOW:Mode() == "Combo" then
	--CAST W
		if ValidTarget(target, 700) and KindredM.Combo.W:Value() then
			if CanUseSpell(myHero, _W) == READY then
				CastSpell(_W)
			end			
		end
--CAST Q
		if ValidTarget(target, 550) then
				local QPred = GetPredictionForPlayer(myHeroPos(),target,GetMoveSpeed(target),1700,250,750,50,false,true)
				if KindredM.Combo.Q:Value() then
					if KindredM.Combo.QM:Value() then
						QPred.PredPos=GetMousePos()
					end
					if CanUseSpell(myHero, _Q) == READY and QPred.HitChance == 1 then
						CastSkillShot(_Q,QPred.PredPos.x,QPred.PredPos.y,QPred.PredPos.z)
					end
				end
			end
		end
	--CAST E	          							  
		if KindredM.Combo.E:Value() then
			if CanUseSpell(myHero, _E) == READY and ValidTarget(target,GetCastRange(myHero,_E)) then
			   CastTargetSpell(target,_E)
			end
		end
		 --CAST R
		for _, ally in pairs(GetAllyHeroes()) do
			if KindredM.Combo.R:Value() then
				if ValidTarget(target, 650) and (GetCurrentHP(ally)/GetMaxHP(ally))<0.15 and CanUseSpell(myHero, _R) == READY and IsObjectAlive(ally) then
					CastTargetSpell(ally,_R)
				end
			end	
		end
---JUNGLECLEAR---- Thanks Deftsu <3
for _,mob in pairs(minionManager.objects) do	
 if GetTeam(mob) == 300 and IOW:Mode() == "LaneClear" then
		
			if CanUseSpell(myHero, _W) == READY and KindredM.JungleClear.W:Value() and ValidTarget(mob, 450) then
				local mobPos=GetOrigin(mob)
				CastSpell(_W)
			end
			
			if CanUseSpell(myHero, _Q) == READY and KindredM.JungleClear.Q:Value() and ValidTarget(mob, 450) then
				local mobPos=GetOrigin(mob)
				if KindredM.JungleClear.QM:Value() then
					mobPos=GetMousePos()
				end
				CastSkillShot(_Q,mobPos.x,mobPos.y,mobPos.z)
			end
			
			
			if CanUseSpell(myHero, _E) == READY and KindredM.JungleClear.E:Value() and ValidTarget(mob, 450) then
				CastTargetSpell(mob, _E)
			end
		end
	end
---LANECLEAR----
for i=1, IOW.mobs.maxObjects do
        local minion = IOW.mobs.objects[i]
        if IOW:Mode() == "LaneClear" then
		
			if CanUseSpell(myHero, _Q) == READY and KindredM.LaneClear.Q:Value() and ValidTarget(minion, 450) then
				local minionPos=GetOrigin(minion)
				if KindredM.LaneClear.Q:Value() then
					minionPos=GetMousePos()
				end
				CastSkillShot(_Q,minionPos.x,minionPos.y,minionPos.z)
			end
			
			if CanUseSpell(myHero, _W) == READY and KindredM.LaneClear.W:Value() and ValidTarget(minion, 450) then
				CastTargetSpell(minion, _W)
			end
			
			if CanUseSpell(myHero, _E) == READY and KindredM.LaneClear.E:Value() and ValidTarget(minion, 450) then
				CastTargetSpell(minion, _E)
			end
		end
	end
	---FLEE---
	if CanUseSpell(myHero, _Q) == READY and KindredM.Misc.Flee:Value() then
		local fleePos=GetMousePos()   
		CastSkillShot(_Q,fleePos.x,fleePos.y,fleePos.z)
	end
				
----AUTOLVL-----
local leveltable = {_W, _Q, _E, _Q, _Q, _R, _E, _E, _E, _Q, _R, _E, _Q, _W, _W, _R, _W, _W}
	if KindredM.Misc.Autolvl:Value() then  
		if GetLevel(myHero) == 3 then
			LevelSpell(leveltable[3])
			LevelSpell(leveltable[2])
			LevelSpell(leveltable[1])
		else
			LevelSpell(leveltable[GetLevel(myHero)]) 
		end
	end
end)

meeleItems={3153,3144,3142,3143}
--	    Botr,Bilg,Ghos,Rand
cleanseItems={3140,3139}
--	     Merc,QSS

function UseItems(unit)		--Item function by Logge; some credits to Deftsu
	if KindredM.Misc.Item:Value() then 
		for _,id in pairs(cleanseItems) do
			if GetItemSlot(myHero,id) > 0 and GotBuff(myHero, "rocketgrab2") > 0 or GotBuff(myHero, "charm") > 0 or GotBuff(myHero, "fear") > 0 or GotBuff(myHero, "flee") > 0 or GotBuff(myHero, "snare") > 0 or GotBuff(myHero, "taunt") > 0 or GotBuff(myHero, "suppression") > 0 or GotBuff(myHero, "stun") > 0 or GotBuff(myHero, "zedultexecute") > 0 or GotBuff(myHero, "summonerexhaust") > 0  then
				CastTargetSpell(myHero, GetItemSlot(myHero,id))
			end
		end
		if IOW:Mode() == "Combo" then
			for _,id in pairs(meeleItems) do
				if GetItemSlot(myHero,id) > 0 and ValidTarget(unit, 550) then
				CastTargetSpell(unit, GetItemSlot(myHero,id))
				end
			end
		end
	end
end

PrintChat("Shadowfire Kindred by Musti and Logge")
PrintChat("Version 1.0 - Rework")
