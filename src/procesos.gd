## Procesos
## SRC

# Script para manipular los procesos.
# Requiere para inicializar:
	# -

extends Node

var HUB
var modulo = "PROCESOS"
# Ruta a la carpeta de programas de HUB
var carpeta_programas = "programas/"
# Código de programas
var codigo = "Programa"
# Procesos del sistema indexados por pid (un string)
var procesos = {"HUB":Proceso.new()}
# Pid del proceso actual
var proceso_actual = "HUB"

func inicializar(hub):
	HUB = hub
	HUB.archivos.codigos_script.append(codigo)
	return true

# Devuelve el pid del proceso actual
func actual():
	return proceso_actual

# Crea un nuevo proceso
func nuevo(programa, argumentos=[]):
	var script_programa = HUB.archivos.abrir(carpeta_programas, programa + ".gd")
	if HUB.errores.fallo(script_programa):
		return HUB.error(programa_inexistente(programa, script_programa), modulo)
	var pid = programa
	var i = 0
	while pid in procesos.keys():
		i += 1
		pid = programa + "_" + str(i)
	var nodo = Node.new()
	add_child(nodo)
	nodo.set_name(pid)
	nodo.set_script(script_programa)
	var resultado_inicializar = nodo.inicializar(HUB, pid, argumentos)
	if HUB.errores.fallo(resultado_inicializar):
		remove_child(nodo)
		nodo.queue_free()
		return HUB.error(programa_no_cargado(programa, resultado_inicializar), modulo)
	procesos[pid] = nodo
	return nodo

func entorno():
	var resultado = ""
	var proceso_actual = actual()
	if proceso_actual != "HUB":
		resultado = "[" + proceso_actual + "]" + resultado
	for comando in pila_comandos():
		resultado = " . "+comando + resultado
	if resultado.length() > 0:
		resultado += "\n"
	return resultado

# Funciones auxiliares

# Apila un comando en la pila de comandos de un proceso
func apilar_comando(comando, proceso=null):
	var i_proceso = proceso
	if i_proceso == null:
		i_proceso = proceso_actual
	procesos[i_proceso].apilar(comando)

# Desapila un comando en la pila de comandos de un proceso
func desapilar_comando(proceso=null):
	var i_proceso = proceso
	if i_proceso == null:
		i_proceso = proceso_actual
	procesos[i_proceso].desapilar()

# Devuelve la pila de comandos de un proceso
func pila_comandos(proceso=null):
	var i_proceso = proceso
	if i_proceso == null:
		i_proceso = proceso_actual
	return procesos[i_proceso].pila_comandos

class Proceso:
	var pila_comandos = []
	func apilar(comando):
		pila_comandos.push_front(comando)
	func desapilar():
		pila_comandos.pop_front()

# Errores

# Programa inexistente
func programa_inexistente(programa, stack_error=null):
	return HUB.errores.error('Programa "' + programa + '" no encontrado.', stack_error)

# Error al cargar el programa
func programa_no_cargado(programa, stack_error=null):
	return HUB.errores.error('No se pudo cargar el programa "' + programa + '".', stack_error)