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

func inicializar(hub, pid, argumentos):
	HUB = hub
	self.pid = pid
	HUB3DLang = lib_map["HUB3DLang"]
	HUB.pantalla.completa()			# Pantalla completa
	HUB.eventos.set_modo_mouse(2)	# Ocultar mouse
	HUB.terminal.cerrar()			# Ocultar terminal
	jugador = HUB3DLang.crear("fps:ox-4:oz4:ry45")
	sala = HUB3DLang.crear("sde/sala:nsala")
	return null

func finalizar():
	HUB.eventos.set_modo_mouse()
	HUB.terminal.abrir()
	HUB.pantalla.completa(false)
	HUB.objetos.borrar(jugador)
	HUB.objetos.borrar(sala)
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