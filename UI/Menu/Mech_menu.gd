extends KinematicBody2D



export (float) var speed := 25000.0
export (float) var limb_movement_speed := 250.0 #<- CIEKAWY BUG PRZY NISKICH WARTOSCIACH priorytet ruchu wymaga poprawki
#rozw dla problemu pryiorytetu - porusza sie konczyna dalej od celu
var limb_distance_threshold := 50.0
#NOTE TO SELF - dodac wydluzenie sie celu w kierunku ruchu (wyjascione w pliku ruch_koncept_1)
#NOTE TO SELF - zmniejszyc treshold gdy robot sie zatrzymal

#KONCZYNY ZORGANIZOWANE PARAMI W KOLEJNOSCI PRAWA, LEWA, LEWA, PRAWA, OD PRZODU DO TYLU
#WYMAGANE USPRAWNIENIE: ^^ zmienic kolejnosc na prawa, lewa, prawa, lewa
#NOTATKA: PROGRAM DZIALA NA RAZIE TYLKO DLA PAZYSTEJ ILOSCI KONCZYN
var limb_positions = [] #gdzie konczyny sa teraz
var limb_targets = [] #refka do pozycji gdzie konczyny pojda w nastemnym kroku
var limbs_moving_to = [] #gdzie konczyny ido w tym kroku
var limbs = [] #refka do konczyn
var limb_moving = [] #ktore konczyny rabia krok i o jaki dystans (konczyna statyczna <=> wart < 0)
var limb_movement_midpoints = [] #punkt w pol drogi od startu ruchu do konca
#The missile knows where it is at all times...
var max_dst_ix

export (float) var frequency := 2.0# = 1
export (float) var dampening := 0.5# = 0.75
export (float) var anticipation := 2# = 0
var proc_anim : Procedural_Animator

export (bool) var testing_movement = false

func _ready():
	proc_anim = Procedural_Animator.new(frequency, dampening, anticipation, position) #queue free
	#NOTE: global pos moze sporo popsuc
	
	limbs.append($FR_Konczyna)
	limbs.append($FL_Konczyna)
	limbs.append($BR_Konczyna)
	limbs.append($BL_Konczyna)
	
	limb_targets = $LimbTargets.get_children()
	
	for limb in limbs:
		limb_positions.append(limb.global_position)
		limbs_moving_to.append(limb.global_position)
		limb_movement_midpoints.append(Vector2.ZERO)
	
	for i in 4:
		limb_moving.append(-1.0)


func _process(delta):
	pass

	leg_movement(delta)
	var maxdst = 0
	for i in limbs.size():
		break
		if limb_positions[i].distance_squared_to(limb_targets[i].global_position)>=pow(limb_distance_threshold, 2):
			#^^ jesli konczyna poza tresholdem NOTKA: mozna zamienic kolejnosc i poruszyc konczyna w tej samej klatce
			var other_limb_index_X #znajdz druga konczyne
			var other_limb_index_Y
			#NOTATKA: PROGRAM DZIALA NA RAZIE TYLKO DLA PAZYSTEJ ILOSCI KONCZYN
			if i%2 == 1:
				other_limb_index_X = i-1
			else:
				other_limb_index_X = i+1
			
			if i<2: #<- TYMCZASOWE ROZWIAZANIE
				other_limb_index_Y = i + 2
			else:
				other_limb_index_Y = i - 2
			
			if limb_moving[other_limb_index_X] <= 0 && limb_moving[other_limb_index_Y] <= 0: 
				#^^ czy sasiednia konczyna na ziemi
				limbs_moving_to[i] = limb_targets[i].global_position
				limb_moving[i] = abs(limb_positions[i].distance_to(limb_targets[i].global_position))
				#^^ miejsce na optymalizacje
				limb_movement_midpoints[i] = lerp(limb_positions[i], limb_targets[i].global_position, 0.5)
		
		limbs[i].global_position = limb_positions[i]

func limb_scale(limb_index):
	var scale_squared = 0
	if limb_moving[limb_index] > 0:
		var dist_to_mid = limb_positions[limb_index].distance_to(limb_movement_midpoints[limb_index])
		#mozna zamienic dist_to na dist_to^2 a limb_moving w cosinusie na limb_moving^2
		scale_squared = cos(dist_to_mid * PI / limb_moving[limb_index]) + 1
	else:
		scale_squared = 1
	limbs[limb_index].scale = Vector2.ONE * scale_squared

func leg_movement(delta): #WADY - porusza 1 konczyne na klatke (nie sadze ze to problem przy 60 FPS
	for i in limbs.size():
		limb_scale(i)
		limbs[i].look_at(global_position)
		limbs[i].rotate(-PI/2)
		
		if limb_moving[i] > 0: ##SPEED THINGS UP WHEN LONG RANGE
			limb_positions[i]=limb_positions[i].move_toward(limbs_moving_to[i], limb_movement_speed * delta)
			if limb_positions[i] == limbs_moving_to[i]:
				limb_moving[i] = -1
	
	max_dst_ix = 0
	var dest_sq_to
	var max_dest_to = 0
	for i in limbs.size():
		if limb_moving[i] < 0:
			dest_sq_to = limb_positions[i].distance_squared_to(limb_targets[i].global_position)
			if dest_sq_to > max_dest_to:
				max_dst_ix = i
				max_dest_to = limb_positions[i].distance_squared_to(limb_targets[i].global_position)
	if max_dest_to >= pow(limb_distance_threshold, 2):
		if neibhour_limbs_are_stationary(max_dst_ix):
			#^^ czy sasiednia konczyna na ziemi
			limbs_moving_to[max_dst_ix] = limb_targets[max_dst_ix].global_position
			limb_moving[max_dst_ix] = abs(limb_positions[max_dst_ix].distance_to(limb_targets[max_dst_ix].global_position))
			#^^ miejsce na optymalizacje
			limb_movement_midpoints[max_dst_ix] = lerp(limb_positions[max_dst_ix], limb_targets[max_dst_ix].global_position, 0.5)
	for i in limbs.size():
		limbs[i].global_position = limb_positions[i]

func neibhour_limbs_are_stationary(ix):
	var other_limb_index_X
	var other_limb_index_Y
	if ix%2 == 1:
		other_limb_index_X = ix-1
	else:
		other_limb_index_X = ix+1
	if ix<2: #<- TYMCZASOWE ROZWIAZANIE
		other_limb_index_Y = ix + 2
	else:
		other_limb_index_Y = ix - 2
	return limb_moving[other_limb_index_X] <= 0 && limb_moving[other_limb_index_Y] <= 0
