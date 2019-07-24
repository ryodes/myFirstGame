
function love.load()
  brique = {}
  brique.stockchoix = 0
  brique.images = {}
  for i = 1,6 do
    brique.images[i] = love.graphics.newImage("Bricks/"..i..".png")
  end
  brique.craftmod = {}
  for l = 1,11 do
    for c = 1,17 do
      brique.craftmod[(l-1)*17 + c] = 0
    end
  end
end

function love.update()
  
end

function love.draw()
  craftchooseBrick(love.mouse.getPosition())
end

function craftchooseBrick(x,y)
      --convertie les coordonnées en ligne, colone
  l,c = math.floor(y/23) + 1,math.floor(x/48) + 1
      --affiche le squellete de la map pour craft  
  for l = 1,11 do
    for c = 1,17 do
      love.graphics.rectangle('line',(48*c)-48,(23*l)-23,48,23)
    end
  end
      --affiche la map craft par le joueur
  for l = 1,11 do
    for c = 1,17 do
      if (brique.craftmod[(l-1)*17 + c] ~= 0) then
        love.graphics.draw(brique.images[brique.craftmod[(l-1)*17 + c]],(48*c)-48,(23*l)-23)
      end
    end
  end
      --affiche la brique selectionné sur le curseur
  if (brique.stockchoix ~= 0) then
    love.graphics.draw(brique.images[brique.stockchoix],x-24,y-12)
  end
      --affiche les briques pour craft
  for i = 1,6 do
    love.graphics.draw(brique.images[i],240  + (48*i),350)
  end
      --affiche les instruction de selection
  love.graphics.print("left-click to select and put : right-click to erase",160,400,0,2,2)
    
      --enregistre la brique selectionné pour craft (intervalle pour choisir les briques)
  if (y > 350 and y < 373) then
    if (x > 288 and x < 568) then
      if (love.mouse.isDown(1)) then
        brique.stockchoix = (math.floor((x%288)/48) + 1)
      end
    end
  end
      --intervalle de la map (put and erase bricks)
  if (y < 253) then
        --met la bique choisie dans la map
    if (love.mouse.isDown(1)) then
      brique.craftmod[(l-1)*17 + c] = brique.stockchoix
    end
        --efface les brique selectionné dans la map
    if (love.mouse.isDown(2)) then
      brique.craftmod[(l-1)*17 + c] = 0
    end
  end
  function love.keypressed(key)
    if key == "return" then
      for l = 1,11 do
        for c = 1,17 do
          print(brique.craftmod[(l-1)*17 + c])
        end
        print("\n")
      end
    end
  end
end