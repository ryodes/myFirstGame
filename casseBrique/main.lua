-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest")

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

function love.load()
  love.window.setTitle("Dark Breaker")
  love.window.setIcon(love.image.newImageData("raquette1.png"))
      --largeur et hauteur de l'ecran
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
      --animation d'explosion
  img = love.graphics.newImage("explosion.png")
  boum = {}
  for n=0,11 do
    boum[n] = love.graphics.newQuad(96*n, 0, 96, 96, img:getDimensions())
  end
  i=1
  j=0
  m=0
  nb = 0
  
      --fond sonore 
  pisteAudio = love.audio.newSource("song.wav","stream")
  pisteAudio:setLooping(true)
  volume = 0.05
  love.audio.setVolume(volume)
  love.audio.play(pisteAudio)
  rebond = love.audio.newSource("rebond.wav","static")
  mort = love.audio.newSource("mort.wav","static")
  
    --table contenant tout les image a afficher
  image = {}
  image.main = love.graphics.newImage('gameOver.png')
  image.width = image.main:getWidth()
  image.height = image.main:getHeight()
  image.coeur = love.graphics.newImage('coeur2.png')
  image.coeurWidth = image.coeur:getWidth()
  image.coeurHeight = image.coeur:getHeight()
  image.terrain = love.graphics.newImage('terrain.png')
  image.raquette = love.graphics.newImage('raquette1.png')
  image.lave = love.graphics.newImage('lave.png')
  image.briqueRouge = love.graphics.newImage('briqueRouge.png')
  image.background = love.graphics.newImage('volcan.jpg')
  image.boule = love.graphics.newImage('boule1.png')
  
      --dragon
  dragon1 = {}
  dragon1.image = love.graphics.newImage('dragon.png')
  dragon1.rubis = love.graphics.newImage('rubis.png')
  dragon1.rubisX = (largeur/2)+2
  dragon1.rubisY = (dragon1.image:getHeight()/4)-60
  dragon1.rubisWidth = dragon1.rubis:getWidth()
  dragon1.rubisHeight = dragon1.rubis:getHeight()
  dragon1.vie = 3
  dragon1.shoots = {}
  dragon1.nbshoot = 0
  dragon1.fire = {}
  for indice=1,16 do
    dragon1.fire[indice] = love.graphics.newImage("/fire/fire"..indice..".png")
  end
  dragon1.fireSpeed = 200
  dragon1.cadence = 200
  dragon1.roar = love.audio.newSource('roar.mp3','static')
  
      --table contenant les stats de la raquette du joueur 1
  platforme1 = {}
  platforme1.image = love.graphics.newImage('raquette1.png')
  platforme1.vie = 2
  platforme1.width = platforme1.image:getWidth()
  platforme1.height = platforme1.image:getHeight()
  platforme1.speed = 300
  platforme1.x = ((largeur-platforme1.width)/2)
  platforme1.y = (hauteur-platforme1.height)
  platforme1.espace = 50
  platforme1.score = 0
  
      --table contenant les stat de la balle du joueur 1
  boule1 = {}
  boule1.image = love.graphics.newImage('boule1.png')
  boule1.width,boule1.height = boule1.image:getWidth(),boule1.image:getHeight()
  boule1.rayon = boule1.width/2
  boule1.speed = 300
  boule1.x,boule1.y = (platforme1.x + (platforme1.width)/2  - boule1.width/2) ,(platforme1.y - boule1.rayon - platforme1.espace - boule1.height/2) 
  boule1.centreX = boule1.x + boule1.width/2
  boule1.centreY = boule1.y + boule1.height/2
      --determinera le sens de la balle
  boule1.mouvX,boule1.mouvY = 1,-1
  
      ----table contenant les stat de la raquette du joueur 2
  platforme2 = {}
  platforme2.image = love.graphics.newImage('raquette2.png')
  platforme2.vie = 2
  platforme2.width = platforme2.image:getWidth()
  platforme2.height = platforme2.image:getHeight()
  platforme2.speed = 300
  platforme2.x = ((largeur-platforme2.width)/2)
  platforme2.y = (hauteur-platforme2.height)
  platforme2.espace = 50
  platforme2.score = 0
  
        --table contenant les stat de la balle du joueur 1
  boule2 = {}
  boule2.image = love.graphics.newImage('boule2.png')
  boule2.width,boule2.height = boule2.image:getWidth(),boule2.image:getHeight()
  boule2.rayon = boule2.width/2
  boule2.speed = 300
  boule2.x,boule2.y = (platforme2.x + (platforme2.width)/2  - boule2.width/2) ,(platforme2.y - boule2.rayon - platforme2.espace - boule2.height/2) 
  boule2.centreX = boule2.x + boule2.width/2
  boule2.centreY = boule2.y + boule2.height/2
      --determinera le sens de la balle
  boule2.mouvX,boule2.mouvY = 1,-1
  
      --map
  brique = {}
  brique.images = {}
  for i=1,6 do
    brique.images[i] = love.graphics.newImage("Bricks/"..i..".png")
  end
      --choix du lvl
  brique.lvl = 0
      --stockera la brique choisie dans le crafmode
  brique.stockchoix = 0
      --choix du craft mode
  brique.mode = 1
  brique.modechoisi = false
      --initialise la map pour le craftmode
  brique.craftmode = {}
  for l = 1,11 do
    for c = 1,17 do
      brique.craftmode[(l-1)*17 + c] = 0
    end
  end

      --charge les images pour le menu
  allraquette = {}
  allboule = {}
  for i=1,6 do
    allraquette[i] = love.graphics.newImage('raquette'..i..'.png')
    allboule[i] = love.graphics.newImage('boule'..i..'.png')
  end
  
      --creer les brique dans la table brique
  --creerBrique()
  
      --boolean
  perdu = false
  gagner = false
  shoot = false
  choose = false
  choose2 = false
  choose3 = false
  joueur2 = false
  pause = false
  craftmode = false
  
      --variable pour stocker le resultat du menu
  skinx = 0
  skiny = 0
  jy = 0
  
end

function love.update(dt)
  if not(pause) then
    if (brique.lvl == 3) and (brique.nombre == 0) and (not(gagner))then
      i = (i+1)%dragon1.cadence
      if (i==0) then
        shoots(dragon1)
      end
      for i,v in ipairs(dragon1.shoots) do
        v.y = v.y + dragon1.fireSpeed*dt
        v.x = v.x + v.sens
        if (v.y > platforme1.y) then
          table.remove(dragon1.shoots,i)
          dragon1.nbshoot = dragon1.nbshoot - 1
        end
      end
      for i,v in ipairs(dragon1.shoots) do
        if (checkcollision2(platforme1.x,platforme1.x+platforme1.width,platforme1.y,platforme1.y+platforme1.height,v.x,v.y,dragon1.fire[1]:getWidth(),dragon1.fire[1]:getHeight(),platforme1)) then
          --resetBall(boule1,platforme1)
          love.audio.setVolume(3)
          mort:play()
          table.remove(dragon1.shoots,i)
          platforme1.vie = platforme1.vie - 1
        end
        if (checkcollision2(platforme2.x,platforme2.x+platforme2.width,platforme2.y,platforme2.y+platforme2.height,v.x,v.y,dragon1.fire[1]:getWidth(),dragon1.fire[1]:getHeight(),platforme1)) and (joueur2==1) then
          --resetBall(boule2,platforme2)
          love.audio.setVolume(3)
          mort:play()
          table.remove(dragon1.shoots,i)
          platforme2.vie = platforme2.vie - 1
        end
      end
    end
        --gere le volume de la piste audio
    love.audio.setVolume(volume)
        --metter le boolean a true pour finir la partie
      if (platforme1.vie == -1) or (platforme2.vie == -1) then
        perdu = true
      end
          --change de niveau quand un niveau est fini
      if brique.mode == 1 and (((brique.lvl == 0) or (brique.lvl == 1) or  (brique.lvl == 2)) and (brique.nombre == 0)) then
        boule1.speed = 300
        platforme1.vie = platforme1.vie + 1
        brique.lvl = brique.lvl + 1
        resetBall(boule1,platforme1)
        creerBrique()
        if (joueur2 == 1) then
          platforme2.vie = platforme2.vie + 1
          resetBall(boule2,platforme2)
          boule2.speed = 300
        end
      end
      if (dragon1.vie == 0) then
        gagner = true
      end
      if brique.mode == 2 and brique.nombre == 0 then
        gagner = true
      end
      if (not(choose)) then
          --enrengistre quelle skin a etait choisie dans la variable skin
        choixDuSkin(boule1,platforme1)
      else
        --boucle tant que des vie sont restante
        if (perdu == false) and (gagner == false) then
            --permet le deplacement de la raquette de gauche a droite entre les bord de l'ecran
          deplacerRaquette(platforme1,dt)
          
            --fait bouger la balle en meme temps que la raquette tant que le joueur tir pas
          gererBalle(boule1,platforme1,dt)
          
            --change la direction de la balle lors de la rencontre avec les bordure de jeu
          directionBalle(boule1)
          
            --casse les brique si une collision est detectée
          casseBrique(boule1,platforme1)
          
            --determine si la balle touche la raquette ou tombe dans le vide sinon, et reset la balle, -1 vie 
          rebondBalle(boule1,platforme1)
          if (joueur2 == 0) then
            choose3 = true
          end
              --insere le 2em joueur si y a
          if (joueur2 == 1) then
            choixDuSkin(boule2,platforme2)
            deplacerRaquette2(platforme2,dt)
            gererBalle(boule2,platforme2,dt)
            directionBalle(boule2)
            casseBrique(boule2,platforme2)
            rebondBalle(boule2,platforme2)
          end
        end
      end
    end
end
function love.draw()
  if (not(choose) or not(choose2) or not(choose3)) then
        --affiche les skin a l'ecran
      afficherMenu()
  else
      afficherJeu()
  end
      --affiche pause
  if pause then
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle('fill',0,0,800,600)
    love.graphics.setColor(1,1,1)
    love.graphics.print("PAUSE",380,280,0,2,2)
  end
end
function afficherBoss(dragon)
    if (j<110) then
      j  = j + 1
      if (i<110) then
        nb = math.floor(j/10)
      end
      for s=0,11 do
        love.graphics.draw(img,boum[nb],15+(62*s),-30)
      end
    else
      love.graphics.setColor(1,0.5,0.5)
      love.graphics.draw(dragon.image,(largeur-dragon.image:getWidth()*0.8)+dragon.image:getWidth()*0.8,dragon.image:getHeight()/4,math.pi,0.8,0.8)
      love.graphics.setColor(1,1,1)
      love.graphics.draw(dragon.rubis,dragon.rubisX,dragon.rubisY)
    end
end
function choixDuSkin(balle,raquette)
  skin = skinx + (3*skiny+1)
      raquette.image = allraquette[skin]
      balle.image = allboule[skin]
end
function afficherJeu()
        --affichage du background en feu
  love.graphics.draw(image.background,0,0,0,800/image.background:getWidth(),600/image.background:getHeight())
  
      --affichage du contour de l'ecran
  love.graphics.setColor(1,1,1)
  love.graphics.draw(image.terrain,0,0,0,.93,.93)
  
      --affichage des briques
  love.graphics.setColor(0.6,0.2,0)
  love.graphics.setColor(1,1,1)
  for l=1,brique.data.height do
    for c=1,brique.data.width do
      if (brique[l][c].vie > 0) then
        local id = brique.map[((l-1)*brique.data.width + c)]
        love.graphics.draw(brique.images[id],brique[l][c].x,brique[l][c].y)
      end
    end
  end
        
      -- affichage du dragon
  if (brique.lvl == 3) and (brique.nombre == 0) then
    m = (m + 1)%151
    local nb = math.floor(m/10) + 1
    afficherBoss(dragon1)
        --affiche les boule de feu stocker
    for i,v in ipairs(dragon1.shoots) do
        if (dragon1.vie < 3 ) then
          love.graphics.setColor(0,1,0)
        end
        love.graphics.draw(dragon1.fire[nb],v.x,v.y)
    end
        --check si le rubis et toucher par une balle
    if (checkcollision(dragon1.rubisX,dragon1.rubisY,dragon1.rubisX+dragon1.rubis:getWidth(),dragon1.rubisY+dragon1.rubis:getHeight(),boule1.centreX,boule1.centreY,boule1)) or (checkcollision(dragon1.rubisX,dragon1.rubisY,dragon1.rubisX+dragon1.rubis:getWidth(),dragon1.rubisY+dragon1.rubis:getHeight(),boule2.centreX,boule2.centreY,boule2)) then
      dragon1.roar:play()
      dragon1.vie = dragon1.vie - 1
      if (dragon1.vie == 2) then
        dragon1.cadence = 100
      end
      if (dragon1.vie == 1) then
        dragon1.fireSpeed = 300
      end
      if (dragon1.vie == 0) then
        gagner = true
      end
      resetBall(boule1,platforme1)
      if (joueu2 == 1) then
        resetBall(boule2,platforme2)
      end
    end
  end
      --affiche la raquette + la balle du joueur
  afficherJoueur(boule1,platforme1)
  if (joueur2 == 1) then
    afficherJoueur(boule2,platforme2)
  end
      --affichage de la lave
  love.graphics.setColor(1,1,1)
  love.graphics.draw(image.lave,0,hauteur-53,0,2,2)
  
      --affichage du game over en cas de defaite
  if (perdu) then
    love.graphics.draw(image.main,(largeur-(image.width*0.4))/2,(hauteur-(image.height*0.4))/2,0,0.4,0.4)
    if (platforme1.vie == -1) then
      love.graphics.print("player 1 loose",((largeur-(image.width*0.4))/2)+(image.width*0.4)/4,((hauteur-(image.height*0.4))/2) + image.height*0.4,0,2,2)
    else
      love.graphics.print("player 2 loose",((largeur-(image.width*0.4))/2)+(image.width*0.4)/4,((hauteur-(image.height*0.4))/2) + image.height*0.4,0,2,2)
    end
    love.graphics.print("press 'R' to reset",((largeur-(image.width*0.4))/2)+(image.width*0.4)/4,(hauteur-image.height),0,2,2)
    pisteAudio:stop()
  end
  if (gagner) then
    if (platforme1.score > platforme2.score) then
      love.graphics.draw(image.main,(largeur-(image.width*0.4))/2,(hauteur-(image.height*0.4))/2,0,0.4,0.4)
      love.graphics.print("player 1 win",((largeur-(image.width*0.4))/2)+(image.width*0.4)/4,((hauteur-(image.height*0.4))/2) + image.height*0.4,0,2,2)
      love.graphics.print("press 'R' to reset",((largeur-(image.width*0.4))/2)+(image.width*0.4)/4,(hauteur-image.height),0,2,2)
      pisteAudio:stop()
    else
      love.graphics.draw(image.main,(largeur-(image.width*0.4))/2,(hauteur-(image.height*0.4))/2,0,0.4,0.4)
      love.graphics.print("player 2 win",((largeur-(image.width*0.4))/2)+(image.width*0.4)/4,((hauteur-(image.height*0.4))/2) + image.height*0.4,0,2,2)
      love.graphics.print("press 'R' to reset",((largeur-(image.width*0.4))/2)+(image.width*0.4)/4,(hauteur-image.height),0,2,2)
      pisteAudio:stop()
    end
  end
end

function afficherJoueur(balle,raquette)
        --affichage de la raquette
  love.graphics.setColor(1,1,1)
  love.graphics.draw(raquette.image,raquette.x,raquette.y - raquette.espace)
      
      --affichage de la balle
  love.graphics.setColor(1,1,1)
  love.graphics.draw(balle.image,balle.x,balle.y)
  
      --affichage des coeurs
  love.graphics.setColor(0.55,0.55,0.59)
  local size = image.coeurWidth*0.06
  for i=0,raquette.vie do
    love.graphics.draw(image.coeur,raquette.x+(size*i)+1,(raquette.y - raquette.espace + raquette.height/8),0,0.06,0.06)
  end
      --afficher les scores
  love.graphics.setColor(1,1,1)
  love.graphics.print(raquette.score,raquette.x +((size*3)+1) ,raquette.y - raquette.espace)
end
function afficherMenu()
  if not(brique.modechoisi) then
    if not(craftmode) then
            --affiche le logo
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.print("DARK",230,20,0,10,10)
        love.graphics.setColor(0.8,0.3,0)
        love.graphics.print("Breaker",150,140,0,11,11)
        love.graphics.setColor(1,1,1)
            --affiche les different mode de jeu
        love.graphics.print("Storie\nCraft  (Beta)",350,350,0,2,2)
        love.graphics.setColor(1,1,1,0.5)
        love.graphics.rectangle('fill',350,330 + (brique.mode*23),70,28)
        love.graphics.setColor(1,1,1)
      if love.keyboard.isDown("down") or brique.mode == 2 then
        brique.mode = 2
      end
      if love.keyboard.isDown("up") then
        brique.mode = 1
      end
    else
        craftchooseBrick(love.mouse.getPosition())
    end
  else
    if (not(choose)) then
      afficheskins()
    end
    if (choose and not(choose2)) then
      pointeur = 200 + (jy *50)
      love.graphics.print("1 player   \"<-\" & \"->\"\n\n2 players   \"Q\" & \"D\"\n\nshoot      \"espace\"\n\nsound      \"M\"\"L\"\"+\"\"-\"\n\npause/play     \"P\"",300,200,0,2,2)
      love.graphics.setColor(1,1,1,0.3)
      love.graphics.rectangle('fill',300,pointeur,120,35)
      love.graphics.setColor(1,1,1)
    end
    if (choose2 and not(choose3)) then
      if (joueur2 == 1) then
        afficheskins()
      end
    end
  end
end
function afficheskins()
    love.graphics.print("choose your skin :",250,100,0,2,2)
    local i=1
    for c=0,1 do
      for l=0,2 do
        love.graphics.draw(allraquette[i],230+(l*100),200+(c*90))
        love.graphics.draw(allboule[i],265+(l*100),180+(c*90))
        i = i+1
      end
    end
    love.graphics.setColor(1,1,1,0.3)
    pointeurX = 225 + (skinx * 100)
    pointeurY = 170 + (skiny * 90)
    love.graphics.rectangle('fill',pointeurX,pointeurY,95,55)
    love.graphics.setColor(1,1,1)
end
function directionBalle(balle)
  if (balle.x + balle.width > largeur-25) then
    rebond:play()
    balle.mouvX = -math.abs(balle.mouvX)
  end
  if (balle.x < 26) then
    rebond:play()
    balle.mouvX = math.abs(balle.mouvX)
  end
  if (balle.y < 20) then
    rebond:play()
    balle.mouvY = math.abs(balle.mouvY)
  end
end

function gererBalle(balle,raquette,dt)
  if (shoot == false) then
    balle.x,balle.y = (raquette.x + (raquette.width)/2  - balle.width/2) ,(raquette.y - balle.rayon - raquette.espace - balle.height/2)
  end
  --stock le centre de la balle (pour les collision avec les brique)
  balle.centreX = balle.x + balle.width/2
  balle.centreY = balle.y + balle.height/2
        
  --met la balle en mouvement lorsque qu'elle quitte la raquette
  if (shoot == true) then
    balle.x = balle.x + balle.mouvX*(balle.speed*dt)
    balle.y = balle.y + balle.mouvY*(balle.speed*dt)
  end
end

    --check les collision entre la balle et les briques
function checkcollision(x1,y1,x2,y2,cx,cy,balle)
  cx1,cx2,cy1,cy2 = (cx - balle.width/2), (cx + balle.width/2), (cy - balle.height/2), (cy + balle.width/2)
  if (cx>=x1 and cy1>=y1 and cx<=x2 and cy1<=y2) then
    balle.mouvY = math.abs(balle.mouvY)
    return true
  end
  if (cx>=x1 and cy2>=y1 and cx<=x2 and cy2<=y2) then
    balle.mouvY = -math.abs(balle.mouvY)
    return true
  end
  if (cx1>=x1 and cy>=y1 and cx1<=x2 and cy<=y2) then
    balle.mouvX = math.abs(balle.mouvX)
    return true
  end
  if (cx2>=x1 and cy>=y1 and cx2<=x2 and cy<=y2) then
    balle.mouvX = -math.abs(balle.mouvX)
    return true
  end
end
    --check les collision avec les boule de feu du dragon
function checkcollision2(x1,x2,y1,y2,fx,fy,fw,fh,raquette)
  cx,cy = (fx + fw/2),(fy+fh)
  return (cx>=x1 and cx<=x2 and cy>=(hauteur - raquette.height - raquette.espace) and cy<=(hauteur - raquette.espace))
end
function casseBrique(balle,raquette)
  if (balle.y < hauteur/2) then
    for l=1,brique.data.height do
      for c=1,brique.data.width do
        if (brique[l][c].vie > 0 ) then 
          if (checkcollision(brique[l][c].x,brique[l][c].y,brique.width+(brique[l][c].x),brique.height+(brique[l][c].y),balle.centreX,balle.centreY,balle)) then
            rebond:play()
            brique[l][c].vie = brique[l][c].vie - 1
            brique.nombre = brique.nombre - 1
            boule1.speed = boule1.speed + 5
            if (joueur2 == 1) then
              boule1.speed = boule1.speed + 2
              boule2.speed = boule2.speed + 7
            end
            raquette.score = raquette.score + 50
          end
        end
      end
    end
  end
end

function rebondBalle(balle,raquette)
  if (balle.y + balle.height > hauteur - raquette.height - raquette.espace) and (balle.y + balle.height < hauteur - raquette.espace) then
        if (balle.centreX >= raquette.x) and (balle.centreX <= raquette.x + raquette.width) then
          rebond:play()
          balle.mouvY = -1
        end
        local delta = balle.x - raquette.x
        balle.mouvX = math.cos(math.pi - ((math.pi/80)*delta))
  elseif (balle.y + balle.image:getHeight() > hauteur - raquette.espace) then
        love.audio.setVolume(3)
        mort:play()
        raquette.vie = raquette.vie - 1
        resetBall(balle,raquette)
  end
end

function deplacerRaquette(raquette,dt)
  if ( raquette.x >= 25 and raquette.x + raquette.width <= largeur-25) then
    if love.keyboard.isDown("right") then
      raquette.x = raquette.x + raquette.speed*dt
    end
    if love.keyboard.isDown("left") then
      raquette.x = raquette.x - raquette.speed*dt
    end
  end
  --debloque la raquette quand t-elle est au bord de l'ecran
  if (raquette.x < 25) then
      raquette.x = raquette.x + raquette.speed*dt
  end
  if (raquette.x + raquette.width > largeur - 25) then
      raquette.x = raquette.x - raquette.speed*dt
  end
end

function deplacerRaquette2(raquette,dt)
  
  if ( raquette.x >= 25 and raquette.x + raquette.width <= largeur-25) then
    if love.keyboard.isDown("d") then
      raquette.x = raquette.x + raquette.speed*dt
    end
    if love.keyboard.isDown("q") then
      raquette.x = raquette.x - raquette.speed*dt
    end
  end
  --debloque la raquette quand t-elle est au bord de l'ecran
  if (raquette.x < 25) then
      raquette.x = raquette.x + raquette.speed*dt
  end
  if (raquette.x + raquette.width > largeur - 25) then
      raquette.x = raquette.x - raquette.speed*dt
  end
end


function love.keypressed(key)
  
      --met pause au jeu
  if not(pause) then
    if key == "p" then
      pause = true
      pisteAudio:pause()
    end
  elseif pause then
    if key == "p" then
      pause = false
      pisteAudio:play()
    end
  end
      --gere la piste audio
  if (key == "kp+") then
    volume = volume + 0.05
  end
  if (key == "kp-") then
    volume = volume - 0.05
  end
  if (key == 'm') then
    pisteAudio:pause()
  end
  if (key == 'l') then
    pisteAudio:play()
  end
  if not(brique.modechoisi) then
    if key == "return" and craftmode and brique.nombre ~= 0 then
      brique.modechoisi = true
    end
    if key == "return" and brique.mode == 1 then
        brique.modechoisi = true
    end
    if key == "return" and brique.mode == 2 then
      craftmode = true
      craftchooseBrick(love.mouse.getPosition())
    end
      --gere le menu des skin
  elseif (not(choose)) then
    creerBrique()
            --choisi dans le menu
      if (key =="return") then
        choose = true
      end
      if (key == ("right")) then
        skinx = (skinx + 1)%3
      end
      if (key == ("left")) then
        skinx = (skinx - 1)%3
      end
      if (key == ("down")) then
        skiny = (skiny + 1)%2
      end
      if (key == ("up")) then
        skiny = (skiny - 1)%2
      end
    elseif (not(choose2)) then
        if (key == ("up")) then
          jy = (jy - 1)%2
        end
        if (key == ("down")) then
          jy = (jy + 1)%2
        end
        if (key == ("return")) then
          choose2 = true
          joueur2 = jy
        end
      elseif (not(choose3)) then
          if (key =="return") then
            choose3 = true
          end
          if (key == ("right")) then
            skinx = (skinx + 1)%3
          end
          if (key == ("left")) then
            skinx = (skinx - 1)%3
          end
          if (key == ("down")) then
            skiny = (skiny + 1)%2
          end
          if (key == ("up")) then
            skiny = (skiny - 1)%2
          end
        else
        if (key == "space") then 
            shoot = true
          end
      end
    if (perdu) or (gagner) then
      if (key == "r") then
        love.load()
      end
    end
end
  --remet la balle en jeu au centre de la raquette
function resetBall(balle,raquette)
  balle.x,balle.y = raquette.x + (raquette.width)/2 , raquette.y - balle.rayon - raquette.espace
  shoot = false
end

    --creation des briques de jeu
function creerBrique()
  local tiledmap = require("niveau"..brique.lvl)
  if brique.mode == 1 then
    brique.map = tiledmap.layers[1].data
  end
  if brique.mode == 2 then
    brique.map = brique.craftmode
  end
  brique.data = tiledmap
  --brique.map = tiledmap.layers[1].data
  brique.width = image.briqueRouge:getWidth()
  brique.height = image.briqueRouge:getHeight()
  brique.nombre = 0
      --compte le nombre de brique dans une map
    for i=1,brique.data.height do
      for j=1,brique.data.width do
        if brique.map[((i-1)*brique.data.width + j)] ~= 0 then
          brique.nombre = brique.nombre + 1
        end
      end
    end
  brique.width = image.briqueRouge:getWidth()
  brique.height = image.briqueRouge:getHeight()
      --creation d'une matrice 3D pour que chaque brique contient des info,coordonné + vie (pour l'instant)...
  for l = 1,brique.data.height do
    brique[l] = {}
    for c = 1,brique.data.width do
        brique[l][c] = {}
        brique[l][c].x = (brique.width*(c-1))
        brique[l][c].y = (brique.height*l) 
        brique[l][c].vie = 0
      if brique.map[((l-1)*brique.data.width + c)] ~= 0 then
        brique[l][c].vie = 1
      end
    end
  end
end
    --creer et stock les boule de feu du dragon
function shoots(dragon)
  local shoot = {}
  shoot.x = (largeur/2)
  shoot.y = (dragon.image:getHeight()/4)
  shoot.sens = math.cos(math.pi - ((math.pi/largeur-40)*math.random(40,largeur-40)))
  table.insert(dragon.shoots,shoot)
  dragon.nbshoot = dragon.nbshoot + 1
end
    --gere le craftmode
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
      if (brique.craftmode[(l-1)*17 + c] ~= 0) then
        love.graphics.draw(brique.images[brique.craftmode[(l-1)*17 + c]],(48*c)-48,(23*l)-23)
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
  love.graphics.print("left-click to select and put : right-click to erase\n        press \"enter\" to test your creation",160,400,0,2,2)
    
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
      brique.craftmode[(l-1)*17 + c] = brique.stockchoix
    end
        --efface les brique selectionné dans la map
    if (love.mouse.isDown(2)) then
      brique.craftmode[(l-1)*17 + c] = 0
    end
  end
end