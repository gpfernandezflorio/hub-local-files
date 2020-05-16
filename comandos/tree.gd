## Tree
## Comando

# Muestra la jerarquía de objetos.
# Requiere:
	# Biblioteca printer

extends Node

var HUB
var printer

var argumentos_validos = {
	"pos":"get_translation",
	"type":"get_type",
	"script":"get_script"
}
var modulo = "Tree"

func inicializar(hub):
	HUB = hub
	printer = HUB.bibliotecas.importar("printer")
	if HUB.errores.fallo(printer):
		return HUB.error(HUB.errores.inicializar_fallo(self, printer), modulo)
	return null

func comando(argumentos):
	var args = []
	var root = HUB.nodo_usuario.mundo
	for argumento in argumentos:
		if argumento.begins_with("-r"):
			var nombre_root = argumento.substr(2,argumento.length()-2)
			root = HUB.objetos.localizar(nombre_root)
			if HUB.errores.fallo(root):
				return HUB.error(HUB.errores.error('No se puede imprimir el árbol de "' + nombre_root + '".', root), modulo)
		elif argumento in argumentos_validos.keys():
			args.append(argumentos_validos[argumento])
		else:
			return HUB.error(HUB.errores.argumento_invalido(argumento), modulo)
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
	r += "\nUso: tree [-rROOT] [INFO1 INFO2 ... INFOn]"
	r += "\n ROOT : Nombre completo del objeto a partir de la cual imprimir. Por defecto, es el objeto Mundo."
	r += "\n INFOi : i-ésimo atributo a mostrar de cada objeto en el árbol. Posibles valores:"
	r += "\n  * pos : Posición del objeto."
	r += "\n  * type : Tipo del objeto."
	r += "\n  * script : Nombre del script del objeto."
	return r
