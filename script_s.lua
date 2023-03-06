function startResource()
  outputChatBox("Zeth 3dtext started")
end
addEventHandler("onResourceStart", getResourceRootElement(), startResource)

local textid = 0
local textObjects = {}

-- servowanie danych nowego stworzonego tekstu z reszta userow
function textObjectCreate(txtObj)
    txtObj.id = textid+1
    table.insert(textObjects, txtObj)
    triggerClientEvent("receiveTextObject", resourceRoot, txtObj)
    textid=textid+1
end
addEvent("onTextObjectCreate", true)
addEventHandler("onTextObjectCreate", getResourceRootElement(), textObjectCreate)

-- synchronizacja wszystkich obiektow tekstowych na loginie gracza
function syncTextObjects(player)
  triggerClientEvent(player, "receiveFullTextObjectData", resourceRoot, textObjects)
end 
addEvent("requestTextObjectsOnJoin", true)
addEventHandler("requestTextObjectsOnJoin", resourceRoot, syncTextObjects)

-- usuwanie obiektu tekstu
function handleTextDeletion(id)
  for i, txtObj in ipairs(textObjects) do
        if (id == txtObj.id) then
            table.remove(textObjects, i)
        end
  end 
  triggerClientEvent("onTextRemoval", resourceRoot, id)
end  
addEvent("onTextDeletionRequest", true)
addEventHandler("onTextDeletionRequest", resourceRoot, handleTextDeletion)

-- aktualizacja istniejacego obiektu tekstu
-- przyklad uzycia: updateTextObject(1, {content="This is edited txtObj content"}) 
function updateTextObject(id, data) -- data to obiekt zawierajacy opcjonalne argumenty, przesylamy tylko to co chcemy zmienic {posX, posY, posZ, content, color, font, distance}
  triggerClientEvent("onTextUpdate", resourceRoot, id, data)
end  
addEvent("onTextUpdateRequest", true)
addEventHandler("onTextUpdateRequest", resourceRoot, updateTextObject)


-- funkcja zwracajaca tablice z wszystkimi obiektami tekstow
function findAllTextObjects()
    return textObjects
end  

-- znalezienie pojedynczego textobiektu o danym id i zwrocenie go
function findTextObject(ID)
  for i,txtObj in ipairs(textObjects) do
    if ID == txtObj.id then
        return txtObj
    end
  end
end
