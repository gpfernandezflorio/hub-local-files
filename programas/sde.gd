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
var cubo

func inicializar(hub, pid, argumentos):
	HUB = hub
	self.pid = pid
	HUB3DLang = lib_map["HUB3DLang"]
	HUB.pantalla.completa()			# Pantalla completa
	HUB.eventos.set_modo_mouse(2)	# Ocultar mouse
	HUB.terminal.cerrar()			# Ocultar terminal
	jugador = HUB3DLang.crear("fps")# Crear jugador
	cubo = HUB3DLang.crear("testcube:oz-5")
	return null

func finalizar():
	HUB.eventos.set_modo_mouse()
	HUB.terminal.abrir()
	HUB.pantalla.completa(false)
	HUB.objetos.borrar(jugador)
	HUB.objetos.borrar(cubo)
	return null