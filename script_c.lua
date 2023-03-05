setDevelopmentMode (true)

local textObjects = {}

-- Event handler for when a player enters a text object's collision sphere
function onTextObjectEnter(txtObj)
    table.insert(textObjects, txtObj) -- add the text object to the list of visible text objects
end
addEvent("onTextObjectEnter", true)
addEventHandler("onTextObjectEnter", resourceRoot, onTextObjectEnter)

-- Event handler for when a player exits a text object's collision sphere
function onTextObjectLeave(txtObj)
    for i, obj in ipairs(textObjects) do
        if obj.id == txtObj.id then
            table.remove(textObjects, i) -- remove the text object from the list of visible text objects
            break
        end
    end
end
addEvent("onTextObjectLeave", true)
addEventHandler("onTextObjectLeave", resourceRoot, onTextObjectLeave)

-- rysowanie obiektow tekstu
function drawTextObject(txtObj)
    local camX, camY, camZ = getCameraMatrix()
    local dist = getDistanceBetweenPoints3D(camX, camY, camZ, unpack(txtObj.position))
    -- walidacja line of sight
      txtX, txtY, txtZ = unpack(txtObj.position)
      txtObj.los_validation = isLineOfSightClear(camX, camY, camZ, txtX, txtY, txtZ,false,false,false)
    if dist <= txtObj.rendering_distance and (txtObj.los_validation) then
    
        local alpha = 255
        local scale = 1

        -- zmiana skali/alphy w zaleznosci od dystansu playera od tekstu
          if dist > txtObj.rendering_distance/2 then
            alpha = math.max(0, math.min(255, (txtObj.rendering_distance - dist) / (txtObj.rendering_distance / 2) * 255))
            scale = math.max(0, math.min(1, (txtObj.rendering_distance - dist) / (txtObj.rendering_distance / 2) * 1))
          end

        local textHeight = dxGetFontHeight(txtObj.font)
        local textWidth = dxGetTextWidth(txtObj.content, 1, txtObj.font)
        local screenX, screenY = getScreenFromWorldPosition(unpack(txtObj.position))
        if screenX and screenY then
            local x = screenX - textWidth / 2
            local y = screenY - textHeight / 2
             dxDrawText(txtObj.content, screenX - textWidth/2, screenY - textHeight/2, screenX + textWidth/2, screenY+textHeight/2, tocolor(txtObj.color[1], txtObj.color[2], txtObj.color[3], alpha), scale, txtObj.font, "center", "center", false, true)        
        end
    end
end

-- draw loop rysujacy wszystkie obiekty tekstu mozliwie widoczne dla gracza
function drawVisibleTextObjects()
    for i, txtObj in ipairs(textObjects) do
        drawTextObject(txtObj)

    end
end
addEventHandler("onClientRender", root, drawVisibleTextObjects)