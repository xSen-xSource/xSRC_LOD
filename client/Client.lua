-- xSRC LOD Optimizer Script with NUI
-- วิธีใช้: วางไฟล์นี้ใน resource ของคุณและเพิ่มใน server.cfg
-- start xSRC_LOD

local LOD = {
    Enabled = false,
    UI = {
        Visible = false
    },
    Settings = {
        ModifyGraphics = true,
        ModifyWorldDensity = true,
        DisableUnusedNativeFeatures = true,
        DistanceLimits = true,
        LodScale = 0.8,
        PedDensity = 0.5,
        VehicleDensity = 0.5,
        RandomVehicleDensity = 0.3,
        ParkedVehicleDensity = 0.4,
        ScenarioPedDensity = 0.5,
        FocusEnabled = false -- เพิ่มการตั้งค่าสำหรับ Focus
    }
}

-- ฟังก์ชันปรับแต่งประสิทธิภาพแบบ event-driven
function ApplyLODOptimizer()
    -- เรียกใช้ฟังก์ชันปรับแต่งค่าต่างๆ เมื่อมีการเรนเดอร์เฟรมใหม่
    if LOD.Settings.ModifyGraphics then
        SetTimecycleModifier("cinema")
        SetTimecycleModifierStrength(1.0)
    end
        
    -- ลดความหนาแน่นของ NPC และรถ
    if LOD.Settings.ModifyWorldDensity then
        SetPedDensityMultiplierThisFrame(LOD.Settings.PedDensity)
        SetVehicleDensityMultiplierThisFrame(LOD.Settings.VehicleDensity)
        SetRandomVehicleDensityMultiplierThisFrame(LOD.Settings.RandomVehicleDensity)
        SetParkedVehicleDensityMultiplierThisFrame(LOD.Settings.ParkedVehicleDensity)
        SetScenarioPedDensityMultiplierThisFrame(LOD.Settings.ScenarioPedDensity, LOD.Settings.ScenarioPedDensity)
    end
        
    -- ปิดฟีเจอร์ที่กินทรัพยากรแต่ไม่จำเป็นต้องใช้
    if LOD.Settings.DisableUnusedNativeFeatures then
        DisableVehicleDistantlights(true)
        SetGarbageTrucks(false)
        SetRandomBoats(false)
        SetCreateRandomCops(false)
        SetCreateRandomCopsNotOnScenarios(false)
        SetCreateRandomCopsOnScenarios(false)
    end
        
    -- ปรับระยะการมองเห็น
    if LOD.Settings.DistanceLimits then
        SetFarDrawVehicles(false)
    end
    
    -- ลด LOD distance ด้วยค่าที่กำหนด (ต้องทำทุกเฟรม)
    if LOD.Settings.ModifyGraphics then
        OverrideLodscaleThisFrame(LOD.Settings.LodScale)
        CascadeShadowsSetCascadeBoundsScale(0.0)
        CascadeShadowsEnableEntityTracker(false)
    end
end

-- ฟังก์ชันกำหนด Focus ที่ตัวผู้เล่น
local focusThread = nil
function ApplyPlayerFocus(toggle)
    if toggle then
        -- ถ้า thread กำลังทำงานอยู่แล้ว ไม่ต้องสร้างใหม่
        if focusThread ~= nil then
            return
        end
        
        -- สร้าง thread ใหม่สำหรับ Focus
        focusThread = Citizen.CreateThread(function()
            while LOD.Enabled and LOD.Settings.FocusEnabled do
                -- ดึงพิกัดของผู้เล่น
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                
                -- กำหนด focus ที่ตำแหน่งผู้เล่น
                SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
                
                Citizen.Wait(0) -- ทำทุกเฟรม
            end
            
            -- ยกเลิก focus และล้างตัวแปร thread
            ClearFocus()
            focusThread = nil
        end)
    else
        -- ถ้าปิด focus ให้ยกเลิก thread
        if focusThread ~= nil then
            -- ยกเลิก focus
            ClearFocus()
            focusThread = nil
        end
    end
end

-- ฟังก์ชันรีเซ็ตการตั้งค่า
function ResetLODOptimizer()
    ClearTimecycleModifier()
    StopLODOptimizerLoop()
    
    -- ยกเลิก focus ถ้ากำลังใช้งานอยู่
    if LOD.Settings.FocusEnabled then
        ClearFocus()
    end
end

-- ลงทะเบียน event handlers
local lodOptimizerThread = nil

-- ฟังก์ชันเริ่มการทำงานแบบ loop
function StartLODOptimizerLoop()
    -- ถ้า thread กำลังทำงานอยู่แล้ว ไม่ต้องสร้างใหม่
    if lodOptimizerThread ~= nil then
        return
    end
    
    -- สร้าง thread ใหม่สำหรับ LOD Optimizer
    lodOptimizerThread = Citizen.CreateThread(function()
        while LOD.Enabled do
            -- เรียกใช้ฟังก์ชันปรับแต่งค่าต่างๆ
            if LOD.Settings.ModifyGraphics then
                -- ใช้ค่า TimecycleModifier ที่กำหนดไว้
                SetTimecycleModifier(LOD.Settings.TimecycleModifier)
                SetTimecycleModifierStrength(LOD.Settings.TimecycleModifierStrength)
            end
                
            -- ลดความหนาแน่นของ NPC และรถ
            if LOD.Settings.ModifyWorldDensity then
                SetPedDensityMultiplierThisFrame(LOD.Settings.PedDensity)
                SetVehicleDensityMultiplierThisFrame(LOD.Settings.VehicleDensity)
                SetRandomVehicleDensityMultiplierThisFrame(LOD.Settings.RandomVehicleDensity)
                SetParkedVehicleDensityMultiplierThisFrame(LOD.Settings.ParkedVehicleDensity)
                SetScenarioPedDensityMultiplierThisFrame(LOD.Settings.ScenarioPedDensity, LOD.Settings.ScenarioPedDensity)
            end
                
            -- ปิดฟีเจอร์ที่กินทรัพยากรแต่ไม่จำเป็นต้องใช้
            if LOD.Settings.DisableUnusedNativeFeatures then
                -- ใช้ค่าที่กำหนดไว้
                DisableVehicleDistantlights(LOD.Settings.VehicleDistantlights)
                SetGarbageTrucks(LOD.Settings.GarbageTrucks)
                SetRandomBoats(LOD.Settings.RandomBoats)
                SetCreateRandomCops(LOD.Settings.RandomCops)
                SetCreateRandomCopsNotOnScenarios(LOD.Settings.RandomCops)
                SetCreateRandomCopsOnScenarios(LOD.Settings.RandomCops)
            end
                
            -- ปรับระยะการมองเห็น
            if LOD.Settings.DistanceLimits then
                SetFarDrawVehicles(false)
            end
            
            -- ลด LOD distance ด้วยค่าที่กำหนด (ต้องทำทุกเฟรม)
            if LOD.Settings.ModifyGraphics then
                OverrideLodscaleThisFrame(LOD.Settings.LodScale)
                -- ใช้ค่า CascadeShadowsScale ที่กำหนดไว้
                CascadeShadowsSetCascadeBoundsScale(LOD.Settings.CascadeShadowsScale)
                CascadeShadowsEnableEntityTracker(false)
            end
            
            Citizen.Wait(0) -- ทำทุกเฟรม
            
            -- ตรวจสอบว่า LOD Optimizer ถูกปิดหรือไม่
            if not LOD.Enabled then
                -- ยกเลิกผลกระทบของ LOD Optimizer
                ClearTimecycleModifier()
                break
            end
        end
        
        lodOptimizerThread = nil
    end)
end

-- ฟังก์ชันหยุดการทำงานของ loop
function StopLODOptimizerLoop()
    if lodOptimizerThread ~= nil then
        -- thread จะปิดตัวเองเมื่อ LOD.Enabled เป็น false
        lodOptimizerThread = nil
    end
end

-- สำหรับเปิด/ปิด UI
function ToggleUI()
    LOD.UI.Visible = not LOD.UI.Visible
    
    if LOD.UI.Visible then
        -- ส่งข้อมูลการตั้งค่าปัจจุบันไปยัง NUI
        SendNUIMessage({
            type = "showUI",
            settings = LOD.Settings,
            enabled = LOD.Enabled
        })
        
        SetNuiFocus(true, true)
    else
        SendNUIMessage({
            type = "hideUI"
        })
        
        SetNuiFocus(false, false)
    end
end

-- ฟังก์ชันปิด UI โดยตรง
function CloseUI()
    if LOD.UI.Visible then
        LOD.UI.Visible = false
        SendNUIMessage({
            type = "hideUI"
        })
        SetNuiFocus(false, false)
    end
end

-- รับข้อมูลจาก NUI
RegisterNUICallback("updateSettings", function(data, cb)
    if data.enabled ~= nil then
        local previousState = LOD.Enabled
        LOD.Enabled = data.enabled
        
        -- ถ้าเปลี่ยนจากเปิดเป็นปิด ให้รีเซ็ตการตั้งค่า
        if previousState and not LOD.Enabled then
            ResetLODOptimizer()
            ApplyPlayerFocus(false) -- ปิด Focus เมื่อปิด LOD
        -- ถ้าเปลี่ยนจากปิดเป็นเปิด ให้ใช้ค่าทันที
        elseif not previousState and LOD.Enabled then
            -- เริ่ม loop ของ LOD Optimizer
            StartLODOptimizerLoop()
            -- เปิด Focus ถ้าตั้งค่าให้เปิด
            if LOD.Settings.FocusEnabled then
                ApplyPlayerFocus(true)
            end
        end
    end
    
    if data.settings then
        local previousFocusEnabled = LOD.Settings.FocusEnabled
        
        for k, v in pairs(data.settings) do
            if LOD.Settings[k] ~= nil then
                LOD.Settings[k] = v
            end
        end
        
        -- ตรวจสอบการเปลี่ยนแปลงของ Focus
        if LOD.Enabled and LOD.Settings.FocusEnabled ~= previousFocusEnabled then
            ApplyPlayerFocus(LOD.Settings.FocusEnabled)
        end
    end
    
    cb({success = true})
end)

-- รับคำสั่งปิด UI จาก NUI
RegisterNUICallback("closeUI", function(data, cb)
    SetNuiFocus(false, false)
    LOD.UI.Visible = false
    SendNUIMessage({
        type = "hideUI"
    })
    cb({success = true})
end)

RegisterKeyMapping('togglelodui', 'เปิด/ปิด LOD Optimizer UI', 'keyboard', 'F7')

-- ลงทะเบียนคำสั่ง
RegisterCommand("lod", function(source, args)
    if args[1] == "ui" or #args == 0 then
        ToggleUI()
    elseif args[1] == "on" then
        LOD.Enabled = true
        StartLODOptimizerLoop()
        TriggerEvent("chatMessage", "^2[xSRC LOD]", {255, 0, 0}, "เปิดใช้งาน LOD Optimizer แล้ว")
    elseif args[1] == "off" then
        LOD.Enabled = false
        ResetLODOptimizer()
        TriggerEvent("chatMessage", "^1[xSRC LOD]", {255, 0, 0}, "ปิดใช้งาน LOD Optimizer แล้ว")
    elseif args[1] == "help" then
        TriggerEvent("chatMessage", "^3[xSRC LOD]", {255, 0, 0}, "คำสั่ง: /lod [ui/on/off/help]")
    end
end, false)

-- ลงทะเบียนคำสั่งเปิด/ปิด UI
RegisterCommand("togglelodui", function()
    ToggleUI()
end, false)

-- แจ้งเตือนผู้เล่นเมื่อเชื่อมต่อ
AddEventHandler('playerSpawned', function()
    -- แจ้งเตือนผู้เล่น
    Citizen.Wait(5000) -- รอ 5 วินาทีก่อนแสดงข้อความ
    TriggerEvent("chatMessage", "^2[xSRC LOD]", {255, 0, 0}, "LOD Optimizer พร้อมใช้งาน กด F7 หรือพิมพ์ /lod เพื่อเปิดเมนู")
end)