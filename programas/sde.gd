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
			{"texto":"comenzar","accion":"crear_sala"},
			{"texto":"salir","accion":"salir"}
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
	HUB.eventos.set_modo_mouse(2)	# Ocultar mouse
	jugador = HUB3DLang.crear("fps:ox-4:oz4:ry45")
	sala = HUB3DLang.crear("sde/sala:nsala")

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
func interruptor_luz(args):
	var encendida = sala.hijo_nombrado("luz").mensaje("alternar")
	#if encendida:
	#	sala.hijo_nombrado("morse").mensaje("apagar")
	#else:
	#	sala.hijo_nombrado("morse").mensaje("encender")

# argumentos: [quien, target, que]
func rsa(args):
	print("RSA")