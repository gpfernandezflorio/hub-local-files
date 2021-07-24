## HTree
## Comando

# Muestra la jerarquía de nodos del HUB.
# Requiere:
	# Biblioteca printer

extends Node

var HUB

var lib_map = [
	"printer"
]

var arg_map = {
	"lista":[
		{"nombre":"raíz", "codigo":"r", "default":"", "path":"HOBJ"},
		{"nombre":"todos", "codigo":"a", "validar":"BOOL", "default":false},
		{"nombre":"tipo", "codigo":"t", "validar":"BOOL", "default":false},
		{"nombre":"posición", "codigo":"p", "validar":"BOOL","default":false}
	]
}

var modulo = "HTree"
var printer

func inicializar(hub):
	HUB = hub
	printer = lib_map["printer"]
	return null

func comando(argumentos):
	var root = get_node(str(HUB.get_path()).plus_file(argumentos["r"]))
	HUB.mensaje(printer.imprimir_arbol(root, AtributosNodo.new(printer, argumentos)))

class AtributosNodo:
	var printer
	var atributos
	func _init(printer_recibido, atributos_recibidos = []):
		self.printer = printer_recibido
		self.atributos = atributos_recibidos
	func nombre_de_nodo(nodo):
		var nombre = nodo.get_name()
		if atributos["t"]:
			nombre += " [" + nodo.get_type() + "]"
		if atributos["p"] and nodo.has_method("get_translation"):
			nombre += " - " + printer.imprimir(nodo.get_translation())
		return nombre
	func hijos_de_nodo(nodo):
		var hijos = nodo.get_children()
		if not atributos["a"]:
			for hijo in hijos:
				if hijo.get_name().begins_with("__hidden__"):
					hijos.erase(hijo)
		return hijos

func descripcion():
	return "Muestra la jerarquía de nodos del HUB"

func man():
	var r = "[ HTREE ] - " + descripcion()
	r += "\nUso: htree [-rROOT] [-a] [-t] [-p]"
	r += "\n ROOT : Ruta al nodo a partir del cual imprimir."
	r += "\n   Por defecto, es el nodo HUB."
	r += "\n -a : Muestra todos los nodos, incluso los ocultos."
	r += "\n -t : Muestra el tipo de nodo."
	r += "\n -p : Muestra la posición del nodo en el mundo."
	return r
