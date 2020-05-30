## FSTree
## Comando

# Muestra la jerarquía de archivos.
# Requiere:
	# Biblioteca printer

extends Node

var HUB

var lib_map = [
	"printer"
]

var arg_map = {
	"lista":[
		{"nombre":"raíz", "codigo":"r", "default":""}
	]
}

var modulo = "FSTree"
var printer

func inicializar(hub):
	HUB = hub
	printer = lib_map["printer"]
	return null

func comando(argumentos):
	var root = ["",argumentos["r"]]
	HUB.mensaje(printer.imprimir_arbol(root, AtributosNodo.new(argumentos, printer, HUB.archivos)))

class AtributosNodo:
	var args
	var printer
	var fs
	func _init(args, printer, fs):
		self.args = args
		self.printer = printer
		self.fs = fs
	func nombre_de_nodo(nodo):
		if (nodo[1]):
			return nodo[1]
		return "RAÍZ"
	func hijos_de_nodo(nodo):
		var hijos = []
		if fs.es_archivo(nodo[0], nodo[1]):
			return hijos
		if fs.es_directorio(nodo[0], nodo[1]):
			var ls = fs.listar(nodo[0], nodo[1])
			for hijo in ls:
				hijos.append([nodo[0]+nodo[1]+"/", hijo])
		return hijos

func descripcion():
	return "Muestra la jerarquía de archivos"

func man():
	var r = "[ FSTREE ] - " + descripcion()
	r += "\nUso: fstree [ROOT]"
	r += "\n ROOT : Ruta del directorio a partir del cual imprimir."
	r += "\n   Por defecto, es la ruta raiz."
	return r
