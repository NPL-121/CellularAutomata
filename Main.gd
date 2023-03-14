extends Node2D

var mode = 0 #draw method (0 - TileSet, 1 - canvas draw)
var mode_old = 2

var dim = 2 # dimension/ Default = 2
var dim_old = 0

var RuleInd_1D = 0 #rule selected

onready var Map = $TileMap
onready var Camera = $Camera2D

var centerCamPos = Vector2(0,0)

var num = 100 # resolution
var num_old = 0
var arr_rect = []
var emptyArr = 0 #for empty array must be 1

#for function NumLiveCells
var x
var y

#info var
var genNum = 0

#for canvas draw method
var sizeCell = 32
var rectSize = Vector2(sizeCell, sizeCell)
var rectColorTrue = Color(1,1,1)
var rectColorFalse = Color(0,0,0)

#==========================
# for GUI
#--------------------------
onready var Conteiner = $Container
onready var But1 = $CanvasLayer/Control/Button
onready var But2 = $CanvasLayer/Control/Button2
onready var labGen = $CanvasLayer/Control/Label
onready var But3 = $CanvasLayer/Control/Button3
onready var But4 = $CanvasLayer/Control/Button4
onready var Spin1 = $CanvasLayer/Control/SpinBox
onready var optionBut = $CanvasLayer/Control/OptionButton
onready var Spin2 = $CanvasLayer/Control/SpinBox2
onready var optionBut2 = $CanvasLayer/Control/OptionButton2
onready var Cam = $Camera2D
#----------------------------

var startOn = 0 #for start simulation must be 1


func GUI_process():
	
	if dim == 1:
		RuleInd_1D = optionBut2.selected
	
	if But1.pressed: #start
		startOn = 1
		Spin1.editable = false
		optionBut.disabled = true
		Spin2.editable = false
		num = int(Spin1.value)
	if But2.pressed: #stop
		startOn = 0
		Spin1.editable = true
		optionBut.disabled = false
		Spin2.editable = true
	if But3.pressed: # New random
		genNum = 0
		startOn = 0
		emptyArr = 0
		OnReady()
	if But4.pressed: # New empty
		genNum = 0
		startOn = 0
		emptyArr = 1
		OnReady()
	
	mode = optionBut.selected
	if mode != mode_old:
		OnReady()
	mode_old = mode
	
	dim = Spin2.value
	if dim != dim_old:
		OnReady()
		genNum = 0
	dim_old = dim
	
	#num = int(Spin1.value)
	if num != num_old:
		OnReady()
		genNum = 0
	num_old = num

	#print(optionBut.selected)
	
	labGen.text = "Generation: " + str(genNum)
	
	var posMouse = get_global_mouse_position()
	#var butMouse = BUTTON_LEFT
	if Cam.if_click_left == true:
		if (posMouse.x >= 0 && posMouse.y >= 0 && floor(posMouse.x/32) < num && floor(posMouse.y/32) < num):
			arr_rect[abs(floor(posMouse.x/32))][abs(floor(posMouse.y/32))] = 1
			print(floor(posMouse.x/32), ", ",floor(posMouse.y/32))
	if Cam.if_click_right == true:
		if (posMouse.x >= 0 && posMouse.y >= 0 && floor(posMouse.x/32) < num && floor(posMouse.y/32) < num):
			arr_rect[abs(floor(posMouse.x/32))][abs(floor(posMouse.y/32))] = 0
			print(floor(posMouse.x/32), ", ",floor(posMouse.y/32))

func OnReady():
	if dim == 2:
		optionBut2.clear()
		optionBut2.add_item("Conway's Game of Life")
	elif dim == 1:
		optionBut2.clear()
		optionBut2.add_item("Rule 30")
		optionBut2.add_item("Rule 110")
		optionBut2.add_item("Rule 90")
		optionBut2.add_item("Rule 184")
		optionBut2.select(RuleInd_1D)
	
	#get resolution - num value
	num = int(Spin1.value)
	#calc coordinate center of field
	var cX = num*32*0.5
	var cY = num*32*0.5
	centerCamPos = Vector2(cX, cY)
	#camera set
	Camera.set_position(centerCamPos)
	Camera.zoom = Vector2(num/18.0, num/18.0)
	#setting cellular world
	randomize()
	if dim == 2:
		for i in range(0, num):
			arr_rect.append([])
			for j in range(0, num):
				arr_rect[i].append(0)
		for i in range(0, num):
			for j in range(0, num):
				if emptyArr == 0:
					if randf() < 0.5:
						arr_rect[i][j] = 0
					else:
						arr_rect[i][j] = 1
				else:
					arr_rect[i][j] = 0
	elif dim == 1:
		for i in range(0, num): #clear field
			arr_rect.append([])
			for j in range(0, num):
				arr_rect[i].append(0)
				arr_rect[i][j] = 0
				
		for i in range(0, num):
			arr_rect.append([])
			for j in range(0, num):
				arr_rect[i].append(0)
		for i in range(0, num):
			if emptyArr == 0:
				if randf() < 0.5:
					arr_rect[i][0] = 0
				else:
					arr_rect[i][0] = 1
			else:
				arr_rect[i][0] = 0		
	Map.clear()

func _ready():	
	OnReady()
	set_process(true)

#Calc neighbor Moor's 2D
func NumLiveCells(x,y):
	var count = 0
	var col = 0
	var row = 0
	for i in range (-1, 2, 1):
		for j in range (-1, 2, 1):
			col = (x + i + num) % num
			row = (y + j + num) % num
			#print("Iteration ", i, " : ", j)
			#print(y, " + ", j, " + ", num, " = ", row)
			var selfChecking = 0
			if col == x && row == y:
				selfChecking = 1
				#print ("SELF CHECKING")
			var hasLife = arr_rect[col][row]
			#print(hasLife)
			if hasLife == 1 && selfChecking == 0:
				count = count + 1
				#print("count inc")
	return count

# New generation
func Iteration(delta):
	#yield(get_tree().create_timer(30*delta), "timeout")
	var arr_rectNew = []
	for i in range(0, num):
		arr_rectNew.append([])
		for j in range(0, num):
			arr_rectNew[i].append(0);
			var hasLife = 0
			var countNeighbor = 0
			countNeighbor = NumLiveCells(i,j)
			hasLife = arr_rect[i][j]
			if hasLife == 0 && countNeighbor == 3:
				#print("New cell!")
				arr_rectNew[i][j] = 1
			elif hasLife == 1 && (countNeighbor < 2 || countNeighbor > 3):
				arr_rectNew[i][j] = 0 
			else:
				arr_rectNew[i][j] = arr_rect[i][j]
		
	for k in range(0, num):
		for m in range (0, num):
			arr_rect[k][m] = arr_rectNew[k][m]
	genNum = genNum + 1
		
func Iteration_1D_110(delta): #for One-dimension cellular automat rule 110
	var arr_rectNew = []
	#var hasLife = 0
	for i in range(0, num):
		arr_rectNew.append(0)
		#print((i+num)%num)
		#arr_rect[(i+1+num)%num] == 1
		if arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 0
	
	for k in range(0, num):
		arr_rect[k][genNum+1] = arr_rectNew[k]

	genNum = genNum + 1
	
func Iteration_1D_30(delta): #for One-dimension cellular automat rule 30
	var arr_rectNew = []
	for i in range(0, num):
		arr_rectNew.append(0)
		if arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 0
			
	for k in range(0, num):
		arr_rect[k][genNum+1] = arr_rectNew[k]

	genNum = genNum + 1

func Iteration_1D_90(delta): #for One-dimension cellular automat rule 90
	var arr_rectNew = []
	for i in range(0, num):
		arr_rectNew.append(0)
		if arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 0
			
	for k in range(0, num):
		arr_rect[k][genNum+1] = arr_rectNew[k]

	genNum = genNum + 1
	
func Iteration_1D_184(delta): #for One-dimension cellular automat rule 184
	var arr_rectNew = []
	for i in range(0, num):
		arr_rectNew.append(0)
		if arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 1 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 1
		elif arr_rect[i][genNum] == 1 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 1:
			arr_rectNew[i] = 0
		elif arr_rect[i][genNum] == 0 && arr_rect[(i-1+num)%num][genNum] == 0 && arr_rect[(i+1+num)%num][genNum] == 0:
			arr_rectNew[i] = 0
			
	for k in range(0, num):
		arr_rect[k][genNum+1] = arr_rectNew[k]

	genNum = genNum + 1

func Grid(num, delta):
	if Spin2.value == 2: # 2D
		if mode == 0: #TileSet draw method
			for i in range(0, num):
				for j in range(0, num):
					if arr_rect[i][j] == 0:
						Map.set_cell(i,j,0)
					else:
						Map.set_cell(i,j,2)
		if mode == 1: #canvas draw method
			pass
	elif Spin2.value == 1: # 1D
		if mode == 0: #TileSet draw method
			for i in range(0, num):
				for j in range(0, genNum+1):
					#print(j)
					if arr_rect[i][j] == 0:
						Map.set_cell(i,j,0)
					else:
						Map.set_cell(i,j,2)
		if mode == 1: #canvas draw method
			pass
			
	if startOn == 1:
		if Spin2.value == 2:
			Iteration(delta)
		elif Spin2.value == 1:
			if optionBut2.text == "Rule 30":
				Iteration_1D_30(delta)
			if optionBut2.text == "Rule 110":
				Iteration_1D_110(delta)
			if optionBut2.text == "Rule 90":
				Iteration_1D_90(delta)
			if optionBut2.text == "Rule 184":
				Iteration_1D_184(delta)
		
func _draw():
	if mode == 1: #canvas draw method	
		for i in range(0, num):
			for j in range(0, num):
				if arr_rect[i][j] == 0:
					draw_rect(Rect2(Vector2(sizeCell*i, sizeCell*j),  rectSize), rectColorFalse)
				else:
					draw_rect(Rect2(Vector2(sizeCell*i, sizeCell*j),  rectSize), rectColorTrue)

func _process(delta):
	
	Grid(num, delta)
	GUI_process()
	update()
