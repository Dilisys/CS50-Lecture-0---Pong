--[[GD50 - Lecture 0 - Pong

Developed by Jan Joseff Genduso
February 2023

]]

--libraries
push = require 'push'
Class = require 'class'

--classes
require 'Ball'
require 'Paddle'

WINDOW_HEIGHT = 720
WINDOW_WIDTH = 1280

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
	--Set default filtering to nearest neighbour, default filtering mode for Love2D is Bilinear
	love.graphics.setDefaultFilter('nearest', 'nearest')

	math.randomseed(os.time())

	--Set the title of the window
	love.window.setTitle('Pong!')

	--Font for the "title"
	smallFont = love.graphics.newFont('font.ttf', 8)

	--font for the scores
	scoreFont = love.graphics.newFont('font.ttf', 78)

	--font for the victory text
	winFont = love.graphics.newFont('font.ttf', 16)

	--set up the sound library here
	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static')
	}

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
		fullscreen = false,
		resizable = true,
		vsync = true
	})


	--initialize starting player scores (which are zero)
	player1score = 0
	player2score = 0

	--initialize the paddles on either end of the screen
	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

	servingplayer = 1

	winningplayer = 0

	--initialize the ball, placing it in the middle of the screen
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	--gamestate variable
	gameState = 'start'
end

function love.resize(w, h)
	push:resize(w, h)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'done' then
			gameState = 'serve'

			ball:reset()

			player1score = 0
			player2score = 0

			if winningplayer == 1 then
				servingplayer = 2
			else
				servingplayer = 1
			end
		end
	end
end

function love.update(dt)
	--player 1 movement
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	--player 2 movement
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

	if gameState == 'serve' then
		--instantiate the math on who's serving here
		ball.dy = math.random(-50, 50)
		if servingplayer == 1 then
			ball.dx = math.random(140, 200)
		elseif servingplayer == 2 then
			ball.dx = -math.random(140, 200)
		end

	--when the game starts, the ball can move
	elseif gameState == 'play' then

		if ball:collides(player1) then
			ball.x = player1.x + 5

			sounds['paddle_hit']:play()
			ball:paddleBounce()
		end

		if ball:collides(player2) then
			ball.x = player2.x - 4

			sounds['paddle_hit']:play()
			ball:paddleBounce()
		end

		--if ball goes left side of the screen, player 2 scores a point
		--also handles the score check, if either player's score is 10, then the game is over
		if ball.x < 0 then
			sounds['score']:play()

			player2score = player2score + 1
			servingplayer = 1

			if player2score == 10 then
				winningplayer = 2
				gameState = 'done'
			else
				ball:reset()
				gameState = 'serve'
			end
		end

		--if ball goes over the right side of the screen, player 1 scores a point
		if ball.x > VIRTUAL_WIDTH then
			sounds['score']:play()

			player1score = player1score + 1
			servingplayer = 2
			
			if player1score == 10 then
				winningplayer = 1
				gameState = 'done'
			else
				ball:reset()
				gameState = 'serve'
			end
		end

		ball:update(dt)
	end

	player1:update(dt)
	player2:update(dt)
end


function love.draw()
	push:apply('start')


	love.graphics.clear(40/255, 45/255, 52/255, 255/255)

	displayscore()

	--set color back to white (previously set the opacity down to make it stylish)
	love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 255))

	if gameState == 'start' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to Start!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'serve' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Player ' .. tostring(servingplayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to Serve!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'play' then
		--nothing happens
	elseif gameState == 'done' then
		love.graphics.setFont(winFont)
		love.graphics.setColor(0, 1, 0, 1)
		love.graphics.printf('Player ' .. tostring(winningplayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
		
		love.graphics.setFont(smallFont)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf('Press Enter to Begin New Game!', 0, 30, VIRTUAL_WIDTH, 'center')
	end

	--render player 1 (left side)
	player1:render()
	
	--render player 2 (right side)
	player2:render()

	--render ball
	ball:render()

	displayFPS()

	push:apply('end')
end

function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(love.math.colorFromBytes(0, 255, 0))
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayscore()
	--Prints the score of the players
	love.graphics.setFont(scoreFont)
	love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 50))
	love.graphics.print(tostring(player1score), VIRTUAL_WIDTH / 3 - 30, VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(player2score), VIRTUAL_WIDTH * 0.66, VIRTUAL_HEIGHT / 3)
end