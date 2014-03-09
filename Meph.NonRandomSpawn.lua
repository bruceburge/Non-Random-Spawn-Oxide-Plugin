PLUGIN.Title = "Non Random Spawn"
PLUGIN.Description = "Sets first time spawn to a fixed location"
PLUGIN.Version = "0.2.0"
PLUGIN.Author = "Meph"

-- Called when oxide loads or user types oxide.reload example at F1 console
function PLUGIN:Init()
    self:AddChatCommand("nrsSetLocation", self.cmdSetLocation)
	--attempt to load config file
	self.LocationFile, self.Location = self:readFileToMap("nrsLocation")
	--check if config file had valid data structure
	if(tablelength(self.Location) > 0 and tablelength(self.Location.Pos) == 3) then
		print( self.Title .. "Spawn location x:"..self.Location.Pos.x.." y:"..self.Location.Pos.y.." z:"..self.Location.Pos.z)
	else
		--if we got a blank table back from the config loader then create the structure and save it to the config file
		self.Location = {}
		self.Location.Pos = {}
		self.Location.Pos.x = 0
		self.Location.Pos.y = 0
		self.Location.Pos.z = 0
		self:SaveMapToFile(self.Location,self.LocationFile)
    end
	
	print( self.Title .. " v" .. self.Version .. " loaded!" )
end

function PLUGIN:OnSpawnPlayer ( playerclient, usecamp, avatar )
	if (not playerclient) then 
		print( self.Title .. " no player client") 
		return 
	end
    
	if (playerclient.netuser.playerClient.hasLastKnownPosition ) then 
	   --print( self.Title .. "player has known location no tp") 
		return 
	end 
	
	if (usecamp) then 
		--print( self.Title .. " using camp no tp") 
		return 
	end
	
	self:TeleportNetuser(playerclient.netuser, self.Location.Pos.x,self.Location.Pos.y,self.Location.Pos.z)
end	

function PLUGIN:cmdSetLocation(netuser, cmd, args)
    local isAuthorized = netuser:CanAdmin() or (oxmin_Plugin and oxmin_Plugin:HasFlag(netuser, self.FLAG_nrsSetter, false))
    
	if not isAuthorized then 
		rust.SendChatToUser( netuser,"You are not authorized to set spawn location ") 
		return 
	end
    
	local pos = netuser.playerClient.lastKnownPosition
	print( self.Title..": set spawn location "..pos.x..","..pos.y..","..pos.z)
	
	self.Location = {}
	self.Location.Pos = {}
    self.Location.Pos.x = pos.x
	self.Location.Pos.y = pos.y
	self.Location.Pos.z = pos.z
    self:SaveMapToFile(self.Location,self.LocationFile)
	rust.SendChatToUser( netuser, "Spawn Location Set")
end


 
 -- Teleport NetUser to Specific Coordinates
function PLUGIN:TeleportNetuser(netuser, x, y, z)
    local coords = netuser.playerClient.lastKnownPosition        
    coords.x ,coords.y ,coords.z = x,y,z    
	-- make sure the values aren't default before warping
	if(x ~= 0 and y~= 0 and z~=0) then
		--timer wrapper because without it, the teleport will kill player.    
		timer.Once( 0, function()
			rust.ServerManagement():TeleportPlayer(netuser.playerClient.netPlayer, coords)
			--TODO: rust.SendChatToUser( netuser,_CONFIG_._TELEPORTMESSAGE_)
		end)    
	end		
end
 
-- Automated Oxide help function (added to /help list)
function PLUGIN:SendHelpText( netuser )
	local isAuthorized = netuser:CanAdmin() or (oxmin_Plugin and oxmin_Plugin:HasFlag(netuser, self.FLAG_nrsSetter, false))
    if not isAuthorized then return end
	--only add to help for admins
	rust.SendChatToUser( netuser, "Use /nrsSetLocation to set spawn to your current location." )
end


function PLUGIN:readFileToMap(filename, map)
    local file = util.GetDatafile(filename)
    local txt = file:GetText()
    if (txt ~= "") then  local decoded = json.decode( txt )
		print( self.Title ..": ".. filename.." loaded: ")
        return file, decoded
    else
        print( self.Title ..": "..filename.." not loaded: ")
        return file, {}
    end
end

function PLUGIN:SaveMapToFile(table, file)
    file:SetText( json.encode( table ) )  
	file:Save() 
end

function tablelength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

