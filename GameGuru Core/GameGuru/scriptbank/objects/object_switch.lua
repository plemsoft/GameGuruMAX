-- LUA Script - precede every function and global member with lowercase name of script + '_main'
-- Object Switch v3   by Necrym59
-- DESCRIPTION: This object will be treated as a one time switch for activating other objects or game elements. Set Physics=ON, Always Active = ON, IsImobile=ON
-- DESCRIPTION: Customise the [PROMPT_TEXT$ = "E to use"]
-- DESCRIPTION: [USE_RANGE=90(1,100)]
-- DESCRIPTION: [@SWITCH_TYPE=1(1=Push, 2=Pull, 3=Slide-Left, 4=Slide-Right, 5=Slide-Up, 6=Slide-Down, 7=Rotate X , 8=Rotate Y , 9=Rotate Z)].
-- DESCRIPTION: [SWITCH_MOVEMENT=10(1,90)]
-- DESCRIPTION: Play <Sound0> when used
-- DESCRIPTION: Play <Sound1> when finished

local U = require "scriptbank\\utillib"

g_objectswitch 			= {}
local prompt_text 		= {}
local use_range 		= {}
local switch_type 		= {}
local switch_movement 	= {}
local status 			= {}
local pressed 			= {}
local objrotval 		= {}
local objpushval 		= {}
local objpullval 		= {}
local objslideval 		= {}

function object_switch_properties(e, prompt_text, use_range ,switch_type, switch_movement)
	g_objectswitch[e] = g_Entity[e]
	g_objectswitch[e]['prompt_text'] = prompt_text
	g_objectswitch[e]['use_range'] = use_range
	g_objectswitch[e]['switch_type'] = switch_type
	g_objectswitch[e]['switch_movement'] =	switch_movement
end 

function object_switch_init(e)
	g_objectswitch[e] = g_Entity[e]
	g_objectswitch[e]['prompt_text'] = "E to use"
	g_objectswitch[e]['use_range'] = 90
	g_objectswitch[e]['switch_type'] = 1
	g_objectswitch[e]['switch_movement'] = 10
	status[e] = "off"
	objrotval[e] = 0
	objpushval[e] = 0
	objpullval[e] = 0
	objslideval[e] = 0
end

function object_switch_main(e)	
	g_objectswitch[e] = g_Entity[e]
	if g_objectswitch[e]['switch_movement'] > 90 then g_objectswitch[e]['switch_movement'] = 90	end
	
	local PlayerDist = GetPlayerDistance(e)
	
	if PlayerDist < g_objectswitch[e]['use_range'] and g_PlayerHealth > 0 then
		local LookingAt = GetPlrLookingAtEx(e,1)
		
		if status[e] == "off" then  --Off
			if LookingAt == 1 then
				if status[e] ~= "on" then PromptLocalForVR(e,g_objectswitch[e]['prompt_text'],3) end
				if g_KeyPressE == 1 then
							
					if g_objectswitch[e]['switch_type'] == 1 then	--Push Switch
						if objpushval[e] < g_objectswitch[e]['switch_movement'] then
							GravityOff(e)
							CollisionOff(e)
							local ox,oy,oz = U.Rotate3D(-0.1,0,0, math.rad(g_Entity[e]['anglex']), math.rad(g_Entity[e]['angley']), math.rad(g_Entity[e]['anglez']))
							local forwardposx, forwardposy, forwardposz = g_Entity[e]['x'] + ox, g_Entity[e]['y'] + oy, g_Entity[e]['z'] + oz				
							SetPosition(e,forwardposx,forwardposy,forwardposz)							
							objpushval[e] = objpushval[e] + 0.1
							LoopSound(e,0)
							CollisionOn(e)
						end
						if objpushval[e] >= g_objectswitch[e]['switch_movement'] then							
							SetActivatedWithMP(e,201)
							PerformLogicConnections(e)
							StopSound(e,0)
							PlaySound(e,1)							
							SetAnimationName(e,"on")
							PlayAnimation(e)
							status[e] = "on"
						end
					end
					if g_objectswitch[e]['switch_type'] == 2 then	--Pull Switch
						if objpullval[e] < g_objectswitch[e]['switch_movement'] then
							GravityOff(e)
							CollisionOff(e)
							local ox,oy,oz = U.Rotate3D(0.1,0,0, math.rad(g_Entity[e]['anglex']), math.rad(g_Entity[e]['angley']), math.rad(g_Entity[e]['anglez']))
							local forwardposx, forwardposy, forwardposz = g_Entity[e]['x'] + ox, g_Entity[e]['y'] + oy, g_Entity[e]['z'] + oz				
							SetPosition(e,forwardposx,forwardposy,forwardposz)													
							objpullval[e] = objpullval[e] + 0.1
							LoopSound(e,0)
							CollisionOn(e)
						end
						if objpullval[e] >= g_objectswitch[e]['switch_movement'] then							
							SetActivatedWithMP(e,201)
							PerformLogicConnections(e)
							StopSound(e,0)
							PlaySound(e,1)							
							SetAnimationName(e,"on")
							PlayAnimation(e)
							status[e] = "on"
						end
					end
					if g_objectswitch[e]['switch_type'] == 3 then	--Slide Left
						if objslideval[e] < g_objectswitch[e]['switch_movement'] then
							GravityOff(e)
							CollisionOff(e)
							local ox,oy,oz = U.Rotate3D(0,0,-0.1, math.rad(g_Entity[e]['anglex']), math.rad(g_Entity[e]['angley']), math.rad(g_Entity[e]['anglez']))
							local forwardposx, forwardposy, forwardposz = g_Entity[e]['x'] + ox, g_Entity[e]['y'] + oy, g_Entity[e]['z'] + oz
							SetPosition(e,forwardposx,forwardposy,forwardposz)							
							objslideval[e] = objslideval[e] + 0.1
							LoopSound(e,0)
							CollisionOn(e)
						end
						if objslideval[e] >= g_objectswitch[e]['switch_movement'] then							
							SetActivatedWithMP(e,201)
							PerformLogicConnections(e)
							StopSound(e,0)
							PlaySound(e,1)							
							SetAnimationName(e,"on")
							PlayAnimation(e)
							status[e] = "on"
						end						
					end
					if g_objectswitch[e]['switch_type'] == 4 then	--Slide Right
						if objslideval[e] < g_objectswitch[e]['switch_movement'] then
							GravityOff(e)
							CollisionOff(e)
							local ox,oy,oz = U.Rotate3D(0,0,0.1, math.rad(g_Entity[e]['anglex']), math.rad(g_Entity[e]['angley']), math.rad(g_Entity[e]['anglez']))
							local forwardposx, forwardposy, forwardposz = g_Entity[e]['x'] + ox, g_Entity[e]['y'] + oy, g_Entity[e]['z'] + oz
							SetPosition(e,forwardposx,forwardposy,forwardposz)							
							objslideval[e] = objslideval[e] + 0.1
							LoopSound(e,0)
							CollisionOn(e)
						end
						if objslideval[e] >= g_objectswitch[e]['switch_movement'] then							
							SetActivatedWithMP(e,201)						
							PerformLogicConnections(e)
							StopSound(e,0)
							PlaySound(e,1)							
							SetAnimationName(e,"on")
							PlayAnimation(e)
							status[e] = "on"
						end						
					end
					if g_objectswitch[e]['switch_type'] ==  5 then	--Slide Up
						if objslideval[e] < g_objectswitch[e]['switch_movement'] then
							GravityOff(e)
							CollisionOff(e)
							local ox,oy,oz = U.Rotate3D(0,0.1,0, math.rad(g_Entity[e]['anglex']), math.rad(g_Entity[e]['angley']), math.rad(g_Entity[e]['anglez']))
							local forwardposx, forwardposy, forwardposz = g_Entity[e]['x'] + ox, g_Entity[e]['y'] + oy, g_Entity[e]['z'] + oz
							SetPosition(e,forwardposx,forwardposy,forwardposz)							
							objslideval[e] = objslideval[e] + 0.1
							LoopSound(e,0)
							CollisionOn(e)
						end
						if objslideval[e] >= g_objectswitch[e]['switch_movement'] then
							SetActivatedWithMP(e,201)						
							PerformLogicConnections(e)
							StopSound(e,0)
							PlaySound(e,1)							
							SetAnimationName(e,"on")
							PlayAnimation(e)
							status[e] = "on"
						end						
					end
					if g_objectswitch[e]['switch_type'] == 6 then	--Slide Down
						if objslideval[e] < g_objectswitch[e]['switch_movement'] then
							GravityOff(e)
							CollisionOff(e)
							local ox,oy,oz = U.Rotate3D(0,-0.1,0, math.rad(g_Entity[e]['anglex']), math.rad(g_Entity[e]['angley']), math.rad(g_Entity[e]['anglez']))
							local forwardposx, forwardposy, forwardposz = g_Entity[e]['x'] + ox, g_Entity[e]['y'] + oy, g_Entity[e]['z'] + oz
							SetPosition(e,forwardposx,forwardposy,forwardposz)							
							objslideval[e] = objslideval[e] + 0.1
							LoopSound(e,0)
							CollisionOn(e)							
						end
						if objslideval[e] >= g_objectswitch[e]['switch_movement'] then							
							SetActivatedWithMP(e,201)
							PerformLogicConnections(e)
							StopSound(e,0)
							PlaySound(e,1)
							SetAnimationName(e,"on")
							PlayAnimation(e)
							status[e] = "on"
						end						
					end
					if g_objectswitch[e]['switch_type'] == 7 then	--Rotate X
						if objrotval[e] < g_objectswitch[e]['switch_movement'] then
							GravityOff(e)
							CollisionOff(e)							
							RotateX(e,objrotval[e])
							objrotval[e] = objrotval[e] + 0.1
							LoopSound(e,0)
							CollisionOn(e)
						end
						if objrotval[e] >= g_objectswitch[e]['switch_movement'] then							
							SetActivatedWithMP(e,201)
							PerformLogicConnections(e)
							StopSound(e,0)
							PlaySound(e,1)							
							SetAnimationName(e,"on")
							PlayAnimation(e)
							status[e] = "on"
						end
					end
					if g_objectswitch[e]['switch_type'] == 8 then	--Rotate Y
						if objrotval[e] < g_objectswitch[e]['switch_movement'] then
							GravityOff(e)
							CollisionOff(e)							
							RotateY(e,objrotval[e])
							objrotval[e] = objrotval[e] + 0.1
							LoopSound(e,0)
							CollisionOn(e)
						end
						if objrotval[e] >= g_objectswitch[e]['switch_movement'] then						
							SetActivatedWithMP(e,201)
							PerformLogicConnections(e)
							StopSound(e,0)
							PlaySound(e,1)							
							SetAnimationName(e,"on")
							PlayAnimation(e)
							status[e] = "on"
						end
					end
					if g_objectswitch[e]['switch_type'] == 9 then	--Rotate Z
						if objrotval[e] < g_objectswitch[e]['switch_movement'] then
							GravityOff(e)
							CollisionOff(e)							
							RotateZ(e,objrotval[e])
							objrotval[e] = objrotval[e] + 0.1
							LoopSound(e,0)
							CollisionOn(e)
						end
						if objrotval[e] >= g_objectswitch[e]['switch_movement'] then							
							SetActivatedWithMP(e,201)
							PerformLogicConnections(e)
							StopSound(e,0)
							PlaySound(e,1)							
							SetAnimationName(e,"on")
							PlayAnimation(e)
							status[e] = "on"
						end
					end
				end
				if g_KeyPressE == 0 then StopSound(e,0) end
			end
		end
	end	
end