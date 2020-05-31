## Tree
## Comando

# Muestra la jerarquía de objetos.
# Requiere:
	# Biblioteca printer

extends Node

var HUB

var lib_map = [
	"printer"
]

var arg_map = {
	"lista":[
		{"nombre":"raíz", "codigo":"r", "default":""},
		{"nombre":"posición", "codigo":"p", "validar":"BOOL","default":false},
		{"nombre":"tipo", "codigo":"t", "validar":"BOOL", "default":false},
		{"nombre":"script", "codigo":"s", "validar":"BOOL", "default":false}
	]
}

var argumentos_validos = {
	"p":"get_translation",
	"t":"get_type",
	"s":"get_script"
}

var modulo = "Tree"
var printer

func inicializar(hub):
	HUB = hub
	printer = lib_map["printer"]
	return null

func comando(argumentos):
	var args = []
	var root = HUB.nodo_usuario.mundo
	for c in argumentos_validos.keys():
		if argumentos[c]:
			args.append(argumentos_validos[c])
	if not argumentos["r"].empty():
		root = HUB.objetos.localizar(argumentos["r"])
		if HUB.errores.fallo(root):
			return HUB.error(HUB.errores.error('No se puede imprimir el árbol de "' + argumentos["r"] + '".', root), modulo)
	HUB.mensaje(printer.imprimir_arbol(root, AtributosNodo.new(args, printer)))

class AtributosNodo:
	var args
	var printer
	func _init(args, printer):
		self.args = args
		self.printer = printer
	func nombre_de_nodo(nodo):
		var txt = nodo.get_name()
		for arg in self.args:
			if nodo.has_method(arg):
				txt += " - " + printer.imprimir(nodo.call(arg))
		return txt
	func hijos_de_nodo(nodo):
		var hijos = nodo.hijos()
		for hijo in hijos:
			if hijo.get_name().begins_with("__hidden__"):
				hijos.erase(hijo)
		return hijos

func descripcion():
	return "Muestra la jerarquía de objetos"

func man():
	var r = "[ TREE ] - " + descripcion()
	r += "\nUso: tree [-rROOT] [-p] [-t] [-s]"
	r += "\n ROOT : Nombre completo del objeto a partir de la cual imprimir."
	r += "\n   Por defecto, es el objeto Mundo."
	r += "\n -p : Muestra la posición del objeto."
	r += "\n -t : Muestra el tipo del objeto."
	r += "\n -s : Muestra el nombre del script del objeto."
	return r