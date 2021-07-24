## KINEMATIC
## SRC

# Script para los componentes de tipo KinematicBody

extends Spatial # Este es un proxy al KinematicBody real

var HUB
var yo

var body_real
var shapes = []

func inicializar(hub, yo_recibido):
	HUB = hub
	self.yo = yo_recibido
	body_real = KinematicBody.new()
	body_real.set_name("BODY REAL")
	for s in shapes:
		add_shape(s[0], s[1])
	var hijos = get_children()
	add_child(body_real)
	for h in hijos:
		remove_child(h)
		body_real.add_child(h)
	#yo.moveme(self)
	HUB.eventos.registrar_periodico(self, "periodico")
	return true

func finalizar():
	HUB.eventos.anular_periodico(self)

func periodico(_delta):
	yo.set_global_transform(body_real.get_global_transform())
	yo.translate(-get_translation())
	body_real.set_transform(Transform())

func mover(cuanto):
	body_real.move(cuanto)#@2
#	body_real.move_and_slide(cuanto*50)#@3

# PROXY

func is_colliding():
	return body_real.is_colliding()#@2
#	return body_real.get_slide_count() > 0#@3

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
