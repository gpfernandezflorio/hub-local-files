## RIGID
## SRC

# Script para los componentes de tipo RigidBody

extends Spatial # Este es un proxy al RigidBody real

var HUB
var yo

var arg_map_empujar = {
	"lista":[
		{"nombre":"accion", "codigo":"i", "default":Vector3(0,0,-5)},
		{"nombre":"accion", "codigo":"p", "default":Vector3(0,0.5,0)}
	]
}

var body_real
var shapes = []

func inicializar(hub, yo_recibido):
	HUB = hub
	self.yo = yo_recibido
	body_real = RigidBody.new()
	body_real.set_name("BODY REAL")
	for s in shapes:
		add_shape(s[0], s[1])
	var hijos = get_children()
	add_child(body_real)
	for h in hijos:
		remove_child(h)
		body_real.add_child(h)
	yo.moveme(self)
	yo.interfaz(self, "empujar", arg_map_empujar, true)
	HUB.eventos.registrar_periodico(self, "periodico")
	return true

func finalizar():
	HUB.eventos.anular_periodico(self)

func periodico(_delta):
	if body_real.get_mode() == 0:
		yo.set_global_transform(body_real.get_global_transform())
		yo.translate(-get_translation())
		body_real.set_transform(Transform())
	else:
		body_real.set_transform(Transform())
		body_real.set_mode(0)

func mover(cuanto):
	body_real.set_mode(1) # Convierto al RigidBody en estático
	body_real.set_transform(Transform().translated(cuanto))

func empujar(args):
	body_real.apply_impulse(args["p"],args["i"])

# PROXY

func is_colliding():
	return body_real.is_colliding()

func get_collision_normal():
	return body_real.get_collision_normal()

func add_shape(shape, transform=Transform()):
	if body_real:
		body_real.add_shape(shape, transform)#@2
#		var s_owner = body_real.create_shape_owner(null)#@3
#		body_real.shape_owner_add_shape(s_owner, shape)#@3
#		body_real.shape_owner_set_transform(s_owner, transform)#@3
	else:
		shapes.append([shape, transform])
