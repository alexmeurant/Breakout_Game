love.window.setTitle("Breakout")

-------------------------------------------------------------------------

-- Création d'un joueur
player = {}

-- Création d'une raquette qui sera manipulée par le joueur
local pad = {}
pad.x = 0
pad.y = 0
pad.largeur = 80
pad.hauteur = 20
pad.vx = 10

-- Création d'une balle
local balle = {}
balle.x = 0
balle.y = 0
balle.colle = false
balle.vx = 0
balle.vy = 0
balle.radius = 0
balle.acceleration = 1.03

-- Création d'une brique
local brique = {}
brique.largeur = 0
brique.hauteur = 0

-- Création d'un niveau
local niveau = {}
niveau.briques = {}

-- On réinitialise le jeu à chaque nouvelle partie
function newGame()
  
  -- On vide le niveau de ses briques
  niveau = {}
  
  -- La balle est positionnée sur la raquette en début de partie
  balle.colle = true
  
  -- On repère les briques par une grille
  local l,c
  for l=1,8 do
    niveau[l] = {}
    for c=1,15 do
      niveau[l][c] = 1
    end
  end
  
  -- Initialisation des paramètres du joueur
  player.score = 0
  player.life = 3

end


function demarre()
  
  -- La balle est positionnée sur la raquette à chaque balle perdue
  balle.colle = true
  
end

function love.load()

  -- Récupération des dimensiosn de la fenêtre de jeu
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  
  -- Ajout d'un fond d'écran
  background = love.graphics.newImage("images/space_bg.png")
  
  -- Ajout du pad
  padImage = love.graphics.newImage("images/pad.png")
  pad.largeur = padImage:getWidth()
  pad.hauteur = padImage:getHeight()
  
  -- Ajout de la balle
  balleImage = love.graphics.newImage("images/balle.png")
  balle.x = balleImage:getWidth()/2
  balle.y = balleImage:getHeight()/2
  balle.radius = balleImage:getWidth()/2
  
  -- On charge l'image d'une brique et on définit ses dimensions en fonction de la fenêtre
  crystal = love.graphics.newImage("images/crystal.png")
  brique.largeur = largeur/15
  brique.hauteur = crystal:getHeight()
  
  -- Positionne la raquette en bas d'écran (mouvements droite et gauche uniquement)
  pad.y = hauteur - 40
  pad.x = largeur/2
  
  -- On démarre une nouvelle partie
  newGame()
  
  -- Musique d'ambiance et effet sonore
  explosion = love.audio.newSource("sounds/fun_explosion.wav", "stream")
  music = love.audio.newSource('sounds/big_blue.mp3', 'stream')
  music:setLooping( true ) -- La musique ne s'arrête pas
  music:play()
  
end

function love.update(dt)
  
    -- Le joueur lance la balle
  if player.life > 0 and love.keyboard.isDown("space") then
    if balle.colle == true then
      launchBall()
    end
  end

  -- On dirige la raquette avec les flèches
  if love.keyboard.isDown("right") then
      pad.x = pad.x + pad.vx
  elseif love.keyboard.isDown("left") then
      pad.x = pad.x - pad.vx
  end
  
  -- On ajuste les limites de mouvements de la raquette pour éviter les collapses sur les bords de la map
  if pad.x <= pad.largeur/2 then
    pad.x = pad.largeur/2
  elseif pad.x >= largeur - pad.largeur/2 then
    pad.x = largeur - pad.largeur/2
  end
  
  -- On positionne la balle sur la raquette lors du démarrage
  if balle.colle == true then
    balle.x = pad.x
    balle.y = pad.y - balle.radius*2
  else 
    balle.x = balle.x + balle.vx*dt
    balle.y = balle.y + balle.vy*dt
  end
  
  -- On repère la balle dans un quadrillage en lignes et en colonnes
  local c = math.floor(balle.x / brique.largeur) + 1
  local l = math.floor(balle.y / brique.hauteur) + 1
  
  -- On vérifie si la balle touche une brique
  if l >= 1 and l <= #niveau and c >= 1 and c <= 15 then
    if niveau[l][c] == 1 then
      explosion:play() -- Effet sonore de la brique qui explose
      niveau[l][c] = 0 -- La brique touchée disparait
      balle.vy = -balle.vy -- La balle rebondit
      balle.vy = balle.vy*balle.acceleration -- La balle accélère à chaque brique cassée
      player.score = player.score + 50 
    end
  end
  
  -- Gestion de la collision entre la balle et les murs
  if balle.x >= largeur - balle.radius - 2 then
    balle.vx = -balle.vx
  elseif balle.x <= balle.radius + 2 then
    balle.vx = -balle.vx
  elseif balle.y <= balle.radius + 1 then
    balle.vy = -balle.vy
  end
  
  -- Gestion de la collision entre la balle et la raquette
  if balle.x >= (pad.x - pad.largeur/2 - 1) and balle.x <= (pad.x + pad.largeur/2 + 1) and balle.y >= (pad.y - pad.hauteur/2 - balle.radius + 1) then
    if balle.y >= pad.y - pad.hauteur/2 then
      balle.vx = -balle.vx
    else
      balle.vy = -balle.vy
    end
  end
  
  -- On repositionne la balle sur la raquette si elle disparait
  if balle.y >= hauteur then
    player.life = player.life - 1 -- Le joueur perd une vie si la balle disparait
    if player.life > 0 then
      demarre()
    else
      player.life = 0
      if love.keyboard.isDown("space") then
        balle.x = pad.x
        balle.y = pad.y - pad.hauteur/2 - balle.radius
        newGame()
      end
    end
  end
  
end


function love.draw()
  
  -- Affiche le fond d'écran
  love.graphics.draw(background, 0, 0)
  
  -- Affiche le score et les vies
  local afficheScore = "Score : "
  afficheScore = afficheScore..tostring(player.score)
  love.graphics.print(afficheScore, 5, hauteur - 25)
  
  local afficheVies = "Life : "
  afficheVies = afficheVies..tostring(player.life)
  love.graphics.print(afficheVies, largeur - 50, hauteur - 25)
  
  if balle.colle and player.life > 0 then
    love.graphics.print("Please click on SPACE to launch the ball", largeur/3, hauteur/2)
  end
  
  if player.life <= 0 then
    love.graphics.print("You lose ! To play again, please click on SPACE button", largeur/3, hauteur/2)
  end
  
  -- Dessine les briques
  local l,c
  local bx,by = 0,0 -- Coordonnées de la 1ère brique
  for l=1,8 do
    bx = 0 -- On revient au départ entre chaque ligne
    for c=1,15 do
      if niveau[l][c] == 1 then 
        -- Affiche une brique
        love.graphics.draw(crystal, bx + 2, by + 2)
      end
      bx = bx + brique.largeur -- On décale chaque brique d'une largeur de brique
    end
    by = by + brique.hauteur + 1 -- On décale la ligne d'une hauteur de brique + 1px
  end
  
  -- Affiche la raquette
  love.graphics.draw(padImage, pad.x - (pad.largeur/2), pad.y - (pad.hauteur/2))
  
  -- Affiche une balle
  love.graphics.draw(balleImage, balle.x - (balle.radius), balle.y - (balle.radius))
  
end

function launchBall()
    -- On décolle la balle et on lui donne une impulsion
      if balle.colle == true then
        balle.colle = false
        balle.vx = 200
        balle.vy = -200
      end
end
  
  
