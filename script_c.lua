setDevelopmentMode (true)
local textObjects = {}
local visibleTextObjects = {}
local textid = 0

-- tworzenie obiektu tekstu
function createTextObject(posX, posY, posZ, content, color, font, distance) 
    local txtObj = {
        id = textid,
        position = {posX, posY, posZ},
        content = content,
        color = color,
        font = font,
        rendering_distance = distance,
        los_validation = false,
        colSphere = nil
    }
    triggerServerEvent("onTextObjectCreate", resourceRoot, txtObj)
end

-- wykonanie update obiektu tekstowego
-- przyklad uzycia: updateTextObject(1, {content="This is edited txtObj content"}) 
function updateTextObject(id, data) -- data to obiekt zawierajacy opcjonalne argumenty, przesylamy tylko to co chcemy zmienic {posX, posY, posZ, content, color, font, distance}
    id = tonumber(id)
    for i,txtObj in ipairs(textObjects) do
      if txtObj.id == id then
        if data.posX and data.posY and data.posZ then
          txtObj.position = {posX, posY, posZ}
        end
        
        if data.content then
          txtObj.content = data.content
        end

        if data.color then 
          txtObj.color = data.color
        end
        
        if data.font then 
          txtObj.font = data.font
        end

        if data.distance then 
          txtObj.rendering_distance = data.distance
        end
        setElementData(txtObj.colSphere, "txtObj", txtObj)
        -- refresh w celu zaktualizowania tekstu, jezeli byl w danym momencie widoczny
        onTextObjectLeave(txtObj)
        onTextObjectEnter(txtObj)
    end
  end
end
addEvent("onTextUpdate", true)
addEventHandler("onTextUpdate", resourceRoot, updateTextObject)

-- request update obiektu tekstowego
function reqTextUpdate(id, data)
    triggerServerEvent("onTextUpdateRequest", resourceRoot, id, data)
end    

-- usuwanie obiektu tekstu
function removeTextObject(ID)
    for i, txtObj in ipairs(textObjects) do
        if txtObj.id == tonumber(ID) then
            destroyElement(txtObj.colSphere)
            table.remove(textObjects, i)
        end
    end
    for i, txtObj in ipairs(visibleTextObjects) do
        if txtObj.id == tonumber(ID) then
            destroyElement(txtObj.colSphere)
            table.remove(visibleTextObjects, i)
        end
    end
end    
addEvent("onTextRemoval", true)
addEventHandler("onTextRemoval", resourceRoot, removeTextObject)

-- request usuniecia tekstu z serwera
function reqTextDeletion(id)
   triggerServerEvent("onTextDeletionRequest", resourceRoot, id) 
end

--request danych textobiektow z serwera
function requestTextObjects()
    triggerServerEvent("requestTextObjectsOnJoin", resourceRoot, localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, requestTextObjects)


-- odebranie wszystkich istniejacych obiektow tekstu na serwerze
function getAllTextObjects(serverTextObjects)
    textObjects = serverTextObjects
    for i,txtObj in ipairs(textObjects) do
        txtObj.colSphere = createColSphere(txtObj.position[1],txtObj.position[2],txtObj.position[3], txtObj.rendering_distance)
        setElementData(txtObj.colSphere, "txtObj", txtObj)
        addEventHandler("onClientColShapeHit", txtObj.colSphere, onColShapeHit)
        addEventHandler("onClientColShapeLeave", txtObj.colSphere, onColShapeLeave)        
    end    
end
addEvent("receiveFullTextObjectData", true)
addEventHandler("receiveFullTextObjectData", resourceRoot, getAllTextObjects)


-- odebranie pojedynczego obiektu tekstu od serwera
function getSingleTextObject(txtObj)
    txtObj.colSphere = createColSphere(txtObj.position[1],txtObj.position[2],txtObj.position[3], txtObj.rendering_distance)
    setElementData(txtObj.colSphere, "txtObj", txtObj)
    addEventHandler("onClientColShapeHit", txtObj.colSphere, onColShapeHit)
    addEventHandler("onClientColShapeLeave", txtObj.colSphere, onColShapeLeave)
    table.insert(textObjects, txtObj)
end    
addEvent("receiveTextObject", true)
addEventHandler("receiveTextObject", resourceRoot, getSingleTextObject)


-- wejscie do colsphere
function onTextObjectEnter(txtObj)
    table.insert(visibleTextObjects, txtObj) -- dodanie tekstu do 'widocznych'
end
addEvent("onTextObjectEnter", true)
addEventHandler("onTextObjectEnter", resourceRoot, onTextObjectEnter)

-- wyjscie z colsphere
function onTextObjectLeave(txtObj)
    for i, obj in ipairs(visibleTextObjects) do
        if obj.id == txtObj.id then
            table.remove(visibleTextObjects, i) -- usuniecie tekstu z 'widocznych'
            break
        end
    end
end
addEvent("onTextObjectLeave", true)
addEventHandler("onTextObjectLeave", resourceRoot, onTextObjectLeave)

-- Event handler kolizji gracza z colsphere
function onColShapeHit(hitElement, matchingDimension)
    if (hitElement == localPlayer) and matchingDimension then
        local player = hitElement
        local txtObj = getElementData(source, "txtObj") -- get the txtObj table from the colSphere
        onTextObjectEnter(txtObj)
    end
end

-- Event handler opuszczenia sphere przez gracza
function onColShapeLeave(hitElement, matchingDimension)
    if (hitElement == localPlayer) and matchingDimension then
        local txtObj = getElementData(source, "txtObj")
        onTextObjectLeave(txtObj)
    end
end



-- rysowanie obiektow tekstu
function drawTextObject(txtObj)
    local camX, camY, camZ = getCameraMatrix()
    local dist = getDistanceBetweenPoints3D(camX, camY, camZ, unpack(txtObj.position))
    -- walidacja line of sight
      txtX, txtY, txtZ = unpack(txtObj.position)
      txtObj.los_validation = isLineOfSightClear(camX, camY, camZ, txtX, txtY, txtZ,true,true,false)
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
    for i, txtObj in ipairs(visibleTextObjects) do
        drawTextObject(txtObj)
    end
end
addEventHandler("onClientRender", root, drawVisibleTextObjects)
