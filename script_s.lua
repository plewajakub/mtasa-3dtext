function sayHello()
    outputChatBox("Hello!")
end

function startResource()
  outputChatBox("Zeth 3dtext started")
end
addEventHandler("onResourceStart", getResourceRootElement(), startResource)

local textid = 0
local textObjects = {}

-- tworzenie obiektu tekstu
function createTextObject(posX, posY, posZ, content, color, font, distance) 
    textid = textid + 1
    local txtObj = {
        id = textid,
        position = {posX, posY, posZ},
        content = content,
        color = color,
        font = font,
        rendering_distance = distance,
        los_validation = false,
        colSphere = createColSphere(posX, posY, posZ, distance)
    }
    setElementData(txtObj.colSphere, "txtObj", txtObj) -- attach the txtObj table to the colSphere
    addEventHandler("onColShapeHit", txtObj.colSphere, onColShapeHit)
    addEventHandler("onColShapeLeave", txtObj.colSphere, onColShapeLeave)
    table.insert(textObjects, txtObj)
    outputChatBox("Dodano tekst")
end

-- aktualizacja istniejacego obiektu tekstu
-- przyklad uzycia: updateTextObject(1, {content="This is edited txtObj content"}) 
function updateTextObject(id, data) -- data to obiekt zawierajacy opcjonalne argumenty, przesylamy tylko to co chcemy zmienic {posX, posY, posZ, content, color, font, distance}
  if type(id) ~= "number" then error("Invalid ID") end
    outputChatBox(data.content)
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
    end
  end 

end 

-- usuwanie obiektu tekstu
function removeTextObject(ID) 
  for i,txtObj in ipairs(textObjects) do
    if txtObj.id == ID then
    destroyElement(txtObj.colSphere)
    table.remove(textObjects, i)
    end
  end
end

-- funkcja zwracajaca tablice z wszystkimi obiektami tekstow
function findAllTextObjects()
    return textObjects
end  

-- znalezienie pojedynczego textobiektu
function findTextObject(ID)
  outputConsole("Text Objects") 
  for i,txtObj in ipairs(textObjects) do
    if ID == txtObj.id then
        return txtObj
    end
  end
end

-- Event handler kolizji gracza z colsphere
function onColShapeHit(hitElement, matchingDimension)
    if getElementType(hitElement) == "player" then
        local player = hitElement
        local txtObj = getElementData(source, "txtObj") -- get the txtObj table from the colSphere
        triggerClientEvent(player, "onTextObjectEnter", resourceRoot, txtObj) 
    end
end

-- Event handler opuszczenia sphere przez gracza
function onColShapeLeave(hitElement, matchingDimension)
    if getElementType(hitElement) == "player" then
        local player = hitElement
        triggerClientEvent(player, "onTextObjectLeave", resourceRoot)
    end
end


createTextObject(0, 0, 3, "Test Test Test", {255, 255, 255, 255}, "arial", 20)
createTextObject(0, 20, 3, "Test Test Test", {255, 255, 255, 255}, "default-bold", 20)
updateTextObject(1, {content="This is edited txtObj content"})
removeTextObject(2)
findAllTextObjects()
