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
balle.radius = 10
balle.colle = false
balle.vx = 0
balle.vy = 0
balle.acceleration = 1.03

-- Création d'une brique
local brique = {}

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
  for l=1,6 do
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
  
  -- On définit les dimensions d'une brique en fonction de la fenêtre
  brique.largeur = largeur/15
  brique.hauteur = 25
  
  -- Positionne la raquette en bas d'écran (mouvements droite et gauche uniquement)
  pad.y = hauteur - pad.hauteur*2
  pad.x = largeur/2
  
  -- On démarre une nouvelle partie
  newGame()
  
  -- Musique d'ambiance et effet sonore
  explosion = love.audio.newSource("sounds/fun_explosion.wav", "stream")
  music = love.audio.newSource('sounds/big_blue.mp3', 'stream')
  music:setLooping( true ) -- La musique ne s'arrête pas
  music:play()
  
  -- Ajout d'un fond d'écran
  background = love.graphics.newImage("images/space_bg.png")
  
end

function love.update(dt)
  
  -- Le joueur lance la balle
  if player.life > 0 and love.keyboard.isDown("space") then
    if balle.colle == true then
      launchBall()
    end
  end

  -- On récupére la position de la sourie que l'on renvoie à la raquette
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
    balle.y = pad.y - pad.hauteur/2 - balle.radius
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
  if balle.x >= largeur - balle.radius then
    balle.vx = -balle.vx
  elseif balle.x <= balle.radius then
    balle.vx = -balle.vx
  elseif balle.y <= balle.radius then
    balle.vy = -balle.vy
  end
  
  -- Gestion de la collision entre la balle et la raquette
  if balle.x >= (pad.x - pad.largeur/2) and balle.x <= (pad.x + pad.largeur/2) and balle.y >= (pad.y - pad.hauteur/2 - balle.radius) then
    balle.vy = -balle.vy
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
  love.graphics.draw(background, -100, 0)
  
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
  for l=1,6 do
    bx = 0 -- On revient au départ entre chaque ligne
    for c=1,15 do
      if niveau[l][c] == 1 then
        -- Dessine une brique
        love.graphics.rectangle("fill", bx + 1, by + 1, brique.largeur - 2, brique.hauteur - 2)
      end
      bx = bx + brique.largeur -- On décale chaque brique d'une largeur de brique
    end
    by = by + brique.hauteur -- On décale la ligne d'une hauteur de brique
  end
  
  -- Dessine la raquette
  love.graphics.rectangle("fill", pad.x - (pad.largeur/2), pad.y - (pad.hauteur/2), pad.largeur, pad.hauteur)
  
  -- Dessine une balle
  love.graphics.circle("fill", balle.x, balle.y, balle.radius)
  
end

function launchBall()
    -- On décolle la balle et on lui donne une impulsion
      if balle.colle == true then
        balle.colle = false
        balle.vx = 200
        balle.vy = -200
      end
end
  
  
