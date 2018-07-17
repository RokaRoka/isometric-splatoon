extends Node2D

#ink square data
onready var inkImage = get_node( "ResourcePreloader" ).get_resource( "ink_temp")
onready var inkGridImage = get_node( "ResourcePreloader" ).get_resource( "ink_grid")

var inkImages = []

var inkSquareSize = 8

#map area
onready var MapArea2D = get_node("../Map")

#grid for all ink data
var inkGrid = [[]]
var inkGridWidth = 100
var inkGridHeight = 100

#mouse painting data
export (bool) var mousePaintingAllowed = false
export (int) var brushsize = 1
var painting = false
var lastMousePosition = Vector2()

func _ready():
	inkImages = [
		0, #none
		inkGridImage, #"ground" image
		inkImage, #ink image
		0 #enemy ink
	]
	#set up grid
	inkGrid.resize( 100 ) # make the ink grid columns 100 high
	for i in inkGridHeight:
		inkGrid[i] = []
		inkGrid[i].resize( 100 ) #make the ink grid rows 100 wide
		for j in inkGridWidth:
			inkGrid[i][j] = 1

func _input(event):
	if mousePaintingAllowed:
		if event is InputEventMouseButton:
			painting = event.pressed
		if event is InputEventMouse:
			lastMousePosition = event.global_position
			if painting:
				var inkArrayPos
				if brushsize > 1:
					for c in brushsize:
						for r in brushsize:
							inkArrayPos = positionToInkArrayIndex( event.global_position + Vector2(c * inkImage.get_width(), r * inkImage.get_height()) )
							inkGrid[inkArrayPos.y][inkArrayPos.x] = GroundType.MyInk
				else:
					inkArrayPos = positionToInkArrayIndex( event.global_position )
					inkGrid[inkArrayPos.y][inkArrayPos.x] = GroundType.MyInk
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


func _draw():
	var r = 0
	var c = 0

	for row in inkGrid:
		for inkSquareNum in row:
			if inkSquareNum > 0:
				draw_texture( inkImages[inkSquareNum], Vector2(c * inkImage.get_width(), r * inkImage.get_height()) )
			c += 1
		c = 0
		r += 1
	#draw_rect( Rect2( 0, 0, 8, 8), Color( 1, 1, 1))
	if mousePaintingAllowed:
		var snapPos = snapPositionToGrid( lastMousePosition )
		if brushsize > 1:
			draw_rect( Rect2( snapPos - Vector2(1, 1), Vector2((inkSquareSize * brushsize) + 2, (inkSquareSize * brushsize) + 2)), Color(0, 0, 0) )
			for c in brushsize:
				for r in brushsize:
					draw_texture( inkImage, snapPos + Vector2(inkSquareSize * r, inkSquareSize * c))
		else:
			draw_rect( Rect2( snapPos - Vector2(1, 1), Vector2((inkSquareSize * brushsize) + 2, (inkSquareSize * brushsize) + 2)), Color(0, 0, 0) )
			draw_texture( inkImage, snapPos )
