PLUGIN.Title = "Non Random Spawn"
PLUGIN.Description = "Sets first time spawn to a fixed location"
PLUGIN.Version = "0.0.1"
PLUGIN.Author = "Meph"

-- Called when oxide loads or user types oxide.reload example at F1 console
function PLUGIN:Init()
    self:AddChatCommand("nrsSetLocation", self.cmdSetLocation)
	self.LocationFile, self.Location = self:readFileToMap("nrsLocation")
	print( self.Title .. " v" .. self.Version .. " loaded!" )
	print( self.Title .. " x:"..self.Location.Pos.x.." y:"..self.Location.Pos.y.." z:"..self.Location.Pos.z)
end

function PLUGIN:readFileToMap(filename, map)
    local file = util.GetDatafile(filename)
    local txt = file:GetText()
    if (txt ~= "") then  local decoded = json.decode( txt )
	print( filename.." loaded: " .. txt )
        return file, decoded
    else
        print( filename.." not loaded: " .. txt )
        return file, {}
    end
end

function PLUGIN:SaveMapToFile(table, file)
    file:SetText( json.encode( table ) )  
	file:Save() 
end


function PLUGIN:OnSpawnPlayer ( playerclient, usecamp, avatar )
	if (not playerclient) then print( self.Title .. " no player client") return end
	if (usecamp) then print( self.Title .. " using camp no tp") return end
	if (not self.Location.Pos.x) then print( self.Title .. " no location set") return end
	 --print( self.Title .. " x:"..self.Location.Pos.x.." y:"..self.Location.Pos.y.." z:"..self.Location.Pos.z)
	self:TeleportNetuser(playerclient.netuser, self.Location.Pos.x,self.Location.Pos.y,self.Location.Pos.z)
end	
 
 
 --function PLUGIN:teleportPlayerToPoint( netuser, TpPos )  
	--self:TeleportNetuser(netuser, TpPos.x, TpPos.y, TpPos.z) 
 --end
 
 -- Teleport NetUser to Specific Coordinates
function PLUGIN:TeleportNetuser(netuser, x, y, z)
    local coords = netuser.playerClient.lastKnownPosition
    coords.x ,coords.y ,coords.z = x,y,z
    rust.ServerManagement():TeleportPlayer(netuser.playerClient.netPlayer, coords)
end
 
 
-- Called when user types /example
function PLUGIN:cmdList( netuser, cmd, args )
    --rust.SendChatToUser( netuser, "Your plugin works!" )
end
 
-- Automated Oxide help function (added to /help list)
function PLUGIN:SendHelpText( netuser )
	local isAuthorized = netuser:CanAdmin() or (oxmin_Plugin and oxmin_Plugin:HasFlag(netuser, self.FLAG_nrsSetter, false))
    if not isAuthorized then return end
	--only add to help for admins
	rust.SendChatToUser( netuser, "Use /nrsSetLocation to set spawn to your current location." )
end

function PLUGIN:cmdSetLocation(netuser, cmd, args)
    local isAuthorized = netuser:CanAdmin() or (oxmin_Plugin and oxmin_Plugin:HasFlag(netuser, self.FLAG_nrsSetter, false))
    if not isAuthorized then print( self.Title..": not authorized to set spawn location ") return end
        local pos = netuser.playerClient.lastKnownPosition
print( self.Title..": trying to set spawn location "..pos.x..","..pos.y..","..pos.z)
	self.Location = {}
        self.Location.Pos.x = pos.x
		self.Location.Pos.y = pos.y
		self.Location.Pos.z = pos.z
        self:SaveMapToFile(self.Location,self.LocationFile)
	rust.SendChatToUser( netuser, "Spawn Location Set")

end
