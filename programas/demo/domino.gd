## Demo/Domino
## Programa

# Dominó

extends Node

var HUB
var pid

var lib_map = [
	"HUB3DLang"
]

var modulo = "Dominó"
var HUB3DLang

var jugador
var fichas
var piso

func inicializar(hub, pid, argumentos):
	HUB = hub
	self.pid = pid
	HUB3DLang = lib_map["HUB3DLang"]
	HUB.pantalla.completa()			# Pantalla completa
	HUB.eventos.set_modo_mouse(2)	# Ocultar mouse
	HUB.terminal.cerrar()			# Ocultar terminal
	HUB3DLang.crear("$ficha=cube(!1,!3,!0.2)")
	piso = HUB3DLang.crear("face(!100,!100)&body(static):cplane")
	#HUB3DLang.crear("camara:oy40:rx"+str(PI/2))
	jugador = HUB3DLang.crear("fps")# Crear jugador
	# Crear dominó
	var pos = Vector2(1,-1.5)
	var delta_angulo = 0.2
	var diff = Vector2(0,-1)
	fichas = []
	for i in range(130):
		pos += diff.rotated(i*delta_angulo)
		if delta_angulo > 0.1:
			delta_angulo *= 0.995
		fichas.append(HUB3DLang.crear("(body(rigid):cbox(!1,!3,!0.2)&ficha:nc:mfixed(random(c))):sinteractive(push,m=c):oy1.5:ry"+str(-i*delta_angulo)+":ox"+str(pos.x)+":oz"+str(pos.y)))
	return null

func finalizar():
	HUB.eventos.set_modo_mouse()
	HUB.terminal.abrir()
	HUB.pantalla.completa(false)
	HUB.objetos.borrar(jugador)
	for p in fichas:
		HUB.objetos.borrar(p)
	HUB.objetos.borrar(piso)
	return null