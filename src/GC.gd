## GC
## SRC

# Recolector de basura
# Requiere para inicializar (sólo que existan los nodos para agregarlos al registro):
	# Pantalla
	# Terminal

extends Node

var HUB

var mapa_de_referencias

func inicializar(hub):
	HUB = hub
	mapa_de_referencias = {}
	excepcion(HUB.pantalla)
	return true

func excepcion(nodo):
	var id_referencia = str(nodo)
	mapa_de_referencias[id_referencia] = {"nodo":nodo}

func crear_nodo(clase):
	var nodo = clase.new()
	var id_referencia = str(nodo)
	mapa_de_referencias[id_referencia] = {"nodo":nodo}
	return nodo

func borrar_nodo(nodo):
	var id_referencia = str(nodo)
	if id_referencia in mapa_de_referencias:
		mapa_de_referencias.erase(id_referencia)

func borrar_objeto(objeto):
	for hijo in objeto.hijos():
		borrar_objeto(hijo)
	for comportamiento in objeto.comportamientos():
		if comportamiento.has_method("finalizar"):
			comportamiento.finalizar()
		borrar_nodo(comportamiento)
	for componente in objeto.componentes():
		if componente.has_method("finalizar"):
			componente.finalizar()
		borrar_nodo(componente)
	borrar_nodo(objeto)
	objeto.queue_free()

func es_valido(nodo):
	var id_referencia = str(nodo)
	if id_referencia == "[Deleted Object]":
		return false
	return id_referencia in mapa_de_referencias