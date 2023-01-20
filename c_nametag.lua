

local font_1 = dxCreateFont("fonts/deltabold.ttf", 8)
local sx, sy = guiGetScreenSize()
local maxIconsPerLine = 6
local streamedPlayers = {}
local streamedPeds = {}
local masks, badges = {}, {}
local moneyFloat = {}

setTimer(
    function()
        if getElementData(localPlayer, "loggedin") ~= 1 then return end
        if getElementInterior(localPlayer) ~= 0 or getElementDimension(localPlayer) ~= 0 then 
            setPlayerHudComponentVisible("radar", false)
        else 
            setPlayerHudComponentVisible("radar", false)
        end
    end, 1000, 0
)


local awardTick = {}
localPlayer:setData("award", false)
function moneyUpdateFX(state, amount, toEachother)
	if amount and tonumber(amount) and tonumber(amount) > 0  then
		local info = {{"Finans Güncellemesi"},{""}}
		local money = localPlayer:getData('money') or 0
		local textType = "Kullanıcı Bilgileri Güncellemesi"
		local bankmoney = localPlayer:getData('bankmoney') or 0
		if state then
			triggerEvent("shop:playCollectMoneySound", localPlayer)
			moneyFloat["mR"] = 20
			moneyFloat["mG"] = 255
			moneyFloat["mB"] = 20
			moneyFloat["mAlpha"] = 255
			moneyFloat["direction"] = 1
			moneyFloat["moneyYOffset"] = 60
			moneyFloat["text"] = "+$"..exports.global:formatMoney(amount)

			table.insert(info, {"   - Para: $"..exports.global:formatMoney(money).." ("..moneyFloat["text"]..")"})
			if toEachother then
				table.insert(info, {"   - Banka Parası: $"..exports.global:formatMoney(bankmoney-amount)})
			else
				table.insert(info, {"   - Banka Parası: $"..exports.global:formatMoney(bankmoney)})
			end
		else
			triggerEvent("shop:playPayWageSound", localPlayer)
			moneyFloat["mR"] = 255
			moneyFloat["mG"] = 20
			moneyFloat["mB"] = 20
			moneyFloat["mAlpha"] = 255
			moneyFloat["direction"] = -1
			moneyFloat["moneyYOffset"] = 180
			moneyFloat["text"] = "-$"..exports.global:formatMoney(amount)

			table.insert(info, {"   - Para: $"..exports.global:formatMoney(money).." ("..moneyFloat["text"]..")"})
			if toEachother then
				table.insert(info, {"   - Banka Parası: $"..exports.global:formatMoney(bankmoney+amount)})
			else
				table.insert(info, {"   - Banka Parası: $"..exports.global:formatMoney(bankmoney)})
			end
		end
		table.insert(info, {""})
		triggerEvent("hudOverlay:drawOverlayTopRight", localPlayer, info, textType)
	end
end
addEvent("moneyUpdateFX", true)
addEventHandler("moneyUpdateFX", root, moneyUpdateFX)

addEventHandler("onClientElementStreamIn", root,
	function()
		if (localPlayer.interior == source.interior) and (localPlayer.dimension == source.dimension) and not streamedPlayers[source] then
			if source.type == "player" then
				createCache(source, "player")
			elseif source.type == "ped" then
				createCache(source, "ped")
			end
		end
	end
)

addEventHandler("onClientElementStreamOut", root,
	function()
		if (localPlayer.interior == source.interior) and (localPlayer.dimension == source.dimension) then
			if source.type == "player" then
				destroyCache(source, "player")
			elseif source.type == "ped" then
				destroyCache(source, "ped")
			end
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		for key, value in pairs(exports['items']:getBadges()) do
			badges[value[1]] = { value[4][1], value[4][2], value[4][3], value[5], value.bandana or false }
		end

		masks = exports['items']:getMasks()

		for index, source in ipairs(getElementsByType("player")) do
			if isElementStreamedIn(source) and not streamedPlayers[source] then
				if (localPlayer.interior == source.interior) and (localPlayer.dimension == source.dimension) then
					createCache(source, "player")
				end
			end
		end
		for index, source in ipairs(getElementsByType("ped")) do
			if isElementStreamedIn(source) then
				if (localPlayer.interior == source.interior) and (localPlayer.dimension == source.dimension) then
					createCache(source, "ped")
				end
			end
		end
		
	end
)

function createCache(element, elementType)
	if elementType == "player" then
		if not streamedPlayers[element] then
			local firstDetails = getFirstDetails(element)
        	streamedPlayers[element] = firstDetails
        end
	elseif elementType == "ped" then
		local firstDetails = getFirstDetails(element)
        streamedPeds[element] = firstDetails
	end
end

function destroyCache(element, elementType)
	if elementType == "player" then
		if streamedPlayers[element] then
			streamedPlayers[element] = nil
		end
	elseif elementType == "ped" then
		if streamedPeds[element] then
			streamedPeds[element] = nil
		end
	end
end

function getFirstDetails(element)
	if element.type == "player" then
		local table = {
			['loggedin'] = element:getData('loggedin'),
			['reconx'] = element:getData('reconx') or false,
			['writting'] = element:getData('writting'),
			['playerid'] = element:getData('playerid'),
			['hiddenadmin'] = element:getData('hiddenadmin'),
			['duty_admin'] = element:getData('duty_admin'),
			['admin_level'] = element:getData('admin_level'),
			['supporter_level'] = element:getData('supporter_level'),
			['account:username'] = element:getData('account:username'),
			['duty_supporter'] = element:getData('duty_supporter'),
			['seatbelt'] = element:getData('playerid'),
			['cellphoneGUIStateSynced'] = element:getData('cellphoneGUIStateSynced'),
			['restrain'] = element:getData('restrain'),
			['freecam:state'] = element:getData('freecam:state'),
			['gasmask'] = element:getData('gasmask'),
			['mask'] = element:getData('mask'),
			['helmet'] = element:getData('helmet'),
			['scuba'] = element:getData('scuba'),
			['christmashat'] = element:getData('christmashat'),
			['vip'] = element:getData('vip'),
			['award'] = element:getData('award'),
		}
		for index, value in pairs(exports["items"]:getBadges()) do
			table[value[1]] = element:getData(value[1])
		end
		return table
	elseif element.type == "ped" then
		local table = {
			['nametag'] = element:getData('nametag'),
			['talk'] = element:getData('talk'),
			
		}
		return table
	end
end

addEventHandler("onClientElementDataChange", root,
	function(dataName)
		if source.type == "player" and streamedPlayers[source] then
			if streamedPlayers[source][dataName] then
				local new_data_value = source:getData(dataName)
				streamedPlayers[source][dataName] = new_data_value
			end
		elseif source.type == "ped" and streamedPeds[source] then
			if streamedPeds[source][dataName] then
				local new_data_value = source:getData(dataName)
				streamedPeds[source][dataName] = new_data_value
			end
		
		end
	end
)

badgesize = 0

function getPlayerIcons(name, player, forTopHUD, distance, status)
	distance = distance or 0
	local tinted, masked = false, false
	local icons = {}
	
		if getElementData(player, "loggedin") then
		
			for key, value in pairs(masks) do
		if getElementData(player, value[1]) then
			-- table.insert(icons, value[1])
			if value[4] then
				masked = true
			end
		end
	end
	
	for k, v in pairs(badges) do
			local title = getElementData(player, k)
			if title then
				if v[4] == 122 or v[4] == 123 or v[4] == 124 or v[4] == 125 or v[4] == 135 or v[4] == 136 or v[4] == 158 or v[4] == 168 then
					
					name = "Belirsiz Kişi (Bandana)"
					badge = true
				end
			end
		end
		
		end

	if getElementData(player, "loggedin") == 1 then
	if not forTopHUD then

if getElementData(player, "admin_level") == 8 and getElementData(player,"duty_admin") == 1 and getElementData(player,"hiddenadmin") == 0 then
            table.insert(icons, 'developeradmm')
        end

        if getElementData(player, "admin_level") == 7 and getElementData(player,"duty_admin") == 1 and getElementData(player,"hiddenadmin") == 0 then
            table.insert(icons, 'developeradmm')
        end

        if getElementData(player, "admin_level") == 6 and getElementData(player,"duty_admin") == 1 and getElementData(player,"hiddenadmin") == 0 then
            table.insert(icons, 'a8_on')
        end

        if getElementData(player, "admin_level") == 5 and getElementData(player,"duty_admin") == 1 and getElementData(player,"hiddenadmin") == 0 then
            table.insert(icons, 'a5_on')
        end

        if getElementData(player, "admin_level") == 4 and getElementData(player,"duty_admin") == 1 and getElementData(player,"hiddenadmin") == 0 then
            table.insert(icons, 'a4_on')
        end

        if getElementData(player, "admin_level") == 3 and getElementData(player,"duty_admin") == 1 and getElementData(player,"hiddenadmin") == 0 then
            table.insert(icons, 'a3_on')
        end

        if getElementData(player, "admin_level") == 2 and getElementData(player,"duty_admin") == 1 and getElementData(player,"hiddenadmin") == 0 then
            table.insert(icons, 'a2_on')
        end

        if getElementData(player, "admin_level") == 1 and getElementData(player,"duty_admin") == 1 and getElementData(player,"hiddenadmin") == 0 then
            table.insert(icons, 'a1_on')
        end
    end

		if getElementData(player, "loggedin") == 1 then	
			if getElementData(player,"duty_supporter") == 1 and getElementData(player,"hiddenadmin") ~= 1 then		
				table.insert(icons, "rehber")				
			end

		if getElementData(player,"ustyklogo") == 1 and getElementData(player,"uyk") == 1 and getElementData(player,"hiddenadmin") == 0 then
			table.insert(icons, "udy_on")
		end

        if player:getData("vipver") == 1 then
			table.insert(icons, "vip1")	
		elseif player:getData("vipver") == 2 then
			table.insert(icons, "vip2")
		elseif player:getData("vipver") == 3 then
			table.insert(icons, "vip3")	
		elseif player:getData("vipver") == 4 then
			table.insert(icons, "vip4")			
		end	
		
		
	
		if getElementData(player,"etiket") == 1 then
			table.insert(icons, "isimetiketleri1")
		end

		if getElementData(player,"etiket") == 2 then
			table.insert(icons, "isimetiketleri2")
		end

		if getElementData(player,"etiket") == 3 then
			table.insert(icons, "isimetiketleri3")
		end

		if getElementData(player,"etiket") == 4 then
			table.insert(icons, "isimetiketleri4")
		end

		if getElementData(player,"etiket") == 5 then
		    table.insert(icons, "isimetiketleri5")
		end

		if getElementData(player,"etiket") == 6 then
		    table.insert(icons, "isimetiketleri6")
		end
		
		
		if getElementData(player,"etiket") == 7 then
		    table.insert(icons, "isimetiketleri7")
		end

        
        if getElementData(player, "youtuber") == 1 then
			table.insert(icons, "youtuberEtiketi")
		end

		if getElementData(player,"ulke") == 0 then
			table.insert(icons, "ulke")
		end
			

		local isMinimized = getElementData(player, "hud:minimized")

		if isMinimized then
			table.insert(icons, "afk")
		end
	end
		
	for key, value in pairs(masks) do
		if getElementData(player, value[1]) then
			--table.insert(icons, value[1])
			if value[4] then
				masked = true
			end
		end
	end


	local vehicle = getPedOccupiedVehicle(player)
	local windowsDown = vehicle and getElementData(vehicle, "vehicle:windowstat") == 1

	if vehicle and not windowsDown and vehicle ~= getPedOccupiedVehicle(localPlayer) and getElementData(vehicle, "tinted") then
		local seat0 = getVehicleOccupant(vehicle, 0) == player
		local seat1 = getVehicleOccupant(vehicle, 1) == player
		--outputDebugString(toJSON(seat0, seat1))
		if seat0 or seat1 then
			name = "Gizli (Cam Filmi)"
			tinted = true
		else
			name = "Gizli (Cam Filmi)"
			tinted = true
		end
	end

	if not tinted then
		-- pretty damn hard to see thru tint
		if getElementData(player,"seatbelt") and getPedOccupiedVehicle(player) then
			table.insert(icons, 'seatbelt')
		end


		if getElementData(player,"smoking") == true then
			table.insert(icons, 'cigarette')
		end

		--[[if masked then
			name = "Belirsiz Kişi ["..getElementData(player, "playerid").."]"
		end--]]
		if getElementData(player, "maske:tak") then 
			name = "Gizli - #"..(getElementData(player , "dbid")*10)+123 
			table.insert(icons, 'maskehacimbu')
		end

		for k, v in pairs(badges) do
			local title = getElementData(player, k)
			if title then
				if not v[5] then
					badge = true
					value = 14
					table.insert(icons, 'badge1')
				else
					value = 0
					print("badgesiyok")
				end
			end
		end

		if tonumber(getElementData(player, 'cellphoneGUIStateSynced') or 0) > 0 then
			table.insert(icons, 'phone')
		end
	end

	

	if not tinted then
		if not forTopHUD then
			local health = getElementHealth( player )
			local tick = math.floor(getTickCount () / 1000) % 2
			if getPedArmor( player ) > 50 then
				--table.insert(icons, 'armour')
			end
			
			
			if getElementData(player, "restrain") == 1 then
				table.insert(icons, "handcuffs")
			end
		end

		
	end
		
	if not forTopHUD then
		if windowsDown then
			--table.insert(icons, 'window2')
		end
	end
	end

	return name, icons, tinted
end


function isPlayerMoving(player)
	return (not isPedInVehicle(player) and (getPedControlState(player, "forwards") or getPedControlState(player, "backwards") or getPedControlState(player, "left") or getPedControlState(player, "right") or getPedControlState(player, "accelerate") or getPedControlState(player, "brake_reverse") or getPedControlState(player, "enter_exit") or getPedControlState(player, "enter_passenger")))
end

local lastrot = nil

function aimsSniper()
	return getPedControlState(localPlayer, "aim_weapon") and ( getPedWeapon(localPlayer) == 22 or getPedWeapon(localPlayer) == 23 or getPedWeapon(localPlayer) == 24 or getPedWeapon(localPlayer) == 25 or getPedWeapon(localPlayer) == 26 or getPedWeapon(localPlayer) == 27 or getPedWeapon(localPlayer) == 28 or getPedWeapon(localPlayer) == 29 or getPedWeapon(localPlayer) == 30 or getPedWeapon(localPlayer) == 31 or getPedWeapon(localPlayer) == 32 or getPedWeapon(localPlayer) == 33 or getPedWeapon(localPlayer) == 34)
end

function aimsAt(player)
	return getPedTarget(localPlayer) == player and aimsSniper()
end

function getBadgeColor(player)
	for k, v in pairs(badges) do
		if getElementData(player, k) then
			return unpack(badges[k])
		end
	end
end

function getVariableColor(variable)
	if (variable) > 50 then
		return "#009432"
	elseif (variable) >= 30 and (variable) <= 50 then
		return "#f1c40f"
	elseif (variable) <= 29 then
		return "#ff0000"
	end
end

local nametag = true 

addCommandHandler("nametag", function()
	nametag = not nametag
end)


function renderNametags()
	local lx, ly, lz = getElementPosition(localPlayer)
	local dim = getElementDimension(localPlayer)
	if localPlayer:getData('loggedin') == 0 or localPlayer:getData('screenshot:mode') then
		return
	end

	if not nametag then return end
	if localPlayer:getData('radaracik') then return end
	font = 'default-bold'
	for player, data in pairs(streamedPlayers) do
		if not isElement(player) then
			streamedPlayers[player] = nil
			break
		end

		local rx, ry, rz = getElementPosition(player)
		local distance = getDistanceBetweenPoints3D(lx, ly, lz, rx, ry, rz)
		local limitdistance = 10
		local reconx = false--local reconx = (streamedPlayers[localPlayer]['reconx'] or false) and (data['admin_level'] >= 2)
		local shown_player = true
		if (player == localPlayer) then
			shown_player = true
		end
		local now = getTickCount()
		if isElementOnScreen(player) and (shown_player) then
			if (aimsAt(player) or distance<limitdistance or reconx) then
				if not data['reconx'] and not data["freecam:state"] and getElementAlpha(player) >= 200 then
					local lx, ly, lz = getCameraMatrix()
					local vehicle = getPedOccupiedVehicle(player) or nil
					local collision, cx, cy, cz, element = processLineOfSight(lx, ly, lz, rx, ry, rz+1, true, true, true, true, false, false, true, false, vehicle)
					if not (collision) or aimsSniper() or (reconx) then
						local x, y, z = getElementPosition(player)
						local alpha = 0
						if not (isPedDucked(player)) then
							z = z + 1.2
						else
							z = z + 0.7
						end
						local sx, sy = getScreenFromWorldPosition(x, y, z+0.30, 100, false)
						local oldsy = nil
					
						local badge = false
						local tinted = false
value = 0

						local name = getPlayerName(player):gsub("_", " ")
						if (sx) and (sy) then
							distance = distance / 5

							if (reconx or aimsAt(player)) then distance = 1
							elseif (distance<1) then distance = 1
							elseif (distance>2) then distance = 2 end

							--DRAW BG
							name, icons, tinted, theBadge = getPlayerIcons(name, player, false, distance)

							if not theBadge then theBadge = false end
							oldsy = sy
								picxsize = 48 / 2 --/distance
								picysize = 48 / 2 --/distance
								ypos = 25
							local xpos = 0



							ypos = ypos - (distance/36)


								
							local expectedIcons = math.min(#icons, maxIconsPerLine)
							local iconsThisLine = 0
							local newY = 0
							local offset = 15 * expectedIcons
							local hpx, hpy, hpw, hph = sx-33/2-7, 3+oldsy+ypos/distance+12, 52, 8
									
							bar_olustur1(hpx-1, hpy-2, getElementHealth(player), 255)
							if getPedArmor(player) > 0 then
								bar_olustur2(hpx-1, hpy+9, getPedArmor(player), 255)
							end

                            if getPedArmor(player) > 0 then anan = 0 else anan = -10 end

							newY = newY + 12
						
							newY = newY/distance
									
							for k, v in ipairs(icons) do
                          	dxDrawImage(sx-offset+xpos+4,6+oldsy+newY+ypos+20+anan,picxsize,picysize,"images/samp/" .. v .. ".png")
								
								iconsThisLine = iconsThisLine + 1
								if iconsThisLine == expectedIcons then
									expectedIcons = math.min(#icons - k, maxIconsPerLine)
									offset = 15 * expectedIcons
									iconsThisLine = 0
									xpos = 0
									ypos = ypos + 35
								else
									xpos = xpos + 25
								end
							end
										
							if (distance<=2) then
								sy = math.ceil( sy + ( 2 - distance ) * 20 )
							end
							sy = sy + 10
							if (sx) and (sy) then
								if (6>5) then
									local offset = 45 / distance
								end
							end

							if (distance<=2) then
								sy = math.ceil( sy - ( 2 - distance ) * 40 )
							end
							sy = sy - 20
							if (distance < 1) then distance = 1 end
							if (distance > 2) then distance = 2 end
							local offset = 75 / distance
							local r, g, b = getBadgeColor(player)
							if not r or tinted then
								r, g, b = getPlayerNametagColor(player)
							end
							local id = data["playerid"]
							if badge then
								sy = sy - dxGetFontHeight(scale, font) * scale + 2.5
							end

								
							if player:getData('mask') then
								name = "Gizli(#"..(player:getData('dbid')*100+123)..")"
							else
								name = name.." ("..id..")"
							end
							sy = sy - distance*3
							if player:getData('yuksekping') == 1 then
								name = "[Yüksek ping değeri - ("..id..")]"
							end

							if player:getData('afk') then
								name = "(AFK) "..name
								r, g, b = 164, 150, 149
							end

							if player:getData("award") then
			                    if not awardTick[player] then
			                        awardTick[player] = {}
			                        awardTick[player].startTick = getTickCount()
			                    end
			                    local y, alpha = interpolateBetween(-5, 1, 1, 5, 255, 50, now / 2500, "SineCurve")
			                    local imgSize = 45
			                    dxDrawImage(sx-3 - ((imgSize/2) * distance), sy - (15 * distance) + (y * distance), imgSize * distance, imgSize * distance, "images/samp/award"..player:getData("award")..".png", 0, 0, 0, tocolor(255, 255, 255, alpha))
			                    if awardTick[player].startTick+2400 <= getTickCount() then
			                        awardTick[player] = nil
			                        collectgarbage("collect")
			                        if player:getData("award") then
			                        	player:setData("award", false)
			                        end
			                    end
			                end
						

							if getElementData(player, "writting") then
								local textWidth = dxGetTextWidth(name, scale, font)
								dxDrawImage(hpx+(dxGetTextWidth(name, scale, font)/2)+32, hpy-20, 20, 20,"images/samp/writting.png")
							end

							local donater = getElementData(player, "donatortag") or 0

							if donater > 0 then 
								dxDrawImage(hpx-(dxGetTextWidth(name, scale, font)/2)-7, hpy-20, picxsize-2,picysize-2,"images/samp/donatorEtiketi"..donater..".png")
							end

							dxDrawText(RemoveHEXColorCode(name), hpx+1, hpy-3, hpw+hpx+1, hph+hpy-12, tocolor(0, 0, 0, 200), 1.1, font, "center", "bottom", false, false, false, false, false)
							dxDrawText(RemoveHEXColorCode(name), hpx-1, hpy-3, hpw+hpx-1, hph+hpy-12, tocolor(0, 0, 0, 200), 1.1, font, "center", "bottom", false, false, false, false, false)
							dxDrawText(RemoveHEXColorCode(name), hpx, hpy+1-3, hpw+hpx, hph+hpy+1-12, tocolor(0, 0, 0, 200), 1.1, font, "center",   "bottom", false, false, false, false, false)
							dxDrawText(RemoveHEXColorCode(name), hpx, hpy-1-3, hpw+hpx, hph+hpy-1-12, tocolor(0, 0, 0, 200), 1.1, font, "center", "bottom", false, false, false, false, false)
							dxDrawText(name, hpx, hpy-1-3, hpw+hpx, hph+hpy-12, tocolor(r, g, b, 255), 1.1, font, "center", "bottom", false, false, false, false, false)
							
							if getElementData(player, 'baygin') == true then
								--if player:getData('afk') then return end
								hpy = hpy - 2
								dxDrawText("[Yaralı - /hasarlar]", hpx+1, (hpy-3)-(badgesize), hpw+hpx+1, hph+hpy-26-(badgesize), tocolor(0, 0, 0, 255), scale, font, "center", "bottom", false, false, false, false, false)
								dxDrawText("[Yaralı - /hasarlar]", hpx-1, hpy-3-(badgesize), (hpw+hpx-1), hph+hpy-26-(badgesize), tocolor(0, 0, 0, 255), scale, font, "center", "bottom", false, false, false, false, false)
								dxDrawText("[Yaralı - /hasarlar]", hpx, hpy+1-3-(badgesize), (hpw+hpx), hph+hpy+1-26-(badgesize), tocolor(0, 0, 0, 255), scale, font, "center",   "bottom", false, false, false, false, false)
								dxDrawText("[Yaralı - /hasarlar]", hpx, hpy-1-3-(badgesize), (hpw+hpx), hph+hpy-1-26-(badgesize), tocolor(0, 0, 0, 255), scale, font, "center", "bottom", false, false, false, false, false)
								dxDrawText("[Yaralı - /hasarlar]", hpx, hpy-1-3-(badgesize), (hpw+hpx), hph+hpy-26-(badgesize), tocolor(163, 72, 65, 255), scale, font, "center", "bottom", false, false, false, false, false)
							end

					end


				end
			end
		end
	end
end
end
setTimer(renderNametags, 5, 0)


value = 0


function aimsSniper()
	return getPedControlState(localPlayer, "aim_weapon") and ( getPedWeapon(localPlayer) == 22 or getPedWeapon(localPlayer) == 23 or getPedWeapon(localPlayer) == 24 or getPedWeapon(localPlayer) == 25 or getPedWeapon(localPlayer) == 26 or getPedWeapon(localPlayer) == 27 or getPedWeapon(localPlayer) == 28 or getPedWeapon(localPlayer) == 29 or getPedWeapon(localPlayer) == 30 or getPedWeapon(localPlayer) == 31 or getPedWeapon(localPlayer) == 32 or getPedWeapon(localPlayer) == 33 or getPedWeapon(localPlayer) == 34)
end

function aimsAt(player)
	return getPedTarget(localPlayer) == player and aimsSniper()
end


local afkEDN = "afk"


local ox,oy,oz = getElementPosition(localPlayer)
setTimer(
    function()
        local nx, ny, nz = getElementPosition(localPlayer)
        if math.floor(ox) == math.floor(nx) and math.floor(oy) == math.floor(ny) and math.floor(oz) == math.floor(ny) then
            setElementData(localPlayer, afkEDN, true)
            moveAfk = true
        else
            if moveAfk then
                if not clickAfk and not minimizeAfk then
                    setElementData(localPlayer, afkEDN, false)
                end
            end
        end
        ox,oy,oz = nx,ny,nz
    end, 30 * 1000, 0
)


addEventHandler("onClientCursorMove", getRootElement(),
		function(x, y)
			if not isCursorShowing() then
				return
			end
			lastClick = getTickCount()
			if 	localPlayer:getData(afkEDN) and not isMTAWindowActive() then
				setElementData(localPlayer,afkEDN,false)
			end
    end
)


addEventHandler("onClientMinimize", getRootElement(), 
	function()
		setElementData(localPlayer,afkEDN,true)
        minimizeAfk = true
	end
)

addEventHandler("onClientRestore", getRootElement(), 
	function()
		setElementData(localPlayer,afkEDN,false)
        minimizeAfk = false
	end
)


bindKey("ralt", "down",
    function()
        if localPlayer:getData("loggedin") ~= 1 then return end
        --if localPlayer:getData("award") then return end
        if isTimer(awardSpam) then return end
        if tonumber(localPlayer:getData("etiket")) > 0 then
            awardSpam = setTimer(function() end, 1000*10, 1)
            setElementData(localPlayer, "award", false)
            setElementData(localPlayer, "award", localPlayer:getData("etiket"))
			
           
        end
    end
)

addEvent("nametag:cal", true)
addEventHandler("nametag:cal", root, function(player)
	x, y, z = getElementPosition(player)
	sound = playSound3D("sounds/award"..getElementData(player, "etiket")..".mp3", x, y, z)
	setSoundMaxDistance(sound, 100)
end)

function bar_olustur1(x, y, v, d)
	if v < 0 then
		v = 0
	elseif v > 100 then
		v = 100
	end
	dxDrawRectangle(x-5.2, y-1, 56, 9, tocolor(18, 18, 18, 215))
	dxDrawRectangle((x-4.2)+1, y+1,( 54)-2, 7-2, tocolor(16, 193, 59,60))
	dxDrawRectangle((x-4.2)+1, y+1, (v / 1.85)-2, (6.8)-2,  tocolor(16, 193, 59, 215))
end

function bar_olustur2(x, y, v, d)
	if v < 0 then
		v = 0
	elseif v > 100 then
		v = 100
	end
	
	dxDrawRectangle(x-5.2, y-1, 56, 9, tocolor(18, 18, 18, 215))
	dxDrawRectangle((x-4.2)+1, (y)+1, (54)-2, 7-2, tocolor(90, 90, 90, 100))
	dxDrawRectangle((x-4.2)+1, y+1, (v / 1.85)-2, (6.8)-2, tocolor(90, 90, 90, 215))
end