## Nodo Comandos
## SRC

# Ejecuta los comandos ingresados en la terminal.

extends Node

var HUB
# Ruta a la carpeta de comandos de HUB
var carpeta_comandos = "comandos/"
# Diccionario con los comandos cargadas (en nodos)
var comandos_cargados = {} # Dicc(string : nodo)

func inicializar(hub):
	HUB = hub
	return true

func ejecutar(comando, argumentos=[]):
	var nodo = cargar(comando)
	if nodo == null:
		HUB.mensaje('Error: Comando "' + comando + '" desconocido.')
		return
	nodo.comando(argumentos)

func cargar(comando):
	if comando in comandos_cargados:
		return comandos_cargados[comando]
	var script_comando = HUB.archivos.abrir(carpeta_comandos, comando + ".gd")
	if script_comando == null:
		return null
	var nodo = Node.new()
	add_child(nodo)
	nodo.set_name(comando)
	nodo.set_script(script_comando)
	comandos_cargados[comando] = nodo
	nodo.inicializar(HUB)
	return nodo