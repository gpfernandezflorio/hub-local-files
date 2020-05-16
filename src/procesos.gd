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
var procesos_activos = {"HUB":Proceso.new(Node.new())}
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
	var script_programa = HUB.archivos.abrir(carpeta_programas, programa + ".gd", codigo)
	if HUB.errores.fallo(script_programa):
		return HUB.error(programa_inexistente(programa, script_programa), modulo)
	var pid = programa
	var i = 0
	while pid in procesos_activos.keys():
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
	procesos_activos[pid] = Proceso.new(nodo)
	return nodo

# Devuelve la lista de procesos activos
func todos():
	return procesos_activos.keys()

# Devuelve el entorno de ejecución
func entorno(pid=null):
	var pid_solicitado = pid
	if pid_solicitado == null:
		pid_solicitado = proceso_actual
	var resultado = ""
	if pid_solicitado != "HUB":
		resultado = "[" + pid_solicitado + "]" + resultado
	for comando in pila_comandos(pid_solicitado):
		resultado = " . "+comando + resultado
	if resultado.length() > 0:
		resultado += "\n"
	return resultado

# Finaliza un proceso por su identificador
func finalizar(pid=null):
	var pid_solicitado = pid
	if pid_solicitado == null:
		pid_solicitado = proceso_actual
	if not pid_solicitado in procesos_activos.keys():
		return HUB.error(pid_inexistente(pid_solicitado), modulo)
	if pid_solicitado == "HUB":
		return HUB.error(pid_invalido(pid_solicitado), modulo)
	var proceso_solicitado = procesos_activos[pid_solicitado]
	procesos_activos.erase(pid_solicitado)
	proceso_solicitado.nodo.finalizar()
	proceso_solicitado.nodo.queue_free()
	if pid_solicitado == proceso_actual:
		proceso_actual = "HUB"

# Funciones auxiliares

# Apila un comando en la pila de comandos de un proceso
func apilar_comando(comando, proceso=null):
	var i_proceso = proceso
	if i_proceso == null:
		i_proceso = proceso_actual
	procesos_activos[i_proceso].apilar(comando)

# Desapila un comando en la pila de comandos de un proceso
func desapilar_comando(proceso=null):
	var i_proceso = proceso
	if i_proceso == null:
		i_proceso = proceso_actual
	procesos_activos[i_proceso].desapilar()

# Devuelve la pila de comandos de un proceso
func pila_comandos(proceso=null):
	var i_proceso = proceso
	if i_proceso == null:
		i_proceso = proceso_actual
	return procesos_activos[i_proceso].pila_comandos

class Proceso:
	var pila_comandos = []
	var nodo
	func _init(nodo):
		self.nodo = nodo
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

# pid inexistente
func pid_inexistente(pid, stack_error=null):
	return HUB.errores.error('No hay ningún proceso con identificador "' + \
	pid + '".')

# pid invalido
func pid_invalido(pid, stack_error=null):
	return HUB.errores.error('No se puede finalizar el proceso con identificador "' + \
	pid + '".')