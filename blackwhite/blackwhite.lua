local screenX, screenY = guiGetScreenSize()
local screenSource = dxCreateScreenSource(screenX, screenY)

function startBlackWhite()
	blackWhiteShader, blackWhiteTec = dxCreateShader("blackwhite/fx/blackwhite.fx")
	if not blackWhiteShader then
		outputChatBox("Hata, :hud/blackwhite/fx/blackwhite.fx")
	end
	addEventHandler("onClientPreRender", root, renderBlackWhite)
end

function renderBlackWhite()
    if (blackWhiteShader) then
        dxUpdateScreenSource(screenSource)     
        dxSetShaderValue(blackWhiteShader, "screenSource", screenSource)
        dxDrawImage(0, 0, screenX, screenY, blackWhiteShader)
    end
end


function stopBlackWhite()
	removeEventHandler("onClientPreRender", root, renderBlackWhite)
end

