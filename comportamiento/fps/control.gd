## FPS/Control
## Comportamiento

# Control de movimiento para un personaje FPS
# Requiere para inicializar:
	# Que el objeto tenga un componente (cuerpo) de tipo KinematicBody
	# Opcional: Que el objeto tenga un componente (mirada) que pueda rotar

extends Spatial

var HUB

var arg_map = {
	"lista":[
		{"nombre":"cuerpo", "codigo":"c"},
		{"nombre":"mirada", "codigo":"m"},
		{"nombre":"velocidad", "codigo":"v", "validar":"DEC;>0", "default":1}
	]
}

var modulo = "FPS/Control"
var yo
var cuerpo
var requisitos_cuerpo = ["is_colliding","get_collision_normal"]
var mirada = null
var velocidad_base
var rango_y = [-35,40] # grados

func inicializar(hub, yo, args):
	HUB = hub
	self.yo = yo
	velocidad_base = args["v"]
	var nombre_cuerpo = args["c"]
	if nombre_cuerpo == null:
		cuerpo = HUB.objetos.componente_candidato(yo, "body", requisitos_cuerpo)
	else:
		cuerpo = yo.componente_nombrado(nombre_cuerpo)
	if HUB.errores.fallo(cuerpo):
		return HUB.error(HUB.errores.error("X1", cuerpo), modulo)
	for req in requisitos_cuerpo:
		if not cuerpo.has_method(req):
			return HUB.error(HUB.errores.error('El cuerpo seleccionado no implementa el método "'+req+'"'), modulo)
	var nombre_mirada = args["m"]
	if  nombre_mirada != null:
		if yo.tiene_componente_nombrado(nombre_mirada):
			mirada = yo.componente_nombrado(nombre_mirada)
		elif yo.tiene_hijo_nombrado(nombre_mirada):
			mirada = yo.hijo_nombrado(nombre_mirada)
		else:
			return HUB.error(HUB.errores.error('No se pudo ubicar un componente ni un hijo con nombre "' + nombre_mirada + '".'), modulo)
		if not mirada.has_method("rotate"):
			return HUB.error(HUB.errores.error("X4"), modulo)
	rango_y[0] *= PI/180
	rango_y[1] *= PI/180
	HUB.eventos.registrar_periodico(self, "periodico")
	return null

func periodico(delta):
	var velocidad = calcular_velocidad()
	var angulo = calcular_angulo()
	var velocidad_real = velocidad.rotated(Vector3(0,1,0),angulo)
	var movimiento = calcular_movimiento(velocidad_real, delta)
	yo.mover(movimiento)
	calcular_rotacion(delta)

func calcular_velocidad():
	var velocidad_entrada = yo.dame("input_mov", Vector3(0,0,0))*velocidad_base
	return velocidad_entrada

func calcular_angulo():
	var angulo = -yo.get_rotation().y
	if (yo.get_rotation().z < -0.01):
		angulo = PI-angulo
	return angulo

func calcular_movimiento(velocidad, delta):
	var movimiento = velocidad*delta
	return movimiento

func calcular_rotacion(delta):
	var entrada = yo.dame("input_rot", Vector2(0,0))
	if yo.dame("input_mouse", false): # El valor se debe tomar como un inmediato y no como input constante
		delta = 1
		yo.pone("input_rot", Vector2(0,0))
	yo.rotate_y(entrada.x/60.0)
	if mirada:
		mirada.rotate_x(entrada.y/80.0) # entrada: ^ - v + ; valor: v - ^ +
		var rotacion = mirada.get_rotation()
		if entrada.y > 0: # mira para abajo
			if rotacion.x < rango_y[0]:
				rotacion.x = rango_y[0]
				mirada.set_rotation(rotacion)
		elif entrada.y < 0: # mira para arriba
			if rotacion.x > rango_y[1]:
				rotacion.x = rango_y[1]
				mirada.set_rotation(rotacion)