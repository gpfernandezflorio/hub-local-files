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
#		(opcional) args
#		[hijos] (componentes)

func inicializar(hub, args):
	HUB = hub

	#var nodo = args["nodo"]
	componentes = args["componentes"]

	for c in componentes:
		HUB.nodo_usuario.inicializar_componente(c, ids)
		add_child(c["nodo"])

	resize(null)
	HUB.eventos.registrar_ventana_escalada(self, "resize")
	return null

func cerrar():
	HUB.eventos.anular_ventana_escalada(self)
	HUB.GC.borrar_nodo(self)

func resize(nuevo_tamanio):
	for c in componentes:
		HUB.nodo_usuario.resize_componente(c)