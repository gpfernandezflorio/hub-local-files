extends Control

var HUB
var componentes
var ids = {}

# ARGS:
#	nodo: Node
#	[componentes]
#		(opcional) id: String -> para identificarlos y editarlos
#		tamanio: Vector2 (null para minimal)
#		posicion: String ("top","bottom-left", etc), Vector2 o ambos
#		clase
#		[hijos] (componentes)

func inicializar(hub, args):
	HUB = hub

	#var nodo = args["nodo"]
	componentes = args["componentes"]

	for c in componentes:
		add_child(inicializar_componente(c))

	resize(null)
	HUB.eventos.registrar_ventana_escalada(self, "resize")
	return null

func inicializar_componente(c):
	var nodo = HUB.GC.crear_nodo(c["clase"])
	c["nodo"] = nodo
	if "id" in c:
		ids[c["id"]] = nodo
	for h in c["hijos"]:
		var hijo = inicializar_componente(h)
		nodo.add_child(hijo)
	return nodo

func cerrar():
	HUB.eventos.anular_ventana_escalada(self)
	HUB.GC.borrar_nodo(self)

func resize(nuevo_tamanio):
	for c in componentes:
		resize_componente(c)

func resize_componente(c):
	var nodo = c["nodo"]
	var size
	if "tamanio" in c:
		size = HUB.pantalla.coordenadas(c["tamanio"].x,c["tamanio"].y)
		nodo.set_size(size)
	else:
		size = nodo.get_size()
	var a_y = c["posicion"][0]
	var a_x = c["posicion"][1]
	var offset = c["posicion"][2]
	offset = HUB.pantalla.coordenadas(offset.x,offset.y)
	var pos = offset
	if a_x == "r":
		pos.x = HUB.pantalla.resolucion.x-size.x-offset.x
	elif a_x == "c":
		pos.x = (HUB.pantalla.resolucion.x-size.x)/2+offset.x
	if a_y == "b":
		pos.y = HUB.pantalla.resolucion.y-size.y-offset.y
	elif a_y == "c":
		pos.y = (HUB.pantalla.resolucion.y-size.y)/2+offset.y
	nodo.set_size(size)
	nodo.set_pos(pos)
	for h in c["hijos"]:
		resize_componente(h)