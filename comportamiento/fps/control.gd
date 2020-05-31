## FPS/Control
## Comportamiento

# Control de movimiento para un personaje FPS
# Requiere para inicializar:
	# Que el objeto tenga un componente de tipo KinematicBody

extends Node

var HUB

var arg_map = {
	"lista":[
		{"nombre":"cuerpo", "codigo":"c"},
		{"nombre":"velocidad", "codigo":"v", "validar":"DEC;>0", "default":1}
	]
}

var modulo = "FPS/Control"
var yo
var cuerpo
var velocidad_entrada

func inicializar(hub, yo, args):
	HUB = hub
	self.yo = yo
	var nombre_cuerpo = args["c"]
	if nombre_cuerpo == null:
		cuerpo = HUB.objetos.componente_candidato(yo, "body", "KinematicBody")
	else:
		cuerpo = yo.componente_nombrado(nombre_cuerpo)
	if HUB.errores.fallo(cuerpo):
		return HUB.error(HUB.errores.error("X", cuerpo), modulo)
	if cuerpo.get_type() != "KinematicBody":
		return HUB.error(HUB.errores.error("X"), modulo)
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
