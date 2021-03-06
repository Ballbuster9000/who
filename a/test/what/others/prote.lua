local _PROTECTIONSERVICERETURNEDTABLE = {}
pcall(function()
local Tfind; do
    local table = table
    Tfind = table.find
end

local lower, upper, sub, format, gsub;
do
    local string = string
    lower, upper, sub, format, gsub =
        string.lower,
        string.upper,
        string.sub,
        string.format,
        string.gsub
end

local InstanceNew, GetService, Clone, IsA, GetPropertyChangedSignal =
    Instance.new,
    game.GetService,
    game.Clone,
    game.IsA,
    game.GetPropertyChangedSignal

local __H = InstanceNew("Humanoid")
local GetState = __H.GetState

local setthreadidentity = (syn and syn.set_thread_identity) or syn_context_set or set_thread_identity or setidentity
local getthreadidentity = (syn and syn.get_thread_identity) or syn_context_get or get_thread_identity or getidentity

local Utils = {["Notify"] = function() end}

local Services = {
    Workspace = GetService(game, "Workspace");
    UserInputService = GetService(game, "UserInputService");
    ReplicatedStorage = GetService(game, "ReplicatedStorage");
    StarterPlayer = GetService(game, "StarterPlayer");
    StarterPack = GetService(game, "StarterPack");
    StarterGui = GetService(game, "StarterGui");
    TeleportService = GetService(game, "TeleportService");
    CoreGui = GetService(game, "CoreGui");
    TweenService = GetService(game, "TweenService");
    HttpService = GetService(game, "HttpService");
    TextService = GetService(game, "TextService");
    MarketplaceService = GetService(game, "MarketplaceService");
    Chat = GetService(game, "Chat");
    Teams = GetService(game, "Teams");
    SoundService = GetService(game, "SoundService");
    Lighting = GetService(game, "Lighting");
    ScriptContext = GetService(game, "ScriptContext");
    Stats = GetService(game, "Stats");
}

setmetatable(Services, {
    __index = function(Table, Property)
        local Ret, Service = pcall(GetService, game, Property);
        if (Ret) then
            Services[Property] = Service
            return Service
        end
        return nil
    end,
    __mode = "v"
});

local LocalPlayer = GetService(game, "Players").LocalPlayer
local Stats = Services.Stats

local filter = function(tbl, ret)
    if (type(tbl) == 'table') then
        local new = {}
        for i, v in next, tbl do
            if (ret(i, v)) then
                new[#new + 1] = v
            end
        end
        return new
    end
end

local map = function(tbl, ret)
    if (type(tbl) == 'table') then
        local new = {}
        for i, v in next, tbl do
            local Value, Key = ret(i, v);
            new[Key or #new + 1] = Value
        end
        return new
    end
end

local tbl_concat = function(...)
    local new = {}
    for i, v in next, {...} do
        for i2, v2 in next, v do
            new[i] = v2
        end
    end
    return new
end

local hookfunction, getconnections;
do
    local GEnv = getgenv()

    local newcclosure = newcclosure or function(f)
        return f
    end

    hookfunction = GEnv.hookfunction or function(func, newfunc, applycclosure)
        if (replaceclosure) then
            replaceclosure(func, newfunc);
            return func
        end
        func = applycclosure and newcclosure or newfunc
        return func
    end

    local CachedConnections = setmetatable({}, {
        __mode = "v"
    });

    getconnections = function(Connection, FromCache, AddOnConnect)
        local getconnections = GEnv.getconnections
        if (not getconnections) then
            return {}
        end
        
        local CachedConnection;
        for i, v in next, CachedConnections do
            if (i == Connection) then
                CachedConnection = v
                break;
            end
        end
        if (CachedConnection and FromCache) then
            return CachedConnection
        end

        local Connections = GEnv.getconnections(Connection);
        CachedConnections[Connection] = Connections
        return Connections
    end
end

local getrawmetatable = getrawmetatable or function()
    return setmetatable({}, {});
end

local getnamecallmethod = getnamecallmethod or function()
    return ""
end

local checkcaller = checkcaller or function()
    return false
end

local Hooks = {
    AntiKick = false,
    AntiTeleport = false,
    NoJumpCooldown = false,
}

local mt = getrawmetatable(game);
local OldMetaMethods = {}
setreadonly(mt, false);
for i, v in next, mt do
    OldMetaMethods[i] = v
end
setreadonly(mt, true);
local MetaMethodHooks = {}

local ProtectInstance, SpoofInstance, SpoofProperty;
local pInstanceCount = 0;
local UnSpoofInstance;
local ProtectedInstances = setmetatable({}, {
    __mode = "v"
});
do
    local SpoofedInstances = setmetatable({}, {
        __mode = "v"
    });
    local SpoofedProperties = {}
    Hooks.SpoofedProperties = SpoofedProperties

    ProtectInstance = function(Instance_)
            if (not Tfind(ProtectedInstances, Instance_)) then
                ProtectedInstances[#ProtectedInstances + 1] = Instance_
                pInstanceCount += 1 + #Instance_:GetDescendants()
                Instance_.DescendantAdded:Connect(function()
                    pInstanceCount += 1
                end);
                Instance_.DescendantRemoving:Connect(function()
                    pInstanceCount = math.max(pInstanceCount - 1, 0);
                end);
            end
    end
    
    SpoofInstance = function(Instance_, Instance2)
            if (not SpoofedInstances[Instance_]) then
                SpoofedInstances[Instance_] = Instance2 and Instance2 or Clone(Instance_);
            end
    end

    UnSpoofInstance = function(Instance_)
            if (SpoofedInstances[Instance_]) then
                SpoofedInstances[Instance_] = nil
            end
    end
    
    local ChangedSpoofedProperties = {}
    SpoofProperty = function(Instance_, Property, NoClone)
            if (SpoofedProperties[Instance_]) then
                local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]
                local Properties = map(SpoofedPropertiesForInstance, function(i, v)
                    return v.Property
                end)
                if (not Tfind(Properties, Property)) then
                    SpoofedProperties[Instance_][#SpoofedPropertiesForInstance + 1] = {
                        SpoofedProperty = SpoofedPropertiesForInstance[1].SpoofedProperty,
                        Property = Property,
                    };
                end
            else
                local Cloned;
                if (not NoClone and IsA(Instance_, "Instance") and not Services[tostring(Instance_)] and Instance_.Archivable) then
                    local Success, Ret = pcall(Clone, Instance_);
                    if (Success) then
                        Cloned = Ret
                    end
                end
                SpoofedProperties[Instance_] = {{
                    SpoofedProperty = Cloned and Cloned or {[Property]=Instance_[Property]},
                    Property = Property,
                }}
                ChangedSpoofedProperties[Instance_] = {}
            end
    end

    local GetAllParents = function(Instance_, NIV)
        if (typeof(Instance_) == "Instance") then
            local Parents = {}
            local Current = NIV or Instance_
            if (NIV) then
                Parents[#Parents + 1] = Current
            end
            repeat
                local Parent = Current.Parent
                Parents[#Parents + 1] = Parent
                Current = Parent
            until not Current
            return Parents
        end
        return {}
    end
    
    local Methods = {
        "FindFirstChild",
        "FindFirstChildWhichIsA",
        "FindFirstChildOfClass",
        "IsA"
    }

    MetaMethodHooks.Namecall = function(...)
        local __Namecall = OldMetaMethods.__namecall;
        local Args = {...}
        local self = Args[1]
        local Method = getnamecallmethod() or "";

        if (Method ~= "") then
            local Success = pcall(OldMetaMethods.__index, self, Method);
            if (not Success) then
                return __Namecall(...);
            end
        end

        if (Hooks.AntiKick and lower(Method) == "kick") then
            local Player, Message = self, Args[2]
            if (Hooks.AntiKick and Player == LocalPlayer) then
                local Notify = Utils.Notify
                local Context;
                if (setthreadidentity) then
                    Context = getthreadidentity();
                    setthreadidentity(3);
                end
                if (Notify and Context) then
                    Notify(nil, "Attempt to kick", format("attempt to kick %s", (Message and type(Message) == 'number' or type(Message) == 'string') and ": " .. Message or ""));
                    setthreadidentity(Context);
                end
                return
            end
        end

        if (Hooks.AntiTeleport and Method == "Teleport" or Method == "TeleportToPlaceInstance") then
            local Player, PlaceId = self, Args[2]
            if (Hooks.AntiTeleport and Player == LocalPlayer) then
                local Notify = Utils.Notify
                local Context;
                if (setthreadidentity) then
                    Context = getthreadidentity();
                    setthreadidentity(3);
                end
                if (Notify and Context) then
                    Notify(nil, "Attempt to teleport", format("attempt to teleport to place %s", PlaceId and PlaceId or ""));
                    setthreadidentity(Context);
                end
                return
            end
        end

        if (checkcaller()) then
            return __Namecall(...);
        end

        if (Tfind(Methods, Method)) then
            local ReturnedInstance = __Namecall(...);
            if (Tfind(ProtectedInstances, ReturnedInstance)) then
                return Method == "IsA" and false or nil
            end
        end
        
        if (lower(Method) == "getchildren" or lower(Method) == "getdescendants") then
            return filter(__Namecall(...), function(i, v)
                local Protected = false
                for i2 = 1, #ProtectedInstances do
                    local ProtectedInstance = ProtectedInstances[i2]
		            local Success = pcall(tostring, ProtectedInstance)
                    Protected = ProtectedInstance == v or (Success and v.IsDescendantOf(v, ProtectedInstance));
                    if (Protected) then
                        break;
                    end
                end
                return not Protected
            end)
        end

        if (Method == "GetFocusedTextBox") then
            local Protected = false
            for i = 1, #ProtectedInstances do
                local ProtectedInstance = ProtectedInstances[i]
                Protected = not Tfind(ProtectedInstances, FocusedTextBox) or FocusedTextBox.IsDescendantOf(FocusedTextBox, ProtectedInstance);
            end
            if (Protected) then
                return nil
            end
        end

        if (Hooks.NoJumpCooldown and Method == "GetState" or Method == "GetStateEnabled") then
            local State = __Namecall(...);
            if (Method == "GetState" and (State == Enum.HumanoidStateType.Jumping or State == "Jumping")) then
                return Enum.HumanoidStateType.RunningNoPhysics
            end
            if (Method == "GetStateEnabled" and (self == Enum.HumanoidStateType.Jumping or self == "Jumping")) then
                return false
            end
        end

        return __Namecall(...);
    end

    local AllowedIndexes = {
        "RootPart",
        "Parent"
    }
    local AllowedNewIndexes = {
        "Jump"
    }
    MetaMethodHooks.Index = function(...)
        local __Index = OldMetaMethods.__index;

        if (checkcaller()) then
            return __Index(...);
        end
        local Instance_, Index = ...

        local SanitisedIndex = Index
        if (typeof(Instance_) == 'Instance' and type(Index) == 'string') then
            SanitisedIndex = gsub(sub(Index, 0, 100), "%z.*", "");
        end
        local SpoofedInstance = SpoofedInstances[Instance_]
        local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

        if (SpoofedInstance) then
            if (Tfind(AllowedIndexes, SanitisedIndex)) then
                return __Index(Instance_, Index);
            end
            return __Index(SpoofedInstance, Index);
        end

        if (SpoofedPropertiesForInstance) then
            for i, SpoofedProperty in next, SpoofedPropertiesForInstance do
                local SanitisedIndex = gsub(SanitisedIndex, "^%l", upper);
                if (SanitisedIndex == SpoofedProperty.Property) then
                    local ClientChangedData = ChangedSpoofedProperties[Instance_][SanitisedIndex]
                    local IndexedSpoofed = __Index(SpoofedProperty.SpoofedProperty, Index);
                    local Indexed = __Index(Instance_, Index);
                    if (ClientChangedData.Caller and ClientChangedData.Value ~= Indexed) then
                        OldMetaMethods.__newindex(SpoofedProperty.SpoofedProperty, Index, Indexed);
                        OldMetaMethods.__newindex(Instance_, Index, ClientChangedData.Value);
                        return Indexed
                    end
                    return IndexedSpoofed
                end
            end
        end

        if (Tfind(ProtectedInstances, __Index(...))) then
            return nil
        end
        if (Tfind(ProtectedInstances, Instance_) and SanitisedIndex == "ClassName") then
            return "Part"
        end

        if (Hooks.NoJumpCooldown and SanitisedIndex == "Jump") then
            if (IsA(Instance_, "Humanoid")) then
                return false
            end
        end
	
	if (Instance_ == Stats and SanitisedIndex == "InstanceCount") then
            return __Index(...) - pInstanceCount;
        end

        if (Instance_ == Stats and SanitisedIndex == "PrimitivesCount") then
            local count = 0;
            local identity = getthreadidentity();
            setthreadidentity(2);
            for i, v in pairs(game:GetDescendants()) do
                if (IsA(v, "BasePart")) then
                    count += 1
                end
            end
            setthreadidentity(identity);
            return count;
        end
        
        return __Index(...);
    end

    MetaMethodHooks.NewIndex = function(...)
        local __NewIndex = OldMetaMethods.__newindex;
        local __Index = OldMetaMethods.__index;
        local Instance_, Index, Value = ...

        local SpoofedInstance = SpoofedInstances[Instance_]
        local SpoofedPropertiesForInstance = SpoofedProperties[Instance_]

        if (checkcaller()) then
            if (Index == "Parent" and Value) then
                local ProtectedInstance
                for i = 1, #ProtectedInstances do
                    local ProtectedInstance_ = ProtectedInstances[i]
                    if (Instance_ == ProtectedInstance_ or Instance_.IsDescendantOf(Value, ProtectedInstance_)) then
                        ProtectedInstance = true
                    end
                end
                if (ProtectedInstance) then
                    local Parents = GetAllParents(Instance_, Value);
                    for i, v in next, getconnections(Parents[1].ChildAdded, true) do
                        v.Disable(v);
                    end
                    for i = 1, #Parents do
                        local Parent = Parents[i]
                        for i2, v in next, getconnections(Parent.DescendantAdded, true) do
                            v.Disable(v);
                        end
                    end
                    local Ret = __NewIndex(...);
                    for i = 1, #Parents do
                        local Parent = Parents[i]
                        for i2, v in next, getconnections(Parent.DescendantAdded, true) do
                            v.Enable(v);
                        end
                    end
                    for i, v in next, getconnections(Parents[1].ChildAdded, true) do
                        v.Enable(v);
                    end
                    return Ret
                end
            end
            if (SpoofedInstance or SpoofedPropertiesForInstance) then
                if (SpoofedPropertiesForInstance) then
                    ChangedSpoofedProperties[Instance_][Index] = {
                        Caller = true,
                        BeforeValue = Instance_[Index],
                        Value = Value
                    }
                end
                local Connections = tbl_concat(
                    getconnections(GetPropertyChangedSignal(Instance_, SpoofedPropertiesForInstance and SpoofedPropertiesForInstance.Property or Index)),
                    getconnections(Instance_.Changed),
                    getconnections(game.ItemChanged)
                )
                
                if (not next(Connections)) then
                    return __NewIndex(Instance_, Index, Value);
                end
                for i, v in next, Connections do
                    v.Disable(v);
                end
                local Ret = __NewIndex(Instance_, Index, Value);
                for i, v in next, Connections do
                    v.Enable(v);
                end
                return Ret
            end
            return __NewIndex(...);
        end

        local SanitisedIndex = Index
        if (typeof(Instance_) == 'Instance' and type(Index) == 'string') then
            SanitisedIndex = gsub(sub(Index, 0, 100), "%z.*", "");
        end

        if (SpoofedInstance) then
            if (Tfind(AllowedNewIndexes, SanitisedIndex)) then
                return __NewIndex(...);
            end
            return __NewIndex(SpoofedInstance, Index, __Index(SpoofedInstance, Index));
        end

        if (SpoofedPropertiesForInstance) then
            for i, SpoofedProperty in next, SpoofedPropertiesForInstance do
                if (SpoofedProperty.Property == SanitisedIndex and not Tfind(AllowedIndexes, SanitisedIndex)) then
                    ChangedSpoofedProperties[Instance_][SanitisedIndex] = {
                        Caller = false,
                        BeforeValue = Instance_[Index],
                        Value = Value
                    }
                    return __NewIndex(SpoofedProperty.SpoofedProperty, Index, Value);
                end
            end
        end

        return __NewIndex(...);
    end

    local hookmetamethod = hookmetamethod or function(metatable, metamethod, func)
        setreadonly(metatable, false);
        Old = hookfunction(metatable[metamethod], func, true);
        setreadonly(metatable, true);
        return Old
    end

    OldMetaMethods.__index = hookmetamethod(game, "__index", MetaMethodHooks.Index);
    OldMetaMethods.__newindex = hookmetamethod(game, "__newindex", MetaMethodHooks.NewIndex);
    OldMetaMethods.__namecall = hookmetamethod(game, "__namecall", MetaMethodHooks.Namecall);
end

Hooks.OldGetChildren = hookfunction(game.GetChildren, newcclosure(function(...)
    if (not checkcaller()) then
        local Children = Hooks.OldGetChildren(...);
        return filter(Children, function(i, v)
            return not Tfind(ProtectedInstances, v);
        end)
    end
    return Hooks.OldGetChildren(...);
end));

Hooks.OldGetDescendants = hookfunction(game.GetDescendants, newcclosure(function(...)
    if (not checkcaller()) then
        local Descendants = Hooks.OldGetDescendants(...);
        return filter(Descendants, function(i, v)
            local Protected = false
            for i2 = 1, #ProtectedInstances do
                local ProtectedInstance = ProtectedInstances[i2]
                Protected = v and ProtectedInstance == v or v.IsDescendantOf(v, ProtectedInstance)
                if (Protected) then
                    break;
                end
            end
            return not Protected
        end)
    end
    return Hooks.OldGetDescendants(...);
end));

Hooks.FindFirstChild = hookfunction(game.FindFirstChild, newcclosure(function(...)
    if (not checkcaller()) then
        local ReturnedInstance = Hooks.FindFirstChild(...);
        if (ReturnedInstance and Tfind(ProtectedInstances, ReturnedInstance)) then
            return nil
        end
    end
    return Hooks.FindFirstChild(...);
end));
Hooks.FindFirstChildOfClass = hookfunction(game.FindFirstChildOfClass, newcclosure(function(...)
    if (not checkcaller()) then
        local ReturnedInstance = Hooks.FindFirstChildOfClass(...);
        if (ReturnedInstance and Tfind(ProtectedInstances, ReturnedInstance)) then
            return nil
        end
    end
    return Hooks.FindFirstChildOfClass(...);
end));
Hooks.FindFirstChildWhichIsA = hookfunction(game.FindFirstChildWhichIsA, newcclosure(function(...)
    if (not checkcaller()) then
        local ReturnedInstance = Hooks.FindFirstChildWhichIsA(...);
        if (ReturnedInstance and Tfind(ProtectedInstances, ReturnedInstance)) then
            return nil
        end
    end
    return Hooks.FindFirstChildWhichIsA(...);
end));
Hooks.IsA = hookfunction(game.IsA, newcclosure(function(...)
    if (not checkcaller()) then
        local Args = {...}
        local IsACheck = Args[1]
        if (IsACheck) then
            local ProtectedInstance = Tfind(ProtectedInstances, IsACheck);
            if (ProtectedInstance and Args[2]) then
                return false
            end
        end
    end
    return Hooks.IsA(...);
end));

local UndetectedCmdBar;
Hooks.OldGetFocusedTextBox = hookfunction(Services.UserInputService.GetFocusedTextBox, newcclosure(function(...)
    if (not checkcaller() and UndetectedCmdBar) then
        local FocusedTextBox = Hooks.OldGetFocusedTextBox(...);
        local Protected = false
        for i = 1, #ProtectedInstances do
            local ProtectedInstance = ProtectedInstances[i]
            Protected = not Tfind(ProtectedInstances, FocusedTextBox) or FocusedTextBox.IsDescendantOf(FocusedTextBox, ProtectedInstance);
        end
        if (Protected) then
            return nil
        end
    end
    return Hooks.OldGetFocusedTextBox(...);
end));

Hooks.OldKick = hookfunction(LocalPlayer.Kick, newcclosure(function(...)
    local Player, Message = ...
    if (Hooks.AntiKick and Player == LocalPlayer) then
        local Notify = Utils.Notify
        local Context;
        if (setthreadidentity) then
            Context = getthreadidentity();
            setthreadidentity(3);
        end
        if (Notify and Context) then
            Notify(nil, "Attempt to kick", format("attempt to kick %s", (Message and type(Message) == 'number' or type(Message) == 'string') and ": " .. Message or ""));
            setthreadidentity(Context)
        end
        return
    end
    return Hooks.OldKick(...);
end))

Hooks.OldTeleportToPlaceInstance = hookfunction(Services.TeleportService.TeleportToPlaceInstance, newcclosure(function(...)
    local Player, PlaceId = ...
    if (Hooks.AntiTeleport and Player == LocalPlayer) then
        local Notify = Utils.Notify
        local Context;
        if (setthreadidentity) then
            Context = getthreadidentity();
            setthreadidentity(3);
        end
        if (Notify and Context) then
            Notify(nil, "Attempt to teleport", format("attempt to teleport to place %s", PlaceId and PlaceId or ""));
            setthreadidentity(Context)
        end
        return
    end
    return Hooks.OldTeleportToPlaceInstance(...);
end))
Hooks.OldTeleport = hookfunction(Services.TeleportService.Teleport, newcclosure(function(...)
    local Player, PlaceId = ...
    if (Hooks.AntiTeleport and Player == LocalPlayer) then
        local Notify = Utils.Notify
        local Context;
        if (setthreadidentity) then
            Context = getthreadidentity();
            setthreadidentity(3);
        end
        if (Notify and Context) then
            Notify(nil, "Attempt to teleport", format("attempt to teleport to place \"%s\"", PlaceId and PlaceId or ""));
            setthreadidentity(Context);
        end
        return
    end
    return Hooks.OldTeleport(...);
end))

Hooks.GetState = hookfunction(GetState, function(...)
    local Humanoid, State = ..., Hooks.GetState(...);
    local Parent, Character = Humanoid.Parent, LocalPlayer.Character
    if (Hooks.NoJumpCooldown and (State == Enum.HumanoidStateType.Jumping or State == "Jumping") and Parent and Character and Parent == Character) then
        return Enum.HumanoidStateType.RunningNoPhysics
    end
    return State
end)

Hooks.GetStateEnabled = hookfunction(__H.GetStateEnabled, function(...)
    local Humanoid, State = ...
    local Ret = Hooks.GetStateEnabled(...);
    local Parent, Character = Humanoid.Parent, LocalPlayer.Character
    if (Hooks.NoJumpCooldown and (State == Enum.HumanoidStateType.Jumping or State == "Jumping") and Parent and Character and Parent == Character) then
        return false
    end
    return Ret
end)

_PROTECTIONSERVICERETURNEDTABLE = {
    ["ProtectInstance"] = ProtectInstance,
    ["SpoofInstance"] = SpoofInstance,
    ["SpoofProperty"] = SpoofProperty,
    ["UnSpoofInstance"] = UnSpoofInstance,
    ["UndetectedCommandbar"] = function(value) UndetectedCmdBar = value end
}
end)
return _PROTECTIONSERVICERETURNEDTABLE
