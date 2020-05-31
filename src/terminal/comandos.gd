## Nodo Comandos
## SRC

# Ejecuta los comandos ingresados en la terminal.

extends Node

var HUB
var modulo = get_parent().modulo
# Ruta a la carpeta de comandos de HUB
var carpeta_comandos = "comandos/"
# Diccionario con los comandos cargadas (en nodos)
var comandos_cargados = {} # Dicc(string : nodo)
# Código de comandos
var codigo = "Comando"

func inicializar(hub):
	HUB = hub
	HUB.archivos.codigos_script.append(codigo)
	return true

func ejecutar(comando, argumentos=[]):
	var nodo = cargar(comando)
	if HUB.errores.fallo(nodo):
		return HUB.error(HUB.terminal.comando_no_cargado(comando, nodo), modulo)
	argumentos = HUB.varios.parsear_argumentos_comandos(nodo, argumentos, modulo)
	if HUB.errores.fallo(argumentos):
		return HUB.error(HUB.terminal.comando_fallido(comando, argumentos), modulo)
	HUB.procesos.apilar_comando(comando)
	var resultado = nodo.comando(argumentos)
	HUB.procesos.desapilar_comando()
	if HUB.errores.fallo(resultado):
		return HUB.error(HUB.terminal.comando_fallido(comando, resultado), modulo)
	return resultado

func cargar(comando):
	if comando in comandos_cargados:
		return comandos_cargados[comando]
	var script_comando = HUB.archivos.abrir(carpeta_comandos, comando + ".gd", codigo)
	if HUB.errores.fallo(script_comando):
		return HUB.error(HUB.terminal.comando_inexistente(comando, script_comando), modulo)
	script_comando.set_name(comando)
	var nodo = Node.new()
	add_child(nodo)
	nodo.set_name(comando)
	nodo.set_script(script_comando)
	var resultado = HUB.varios.cargar_bibliotecas(nodo, modulo)
	if HUB.errores.fallo(resultado):
		return HUB.error(HUB.terminal.comando_no_cargado(comando, resultado), modulo)
	resultado = nodo.inicializar(HUB)
	if HUB.errores.fallo(resultado):
		remove_child(nodo)
		nodo.queue_free()
		return HUB.error(HUB.terminal.comando_no_cargado(comando, resultado), modulo)
	comandos_cargados[comando] = nodo
	return nodo