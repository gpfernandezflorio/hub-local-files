## Eventos
## SRC

# Administra el manejo de eventos.
# Requiere para inicializar:
	# -

extends Node

var HUB
var modulo = "EVENTOS"

# Diccionario que guarda, para cada accion, una lista de pares nodo-función registrados para esa acción
var registro_eventos = {} # Dicc(string : [{nodo, función}])
var modo_mouse = 0
var secuencias = [] # Diccionarios con nodo, id, índice, contador y secuencia

func inicializar(hub):
	HUB = hub
	return true

# Registra la función del nodo cuando se mueve el mouse
func registrar_mouse_mov(nodo, funcion):
	# La funcion debe tomar un Vector2 como argumento
	registrar_generico("MM", nodo, funcion)

# Anula la función del nodo cuando se mueve el mouse
func anular_mouse_mov(nodo):
	anular_generico("MM", nodo)

# Registra la función del nodo cuando se presiona un botón
func registrar_press(boton, nodo, funcion):
	# La funcion no debe tomar parámetros
	registrar_generico("P" + str(boton), nodo, funcion)

# Anula la función del nodo cuando se presiona un botón
func anular_press(boton, nodo):
	anular_generico("P" + str(boton), nodo)

# Registra la función del nodo cuando se suelta un botón
func registrar_release(boton, nodo, funcion):
	# La funcion no debe tomar parámetros
	registrar_generico("R" + str(boton), nodo, funcion)

# Anula la función del nodo cuando se suelta un botón
func anular_release(boton, nodo):
	anular_generico("R" + str(boton), nodo)

# Registra la función del nodo cuando cambia la resolución de la pantalla
func registrar_ventana_escalada(nodo, funcion):
	# La funcion debe tomar un Vector2 como parámetro
	registrar_generico("WS", nodo, funcion)

# Anula la función del nodo cuando cambia la resolución de la pantalla
func anular_ventana_escalada(nodo):
	anular_generico("WS", nodo)

# Registra una función periódica en el nodo
func registrar_periodico(nodo, funcion):
	registrar_generico("T", nodo, funcion)

# Anula la función periódica en el nodo
func anular_periodico(nodo):
	anular_generico("T", nodo)

# Asigna el modo del cursor del mouse
func set_modo_mouse(modo=0):
	if HUB.os == "HTML5":
		modo = 0
	modo_mouse = modo
	if not HUB.terminal.activa():
		Input.set_mouse_mode(modo_mouse)

# Funciones auxiliares

func iniciar():
	set_process_input(true)
	set_fixed_process(true)#@2
#	set_physics_process(true)#@3
	return get_tree().get_root().connect("size_changed", self, "ventana_escalada")

func _input(ev):
	if ev.type == InputEvent.MOUSE_MOTION:#@2
#	if ev is InputEventMouseMotion:#@3
		mouse_movido(ev)
	if ev.type == InputEvent.KEY:#@2
#	if ev is InputEventKey:#@3
		if ev.pressed:
			tecla_presionada(ev)
		else:
			tecla_soltada(ev)

func _fixed_process(delta):#@2
#func _physics_process(delta):#@3
	periodico(delta)
	procesar_secuencias(delta)

func registrar_generico(accion, nodo, funcion):
	if registro_eventos.has(accion):
		registro_eventos[accion].append({"nodo":nodo,"funcion":funcion})
	else:
		registro_eventos[accion] = [{"nodo":nodo,"funcion":funcion}]

func anular_generico(accion, nodo):
	var id_referencia = str(nodo)
	if registro_eventos.has(accion):
		for registro in registro_eventos[accion]:
			if str(registro["nodo"]) == id_referencia:
				registro_eventos[accion].erase(registro)
				return

func mouse_movido(ev):
	if registro_eventos.has("MM"):
		var mov = ev.relative_pos#@2
#		var mov = ev.relative#@3
		if HUB.os == "HTML5":
			mov = 2.2*ev.global_pos/HUB.pantalla.resolucion - Vector2(1.1,1.1)
			mov = 10*Vector2(pow(mov.x,9),pow(mov.y,9))
		for registro in registro_eventos["MM"]:
			registro["nodo"].call(registro["funcion"], mov)

func ventana_escalada():
	if registro_eventos.has("WS"):
		for registro in registro_eventos["WS"]:
			var nodo = registro["nodo"]
			if HUB.GC.es_valido(nodo):
				registro["nodo"].call(registro["funcion"], OS.get_window_size())
			else:
				registro_eventos["WS"].erase(registro)

func tecla_presionada(ev):
	var accion = "P"+str(ev.scancode)
	if registro_eventos.has(accion):
		for registro in registro_eventos[accion]:
			var nodo = registro["nodo"]
			if HUB.GC.es_valido(nodo):
				var corresponde = nodo != HUB.terminal.campo_entrada
				if HUB.terminal.activa():
					corresponde = nodo in [HUB, HUB.terminal, HUB.terminal.campo_entrada]
				if corresponde:
					nodo.call(registro["funcion"])
			else:
				registro_eventos[accion].erase(registro)

func tecla_soltada(ev):
	var accion = "R"+str(ev.scancode)
	if registro_eventos.has(accion):
		for registro in registro_eventos[accion]:
			var nodo = registro["nodo"]
			if HUB.GC.es_valido(nodo):
				var corresponde = nodo != HUB.terminal.campo_entrada
				if HUB.terminal.activa():
					corresponde = nodo in [HUB, HUB.terminal, HUB.terminal.campo_entrada]
				if corresponde:
					nodo.call(registro["funcion"])
			else:
				registro_eventos[accion].erase(registro)

func periodico(delta):
	if registro_eventos.has("T"):
		for registro in registro_eventos["T"]:
			var nodo = registro["nodo"]
			if HUB.GC.es_valido(nodo):
				nodo.call(registro["funcion"], delta)
			else:
				registro_eventos["T"].erase(registro)

func registrar_secuencia(nodo, id, secuencia):
	secuencias.append({
		"nodo":nodo,
		"id":id,
		"i":0,
		"contador":0,
		"secuencia":secuencia,
		"esperando":0
	})

func anular_secuencia(nodo, id):
	for sec in secuencias:
		if sec["nodo"] == nodo and sec["id"] == id:
			secuencias.erase(sec)

func procesar_secuencias(delta):
	for sec in secuencias:
		sec["contador"] += delta*1000
		if sec["contador"] > sec["esperando"]:
			sec["contador"] = 0
			avanzar_secuencia(sec)

func avanzar_secuencia(sec):
	var wait = null
	while wait == null:
		wait = ejecutar(sec)
	if wait < 0:
		secuencias.erase(sec)
	else:
		sec["esperando"] = wait

func ejecutar(sec):
	var nodo = sec["nodo"]
	var i = sec["i"]
	if i >= sec["secuencia"].size():
		return -1
	var paso = sec["secuencia"][i]
	if paso == "R":
		sec["i"] = 0
		return null
	sec["i"] += 1
	paso = paso.split("|")
	if paso[0] == "W":
		return int(paso[1])
	elif paso[0] == "F":
		var f = paso[1]
		var args = argumentos(paso)
		nodo.call(f, args)
		return null
	elif paso[0] == "M":
		var m = paso[1]
		var args = argumentos(paso)
		nodo.mensaje(m, args)
		return null
	return -1

func argumentos(l):
	var args = []
	for i in range(l.size()-2):
		args.append(arg(l[i+2]))
	return args

func arg(x):
	if x.is_valid_integer():
		return int(x)
	elif x.is_valid_float():
		return float(x)
	return x

# Constantes del teclado:
#	KEY_ESCAPE,KEY_F1,KEY_F2,KEY_F3,KEY_F4,KEY_F5,KEY_F6,KEY_F7,KEY_F8,KEY_F9,KEY_F10,KEY_F11,KEY_F12,
#	KEY_INSERT,KEY_DELETE,KEY_HOME,KEY_END,KEY_PAGEUP,KEY_PAGEDOWN,
#	KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8,KEY_9,KEY_0,KEY_BACKSPACE,
#	KEY_NUMLOCK,KEY_KP_DIVIDE,KEY_KP_MULTIPLY,KEY_KP_SUBTRACT,KEY_KP_ADD,KEY_ENTER,KEY_KP_PERIOD,
#	KEY_KP_1,KEY_KP_2,KEY_KP_3,KEY_KP_4,KEY_KP_5,KEY_KP_6,KEY_KP_7,KEY_KP_8,KEY_KP_9,KEY_KP_0,
#	KEY_TAB,KEY_Q,KEY_W,KEY_E,KEY_R,KEY_T,KEY_Y,KEY_U,KEY_I,KEY_O,KEY_P,
#	KEY_CAPSLOCK,KEY_A,KEY_S,KEY_D,KEY_F,KEY_G,KEY_H,KEY_J,KEY_K,KEY_L,KEY_NTILDE,
#	KEY_Z,KEY_X,KEY_C,KEY_V,KEY_B,KEY_N,KEY_M,KEY_COMMA,KEY_PERIOD,KEY_MINUS,
#	KEY_SPACE,KEY_RIGHT,KEY_LEFT,KEY_UP,KEY_DOWN,KEY_RETURN,KEY_MENU

# La acción que triggerea se guarda como un string de la siguiente forma:
	# P + str(scancode) : Se presiona una tecla o un botón del mouse
	# R + str(scancode) : Se suelta una tecla o un botón del mouse
	# WS : Cambió el tamaño de la pantalla
	# MM : Se movió el mouse
	# T : Para funciones periódicas
