## Bibliotecas
## SRC

# Script para la manipulación de bibliotecas comunes.
# Requiere para inicializar:
	# -

extends Node

var HUB
var modulo = "BIBLIOTECAS"
# Ruta a la carpeta de bibliotecas
var carpeta_bibliotecas = "bibliotecas/"
# Diccionario con las bibliotecas cargadas (en nodos)
var bibliotecas_cargadas = {} # Dicc(string : nodo)
# Código de bibliotecas
var codigo = "Biblioteca"

func inicializar(hub):
	HUB = hub
	HUB.archivos.codigos_script.append(codigo)
	return true

# Devuelve el nodo correspondiente a la biblioteca solicitada
func importar(biblioteca):
	var nodo = cargar(biblioteca)
	if HUB.errores.fallo(nodo):
		return HUB.error(biblioteca_no_cargada(biblioteca, nodo), modulo)
	return nodo

# Funciones auxiliares

func cargar(biblioteca):
	if biblioteca in bibliotecas_cargadas:
		return bibliotecas_cargadas[biblioteca]
	var script_biblioteca = HUB.archivos.abrir(carpeta_bibliotecas, biblioteca + ".gd", codigo)
	if HUB.errores.fallo(script_biblioteca):
		return HUB.error(biblioteca_inexistente(biblioteca, script_biblioteca), modulo)
	var nodo = Node.new()
	add_child(nodo)
	nodo.set_name(biblioteca)
	nodo.set_script(script_biblioteca)
	var resultado_inicializar = nodo.inicializar(HUB)
	if HUB.errores.fallo(resultado_inicializar):
		remove_child(nodo)
		nodo.queue_free()
		return HUB.error(biblioteca_no_cargada(biblioteca, resultado_inicializar), modulo)
	bibliotecas_cargadas[biblioteca] = nodo
	return nodo

# Errores

# Biblioteca inexistente
func biblioteca_inexistente(biblioteca, stack_error=null):
	return HUB.errores.error('Biblioteca "' + biblioteca + '" no encontrada.', stack_error)

# Error al cargar la biblioteca
func biblioteca_no_cargada(biblioteca, stack_error=null):
	return HUB.errores.error('No se pudo cargar la biblioteca "' + biblioteca + '".', stack_error)