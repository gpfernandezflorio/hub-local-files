## HUB
## SRC

# El nodo raíz de todo el árbol, único nodo al empezar la ejecución.
# Crea e inicializa a los demás módulos.

extends Node

# Ruta a la carpeta de archivos de usuario
var ruta_raiz
# Ruta a la carpeta de archivos fuente de HUB
var hub_src = "src/"

# Manipulador de archivos
var archivos = Node.new()
# Control de eventos
var eventos = Node.new()
# Controlador de la pantalla
var pantalla = Node2D.new()
# Manipulador de objetos
var objetos = Node.new()
# Manipulador de bibliotecas
var bibliotecas = Node.new()
# Control de la Terminal
var terminal = Node.new()
# Entorno manipulado por el usuario
var nodo_usuario = Node.new()
# Manipulador de errores
var errores = Node.new()
# Controlador de procesos
var procesos = Node.new()
# Entorno de testing
var testing = Node.new()

func inicializar(hub, extension):
	ruta_raiz = get_parent().ruta_raiz
	for componente in [
		[archivos,     "archivos",   "Archivos"],
		[eventos,      "eventos",    "Eventos"],
		[pantalla,     "pantalla",   "Pantalla"],
		[objetos,      "objetos",    "Objetos"],
		[bibliotecas,  "bibliotecas","Bibliotecas"],
		[terminal,     "terminal",   "Terminal"],
		[nodo_usuario, "usuario",    "Nodo Usuario"],
		[errores,      "errores",    "Errores"],
		[procesos,     "procesos",   "Procesos"],
		[testing,      "testing",    "Testing"]
	]:
		if not inicializar_componente(
			componente[0],
			componente[1] + extension,
			componente[2]
		):
			return false
	eventos.iniciar()
	if archivos.existe("comandos/", "sh.gd") and \
		archivos.existe("shell/", "INI.gd"):
		terminal.ejecutar("sh INI.gd")
	return true

# Manda un mensaje a la terminal del HUB
func mensaje(texto):
	if testing.testeando:
		testing.redirigir_mensaje(texto)
		return
	else:
		terminal.campo_mensajes.mensaje(
			"\t" + str(texto).replace("\n","\n\t"),
			procesos.entorno())

# Notifica un error
func error(error, emisor=""):
	if not testing.testeando:
		mensaje(("" if emisor.empty() else \
		"[" + emisor + "] ") + 'Error: ' + error.mensaje)
	return error

# Finaliza la ejecución
func salir():
	get_tree().quit()

# Funciones auxiliares

func inicializar_componente(nodo, script, nombre):
	add_child(nodo)
	var ruta_completa = ruta_raiz+hub_src+script
	if not File.new().file_exists(ruta_completa):
		return false
	nodo.set_script(load(ruta_completa))
	if not nodo.has_method("inicializar"):
		return false
	nodo.set_name(nombre)
	return nodo.inicializar(self)