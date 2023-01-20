local mysql = exports.mysql
addEvent("tiredAnimation",true)
addEventHandler("tiredAnimation",root,function(target)
	setPedAnimation ( target, "FAT", "IDLE_tired", -1, true, false )
	setElementData(target, "tired", true)
	setTimer(triggerEvent, 3000, 1, "switchToNormal", root, target )
end)

addEvent("switchToNormal",true)
addEventHandler("switchToNormal",root,function(target)
	setPedAnimation ( target, "ped", "IDLE_tired", 200 )
	setElementData(target, "tired", false)
	setPedAnimation(target,false)
end)


addCommandHandler("sethunger",
	function(player, cmd, targetPlayer, value)
		if exports.integration:isPlayerSeniorAdmin(player) then
			value = tonumber(value)
			if value and targetPlayer then
				local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
				if targetPlayer then
					outputChatBox(exports.pool:getServerSyntax(false, "s").. "Kişinin açlık değeri başarıyla değiştirildi. ("..getElementData(targetPlayer, "hunger").." - > "..value..")", player, 255, 255, 255, true)
					setElementData(targetPlayer, "hunger", value)
				else
					outputChatBox(exports.pool:getServerSyntax(false, "e").. "Kişi bulunamadı.", player, 255, 255, 255, true)
				end
			else
				outputChatBox(exports.pool:getServerSyntax(false, "e").. "Geçersiz değer girdiniz.", player, 255, 255, 255, true)
			end
		end
	end
)

addCommandHandler("setthirst",
	function(player, cmd, targetPlayer, value)
		if exports.integration:isPlayerSeniorAdmin(player) then
			value = tonumber(value)
			if value and targetPlayer then
				local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
				if targetPlayer then
					outputChatBox(exports.pool:getServerSyntax(false, "s").. "Kişinin susuzluk değeri başarıyla değiştirildi. ("..getElementData(targetPlayer, "thirst").." - > "..value..")", player, 255, 255, 255, true)
					setElementData(targetPlayer, "thirst", value)
				else
					outputChatBox(exports.pool:getServerSyntax(false, "e").. "Kişi bulunamadı.", player, 255, 255, 255, true)
				end
			else
				outputChatBox(exports.pool:getServerSyntax(false, "e").. "Geçersiz değer girdiniz.", player, 255, 255, 255, true)
			end
		end
	end
)

--addEvent("save:level", true)
--addEventHandler("save:level", root,
	--function(player, level, hoursaim)
	--	dbExec(mysql:getConnection(), "UPDATE characters SET level = ?, hoursaim = ? WHERE id = ?", level, hoursaim, getElementData(player, "dbid"))
	--end
--)