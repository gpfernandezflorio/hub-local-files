## Interactuer
## Comportamiento

# Objeto que puede interactuar
# Requiere para inicializar:
	# -

extends Spatial

var HUB

var arg_map = {
	"lista":[
		{"nombre":"radio", "codigo":"r", "default":1, "validar":"NUM;>0"},
		{"nombre":"offset", "codigo":"o", "default":[], "validar":"ARR"}
	]
}

var arg_map_interact = {
	"lista":[
		{"nombre":"accion", "codigo":"a", "default":null}
	]
}

var modulo = "Interactuer"
var yo
var colisionador
var posibilidades

var signal_entrada = "area_enter_shape"#@2
#var signal_entrada = "area_shape_entered"#@3
var signal_salida = "area_exit_shape"#@2
#var signal_salida = "area_shape_exited"#@3

func inicializar(hub, yo_recibido, args):
	HUB = hub
	self.yo = yo_recibido
	colisionador = Area.new()
	var shape = SphereShape.new()
	var offset = Transform()
	if args["o"].size()>2:
		offset.origin.z = float(args["o"][2])
	if args["o"].size()>1:
		offset.origin.y = float(args["o"][1])
	if args["o"].size()>0:
		offset.origin.x = float(args["o"][0])
	shape.set_radius(args["r"])
	colisionador.add_shape(shape, offset)#@2
#	var s_owner = colisionador.create_shape_owner(null)#@3
#	colisionador.shape_owner_add_shape(s_owner, shape)#@3
#	colisionador.shape_owner_set_transform(s_owner, offset)#@3
	colisionador.connect(signal_entrada, self, "contacto_in")
	colisionador.connect(signal_salida, self, "contacto_out")
	add_child(colisionador)
	posibilidades = []
	yo.interfaz(self, "interact", arg_map_interact)
	return null

func contacto_in(_i, objeto, _a, _s):
	if objeto.get_parent().has_method("interact_in"):
		if not posibilidades.empty():
			posibilidades[0].interact_out(yo)
		var interactive = objeto.get_parent()
		interactive.interact_in(yo)
		posibilidades.push_front(interactive)

func contacto_out(_i, objeto, _a, _s):
	if objeto == null:
		return
	if objeto.get_parent().has_method("interact_out"):
		var interactive = objeto.get_parent()
		var change = posibilidades[0] == interactive
		posibilidades.erase(interactive)
		if change:
			interactive.interact_out(yo)
			if not posibilidades.empty():
				var mi_posicion = get_global_transform().origin
				var candidato = posibilidades[0]
				var distancia = candidato.get_global_transform().origin.distance_to(mi_posicion)
				for c in posibilidades:
					var distancia_c = c.get_global_transform().origin.distance_to(mi_posicion)
					if distancia_c < distancia:
						candidato = c
						distancia = distancia_c
				posibilidades.erase(candidato)
				posibilidades.push_front(candidato)
				candidato.interact_in(yo)

func interact(args):
	if not posibilidades.empty():
		posibilidades[0].interact(yo, args["a"])
