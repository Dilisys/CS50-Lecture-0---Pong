Ball = Class{}

function Ball:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	
	--variables for the ball's velocity
	self.dx = math.random(2) == 1 and 100 or -100
	self.dy = math.random(-50, 50)
end

--resets the position of the ball to the middle of the screen and generates a new velocity
function Ball:reset()
	self.x = VIRTUAL_WIDTH / 2 - 2
	self.y = VIRTUAL_HEIGHT / 2 - 2

	self.dx = math.random(2) == 1 and 100 or -100
	self.dy = math.random(-50, 50) --make a better random algorithm here later
end

function Ball:update(dt)
	self.x = self.x + self.dx * dt 
	self.y = self.y + self.dy * dt

	--check the boundary collisions of the ball and make it reverse when it hits the top or bottom

	if self.y < 0 then
		sounds['wall_hit']:play()

		self.y = 0
		self.dy = -self.dy
	end

	if self.y >= VIRTUAL_HEIGHT - 4 then
		sounds['wall_hit']:play()
		
		self.y = VIRTUAL_HEIGHT - 4
		self.dy = -self.dy
	end
end

function Ball:render()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 2, 2)
end

function Ball:collides(paddle)
	if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
		return false
	end

	if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
		return false
	end

	return true
end

function Ball:paddleBounce()
	--bounce the ball off the paddle, keeping the vertical momentum going
	--i.e. if it's going up, it keeps going up, and if it's going down, it keeps going down.
		self.dx = -self.dx * 1.03

		if self.dy < 0  then
			self.dy = -math.random(10, 150)
		else
			self.dy = math.random(10, 150)
		end
end