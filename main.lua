love.window.setTitle("Breakout")

-------------------------------------------------------------------------

-- Création d'une raquette qui sera manipulée par le joueur
local pad = {}
pad.x = 0
pad.y = 0
pad.largeur = 80
pad.hauteur = 20

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

-- On positionne la balle sur la raquette à chaque démarrage
function demarre()
  
  balle.colle = true
  
  -- On vide le niveau de ses briques et on affiche toutes les briques lors du démarrage
  niveau = {}
  
  local l,c
  for l=1,6 do
    niveau[l] = {}
    for c=1,15 do
      niveau[l][c] = 1
    end
  end
end

function love.load()

  -- Récupération des dimensiosn de la fenêtre de jeu
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  
  -- On définit les dimensions d'une brique en fonction de la fenêtre
  brique.largeur = largeur/15
  brique.hauteur = 25
  
  -- Positionne la raquette en bas d'écran (mouvements droite et gauche uniquement)
  pad.y = hauteur - (pad.hauteur/2)
  pad.x = largeur/2
  
  -- Positionne la balle lors du chargement du jeu
  demarre()
  
  -- Musique d'ambiance et effet sonore
  explosion = love.audio.newSource("sounds/fun_explosion.wav", "stream")
  music = love.audio.newSource('sounds/big_blue.mp3', 'stream')
  music:setLooping( true ) -- La musique ne s'arrête pas
  music:play()
  
  -- Ajout d'un fond d'écran
  background = love.graphics.newImage("images/space_bg.png")
  
end

function love.update(dt)

  -- On récupére la position de la sourie que l'on renvoie à la raquette
  pad.x = love.mouse.getX()
  
  -- On ajuste les limites de mouvements de la raquette pour éviter les collapses sur les bords de la map
  if pad.x <= pad.largeur/2 then
    pad.x = pad.largeur/2
  elseif pad.x >= largeur - pad.largeur/2 then
    pad.x = largeur - pad.largeur/2
  end
  
  -- On positionne la balle sur la raquette lors du démarrage et la balle est lancée si on clique sur un bouton de la souris
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
  
  -- On modifie l'angle de rebond sur la rquette selon la zone d'impact
  if balle.x >= (pad.x - pad.largeur/2) and balle.x <= (pad.x - pad.largeur/4) and balle.y >= (pad.y - pad.hauteur/2 - balle.radius) then
    balle.vy = -balle.vy
  end
  
  -- On repositionne la balle sur la raquette si elle disparait
  if balle.y >= hauteur - balle.radius then
    demarre()
  end
  
end


function love.draw()
  
  -- Affiche le fond d'écran
  love.graphics.draw(background, -100, 0)
  
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

function love.mousepressed(x, y, n)
    -- On décolle la balle et on lui donne une impulsion
    if balle.colle == true then
      balle.colle = false
      balle.vx = 200
      balle.vy = -200
    end
end
  
  
