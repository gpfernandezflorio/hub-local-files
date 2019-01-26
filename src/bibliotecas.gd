## Bibliotecas
## SRC

# Script para la manipulación de bibliotecas comunes.
# Requiere para inicializar:
	# -

extends Node

var HUB
# Ruta a la carpeta de bibliotecas
var carpeta_bibliotecas = "bibliotecas/"
# Diccionario con las bibliotecas cargadas (en nodos)
var bibliotecas_cargadas = {} # Dicc(string : nodo)

func inicializar(hub):
	HUB = hub
	return true

# Devuelve el nodo correspondiente a la biblioteca solicitada
func importar(biblioteca):
	var nodo = cargar(biblioteca)
	if nodo == null:
		HUB.mensaje('Error: Biblioteca "' + biblioteca + '" no encontrada.')
	return nodo

# Funciones auxiliares

func cargar(biblioteca):
	if biblioteca in bibliotecas_cargadas:
		return bibliotecas_cargadas[biblioteca]
	var script_biblioteca = HUB.archivos.abrir(carpeta_bibliotecas, biblioteca + ".gd")
	if script_biblioteca == null:
		return null
	var nodo = Node.new()
	add_child(nodo)
	nodo.set_name(biblioteca)
	nodo.set_script(script_biblioteca)
	bibliotecas_cargadas[biblioteca] = nodo
	nodo.inicializar(HUB)
	return nodo