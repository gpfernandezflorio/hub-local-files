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

func inicializar(hub):
	HUB = hub
	return true

# Registra la función del nodo cuando se presiona un botón
func registrar_press(boton, nodo, funcion):
	# La funcion no debe tomar parámetros
	var accion = "P" + str(boton)
	if registro_eventos.has(accion):
		registro_eventos[accion].append({"nodo":nodo,"funcion":funcion})
	else:
		registro_eventos[accion] = [{"nodo":nodo,"funcion":funcion}]

# Registra la función del nodo cuando se suelta un botón
func registrar_release(boton, nodo, funcion):
	# La funcion no debe tomar parámetros
	var accion = "R" + str(boton)
	if registro_eventos.has(accion):
		registro_eventos[accion].append({"nodo":nodo,"funcion":funcion})
	else:
		registro_eventos[accion] = [{"nodo":nodo,"funcion":funcion}]

# Registra la función del nodo cuando cambia la resolución de la pantalla
func registrar_ventana_escalada(nodo, funcion):
	# La funcion debe tomar un Vector2 como parámetro
	var accion = "WS"
	if registro_eventos.has(accion):
		registro_eventos[accion].append({"nodo":nodo,"funcion":funcion})
	else:
		registro_eventos[accion] = [{"nodo":nodo,"funcion":funcion}]

# Registra una función periódica en el nodo
func registrar_periodico(nodo, funcion):
	var accion = "T"
	if registro_eventos.has(accion):
		registro_eventos[accion].append({"nodo":nodo,"funcion":funcion})
	else:
		registro_eventos[accion] = [{"nodo":nodo,"funcion":funcion}]

# Asigna el modo del cursor del mouse
func set_modo_mouse(modo):
	modo_mouse = modo
	if not HUB.terminal.activa():
		Input.set_mouse_mode(modo_mouse)

# Funciones auxiliares

func iniciar():
	set_process_input(true)
	set_fixed_process(true)
	get_tree().get_root().connect("size_changed", self, "ventana_escalada")

func _input(ev):
	if (ev.type == InputEvent.KEY):
		if ev.pressed:
			tecla_presionada(ev)
		else:
			tecla_soltada(ev)

func _fixed_process(delta):
	periodico(delta)

func ventana_escalada():
	if registro_eventos.has("WS"):
		for registro in registro_eventos["WS"]:
			registro["nodo"].call(registro["funcion"], OS.get_window_size())

func tecla_presionada(ev):
	var accion = "P"+str(ev.scancode)
	if registro_eventos.has(accion):
		for registro in registro_eventos[accion]:
			var nodo = registro["nodo"]
			var corresponde = nodo != HUB.terminal.campo_entrada
			if HUB.terminal.activa():
				corresponde = nodo in [HUB, HUB.terminal, HUB.terminal.campo_entrada]
			if corresponde:
				nodo.call(registro["funcion"])

func tecla_soltada(ev):
	var accion = "R"+str(ev.scancode)
	if registro_eventos.has(accion):
		for registro in registro_eventos[accion]:
			var nodo = registro["nodo"]
			var corresponde = nodo != HUB.terminal.campo_entrada
			if HUB.terminal.activa():
				corresponde = nodo in [HUB, HUB.terminal, HUB.terminal.campo_entrada]
			if corresponde:
				nodo.call(registro["funcion"])

func periodico(delta):
	if registro_eventos.has("T"):
		for registro in registro_eventos["T"]:
			registro["nodo"].call(registro["funcion"], delta)

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