extends Node2D

#ref to boundaries
onready var boundaries = get_node("/root/Game/Boundaries")

enum GroundType {
	NONE,
	GROUND,
	MY_INK,
	THEIR_INK
}

#ink square data
onready var inkImages = [
		0, #none
		preload("ink_grid.png"), #"ground" image
		preload("ink_temp.png"), #ink image
		preload("ink_enemy_temp.png") #enemy ink image
	]
var inkSquareSize = 8

#grid for all ink data
var inkGrid = [[]]
var inkGridWidth = 0
var inkGridHeight = 0

#mouse painting data
var mousePaintingAllowed = false
var brushsize = 3
var painting = false
var lastMousePosition = Vector2()

func _ready():
	if boundaries != null:
		var width = 0
		var height = 0
		var concaveShape = boundaries.get_node("CollisionPolygon2D").polygon
		for point in concaveShape:
			if point.x > width:
				width = point.x
			if point.y > height:
				height = point.y
		
		position = boundaries.position
		inkGridWidth = width/inkSquareSize
		inkGridHeight = height/inkSquareSize
	
	#set up grid
	inkGrid.resize( inkGridHeight ) # make the ink grid columns 100 high
	for i in inkGridHeight:
		inkGrid[i] = []
		inkGrid[i].resize( inkGridWidth ) #make the ink grid rows 100 wide
		for j in inkGridWidth:
			inkGrid[i][j] = GroundType.GROUND
	
	#testing stuff
	#inkSplat( GroundType.MyInk, Vector2(32, 32), 2)

func _input(event):
	if mousePaintingAllowed:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				painting = event.pressed
			if event.button_index == BUTTON_RIGHT:
				inkSplat( GroundType.MyInk, Vector2(3, 3), 1)
		if event is InputEventMouse:
			lastMousePosition = event.global_position
			if painting:
				var inkArrayPos
				if brushsize > 1:
					for c in brushsize:
						for r in brushsize:
							paintPosition( GroundType.MyInk, event.global_position + Vector2(c * inkImages[1].get_width(), r * inkImages[1].get_height()) )
							#inkArrayPos = positionToInkArrayIndex( event.global_position + Vector2(c * inkImage.get_width(), r * inkImage.get_height()) )
							#inkGrid[inkArrayPos.y][inkArrayPos.x] = GroundType.MyInk
				else:
					paintPosition( GroundType.MyInk, event.global_position )
					#inkArrayPos = positionToInkArrayIndex( event.global_position )
					#inkGrid[inkArrayPos.y][inkArrayPos.x] = GroundType.MyInk
			update()


#returns a index positions for the world position's indexes in the array
func positionToInkArrayIndex(position):
	var newPos = position - global_position
	newPos /= inkSquareSize
	newPos = newPos.floor()
	
	if newPos.y < 0 or newPos.y > inkGrid.size() - 1:
		return Vector2(0, 0)
	if newPos.x < 0 or newPos.x > inkGrid[newPos.y].size() - 1:
		return Vector2(0, 0)
	#print("Pos in Ink array is X: "+String(newPos.x)+" Y:"+String(newPos.y))
	return newPos 


func snapPositionToGrid(position):
	var newPos = position - global_position
	newPos /= inkSquareSize
	return newPos.floor() * inkSquareSize


func getGroundTypeByIndex(var x, var y):
	return inkGrid[y][x]


func getGroundTypeAtPosition(position):
	var index = positionToInkArrayIndex( position )
	return getGroundTypeByIndex( index.x, index.y )


func checkForSurroundedCell(x, y, inkType):
	#check each surrounding cell for ink
	#left
	if not getGroundTypeByIndex(x - 1, y) == inkType:
		return false
	#right
	if not getGroundTypeByIndex(x + 1, y) == inkType:
		return false
	#top
	if not getGroundTypeByIndex(x, y - 1) == inkType:
		return false
	#bottom
	if not getGroundTypeByIndex(x, y + 1) == inkType:
		return false
	#return true if not surrounded
	return true


func _draw():
	var r = 0
	var c = 0

	for row in inkGrid:
		for inkSquareNum in row:
			if inkSquareNum > 0:
				draw_texture( inkImages[inkSquareNum], Vector2(c * inkImages[1].get_width(), r * inkImages[1].get_height()) )
			c += 1
		c = 0
		r += 1
	#draw_rect( Rect2( 0, 0, 8, 8), Color( 1, 1, 1))
	if mousePaintingAllowed:
		var snapPos = snapPositionToGrid( lastMousePosition )
		if brushsize > 1:
			draw_rect( Rect2( snapPos - Vector2(1, 1), Vector2((inkSquareSize * brushsize) + 2, (inkSquareSize * brushsize) + 2)), Color(0, 0, 0) )
			for bc in brushsize:
				for br in brushsize:
					draw_texture( inkImages[1], snapPos + Vector2(inkSquareSize * br, inkSquareSize * bc))
		else:
			draw_rect( Rect2( snapPos - Vector2(1, 1), Vector2((inkSquareSize * brushsize) + 2, (inkSquareSize * brushsize) + 2)), Color(0, 0, 0) )
			draw_texture( inkImages[1], snapPos )

func paintPosition(groundType, target_position):
	var index = positionToInkArrayIndex(target_position)
	inkGrid[index.y][index.x] = groundType
	update()

func inkSplat(groundType, center_position, radius):
	#print('painting ground starting at: '+String(center_position))
	paintPosition( groundType, center_position)

	var inbetween = radius
	for i in radius + 1: #we paint in four directions
		#down
		var paint_position = center_position + (dir.down * (i + 1) * inkSquareSize)
		#print('painting ground: '+String(paint_position))
		paintPosition( groundType, paint_position )
		
		for j in inbetween:
			var inbetween_pos = paint_position
			inbetween_pos += dir.left * (j + 1) * inkSquareSize
			paintPosition( groundType, inbetween_pos)
		
		#up
		paint_position = center_position + (dir.up * (i + 1) * inkSquareSize)
		#print('painting ground: '+String(paint_position))
		paintPosition( groundType, paint_position )
		
		for j in inbetween:
			var inbetween_pos = paint_position
			inbetween_pos += dir.right * (j + 1) * inkSquareSize
			paintPosition( groundType, inbetween_pos)
		
		#right
		paint_position = center_position + (dir.right * (i + 1) * inkSquareSize)
		#print('painting ground: '+String(paint_position))
		paintPosition( groundType, paint_position )
		
		for j in inbetween:
			var inbetween_pos = paint_position
			inbetween_pos += dir.down * (j + 1) * inkSquareSize
			paintPosition( groundType, inbetween_pos)
		
		#left
		paint_position = center_position + (dir.left * (i + 1) * inkSquareSize)
		#print('painting ground: '+String(paint_position))
		paintPosition( groundType, paint_position )
		
		for j in inbetween:
			var inbetween_pos = paint_position
			inbetween_pos += dir.up * (j + 1) * inkSquareSize
			paintPosition( groundType, inbetween_pos)
		
		inbetween -= 1
	#right before the end of the function, check for surrounds starting from the top left corner
	"""
	var originIndex = positionToInkArrayIndex( center_position + (Vector2(-1, -1) * inkSquareSize * (radius + 1)))
	print('checking top left index at '+String(originIndex))
	var lastSpaceTypes = [GroundType.None, GroundType.None]
	for j in (radius * 2)+1:
		lastSpaceTypes[0] = inkGrid[originIndex.x - 2][originIndex.y + j]
		lastSpaceTypes[1] = inkGrid[originIndex.x - 1][originIndex.y + j]
		for i in (radius * 2)+1:
			print('checking space '+String(originIndex + Vector2(i, j)))
			if (lastSpaceTypes[0] == groundType or lastSpaceTypes[0] == GroundType.None) and lastSpaceTypes[1] == GroundType.Ground and inkGrid[originIndex.x + i][originIndex.y + j] == groundType:
				if checkForSurroundedCell(originIndex.x + i - 1, originIndex.y + j - 1, groundType):
					print('surrounded space at '+String(Vector2(i, j)))
					paintPosition( groundType, Vector2((originIndex.x + i - 1) * inkSquareSize, (originIndex.y + j - 1) * inkSquareSize))
			#clear values and move on
			lastSpaceTypes.pop_front()
			lastSpaceTypes.append(inkGrid[originIndex.x + i][ originIndex.y +j])
	"""
