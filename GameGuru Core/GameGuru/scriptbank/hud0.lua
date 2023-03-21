-- DESCRIPTION: A global script that controls the in-game HUD. Do not assign to an object.

cursorControl = require "scriptbank\\huds\\cursorcontrol"
local U = require "scriptbank\\utillib"

g_sprCursorPtrX = 50
g_sprCursorPtrY = 33
g_sprCursorPtrClick = 0

hud0 = {}
hud0_pointerID = -1
hud0_pointerSpriteID = nil
hud0_pointerSpriteImageID = 0
hud0_gridSpriteID = nil
hud0_gridSelected = 0
hud0_gridSelectedIndex = -1

hud0_pulledoutofslot = 0
hud0_pulledoutofslotfromX = 0
hud0_pulledoutofslotfromY = 0

hud0_freezeforpointer = 0

hud0_playercontainer_screenID = 0
hud0_playercontainer_collectionindex = {}
hud0_playercontainer_img = {}
hud0_playercontainer_e = {}

hud0_lastgoodplayerinventory0qty = 0
hud0_lastgoodplayerinventory1qty = 0

hud0_mapView_WindowX = 0
hud0_mapView_WindowY = 0
hud0_mapView_WindowW = 0
hud0_mapView_WindowH = 0
hud0_mapView_ImageX = 0
hud0_mapView_ImageY = 0
hud0_mapView_ImageW = 0
hud0_mapView_ImageH = 0
hud0_mapView_ImageOW = 0
hud0_mapView_ImageOH = 0
hud0_mapView_ScrollX = 0
hud0_mapView_ScrollY = 0
hud0_mapView_Scale = 1.0

hud0_populateallcontainers = 1

hud0_scrollbar_forscreen = 0
hud0_scrollbar_mode = 0
hud0_scrollbar_boxx = 0
hud0_scrollbar_boxy = 0
hud0_scrollbar_boxw = 0
hud0_scrollbar_boxh = 0
hud0_scrollbar_percentage = 0
hud0_itemindexmaxslotused = 0
hud0_itemindexscrolloffset = 0
hud0_scrollpanel_mainrow = 0
hud0_scrollpanel_maincolumn = 0

function hud0.init()
 -- initialise all globals
 InitScreen("HUD0")
 -- create resources for HUD
 hud0_gridSpriteID = CreateSprite ( LoadImage("imagebank\\HUD\\blank.png") )
 -- init in-game HUD base container for hotkeys panel if any
 hud0_playercontainer_screenID = 0
 if hud0_playercontainer_collectionindex[hud0_playercontainer_screenID] == nil then 
	hud0_playercontainer_collectionindex[hud0_playercontainer_screenID] = {}
	hud0_playercontainer_img[hud0_playercontainer_screenID] = {}
	hud0_playercontainer_e[hud0_playercontainer_screenID] = {}
 end
 if hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][1] == nil then 
	hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][1] = {}
	hud0_playercontainer_img[hud0_playercontainer_screenID][1] = {}
	hud0_playercontainer_e[hud0_playercontainer_screenID][1] = {}
 end
 -- default container is a shop container
 g_UserGlobalContainer = "shop"
 g_UserGlobalContainerLast = ""
 g_UserGlobalContainerRefresh = 0
 -- default settings
 hud0_scrollbar_mode = -1
 hud0_scrollbar_boxw = 0
end

function hud0.refreshHUD()
	-- populate local HUD containers with collection list
	local tgridqty = GetScreenElementsType("user defined global panel")
	for gridi = 1, tgridqty, 1 do
		local thegridelementID = GetScreenElementTypeID("user defined global panel",gridi)
		if thegridelementID > 0 then	
			-- init this container
			if hud0_playercontainer_collectionindex[hud0_playercontainer_screenID] == nil then 
				hud0_playercontainer_collectionindex[hud0_playercontainer_screenID] = {}
				hud0_playercontainer_img[hud0_playercontainer_screenID] = {}
				hud0_playercontainer_e[hud0_playercontainer_screenID] = {}
			end
			if hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi] == nil then 
				hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi] = {}
				hud0_playercontainer_img[hud0_playercontainer_screenID][gridi] = {}
				hud0_playercontainer_e[hud0_playercontainer_screenID][gridi] = {}
			end
			-- provide by panel settings (row, column)
			totalinrow, totalincolumn = GetScreenElementDetails(thegridelementID)
			if totalinrow < 1 then totalinrow = 1 end
			if totalincolumn < 1 then totalincolumn = 1 end
			-- fill container with collection/inventory
			local whattoshowinpanel = 0
			local panelname = GetScreenElementName(thegridelementID)
			if panelname == "collection" then
				-- show ALL collection
				local itemindex = 0
				local tcollectionmax = GetCollectionItemQuantity()
				for tcollectionindex = 1, tcollectionmax, 1 do
					local titemimg = GetCollectionItemAttribute(tcollectionindex,"image")
					if string.len(titemimg) > 0 then
						hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][itemindex] = tcollectionindex
						hud0_playercontainer_img[hud0_playercontainer_screenID][gridi][itemindex] = LoadImage(titemimg)
						hud0_playercontainer_e[hud0_playercontainer_screenID][gridi][itemindex] = 0
						itemindex=itemindex+1
					end
				end
			else
				-- refresh containers
				local playercontainer = 0
				local inventorycontainer = panelname
				local thisitemindexoffset = 0
				local itemcount = totalinrow*totalincolumn
				if panelname == "inventory:player" then 
					playercontainer = 1 
					thisitemindexoffset = hud0_itemindexscrolloffset
					itemcount = hud0_itemindexmaxslotused
				end
				if panelname == "inventory:hotkeys" then playercontainer = 2 end
				if panelname == "inventory:container" then playercontainer = 3 inventorycontainer = "inventory:"..g_UserGlobalContainer end
				if playercontainer > 0 then
					if playercontainer == 3 and g_UserGlobalContainer ~= g_UserGlobalContainerLast then
						-- if this did not exist at start of level, create it now
						local tcontainerfullname = "inventory:"
						tcontainerfullname = tcontainerfullname .. g_UserGlobalContainer
						MakeInventoryContainer(tcontainerfullname)
						-- must clear container if previously used for something else
						g_UserGlobalContainerLast = g_UserGlobalContainer
						for itemindex = 0, itemcount, 1 do
							hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][itemindex] = nil
							hud0_playercontainer_img[hud0_playercontainer_screenID][gridi][itemindex] = nil								
							hud0_playercontainer_e[hud0_playercontainer_screenID][gridi][itemindex] = 0								
						end
					end
					local tinventoryqty = GetInventoryQuantity(inventorycontainer)
					for tinventoryindex = 1, tinventoryqty, 1 do
						local itemindex = -1
						local tcollectionindex = GetInventoryItem(inventorycontainer,tinventoryindex)
						local tslotindex = GetInventoryItemSlot(inventorycontainer,tinventoryindex)
						local titemimg = GetCollectionItemAttribute(tcollectionindex,"image")
						if string.len(titemimg) > 0 then
							for findifexist = 0, itemcount, 1 do
								if findifexist == tslotindex and hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][findifexist] == tcollectionindex then
									-- already know about this one, and in right slot
									itemindex = findifexist
									break
								end
							end
							if itemindex == -1 then
								itemindex = tslotindex
								if hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][itemindex] == nil then
									-- add this new arrival
									hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][itemindex] = tcollectionindex
									hud0_playercontainer_img[hud0_playercontainer_screenID][gridi][itemindex] = LoadImage(titemimg)
									local tentityindex = GetInventoryItemID(inventorycontainer,tinventoryindex)
									hud0_playercontainer_e[hud0_playercontainer_screenID][gridi][itemindex] = tentityindex
								end
							end
						end
					end
					-- remove any items if no longer in inventory
					for itemindex = 0, itemcount, 1 do
						local thiscontainercollectionindex = hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][itemindex]
						if thiscontainercollectionindex ~= nil then
							local foundininventoryandrightslot = 0
							for tinventoryindex = 1, tinventoryqty, 1 do
								local tcollectionindex = GetInventoryItem(inventorycontainer,tinventoryindex)
								if tcollectionindex == thiscontainercollectionindex then
									local tslotindex = GetInventoryItemSlot(inventorycontainer,tinventoryindex)
									if tslotindex == itemindex then
										foundininventoryandrightslot = 1
									end
								end
							end
							if foundininventoryandrightslot == 0 then
								hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][itemindex] = nil
								hud0_playercontainer_img[hud0_playercontainer_screenID][gridi][itemindex] = nil								
								hud0_playercontainer_e[hud0_playercontainer_screenID][gridi][itemindex] = 0								
							end
						end
					end
				end
			end
		end
	end
end

function hud0.main()

 -- This section controls which HUD screens are shown to the player whilst in-game (not paused or in a menu screen)
 if IsPlayerInGame() then
 
  if hud0_populateallcontainers == 1 then 
    -- create all shop and chest containers
	local tcollectionmax = GetCollectionItemQuantity()
	for tcollectionindex = 1, tcollectionmax, 1 do
		local tcontainername = GetCollectionItemAttribute(tcollectionindex,"container")
		if tcontainername ~= nil then
			local tcontainerfullname = "inventory:"
			tcontainerfullname = tcontainerfullname .. tcontainername
			MakeInventoryContainer(tcontainerfullname)
		end
	end
	-- create shop items from collection for this level
	local tcollectionmax = GetCollectionItemQuantity()
	for tcollectionindex = 1, tcollectionmax, 1 do
		local tname = GetCollectionItemAttribute(tcollectionindex,"title")
		local anyee = 0
		for ee = 1, g_EntityElementMax, 1 do
			if e ~= ee then
				if g_Entity[ee] ~= nil then
					if g_Entity[ee]['active'] > 0 then
						if GetEntityName(ee) == tname then
							anyee = ee
							break
						end
					end
				end
			end
		end
		if anyee > 0 then
			-- item object is in 3D world, create a clone for the shop
			local newe = SpawnNewEntity(anyee)
			local tcontainerfullname = "inventory:shop"
			local tcontainername = GetCollectionItemAttribute(tcollectionindex,"container")
			if tcontainername ~= nil then
				tcontainerfullname = "inventory:"
				tcontainerfullname = tcontainerfullname .. tcontainername
			end
			SetEntityCollected(newe,3,-1,tcontainerfullname)
		end
	end			
	-- finished creating container items and entities
	hud0_populateallcontainers = 0
  end
 
  -- Some screens can be toggled on/off with a key press, if the required key press is detected then that screen will be set to the current screen and appear in-game
  CheckScreenToggles()
  
  -- detect any inventory changes
  local tinventory0qty = GetInventoryQuantity("inventory:player")
  local tinventory1qty = GetInventoryQuantity("inventory:hotkeys")
  if tinventory0qty ~= hud0_lastgoodplayerinventory0qty or tinventory1qty ~= hud0_lastgoodplayerinventory1qty or g_UserGlobalContainerRefresh == 1then
	hud0_lastgoodplayerinventory0qty = tinventory0qty
	hud0_lastgoodplayerinventory1qty = tinventory1qty
	hud0.refreshHUD()
	hud0_gridSelected = 0
	hud0_gridSelectedIndex = -1
	g_UserGlobalContainerRefresh = 0
  end

  -- needed to separate HUD panels
  if GetCurrentScreen() > 0 then
	hud0_playercontainer_screenID = GetCurrentScreen()
  else
	hud0_playercontainer_screenID = 0
  end
  
  -- flag mouse pointer drawing below
  local drawMousePointer = 0
 
  -- If there is an active screen (resulting from CheckScreenToggles()) then display that screen, otherwise dispay the default HUD screen
  if GetCurrentScreen() > -1 then

	-- switch to mouse mode  
	if hud0_freezeforpointer == 0 then 
		SetCameraOverride(3)
		FreezePlayer()
		ActivateMouse()
		hud0_freezeforpointer = 1
		hud0.refreshHUD()
	end
	
	-- display HUD screen (and any button press handling later)
	local buttonElementID = DisplayCurrentScreen()
	
	-- use mouse pointer
	g_sprCursorPtrX,g_sprCursorPtrY,g_sprCursorPtrClick = cursorControl.getinput(g_sprCursorPtrX,g_sprCursorPtrY,g_sprCursorPtrClick)
	
	-- detect ineraction with scroll bars (controls panel grid offsets)
	if hud0_scrollbar_forscreen ~= hud0_playercontainer_screenID then
		hud0_scrollbar_forscreen = hud0_playercontainer_screenID
		hud0_scrollbar_mode = -1
		hud0_scrollbar_boxw = 0
	end	
	if hud0_pulledoutofslot == 0 then
		local timgqty = GetScreenElementsType("user defined global image")
		for tindex = 1, timgqty, 1 do
			local elementID = GetScreenElementTypeID("user defined global image",tindex)
			if elementID > 0 then
				if hud0_scrollbar_boxw == 0 then
					if GetScreenElementName(elementID) == "scrollbar:box" then
						hud0_scrollbar_boxx,hud0_scrollbar_boxy,hud0_scrollbar_boxw,hud0_scrollbar_boxh = GetScreenElementArea(elementID)    
					end
				end
				if GetScreenElementName(elementID) == "scrollbar:handle" then
					tareax,tareay,tareaw,tareah = GetScreenElementArea(elementID)    
					if hud0_scrollbar_mode == -1 then
						SetScreenElementPosition(elementID,hud0_scrollbar_boxx,hud0_scrollbar_boxy)
						hud0_scrollbar_percentage = 0
						hud0_scrollbar_mode = 0
					end
					if hud0_scrollbar_mode == 0 then		
						if hud0_itemindexmaxslotused - (hud0_scrollpanel_mainrow*hud0_scrollpanel_maincolumn) > 0 then
							SetScreenElementVisibility(elementID,1)
						else
							SetScreenElementVisibility(elementID,0)
						end
						if g_sprCursorPtrClick == 1 then
							if g_sprCursorPtrX >= tareax and g_sprCursorPtrX <= tareax+tareaw then
								if g_sprCursorPtrY >= tareay and g_sprCursorPtrY <= tareay+tareah then
									hud0_scrollbar_mode = 1
								end
							end
						end
					else
						local toffsety = g_sprCursorPtrY-hud0_scrollbar_boxy
						if toffsety < 0 then toffsety = 0 end
						if toffsety > hud0_scrollbar_boxh-tareah then toffsety = hud0_scrollbar_boxh-tareah end
						SetScreenElementPosition(elementID,hud0_scrollbar_boxx,hud0_scrollbar_boxy+toffsety)
						hud0_scrollbar_percentage = toffsety / (hud0_scrollbar_boxh-tareah)
						local gridrowstoscroll = (hud0_scrollpanel_mainrow+(hud0_itemindexmaxslotused - (hud0_scrollpanel_mainrow*hud0_scrollpanel_maincolumn)))*hud0_scrollbar_percentage
						local gridrowslimit = math.floor(gridrowstoscroll/hud0_scrollpanel_mainrow)
						if gridrowslimit < 0 then gridrowslimit = 0 end
						hud0_itemindexscrolloffset = gridrowslimit * hud0_scrollpanel_mainrow
						if g_sprCursorPtrClick == 0 then
							hud0_scrollbar_mode = 0
						end
					end
				end
			end
		end
	end
					
	-- detect when select and let go of an element for each grid
	local tgridqty = GetScreenElementsType("user defined global panel")
	for gridi = 1, tgridqty, 1 do
		local thegrid = GetScreenElementTypeID("user defined global panel",gridi)
		if thegrid > 0 then
		
			local tgridx = 0
			local tgridy = 0
			local tgridwidth = 0
			local tgridheight = 0
			tgridx,tgridy,tgridwidth,tgridheight = GetScreenElementArea(thegrid)    

			-- provide by panel settings (row, column)Storyboard.widget_textoffset[nodeID][widgetSlot]
			totalinrow, totalincolumn = GetScreenElementDetails(thegrid)
			if totalinrow < 1 then totalinrow = 1 end
			if totalincolumn < 1 then totalincolumn = 1 end
			local gridtilewidth = tgridwidth/totalinrow
			local gridtileheight = tgridheight/totalincolumn
			
			-- get main inventory for scroll activity
			local thisitemindexoffset = 0
			if GetScreenElementName(thegrid) == "inventory:player" then
				hud0_scrollpanel_mainrow = totalinrow
				hud0_scrollpanel_maincolumn = totalincolumn
				thisitemindexoffset = hud0_itemindexscrolloffset
				local maininvqty = GetInventoryQuantity("inventory:player")
				if maininvqty > hud0_itemindexmaxslotused then
					hud0_itemindexmaxslotused = maininvqty
				end
			end
		
			-- if in panel, control contents
			if g_sprCursorPtrX >= tgridx and g_sprCursorPtrX <= tgridx+tgridwidth then
				if g_sprCursorPtrY >= tgridy and g_sprCursorPtrY <= tgridy+tgridheight and hud0_scrollbar_mode == 0 then
				
					-- where in grid
					local itemindex = 0
					local gridslotx = g_sprCursorPtrX - tgridx
					local gridsloty = g_sprCursorPtrY - tgridy
					gridslotx=math.floor(gridslotx/gridtilewidth)
					gridsloty=math.floor(gridsloty/gridtileheight)
					itemindex=thisitemindexoffset+(gridslotx+(gridsloty*totalinrow))

					-- handle click/drag/release
					if hud0_pulledoutofslot == 0 and gridi > 0 then
						-- click into this grid for first time
						if g_sprCursorPtrClick == 1 then
							hud0_gridSelectedIndex = itemindex
							hud0_gridSelected = gridi
							local panelname = GetScreenElementName(thegrid)
							if panelname == "inventory:container" then
								if string.sub(g_UserGlobalContainer,1,5) == "chest" then
									-- chests are free for all
									hud0_pulledoutofslot = 1
								else	
									-- owned by other
								end
							else
								-- player inventories are okay
								hud0_pulledoutofslot = 1
							end
						end
					else
						if g_sprCursorPtrClick == 1 then
							if hud0_pulledoutofslot == 1 then
								hud0_pulledoutofslotfromX = g_sprCursorPtrX
								hud0_pulledoutofslotfromY = g_sprCursorPtrY
								hud0_pulledoutofslotfromW = gridtilewidth
								hud0_pulledoutofslotfromH = gridtileheight
								hud0_pulledoutofslot = 2
							end
							local whenoutofslot = 1
							if hud0_pulledoutofslot == 2 and (math.abs(g_sprCursorPtrX-hud0_pulledoutofslotfromX)>whenoutofslot or math.abs(g_sprCursorPtrY-hud0_pulledoutofslotfromY)>whenoutofslot) then
								-- can start dragging once pulled out of slot sufficiently
								hud0_pulledoutofslot = 3
							end
						else
							-- release dragged item into this grid if different in any way
							if hud0_pulledoutofslot == 3 then
								if hud0_gridSelected ~= gridi or hud0_gridSelectedIndex ~= itemindex then
									local placedatitemindex = -1
									if hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][itemindex] == nil then
										placedatitemindex = itemindex
									else
										local itemcount = totalincolumn*totalinrow
										local newlocationitemindex = itemindex
										for gothroughall = 1, itemcount-1, 1 do
											newlocationitemindex = newlocationitemindex + 1
											if newlocationitemindex >= itemcount then newlocationitemindex = 0 end
											if hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][newlocationitemindex] == nil then
												placedatitemindex = newlocationitemindex
												break
											end
										end
									end
									if placedatitemindex ~= -1 then
									
										-- from and to
										local thegridFrom = GetScreenElementTypeID("user defined global panel",hud0_gridSelected)
										local thegridTo = GetScreenElementTypeID("user defined global panel",gridi)
										local panelnameFrom = GetScreenElementName(thegridFrom)
										local panelnameTo = GetScreenElementName(thegridTo)
										
										-- if entity removed from collection, need entity index
										local cancelmove = 0
										local entityindex = 0
										
										-- cancel if dragging into a container not owned by player
										if panelnameTo == "inventory:container" then
											if string.sub(g_UserGlobalContainer,1,5) ~= "chest" then
												-- owned by other - cannot move item here
												cancelmove = 1
											end
										end		
										
										-- cancel if moving item into recipe that is not a recipe
										if panelnameTo == "inventory:craft" then
											local findcollectionindex = hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
											if findcollectionindex ~= -1 then
												local tstyle = GetCollectionItemAttribute(findcollectionindex,"style")
												if tstyle ~= "recipe" then
													cancelmove = 1
												end
											end
										end															
										
										-- shuffled inside hotkey, handle weapons
										if cancelmove == 0 and (panelnameFrom == "inventory:hotkeys" or panelnameTo == "inventory:hotkeys") then
											local panelname = panelnameFrom
											local findcollectionindex = hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
											if findcollectionindex ~= -1 then
												local tinventoryqty = GetInventoryQuantity(panelname)
												for tinventoryindex = 1, tinventoryqty, 1 do
													local tcollectionindex = GetInventoryItem(panelname,tinventoryindex)
													if tcollectionindex == findcollectionindex then 
														local tcollectionentity = GetInventoryItemID(panelname,tinventoryindex)
														if tcollectionentity == 0 then
															-- this item is FIXED and cannot be moved (i.e. start weapon)
															cancelmove = 1
														else
															if panelnameFrom == "inventory:hotkeys" then
																-- remove from hot key location
																if hud0_gridSelectedIndex >= 0 and hud0_gridSelectedIndex <= 9 then
																	RemovePlayerWeapon(1+hud0_gridSelectedIndex)
																	entityindex = GetInventoryItemID(panelname,tinventoryindex)
																	if entityindex > 0 then
																		SetEntityCollected(entityindex,0,0)
																	end
																end
															else
																-- removing to place in hot key location
																if panelnameTo == "inventory:hotkeys" then
																	entityindex = GetInventoryItemID(panelname,tinventoryindex)
																	if entityindex > 0 then
																		SetEntityCollected(entityindex,0,0)
																	end
																end
															end
														end
														break
													end
												end
											end
										end
										if cancelmove == 0 then
											if entityindex == 0 then
												-- moved item to new inventory container
												local collectionindex = hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
												local entityindex = hud0_playercontainer_e[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
												local inventorycontainerFrom = panelnameFrom
												local inventorycontainerTo = panelnameTo
												if inventorycontainerFrom == "inventory:container" then inventorycontainerFrom = "inventory:"..g_UserGlobalContainer end
												if inventorycontainerTo == "inventory:container" then inventorycontainerTo = "inventory:"..g_UserGlobalContainer end
												MoveInventoryItem(inventorycontainerFrom,inventorycontainerTo,-1,entityindex,placedatitemindex)
												g_UserGlobalContainerRefresh = 1
											else
												-- add to new location as we removed it above
												local suggestedslotvalid = -1
												if panelnameTo == "inventory:hotkeys" then
													suggestedslotvalid = SetEntityCollected(entityindex,2,placedatitemindex)
													if GetEntityCollectable(entityindex) == 2 then
														-- resources can never be weapons
													else
														AddPlayerWeaponSuggestSlot(entityindex,1+placedatitemindex)
													end
												end
												if suggestedslotvalid == -1 then
													SetEntityCollected(entityindex,1,placedatitemindex)
												end
											end
											-- finish movement																		
											hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][placedatitemindex] = hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
											hud0_playercontainer_img[hud0_playercontainer_screenID][gridi][placedatitemindex] = hud0_playercontainer_img[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
											hud0_playercontainer_e[hud0_playercontainer_screenID][gridi][placedatitemindex] = hud0_playercontainer_e[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
											hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex] = nil
											hud0_playercontainer_img[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex] = nil
											hud0_playercontainer_e[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex] = 0
											hud0_gridSelected = gridi
											hud0_gridSelectedIndex = placedatitemindex
										end
									end
								end
								hud0_pulledoutofslot = 0
							end
						end
					end			  	
				end
			end
			
			-- paste all items into the panel from collection list
			if hud0_gridSpriteID ~= nil then
				for yy = 0, totalincolumn-1, 1 do
					for xx = 0, totalinrow-1, 1 do
						local itemindex = thisitemindexoffset+(xx+(yy*totalinrow))
						if hud0_playercontainer_collectionindex[hud0_playercontainer_screenID] ~= nil then
							if hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi] ~= nil then
								if hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][itemindex] ~= nil then
									-- except if dragging it
									if gridi ~= hud0_gridSelected or itemindex ~= hud0_gridSelectedIndex or g_sprCursorPtrClick == 0 or hud0_pulledoutofslot ~= 3 then
										local scrx = tgridx+(xx*gridtilewidth)
										local scry = tgridy+(yy*gridtileheight)
										local scrimg = hud0_playercontainer_img[hud0_playercontainer_screenID][gridi][itemindex]
										SetSpritePosition(hud0_gridSpriteID,scrx,scry)
										SetSpriteImage(hud0_gridSpriteID,scrimg)
										SetSpriteSize(hud0_gridSpriteID,gridtilewidth,-1)
										if hud0_gridSelectedIndex == itemindex and hud0_gridSelected == gridi then
											SetSpriteColor(hud0_gridSpriteID,255,255,255,255)
										else
											SetSpriteColor(hud0_gridSpriteID,255,255,255,192)
										end
										SetSpritePriority(hud0_gridSpriteID,-1)
										PasteSprite(hud0_gridSpriteID)
									end
								end
							end
						end
					end
				end
			end
		
			-- draw the dragged item in transit
			if hud0_gridSelected > 0 and hud0_pulledoutofslot == 3 then
				local scrx = g_sprCursorPtrX
				local scry = g_sprCursorPtrY
				local scrimg = hud0_playercontainer_img[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
				if scrimg ~= nil then
					SetSpritePosition(hud0_gridSpriteID,scrx,scry)
					SetSpriteImage(hud0_gridSpriteID,scrimg)
					SetSpriteSize(hud0_gridSpriteID,hud0_pulledoutofslotfromW,-1)--gridtilewidth,-1)
					SetSpriteColor(hud0_gridSpriteID,255,255,255,255)
					SetSpritePriority(hud0_gridSpriteID,-1)
					PasteSprite(hud0_gridSpriteID)
				end
			end

		end
	end
	if g_sprCursorPtrClick == 0 then	 
		hud0_pulledoutofslot = 0
	end
	
	-- draw any user defined global overlays (hud0_gridSelectedIndex)
	local displayingselecteditem = 0
	if hud0_gridSelectedIndex >= 0 and hud0_gridSelected > 0 then
		if hud0_playercontainer_img[hud0_playercontainer_screenID] ~= nil then
			if hud0_playercontainer_img[hud0_playercontainer_screenID][hud0_gridSelected] ~= nil then
				if hud0_playercontainer_img[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex] ~= nil then
					if hud0_playercontainer_img[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex] ~= nil then
						local iqty = GetScreenElements("selected:*")
						for ti = 1, iqty, 1 do
							local elementID = GetScreenElementID("selected:*",ti)
							local elementName = GetScreenElementName(elementID)
							if elementName == "selected:image" then
								local elementImageID = elementID
								if elementImageID > 0 then
									telementx,telementy,telementwidth,telementheight = GetScreenElementArea(elementImageID)    
									SetSpritePosition(hud0_gridSpriteID,telementx,telementy)
									SetSpriteImage(hud0_gridSpriteID,hud0_playercontainer_img[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex])
									SetSpriteColor(hud0_gridSpriteID,255,255,255,255)
									SetSpriteSize(hud0_gridSpriteID,telementwidth,-1)
									SetSpritePriority(hud0_gridSpriteID,-1)
									PasteSprite(hud0_gridSpriteID)
									displayingselecteditem = 1
								end
							else
								local tcollectionattribqty = GetCollectionAttributeQuantity()
								for tattribindex = 1, tcollectionattribqty, 1 do
									local attributelabel = GetCollectionAttributeLabel(tattribindex)
									if elementName == "selected:"..attributelabel then
										local elementTextID = elementID
										if elementTextID > 0 then
											local tcollectionindex = hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
											local tattrubutedata = GetCollectionItemAttribute(tcollectionindex,attributelabel)
											local tentityindex = hud0_playercontainer_e[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
											if tentityindex > 0 then
												if GetEntityCollectable(tentityindex) == 2 and attributelabel == "title" then
													local tQty = GetEntityQuantity(tentityindex)
													tattrubutedata = tattrubutedata .. " (" .. tQty .. ")"
												end
											end
											SetScreenElementText(elementTextID,tattrubutedata)
											displayingselecteditem = 1
										end
									end
								end
							end
						end
					end
				end			
			end			
		end
	end
	if displayingselecteditem == 0 then
		local iqty = GetScreenElements("selected:*")
		for ti = 1, iqty, 1 do
			local elementID = GetScreenElementID("selected:*",ti)
			local elementName = GetScreenElementName(elementID)
			if elementName ~= "selected:image" then
				local tcollectionattribqty = GetCollectionAttributeQuantity()
				for tattribindex = 1, tcollectionattribqty, 1 do
					local attributelabel = GetCollectionAttributeLabel(tattribindex)
					if elementName == "selected:"..attributelabel then
						local elementTextID = elementID
						if elementTextID > 0 then
							SetScreenElementText(elementTextID,"")
						end
					end
				end
			end			
		end			
	end
	
	-- handle any craft text	
	local iqty = GetScreenElements("craft:*")
	for ti = 1, iqty, 1 do
		local elementID = GetScreenElementID("craft:*",ti)
		local elementName = GetScreenElementName(elementID)
		local tcollectionattribqty = GetCollectionAttributeQuantity()
		for tattribindex = 1, tcollectionattribqty, 1 do
			local attributelabel = GetCollectionAttributeLabel(tattribindex)
			if elementName == "craft:"..attributelabel then
				local tcontainerfullname = "inventory:craft"
				MakeInventoryContainer(tcontainerfullname)
				local tinventoryindex = GetInventoryQuantity(tcontainerfullname)
				if tinventoryindex == 1 then
					local tcollectionindex = GetInventoryItem(tcontainerfullname,tinventoryindex)
					local tattrubutedata = GetCollectionItemAttribute(tcollectionindex,attributelabel)
					SetScreenElementText(elementID,tattrubutedata)
				else
					SetScreenElementText(elementID,"")
				end
			end
		end
	end
	
	-- handle any logic ascribed to global text elements
	local telementqty = GetScreenElementsType("user defined global text")
	for elementi = 1, telementqty, 1 do
		local elementid = GetScreenElementTypeID("user defined global text",elementi)
		if elementid > 0 then
			local elementName = GetScreenElementName(elementid)
			if elementName == "MyNewPointsText" then 
				local pointavailable = 0
				if _G["g_UserGlobal['".."MyNewPoints".."']"] ~= nil then pointavailable = _G["g_UserGlobal['".."MyNewPoints".."']"] end
				if pointavailable == 0 then
					SetScreenElementText(elementid,"")
				else
					if pointavailable == 1 then
						SetScreenElementText(elementid,"You can upgrade your stats, 1 point remains")
					else
						SetScreenElementText(elementid,"You can upgrade your stats, "..pointavailable.." points remain")
					end
				end
			end
		end
	end

	-- handle any button activity for INVENTORY = DROP, USE, BUY, SELL, etc
	if buttonElementID ~= -1 then
		local buttonElementName = GetScreenElementName(1+buttonElementID)
		if string.len(buttonElementName) > 0 then
			local actionOnObject = 0
			if buttonElementName == "DROP" then actionOnObject = 1 end
			if buttonElementName == "USE" then actionOnObject = 2 end
			if buttonElementName == "BUY" then actionOnObject = 3 end
			if buttonElementName == "SELL" then actionOnObject = 4 end
			if actionOnObject > 0 then
				-- DROP OR USE OBJECT FROM INVENTORY
				if hud0_gridSelected > 0 and hud0_gridSelectedIndex >= 0 then
					local thisdisplayingselecteditem = hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][hud0_gridSelected][hud0_gridSelectedIndex]
					local thegridelementID = GetScreenElementTypeID("user defined global panel",hud0_gridSelected)
					if thegridelementID > 0 then	
						local thispanelname = GetScreenElementName(thegridelementID)
						local panelname = ""
						local inventorycontainer = thispanelname
						if actionOnObject == 1 or actionOnObject == 2 then
							if thispanelname == "inventory:player" then panelname = thispanelname end
							if thispanelname == "inventory:hotkeys" then panelname = thispanelname end
						end
						if actionOnObject == 3 or actionOnObject == 4 then
							if thispanelname == "inventory:player" then panelname = thispanelname end
							if thispanelname == "inventory:container" then panelname = thispanelname inventorycontainer = "inventory:"..g_UserGlobalContainer end
						end
						local selecteditemcontainerID = -1
						if thispanelname == panelname then selecteditemcontainerID = thisdisplayingselecteditem end
						if selecteditemcontainerID ~= -1 then
							local tinventoryqty = GetInventoryQuantity(inventorycontainer)
							for tinventoryindex = 1, tinventoryqty, 1 do
								local tcollectionindex = GetInventoryItem(inventorycontainer,tinventoryindex)
								local tcollectionslot = GetInventoryItemSlot(inventorycontainer,tinventoryindex)
								if tcollectionindex == selecteditemcontainerID and tcollectionslot == hud0_gridSelectedIndex then
									if actionOnObject == 1 then
										-- DROP
										local entityindex = GetInventoryItemID(inventorycontainer,tinventoryindex)
										if entityindex > 0 then
											SetEntityCollected(entityindex,0,0)
											local floorlevelfordrop = RDGetYFromMeshPosition(g_PlayerPosX,g_PlayerPosY,g_PlayerPosZ)
											ResetPosition(entityindex,g_PlayerPosX,floorlevelfordrop,g_PlayerPosZ)
										end
									end
									if actionOnObject == 2 then
										-- USE
										local entityindex = GetInventoryItemID(inventorycontainer,tinventoryindex)
										if entityindex > 0 then
											if GetEntityUsed(entityindex) == 0 then
												SetEntityUsed(entityindex,1)
											end
										end
									end
									if actionOnObject == 3 or actionOnObject == 4 then
										-- BUY or SELL
										local tinventorysource = ""
										local tinventorydest = ""
										local thisValue = 0
										if actionOnObject == 3 and panelname == "inventory:container" then 
											-- BUY
											tinventorysource = "inventory:"..g_UserGlobalContainer
											tinventorydest = "inventory:player"
											thisValue = tonumber(GetCollectionItemAttribute(tcollectionindex,"cost"))
										end
										if actionOnObject == 4 and panelname == "inventory:player" then 
											-- SELL
											tinventorysource = "inventory:player"
											tinventorydest = "inventory:"..g_UserGlobalContainer
											thisValue = tonumber(GetCollectionItemAttribute(tcollectionindex,"value"))
										end
										-- money check
										local myMoney = 0
										if _G["g_UserGlobal['".."MyMoney".."']"] ~= nil then myMoney = _G["g_UserGlobal['".."MyMoney".."']"] end
										if (actionOnObject==3 and thisValue <= myMoney) or actionOnObject == 4 then
											-- spend or gain money
											if actionOnObject == 3 then
												myMoney = myMoney - thisValue
											end
											if actionOnObject == 4 then
												myMoney = myMoney + thisValue
											end
											_G["g_UserGlobal['".."MyMoney".."']"] = myMoney
											-- find destination entity if any
											local entityindexto = 0
											local tinventorytoqty = GetInventoryQuantity(tinventorydest)
											for tinventorytoindex = 1, tinventorytoqty, 1 do
												local tcollectiontoindex = GetInventoryItem(tinventorydest,tinventorytoindex)
												if tcollectiontoindex == tcollectionindex then
													entityindexto = GetInventoryItemID(tinventorydest,tinventorytoindex)
													if GetEntityCollectable(entityindexto) ~= 2 then
														entityindexto = 0
													end
												end
											end
											-- deduct from source
											local entityindexfrom = GetInventoryItemID(tinventorysource,tinventoryindex)
											if entityindexfrom > 0 then
												if GetEntityCollectable(entityindexfrom) == 2 then
													local tqtyfrom = GetEntityQuantity(entityindexfrom)
													tqtyfrom = tqtyfrom - 1
													SetEntityQuantity(entityindexfrom,tqtyfrom)
													if tqtyfrom == 0 then
														MoveInventoryItem(tinventorysource,"",-1,entityindexfrom,-1)
														g_UserGlobalContainerRefresh = 1
													end
												else
													entityindexfrom = 0
												end
											end
											-- add to dest or move to dest
											if entityindexfrom > 0 then
												if entityindexto > 0 then
													local tqtyto = 1
													tqtyto = GetEntityQuantity(entityindexto)
													tqtyto = tqtyto + 1
													SetEntityQuantity(entityindexto,tqtyto)
												else
													-- need to create new resource item in destination (as source still needs its item as not depleted)
													local newe = SpawnNewEntity(entityindexfrom)
													SetEntityCollected(newe,3,-1,tinventorydest)
													g_UserGlobalContainerRefresh = 1
												end
											else
												local entityindexfrom = GetInventoryItemID(tinventorysource,tinventoryindex)
												if entityindexfrom > 0 then
													MoveInventoryItem(tinventorysource,tinventorydest,-1,entityindexfrom,-1)
												else
													MoveInventoryItem(tinventorysource,tinventorydest,tcollectionindex,0,-1)
												end
												g_UserGlobalContainerRefresh = 1
											end
										end
									end
									break
								end
							end
						end
					end
				end
			end
			local actionOnScreen = 0
			if buttonElementName == "LEAVE" then actionOnScreen = 101 end
			if buttonElementName == "TAKE ALL" then actionOnScreen = 102 end
			if buttonElementName == "CRAFT" then actionOnScreen = 103 end
			if buttonElementName == "ACCEPT" then actionOnScreen = 104 end
			if buttonElementName == "CANCEL" then actionOnScreen = 105 end
			if actionOnScreen > 0 then
				if actionOnScreen == 101 then
					-- LEAVE HUD screen
					ScreenToggle("")
				end
				if actionOnScreen == 102 then
					-- TAKE ALL Contents
					local cycleuntilnomoretransfers = 1
					while cycleuntilnomoretransfers == 1 do
						cycleuntilnomoretransfers = 0 
						local inventorycontainer = "inventory:"..g_UserGlobalContainer
						local tinventoryqty = GetInventoryQuantity(inventorycontainer)
						for tinventoryindex = 1, tinventoryqty, 1 do
							local tcollectionindex = GetInventoryItem(inventorycontainer,tinventoryindex)
							local tentityindex = GetInventoryItemID(inventorycontainer,tinventoryindex)
							MoveInventoryItem(inventorycontainer,"inventory:player",-1,tentityindex,-1)
							g_UserGlobalContainerRefresh = 1
							cycleuntilnomoretransfers = 1
						end
					end
				end
				if actionOnScreen == 103 then
					-- CRAFT recipe from inventory:craft
					local inventorycontainer = "inventory:craft"
					local tinventoryindex = GetInventoryQuantity(inventorycontainer)
					if tinventoryindex == 1 then
						-- determine if can craft 'nameofitemtomake'
						local tcollectionindex = GetInventoryItem(inventorycontainer,tinventoryindex)
						local nameofitemtomake = GetCollectionItemAttribute(tcollectionindex,"description")
						local anyee = 0
						for ee = 1, g_EntityElementMax, 1 do
							if e ~= ee then
								if g_Entity[ee] ~= nil then
									if g_Entity[ee]['active'] > 0 then
										if GetEntityName(ee) == nameofitemtomake then
											anyee = ee
											break
										end
									end
								end
							end
						end
						if anyee > 0 then
							-- check then eat ingredients
							local listofitems = {}
							local listofitemscount = 0							
							local haveallingredients = 0
							for twopasses = 1, 2, 1 do
								haveallingredients = 1
								local ingredientsneeded = GetCollectionItemAttribute(tcollectionindex,"ingredients")
								while string.len(ingredientsneeded) > 0 do
									i, j = string.find(ingredientsneeded,",")
									if i ~= nil then
										nextingredient = string.sub(ingredientsneeded,1,i-1)
										ingredientsneeded = string.sub(ingredientsneeded,i+1,-1)
									else
										nextingredient = ingredientsneeded
										ingredientsneeded = ""
									end
									if string.len(nextingredient) > 0 then
										local inventorycontainer = "inventory:"..g_UserGlobalContainer
										local tinventoryqty = GetInventoryQuantity(inventorycontainer)
										local wehavethisone = 0
										for tinventoryindex = 1, tinventoryqty, 1 do
											local dowehavethisitem = GetInventoryItem(inventorycontainer,tinventoryindex)
											local nameofingredientitem = GetCollectionItemAttribute(dowehavethisitem,"title")
											local tstring1 = string.upper(nextingredient)
											local tstring2 = string.upper(nameofingredientitem)
											if tstring1 == tstring2 then
												wehavethisone = 1
												if twopasses == 2 then
													-- mark for consumption
													local entityindex = GetInventoryItemID(inventorycontainer,tinventoryindex)
													if entityindex > 0 then
														listofitemscount=listofitemscount+1
														listofitems[listofitemscount] = entityindex
													end
												end
											end
										end
										if wehavethisone == 0 then
											haveallingredients = 0
											break
										end
									end
								end
								if twopasses == 1 and haveallingredients == 0 then
									break
								end
							end
							if haveallingredients == 1 then
								-- consume used items
								local inventorycontainer = "inventory:"..g_UserGlobalContainer
								local cycleuntilnomoretransfers = 1
								while cycleuntilnomoretransfers == 1 do
									cycleuntilnomoretransfers = 0 
									local tinventoryqty = GetInventoryQuantity(inventorycontainer)
									for tinventoryindex = 1, tinventoryqty, 1 do
										local entityindex = GetInventoryItemID(inventorycontainer,tinventoryindex)
										for tlistindex = 1, listofitemscount, 1 do
											if listofitems[tlistindex] == entityindex then
												local tcollectionindex = GetInventoryItem(inventorycontainer,tinventoryindex)
												local tqty = 1
												if GetEntityCollectable(entityindex) == 2 then
													tqty = GetEntityQuantity(entityindex)
												end
												tqty = tqty - 1
												if tqty <= 0 then
													SetEntityCollected(entityindex,0,0)
													Destroy(entityindex)
													cycleuntilnomoretransfers = 1
													break
												else
													if GetEntityCollectable(entityindex) == 2 then
														SetEntityQuantity(entityindex,tqty)
													end
												end
											end
										end
									end
								end
								-- create new item
								local newe = SpawnNewEntity(anyee)
								SetEntityCollected(newe,1,-1)
							end
						end
					end
				end
				if actionOnScreen == 104 then
					-- ACCEPT on QUEST screen
					local findee = 0
					for ee = 1, g_EntityElementMax, 1 do
						if e ~= ee then
							if g_Entity[ee] ~= nil then
								if g_Entity[ee]['active'] > 0 then
									if GetEntityName(ee) == g_UserGlobalQuestTitleShowingObject then
										findee = ee
										break
									end
								end
							end
						end
					end
					if findee > 0 then
						g_UserGlobalQuestTitleActive = g_UserGlobalQuestTitleShowing
						g_UserGlobalQuestTitleActiveE = findee
						ScreenToggle("")
					end
				end
				if actionOnScreen == 105 then
					-- CANCEL current QUEST
					g_UserGlobalQuestTitleActive = ""
					g_UserGlobalQuestTitleActiveObject = ""
					g_UserGlobalQuestTitleActiveE = 0
					ScreenToggle("")
				end
			end
		end
	end
	-- handle any button activity for GLOBAL VALUES = AWARD, etc
	local updatePlayerLimits = 0
	if buttonElementID ~= -1 then
		local buttonElementName = GetScreenElementName(1+buttonElementID)
		if string.len(buttonElementName) > 0 then
			local functionOnObject = 0
			local functionName = string.sub(buttonElementName, 1, 6)
			local functionParameter = ""
			if functionName == "AWARD:" then 
				functionOnObject = 1 
				functionParameter = string.sub(buttonElementName, 7, -1)
			end
			if functionOnObject > 0 then
				if functionOnObject == 1 then
					-- AWARD = Spend a POINT to increase a global value
					local pointavailable = 0
					if _G["g_UserGlobal['".."MyNewPoints".."']"] ~= nil then pointavailable = _G["g_UserGlobal['".."MyNewPoints".."']"] end
					local valuetoamend = 0
					if _G["g_UserGlobal['"..functionParameter.."']"] ~= nil then valuetoamend = _G["g_UserGlobal['"..functionParameter.."']"] end
					local valuetoamendmax = 100
					if _G["g_UserGlobal['"..functionParameter.."Max".."']"] ~= nil then valuetoamendmax = _G["g_UserGlobal['"..functionParameter.."Max".."']"] end
					local amounttoamend = 1
					if pointavailable > 0 and valuetoamend < valuetoamendmax then
						_G["g_UserGlobal['"..functionParameter.."']"] = valuetoamend + amounttoamend
						_G["g_UserGlobal['".."MyNewPoints".."']"] = pointavailable - amounttoamend
						updatePlayerLimits = 1
					end
				end
			end
		end
	end
	
	-- handle any adjustments to player limits and maximums	
	if updatePlayerLimits == 1 then
		-- these can be amended via custom scripts for more sophisticated mechanics
		local modifyglobal = ""
		-- strength increases max health
		local currentstrength = 0 if _G["g_UserGlobal['".."MyStrength".."']"] ~= nil then currentstrength = _G["g_UserGlobal['".."MyStrength".."']"] end
		local initialhealthmax = 100 if _G["g_UserGlobal['".."MyHealthInitial".."']"] ~= nil then initialhealthmax = _G["g_UserGlobal['".."MyHealthInitial".."']"] end
		local newhealthmax = initialhealthmax + (currentstrength*100)
		SetGamePlayerControlStartStrength(newhealthmax)
		g_gameloop_StartHealth = newhealthmax
		-- intelligence increases max mana
		local currentintelligence = 0 if _G["g_UserGlobal['".."MyIntelligence".."']"] ~= nil then currentintelligence = _G["g_UserGlobal['".."MyIntelligence".."']"] end
		local initialmanamax = 100 if _G["g_UserGlobal['".."MyManaInitial".."']"] ~= nil then initialmanamax = _G["g_UserGlobal['".."MyManaInitial".."']"] end
		modifyglobal = "MyManaMax" _G["g_UserGlobal['"..modifyglobal.."']"] = initialmanamax + (currentintelligence*100)
		-- dexterity increases stamina
		local currentdexterity = 0 if _G["g_UserGlobal['".."MyDexterity".."']"] ~= nil then currentdexterity = _G["g_UserGlobal['".."MyDexterity".."']"] end
		local initialstaminamax = 100 if _G["g_UserGlobal['".."MyStaminaInitial".."']"] ~= nil then initialstaminamax = _G["g_UserGlobal['".."MyStaminaInitial".."']"] end
		modifyglobal = "MyStaminaMax" _G["g_UserGlobal['"..modifyglobal.."']"] = initialstaminamax + (currentdexterity*100)
	end
	
	-- draw mouse pointer below
	drawMousePointer = 1
	
  else
  
	-- leave mouse mode
	if hud0_freezeforpointer == 1 then 
		DeactivateMouse()
		UnFreezePlayer()
		SetCameraOverride(0)
		hud0_freezeforpointer = 0
		hud0.refreshHUD()
	end

	-- display main in-game HUD screen
	DisplayScreen("HUD0")

	-- display contents of any hot key panels in the main in-game HUD too (although need to get order from hotkey shortcut)
	local tgridqty = GetScreenElementsType("user defined global panel")
	for gridi = 1, tgridqty, 1 do
		local thegrid = GetScreenElementTypeID("user defined global panel",gridi)
		if thegrid > 0 then
			local panelname = GetScreenElementName(thegrid)
			if panelname == "inventory:hotkeys" then
				local tgridx = 0
				local tgridy = 0
				local tgridwidth = 0
				local tgridheight = 0
				tgridx,tgridy,tgridwidth,tgridheight = GetScreenElementArea(thegrid)    
				totalinrow, totalincolumn = GetScreenElementDetails(thegrid)
				if totalinrow < 1 then totalinrow = 1 end
				if totalincolumn < 1 then totalincolumn = 1 end
				local gridtilewidth = tgridwidth/totalinrow
				local gridtileheight = tgridheight/totalincolumn
				if hud0_gridSpriteID ~= nil then		
					for itemindex = 0, 8, 1 do
						local tcollectionindex = hud0_playercontainer_collectionindex[hud0_playercontainer_screenID][gridi][itemindex]
						local scrimg = hud0_playercontainer_img[hud0_playercontainer_screenID][gridi][itemindex]
						if tcollectionindex ~= nil and scrimg > 0 then
							local scrx = tgridx+((itemindex)*gridtilewidth)
							SetSpritePosition(hud0_gridSpriteID,scrx,tgridy)
							SetSpriteImage(hud0_gridSpriteID,scrimg)
							SetSpriteSize(hud0_gridSpriteID,gridtilewidth,-1)
							SetSpriteColor(hud0_gridSpriteID,255,255,255,255)
							SetSpritePriority(hud0_gridSpriteID,-1)
							PasteSprite(hud0_gridSpriteID)
						end
					end
				end
			end
		end
	end

  end

  -- display contents of any user defined images for map views 
  if GetIfUsingTABScreen() == 0 then
   local realmapsize = 50000
   local tqty = GetScreenElementsType("user defined global image")
   for ii = 1, tqty, 1 do
	local theelementID = GetScreenElementTypeID("user defined global image",ii)
	if theelementID > 0 then
		local imagename = GetScreenElementName(theelementID)
		local isMap = string.sub(imagename, 1, 4)
		if isMap == "map:" then
			scrx,scry,tscrwidth,tscrheight = GetScreenElementArea(theelementID)    
			local scrimg = GetScreenElementImage(theelementID)
			local scruseoffset = 0
			SetScreenElementVisibility(theelementID,0)
			local mapName = string.sub(imagename, 5, -1)
			local scritems = -1
			if mapName == "window" then
				hud0_mapView_WindowX = scrx
				hud0_mapView_WindowY = scry
				hud0_mapView_WindowW = tscrwidth
				hud0_mapView_WindowH = tscrheight
			end
			if mapName == "image" then
				scrx = hud0_mapView_ImageX
				scry = hud0_mapView_ImageY
				tscrwidth = hud0_mapView_WindowW
				tscrheight = tscrwidth * (GetImageHeight(scrimg)/GetImageWidth(scrimg))
				hud0_mapView_ImageOW = tscrwidth
				hud0_mapView_ImageOH = tscrheight
				tscrwidth=tscrwidth*hud0_mapView_Scale
				tscrheight=tscrheight*hud0_mapView_Scale
			end
			if mapName == "player" then
				placex =  g_PlayerPosX
				placez =  g_PlayerPosZ
				scrx = (hud0_mapView_ImageX + (hud0_mapView_ImageW/2)) - (tscrwidth/2) + (placex/realmapsize)*(hud0_mapView_ImageW/2)
				scry = (hud0_mapView_ImageY + (hud0_mapView_ImageH/2)) - (tscrheight/2) - (placez/realmapsize)*(hud0_mapView_ImageH/2)
			end
			local itemstodraw = {}
			local itemstodrawscale = {}
			if mapName == "character" or mapName == "objective" or mapName == "winzone" then
				local entlist = U.ClosestEntities( realmapsize )
				scritems = 0
				for entlistindex = 1, #entlist, 1 do
					local ee = entlist[entlistindex]
					if ee > 0 then
						if g_Entity[ee].active > 0 then
							if mapName == "character" then
								local thisallegiance = GetEntityAllegiance(ee)
								if thisallegiance >= 0 then
									scritems = scritems + 1
									itemstodraw[scritems] = ee
									itemstodrawscale[scritems] = 1.0
								end
							end
							if mapName == "objective" then
								local thisobjective = GetEntityObjective(ee)
								if thisobjective == 1 then
									if g_UserGlobalQuestTitleActiveE > 0 and g_UserGlobalQuestTitleActiveE == ee then
										scritems = scritems + 1
										itemstodraw[scritems] = ee
										itemstodrawscale[scritems] = 2.0 + math.cos(Timer()/500.0)
										scruseoffset = 1
									end
								end
							end
							if mapName == "winzone" then
								local thisobjective = GetEntityObjective(ee)
								if thisobjective == 2 then
									scritems = scritems + 1
									itemstodraw[scritems] = ee
									itemstodrawscale[scritems] = 1.0
								end
							end
						end
					end
				end
			end
			if hud0_gridSpriteID ~= nil then
				local drawthelot = scritems
				if scritems == -1 and drawthelot < 1 then drawthelot = 1 end
				for titem = 1, drawthelot, 1 do
					if scritems > 0 then
						placex = g_Entity[itemstodraw[titem]].x
						placez = g_Entity[itemstodraw[titem]].z
						scrx = (hud0_mapView_ImageX + (hud0_mapView_ImageW/2)) - (tscrwidth/2) + (placex/realmapsize)*(hud0_mapView_ImageW/2)
						scry = (hud0_mapView_ImageY + (hud0_mapView_ImageH/2)) - (tscrheight/2) - (placez/realmapsize)*(hud0_mapView_ImageH/2)
					end
					local tusescrwidth = tscrwidth
					local tusescrheight = tscrheight
					if scritems > 0 then
						tusescrwidth = tusescrwidth * itemstodrawscale[scritems]
						tusescrheight = tusescrheight * itemstodrawscale[scritems]
					end
					if scrimg > 0 then
						SetSpritePosition(hud0_gridSpriteID,scrx,scry)
						SetSpriteImage(hud0_gridSpriteID,scrimg)
						if scruseoffset == 1 then
							SetSpriteOffset(hud0_gridSpriteID,tusescrwidth/2,-1)
						else
							SetSpriteOffset(hud0_gridSpriteID,0,0)
						end
						SetSpriteSize(hud0_gridSpriteID,tusescrwidth,tusescrheight)
						SetSpriteColor(hud0_gridSpriteID,255,255,255,255)
						SetSpritePriority(hud0_gridSpriteID,-1)
						SetSpriteScissor(hud0_mapView_WindowX,hud0_mapView_WindowY,hud0_mapView_WindowW,hud0_mapView_WindowH)
						PasteSprite(hud0_gridSpriteID)
						SetSpriteScissor(0,0,0,0)
						SetSpriteOffset(hud0_gridSpriteID,0,0)
					end
				end
			end
		end
	end
   end
   -- map controls and scroller update
   local updateMapViewImage = 1
   if 1 then
	myuserglobal = "MyMapMiniZoom"
	if GetCurrentScreen() > -1 then
		if _G["g_UserGlobal['"..myuserglobal.."']"] ~= nil then hud0_mapView_Scale = _G["g_UserGlobal['"..myuserglobal.."']"]/100.0 end
		if g_MouseWheel > 0 then
			hud0_mapView_Scale = hud0_mapView_Scale + 0.2
			if hud0_mapView_Scale > 50 then hud0_mapView_Scale = 50 end
		end
		if g_MouseWheel < 0 then
			hud0_mapView_Scale = hud0_mapView_Scale - 0.2
			if hud0_mapView_Scale < 1 then hud0_mapView_Scale = 1 end
		end
		_G["g_UserGlobal['"..myuserglobal.."']"] = hud0_mapView_Scale * 100.0
	else
		if _G["g_UserGlobal['"..myuserglobal.."']"] ~= nil then hud0_mapView_Scale = _G["g_UserGlobal['"..myuserglobal.."']"]/100.0 end
	end
   end
   if updateMapViewImage == 1 then
	tscrwidth = hud0_mapView_ImageOW
	tscrheight = hud0_mapView_ImageOH
	tscrwidth=tscrwidth*hud0_mapView_Scale
	tscrheight=tscrheight*hud0_mapView_Scale
	hud0_mapView_ImageW = tscrwidth
	hud0_mapView_ImageH = tscrheight
	placex =  g_PlayerPosX
	placez =  g_PlayerPosZ
	scrollxlimit = (hud0_mapView_ImageW/2) - (hud0_mapView_WindowW/2)
	hud0_mapView_ScrollX = (placex/realmapsize)*(hud0_mapView_ImageW/2)
	if hud0_mapView_ScrollX < scrollxlimit*-1 then hud0_mapView_ScrollX = scrollxlimit*-1 end
	if hud0_mapView_ScrollX > scrollxlimit then hud0_mapView_ScrollX = scrollxlimit end
	scrollylimit = (hud0_mapView_ImageH/2) - (hud0_mapView_WindowH/2)	
	hud0_mapView_ScrollY = ((placez*-1)/realmapsize)*(hud0_mapView_ImageH/2)
	if hud0_mapView_ScrollY < scrollylimit*-1 then hud0_mapView_ScrollY = scrollylimit*-1 end
	if hud0_mapView_ScrollY > scrollylimit then hud0_mapView_ScrollY = scrollylimit end
	hud0_mapView_ImageX = hud0_mapView_WindowX - ((hud0_mapView_ImageW-hud0_mapView_WindowW)/2) - hud0_mapView_ScrollX
	hud0_mapView_ImageY = hud0_mapView_WindowY - ((hud0_mapView_ImageH-hud0_mapView_WindowH)/2) - hud0_mapView_ScrollY
   end
  end

  -- draw mouse pointer last
  if drawMousePointer == 1 then
	if hud0_pointerID == -1 then hud0_pointerID = GetScreenElementID("pointer",1) end
	if hud0_pointerID > 0 then
		-- use custom HUD pointer image if available
		SetScreenElementPosition(hud0_pointerID,g_sprCursorPtrX,g_sprCursorPtrY)
		hud0_pointerSpriteImageID = GetScreenElementImage(hud0_pointerID)
	end
	if hud0_pointerSpriteImageID == 0 then hud0_pointerSpriteImageID = LoadImage("imagebank\\HUD\\cursor-medium.png") end
	if hud0_pointerSpriteID == nil then hud0_pointerSpriteID = CreateSprite ( hud0_pointerSpriteImageID ) end
	SetSpritePosition ( hud0_pointerSpriteID, g_sprCursorPtrX, g_sprCursorPtrY )
	SetSpritePriority(hud0_pointerSpriteID,-1)
	PasteSprite(hud0_pointerSpriteID)
  end
  
  -- handle slow absorbsion of magic
  local currentmana = 0 
  if _G["g_UserGlobal['".."MyMana".."']"] ~= nil then currentmana = _G["g_UserGlobal['".."MyMana".."']"] end
  local maxiumummana = 100 if _G["g_UserGlobal['".."MyManaMax".."']"] ~= nil then maxiumummana = _G["g_UserGlobal['".."MyManaMax".."']"] end
  if currentmana < maxiumummana then
	currentmana = currentmana + 0.01
  end
  _G["g_UserGlobal['".."MyMana".."']"] = currentmana
  
  -- handle awarding of XP points
  local entitykilled = GetNearestEntityDestroyed(0)
  if entitykilled > 0 then
    -- determine what has been destroyed
	local allegiance = GetEntityAllegiance(entitykilled) -- get the allegiance value for this object (-1-none, 0-ally, 1-enemy, 2-neutral)
	if allegiance == 0 then
		local scoredXP = 100
		local currentXP = 0 if _G["g_UserGlobal['".."MyXP".."']"] ~= nil then currentXP = _G["g_UserGlobal['".."MyXP".."']"] end
		currentXP = currentXP + scoredXP
		local maximumXP = 0 if _G["g_UserGlobal['".."MyXPMax".."']"] ~= nil then maximumXP = _G["g_UserGlobal['".."MyXPMax".."']"] end
		if currentXP >= maximumXP then
			-- levelling up!
			triggerElementPrompt = "MyLevelUpText"
			triggerElementPromptText = "YOU'VE LEVELLED UP!"
			triggerElementPromptTimer = Timer()
			-- reset current XP
			currentXP = currentXP - maximumXP
			-- increase new points available
			local pointavailable = 0 if _G["g_UserGlobal['".."MyNewPoints".."']"] ~= nil then pointavailable = _G["g_UserGlobal['".."MyNewPoints".."']"] end
			_G["g_UserGlobal['".."MyNewPoints".."']"] = pointavailable + 2
			-- increase player level
			local playerlevel = 1 if _G["g_UserGlobal['".."MyPlayerLevel".."']"] ~= nil then playerlevel = _G["g_UserGlobal['".."MyPlayerLevel".."']"] end
			playerlevel = playerlevel + 1
			_G["g_UserGlobal['".."MyPlayerLevel".."']"] = playerlevel
			-- new XP threshold for new player level
			maximumXP = playerlevel * 500
		end
		modifyglobal = "MyXP" _G["g_UserGlobal['"..modifyglobal.."']"] = currentXP
		modifyglobal = "MyXPMax" _G["g_UserGlobal['"..modifyglobal.."']"] = maximumXP
	end
  end
  
  -- handle any general element text work
  if triggerElementPrompt ~= nil then
	local telementqty = GetScreenElementsType("user defined global text")
	local elementbeingused = -1
	for elementi = 1, telementqty, 1 do
		local elementid = GetScreenElementTypeID("user defined global text",elementi)
		if elementid > 0 then
			local elementName = GetScreenElementName(elementid)
			if elementName == triggerElementPrompt then 
				elementbeingused = elementid
			end
		end
	end
	if elementbeingused > -1 then
		if Timer() < triggerElementPromptTimer + 3000 then
			SetScreenElementText(elementbeingused,triggerElementPromptText)
		else
			SetScreenElementText(elementbeingused,"")
			triggerElementPrompt = nil
		end
	end
  end 
 
  -- remove sprite pasters
  if hud0_pointerSpriteID ~= nil then SetSpritePosition(hud0_pointerSpriteID,-99999,-99999) end
  if hud0_gridSpriteID ~= nil then SetSpritePosition(hud0_gridSpriteID,-99999,-99999) end
      
  -- Hot Key Select can be from keys 1,2,3,4,5,6,7,8,9,0 in any HUD screen
  local tselkeystate = 0
  if tselkeystate == 0 then 
	for ti = 2, 11, 1 do
		if GetKeyState(ti) == 1 then 
			tselkeystate = ti-1
			break
		end
	end
  end
  if tselkeystate >= 1 and tselkeystate <= 9 then
	itemindex = tselkeystate - 1
	local panelname = "inventory:hotkeys"
	local tinventoryqty = GetInventoryQuantity(panelname)
	for tinventoryindex = 1, tinventoryqty, 1 do
		local tslotindex = GetInventoryItemSlot(panelname,tinventoryindex)
		if tslotindex == itemindex then 
			local entityindex = GetInventoryItemID(panelname,tinventoryindex)
			if entityindex > 0 then
				if GetEntityUsed(entityindex) == 0 then
					SetEntityUsed(entityindex,1)
				end
			end
		end
	end
  end
  
 end
end

function hud0.quit()
end

return hud0