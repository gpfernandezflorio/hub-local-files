## FPS/Control
## Comportamiento

# Control de movimiento para un personaje FPS
# Requiere para inicializar:
	# Que el objeto tenga un componente de tipo KinematicBody

# Argumentos posibles:
	# cuerpo: Nombre del componente de tipo KinematicBody usado para mover al personaje

# Orden por defecto:
	# | cuerpo |

extends Node

var HUB
var modulo
var yo
var cuerpo
var velocidad_entrada

func inicializar(hub, yo, args):
	# OJO: "args" es un par lista-diccionario
	HUB = hub
	modulo = "FPS/Control"
	self.yo = yo
	var nombre_cuerpo = null
	if args[0].size() > 0:
		nombre_cuerpo = args[0][0]
	elif "cuerpo" in args[1].keys():
		nombre_cuerpo = args[1]["cuerpo"]
	if nombre_cuerpo == null:
		cuerpo = HUB.objetos.componente_candidato(yo, "body", "KinematicBody")
	else:
		cuerpo = yo.componente_nombrado(nombre_cuerpo)
	if HUB.errores.fallo(cuerpo):
		return HUB.error(HUB.errores.error("X", cuerpo), modulo)
	velocidad_entrada = Vector3(0.0,0.0,0.1)
	HUB.eventos.registrar_periodico(self, "periodico")
	return null

func periodico(delta):
	var velocidad = calcular_velocidad(delta)
	var angulo = calcular_angulo()
	var velocidad_real = velocidad.rotated(Vector3(0,1,0),angulo)
	var movimiento = calcular_movimiento(velocidad_real, delta)
	yo.mover(movimiento)

func calcular_velocidad(delta):
	return velocidad_entrada

func calcular_angulo():
	var angulo = -yo.get_rotation().y
	if (yo.get_rotation().z < -0.01):
		angulo = PI-angulo
	return angulo

func calcular_movimiento(velocidad, delta):
	var movimiento = velocidad*delta
	return movimiento
