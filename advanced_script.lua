-- Advanced script similar to the original loadstring pattern
-- This demonstrates loading scripts from external URLs

-- Configuration
local CONFIG = {
    SCRIPT_URL = "https://raw.githubusercontent.com/Sterben120326/grow-garden-script/main/script.lua",
    FALLBACK_SCRIPT = [[
        -- Fallback script content if URL fails
        print("Using fallback script...")
        
        -- Your main script logic here
        local function main()
            print("Main function executed!")
            -- Add your game-specific code here
        end
        
        main()
    ]],
    ENABLE_ERROR_HANDLING = true
}

-- Main loader function
local function loadScript()
    if CONFIG.ENABLE_ERROR_HANDLING then
        -- Safe loading with error handling
        local success, result = pcall(function()
            return loadstring(game:HttpGet(CONFIG.SCRIPT_URL))()
        end)
        
        if success then
            print("Script loaded successfully from URL!")
        else
            print("Failed to load from URL, using fallback...")
            print("Error:", result)
            
            -- Load fallback script
            local fallbackSuccess, fallbackResult = pcall(function()
                return loadstring(CONFIG.FALLBACK_SCRIPT)()
            end)
            
            if fallbackSuccess then
                print("Fallback script executed successfully!")
            else
                print("Fallback script failed:", fallbackResult)
            end
        end
    else
        -- Direct loading (like the original)
        loadstring(game:HttpGet(CONFIG.SCRIPT_URL))()
    end
end

-- Alternative: Simple one-liner (like the original)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Sterben120326/grow-garden-script/main/script.lua"))();

-- Execute the script
loadScript()
