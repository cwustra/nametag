local localPlayer = getLocalPlayer()
local show = false
local width, height = 570,100
local woffset, hoffset = 0, 0
local sx, sy = guiGetScreenSize()
local content = {}
local timerClose = getTickCount()
local cooldownTime = 5 --seconds
local toBeDrawnWidth = 0

renderTimers = {}

function createRender(id, func)
    if not isTimer(renderTimers[id]) then
        renderTimers[id] = setTimer(func, 0, 0)
    end
end

function destroyRender(id)
    if isTimer(renderTimers[id]) then
        killTimer(renderTimers[id])
        renderTimers[id] = nil
        collectgarbage("collect")
    end
end

local function removeRender()
	if show then
		destroyRender( "clientRender", clientRender )
		show = false
	end
end

local function makeFonts()
	BizNoteFont18 = exports.fonts:getFont("RobotoL", 15)
end

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
	if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
		local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
		if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
			for _, v in ipairs( aAttachedFunctions ) do
				if v == func then
					return true
				end
			end
		end
	end

	return false
end

function drawOverlayBottomCenter(info, widthNew, woffsetNew, hoffsetNew, cooldown)
	if getElementData(localPlayer, "loggedin") == 1 then
		makeFonts()
		content = info
		if woffsetNew then
			woffset = woffsetNew
		end
		if hoffsetNew then
			hoffset = hoffsetNew
		end
		
		playSoundFrontEnd ( 101 )	
		toBeDrawnWidth = dxGetTextWidth ( content[1][1] or "" , 1 , BizNoteFont18)
		
		for i=1, #info do
			outputConsole(info[i][1] or "")
		end
		if not show and not createRender("clientRender", clientRender) then
			createRender( "clientRender", clientRender )
		end
		timerClose = getTickCount()
	else
		removeRender()
	end
end
addEvent("hudOverlay:drawOverlayBottomCenter", true)
addEventHandler("hudOverlay:drawOverlayBottomCenter", localPlayer, drawOverlayBottomCenter)

local font = exports.fonts:getFont("RobotoL", 9)
function clientRender() 
	show = true
	if ( getPedWeapon( localPlayer ) ~= 43 or not getPedControlState( localPlayer, "aim_weapon" ) ) then
		local h = 16*(#content)+30
		local posX = (sx/2)-(toBeDrawnWidth/2)+woffset
		local posY = sy-(h+30)+hoffset
		x, y, w, h = posX, posY , toBeDrawnWidth, h
		roundedRectangle(x, y, w, h, tocolor(0, 0, 0, 80))
		w, h = w-4, h-4
		x, y = x+2, y+2
		roundedRectangle(x, y, w, h, tocolor(0, 0, 0, 80))
		roundedRectangle(x, y, w, 25, tocolor(0, 0, 0, 80))

		content[1][2], content[1][3], content[1][4], content[1][5] = 85, 155, 255, 255
		dxDrawText(content[1][1], x, y, w+x, 25+y, tocolor(000,000,225), 1, font, "center", "center")
		posY = posY-7
		for i=2, #content do
			if content[i] then
			
				local currentWidth = dxGetTextWidth ( content[i][1] or "" , 1 , font) + 30
				if currentWidth > toBeDrawnWidth then
					toBeDrawnWidth = currentWidth
				end
				dxDrawText( content[i][1] or "" , posX+16, posY+(16*i), toBeDrawnWidth-5, 15, tocolor ( content[i][2] or 255, content[i][3] or 255, content[i][4] or 255, content[i][5] or 255 ), content[i][6] or 1,font  )
			end
		end
	end

	if getTickCount() - timerClose > cooldownTime*1000 then
		removeRender()
	end
end

function roundedRectangle(x, y, w, h, borderColor, bgColor, postGUI)
	if (x and y and w and h) then
		if (not borderColor) then
			borderColor = tocolor(0, 0, 0, 180)
		end
		if (not bgColor) then
			bgColor = borderColor
		end
		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		dxDrawRectangle(x + 2, y - 1, w - 4, 1, borderColor, postGUI);
		dxDrawRectangle(x + 2, y + h, w - 4, 1, borderColor, postGUI);
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, borderColor, postGUI);
		dxDrawRectangle(x + w, y + 2, 1, h - 4, borderColor, postGUI);
        
        --Sarkokba pötty:
        dxDrawRectangle(x + 0.5, y + 0.5, 1, 2, borderColor, postGUI);
        dxDrawRectangle(x + 0.5, y + h - 1.5, 1, 2, borderColor, postGUI);
        dxDrawRectangle(x + w - 0.5, y + 0.5, 1, 2, borderColor, postGUI);
        dxDrawRectangle(x + w - 0.5, y + h - 1.5, 1, 2, borderColor, postGUI);
	end
end