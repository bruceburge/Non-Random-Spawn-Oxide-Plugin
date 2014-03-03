PLUGIN.Title = "Non Random Spawn"
PLUGIN.Description = "Sets first time spawn to a fixed location"
PLUGIN.Version = "0.0.1"
PLUGIN.Author = "Meph"

-- Called when oxide loads or user types oxide.reload example at F1 console
function PLUGIN:Init()
    self:AddChatCommand("nrsSetLocation", self.cmdList)
	self.LocationFile, self.Location = self:readFileToMap("nrsLocation")
	print( self.Title .. " v" .. self.Version .. " loaded!" )
end

function PLUGIN:readFileToMap(filename, map)
    local file = util.GetDatafile(filename)
    local txt = file:GetText()
    if (txt ~= "") then  local decoded = json.decode( txt )
        print( filename..": loaded ".. tostring(self:tsize(decoded)).." entries" )-- .. txt
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
	if (not playerclient) then print( self.Title .. " No playerclient, don't teleport" ) return end
	if (usecamp) then return end
	--local userid = rust.GetUserID( playerclient.netuser )
	
    if(not self.Location) then print( self.Title .. " No spawn location set, don't teleport" ) return end	
	print( self.Title .. " spawn location set, attempt teleport!" )
	teleportPlayerToPoint(playerclient.netuser, self.Location)
end	
 
 function PLUGIN:teleportPlayerToPoint( netuser, TpPos )  
	self:TeleportNetuser(netuser, TpPos.x, TpPos.y, TpPos.z) 
 end
 
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
    if not isAuthorized then return end	
        local pos = netuser.playerClient.lastKnownPosition
		self.Location["nrsSpawn"] = {}
        self.Location["nrsSpawn"].Location = pos
		print( self.Title .. " Attempting to save spawn location" )
        self:SaveMapToFile(self.Location,self.LocationFile)
		rust.SendChatToUser( netuser, "Spawn Location Set")

    end