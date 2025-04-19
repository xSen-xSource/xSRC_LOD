// ตัวแปรเก็บการตั้งค่า
let settings = {
    ModifyGraphics: true,
    ModifyWorldDensity: true,
    DisableUnusedNativeFeatures: true,
    DistanceLimits: true,
    TimecycleModifier: "cinema",
    TimecycleModifierStrength: 1.0,
    LodScale: 0.8,
    CascadeShadowsScale: 0.0,
    PedDensity: 0.5,
    VehicleDensity: 0.5,
    RandomVehicleDensity: 0.3,
    ParkedVehicleDensity: 0.4,
    ScenarioPedDensity: 0.5,
    FocusEnabled: false,
    VehicleDistantlights: true,
    GarbageTrucks: false,
    RandomBoats: false,
    RandomCops: false
};

let masterEnabled = false;
let fpsCounter = 0;
let lastTime = 0;
let frameCount = 0;

// รับข้อมูลจากเกม
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'showUI') {
        document.getElementById('app').style.display = 'flex';
        settings = data.settings;
        masterEnabled = data.enabled;
        
        // อัปเดต UI ตามการตั้งค่าที่ได้รับ
        updateUIFromSettings();
    } else if (data.type === 'hideUI') {
        document.getElementById('app').style.display = 'none';
    } else if (data.type === 'updateFPS') {
        fpsCounter = data.fps;
        document.getElementById('fps-counter').textContent = fpsCounter;
    }
});

// อัปเดต UI จากการตั้งค่า
function updateUIFromSettings() {
    // Master toggle
    document.getElementById('master-toggle').checked = masterEnabled;
    document.getElementById('toggle-status').textContent = masterEnabled ? 'เปิด' : 'ปิด';
    
    // Graphics settings
    document.getElementById('graphics-toggle').checked = settings.ModifyGraphics;
    document.getElementById('lod-scale').value = settings.LodScale;
    document.getElementById('lod-scale-value').textContent = settings.LodScale.toFixed(2);
    document.getElementById('timecycle-strength').value = settings.TimecycleModifierStrength;
    document.getElementById('timecycle-strength-value').textContent = settings.TimecycleModifierStrength.toFixed(2);
    document.getElementById('shadow-scale').value = settings.CascadeShadowsScale;
    document.getElementById('shadow-scale-value').textContent = settings.CascadeShadowsScale.toFixed(2);
    document.getElementById('timecycle-modifier').value = settings.TimecycleModifier;
    
    // Density settings
    document.getElementById('density-toggle').checked = settings.ModifyWorldDensity;
    document.getElementById('ped-density').value = settings.PedDensity;
    document.getElementById('ped-density-value').textContent = settings.PedDensity.toFixed(2);
    document.getElementById('vehicle-density').value = settings.VehicleDensity;
    document.getElementById('vehicle-density-value').textContent = settings.VehicleDensity.toFixed(2);
    document.getElementById('random-vehicle-density').value = settings.RandomVehicleDensity;
    document.getElementById('random-vehicle-density-value').textContent = settings.RandomVehicleDensity.toFixed(2);
    document.getElementById('parked-vehicle-density').value = settings.ParkedVehicleDensity;
    document.getElementById('parked-vehicle-density-value').textContent = settings.ParkedVehicleDensity.toFixed(2);
    document.getElementById('scenario-ped-density').value = settings.ScenarioPedDensity;
    document.getElementById('scenario-ped-density-value').textContent = settings.ScenarioPedDensity.toFixed(2);
    
    // Features settings
    document.getElementById('features-toggle').checked = settings.DisableUnusedNativeFeatures;
    document.getElementById('vehicle-distantlights').checked = settings.VehicleDistantlights;
    document.getElementById('garbage-trucks').checked = settings.GarbageTrucks;
    document.getElementById('random-boats').checked = settings.RandomBoats;
    document.getElementById('random-cops').checked = settings.RandomCops;
    
    // Other settings
    document.getElementById('distance-toggle').checked = settings.DistanceLimits;
    document.getElementById('focus-toggle').checked = settings.FocusEnabled;
}

// ส่งการตั้งค่าไปยังเกม
function sendSettings() {
    fetch('https://xSRC_LOD/updateSettings', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            enabled: masterEnabled,
            settings: settings
        })
    });
}

// Auto-save settings when changed
function autoSaveSettings() {
    fetch('https://xSRC_LOD/updateSettings', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            enabled: masterEnabled,
            settings: settings
        })
    });
}

// ปิด UI
function closeUI() {
    fetch('https://xSRC_LOD/closeUI', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

document.addEventListener('DOMContentLoaded', function() {
    // Event listeners
    
    // Master toggle
    document.getElementById('master-toggle').addEventListener('change', function() {
        masterEnabled = this.checked;
        document.getElementById('toggle-status').textContent = masterEnabled ? 'เปิด' : 'ปิด';
        autoSaveSettings();
    });
    
    // Graphics settings
    document.getElementById('graphics-toggle').addEventListener('change', function() {
        settings.ModifyGraphics = this.checked;
        autoSaveSettings();
    });
    
    document.getElementById('lod-scale').addEventListener('input', function() {
        settings.LodScale = parseFloat(this.value);
        document.getElementById('lod-scale-value').textContent = settings.LodScale.toFixed(2);
        autoSaveSettings();
    });
    
    document.getElementById('timecycle-strength').addEventListener('input', function() {
        settings.TimecycleModifierStrength = parseFloat(this.value);
        document.getElementById('timecycle-strength-value').textContent = settings.TimecycleModifierStrength.toFixed(2);
        autoSaveSettings();
    });
    
    document.getElementById('shadow-scale').addEventListener('input', function() {
        settings.CascadeShadowsScale = parseFloat(this.value);
        document.getElementById('shadow-scale-value').textContent = settings.CascadeShadowsScale.toFixed(2);
        autoSaveSettings();
    });
    
    document.getElementById('timecycle-modifier').addEventListener('change', function() {
        settings.TimecycleModifier = this.value;
        autoSaveSettings();
    });
    
    // Density settings
    document.getElementById('density-toggle').addEventListener('change', function() {
        settings.ModifyWorldDensity = this.checked;
        autoSaveSettings();
    });
    
    document.getElementById('ped-density').addEventListener('input', function() {
        settings.PedDensity = parseFloat(this.value);
        document.getElementById('ped-density-value').textContent = settings.PedDensity.toFixed(2);
        autoSaveSettings();
    });
    
    document.getElementById('vehicle-density').addEventListener('input', function() {
        settings.VehicleDensity = parseFloat(this.value);
        document.getElementById('vehicle-density-value').textContent = settings.VehicleDensity.toFixed(2);
        autoSaveSettings();
    });
    
    document.getElementById('random-vehicle-density').addEventListener('input', function() {
        settings.RandomVehicleDensity = parseFloat(this.value);
        document.getElementById('random-vehicle-density-value').textContent = settings.RandomVehicleDensity.toFixed(2);
        autoSaveSettings();
    });
    
    document.getElementById('parked-vehicle-density').addEventListener('input', function() {
        settings.ParkedVehicleDensity = parseFloat(this.value);
        document.getElementById('parked-vehicle-density-value').textContent = settings.ParkedVehicleDensity.toFixed(2);
        autoSaveSettings();
    });
    
    document.getElementById('scenario-ped-density').addEventListener('input', function() {
        settings.ScenarioPedDensity = parseFloat(this.value);
        document.getElementById('scenario-ped-density-value').textContent = settings.ScenarioPedDensity.toFixed(2);
        autoSaveSettings();
    });
    
    // Features settings
    document.getElementById('features-toggle').addEventListener('change', function() {
        settings.DisableUnusedNativeFeatures = this.checked;
        autoSaveSettings();
    });
    
    document.getElementById('vehicle-distantlights').addEventListener('change', function() {
        settings.VehicleDistantlights = this.checked;
        autoSaveSettings();
    });
    
    document.getElementById('garbage-trucks').addEventListener('change', function() {
        settings.GarbageTrucks = this.checked;
        autoSaveSettings();
    });
    
    document.getElementById('random-boats').addEventListener('change', function() {
        settings.RandomBoats = this.checked;
        autoSaveSettings();
    });
    
    document.getElementById('random-cops').addEventListener('change', function() {
        settings.RandomCops = this.checked;
        autoSaveSettings();
    });
    
    // Other settings
    document.getElementById('distance-toggle').addEventListener('change', function() {
        settings.DistanceLimits = this.checked;
        autoSaveSettings();
    });
    
    document.getElementById('focus-toggle').addEventListener('change', function() {
        settings.FocusEnabled = this.checked;
        autoSaveSettings();
    });
    
    // Buttons
    document.getElementById('close-btn').addEventListener('click', function() {
        closeUI();
    });
    
    document.getElementById('close-btn-bottom').addEventListener('click', function() {
        closeUI();
    });
    
    // ป้องกันการคลิกด้านหลัง UI แล้วปิด UI
    document.querySelector('.fps-booster-ui').addEventListener('click', function(event) {
        event.stopPropagation();
    });
    
    // ปิด UI เมื่อกด ESC
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeUI();
        }
    });
    
    // ปิด UI เมื่อคลิกนอก UI
    document.getElementById('app').addEventListener('click', function(event) {
        if (event.target === this) {
            closeUI();
        }
    });
    
    // เริ่มการนับ FPS (แบบจำลอง)
    startFPSCounter();
});

// ฟังก์ชันสำหรับจำลองการนับ FPS
function startFPSCounter() {
    // ในเกมจริงข้อมูล FPS จะถูกส่งมาจากตัวเกม
    // แต่ในที่นี้เราจะจำลองการนับ FPS เพื่อทดสอบหน้า UI
    
    function updateFPS() {
        const now = performance.now();
        frameCount++;
        
        if (now - lastTime >= 1000) {
            fpsCounter = frameCount;
            document.getElementById('fps-counter').textContent = fpsCounter;
            
            frameCount = 0;
            lastTime = now;
        }
        
        requestAnimationFrame(updateFPS);
    }
    
    requestAnimationFrame(updateFPS);
}

// ป้องกันการ drag and drop บนหน้า UI
document.addEventListener('dragover', function(event) {
    event.preventDefault();
});

document.addEventListener('drop', function(event) {
    event.preventDefault();
});