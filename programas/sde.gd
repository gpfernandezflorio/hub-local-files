## SdE
## Programa

# Sala de Escape

extends Node

var HUB
var pid

var lib_map = [
	"HUB3DLang"
]

var modulo = "SdE"
var HUB3DLang

var jugador
var sala
var ventana
var tip

var light_switch
var luz
var monitor
var morse

func inicializar(hub, pid, argumentos):
	HUB = hub
	self.pid = pid
	HUB3DLang = lib_map["HUB3DLang"]
	HUB.pantalla.completa()			# Pantalla completa
	HUB.terminal.cerrar()			# Ocultar terminal
	pantalla_inicio()
	return null

func pantalla_inicio():
	HUB.eventos.set_modo_mouse()	# Mostrar mouse
	var texto_intro = HUB.archivos.leer("data/sde","intro.txt")
	ventana = HUB.nodo_usuario.ventana(self,{
		"tamanio":Vector2(75,75),
		"botones":[
			{"texto":"Comenzar","accion":"crear_sala"},
			{"texto":"Salir","accion":"salir"}
		],
		"cuerpo":[
			{"clase":ScrollContainer,"tamanio":Vector2(95,98),"posicion":"center","args":{"scroll/horizontal":false},
			"hijos":[{"clase":Label,"args":{"text":texto_intro},"tamanio":Vector2(5,5)}]}
		]
	})

func crear_sala():
	if ventana != null:
		ventana.cerrar()
		ventana = null
	HUB.eventos.set_modo_mouse(2)
	jugador = HUB3DLang.crear("fps:ox-4:oz4:ry45")
	sala = HUB3DLang.crear("sde/sala:nsala")
	light_switch = sala.hijo_nombrado("switch")
	monitor = sala.hijo_nombrado("rsa").hijo_nombrado("monitor")
	luz = sala.hijo_nombrado("luz")
	#morse = sala.hijo_nombrado("morse")

func salir():
	HUB.procesos.finalizar(self)

func finalizar():
	if ventana != null:
		ventana.cerrar()
	if jugador != null:
		HUB.objetos.borrar(jugador)
	if sala != null:
		HUB.objetos.borrar(sala)
	HUB.eventos.set_modo_mouse()
	HUB.pantalla.completa(false)
	HUB.terminal.abrir()
	return null

# argumentos: [quien, target, que]
func tip(args):
	if args[2]:
		if tip != null:
			tip.cerrar()
		var texto = "Q: "
		var item = args[1]
		if item == light_switch:
			if luz.mensaje("encendida"):
				texto += "apagar"
			else:
				texto += "encender"
			texto += " la luz"
		#elif item == monitor:
		#	texto = "aa"
		else:
			texto += "interactuar"
		tip = HUB.nodo_usuario.ventana(self,{
			"titulo":"",
			"tamanio":Vector2(15,7),
			"posicion":["bottom-center",Vector2(0,10)],
			"cuerpo":[
				{"clase":CenterContainer,"tamanio":Vector2(100,100),
				"hijos":[{"clase":Label,"id":"tip","args":{"text":texto}}]}
			]
		})
	elif tip != null:
		tip.cerrar()
		tip = null

# argumentos: [quien, target, que]
func interruptor_luz(args):
	var encendida = luz.mensaje("alternar")
	if tip != null:
		var texto
		if luz.mensaje("encendida"):
			texto = "apagar"
		else:
			texto = "encender"
		texto += " la luz"
		var label = HUB.nodo_usuario.gui_id("tip")
		label.set_text(texto)
	#if encendida:
	#	morse.mensaje("apagar")
	#else:
	#	morse.mensaje("encender")

# argumentos: [quien, target, que]
func rsa(args):
	HUB.eventos.set_modo_mouse()
	jugador.pausa()
	monitor.mensaje("silencio")
	ventana = HUB.nodo_usuario.ventana(self,{
		"tamanio":Vector2(80,80),
		"titulo":"chat",
		"botones":[{"texto":"Cerrar","accion":"cerrar_rsa"}]
	})

func cerrar_rsa():
	if ventana != null:
		ventana.cerrar()
	jugador.pausa(false)
	HUB.eventos.set_modo_mouse(2)