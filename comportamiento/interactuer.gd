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

func inicializar(hub, yo, args):
	HUB = hub
	self.yo = yo
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
	colisionador.add_shape(shape, offset)
	colisionador.connect("area_enter_shape", self, "contacto_in")
	colisionador.connect("area_exit_shape", self, "contacto_out")
	add_child(colisionador)
	posibilidades = []
	yo.interfaz(self, "interact", arg_map_interact)
	return null

func contacto_in(i, objeto, a, s):
	if objeto.get_parent().has_method("interact_in"):
		var interactive = objeto.get_parent()
		interactive.interact_in(yo)
		if not posibilidades.empty():
			posibilidades[0].interact_out(yo)
		posibilidades.push_front(interactive)

func contacto_out(i, objeto, a, s):
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