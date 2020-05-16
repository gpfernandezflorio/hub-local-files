## HTree
## Comando

# Muestra la jerarquía de nodos del HUB.
# Requiere:
	# Biblioteca printer

extends Node

var HUB
var printer

var modulo = "HTree"

func inicializar(hub):
	HUB = hub
	printer = HUB.bibliotecas.importar("printer")
	if HUB.errores.fallo(printer):
		return HUB.error(HUB.errores.inicializar_fallo(self, printer), modulo)
	return null

func comando(argumentos):
	var atributos = parsear_argumentos(argumentos)
	HUB.mensaje(printer.imprimir_arbol(HUB, AtributosNodo.new(atributos)))

func parsear_argumentos(argumentos):
	var atributos = []
	for argumento in argumentos:
		if argumento == "-a":
			atributos.append("TODOS")
		elif argumento == "-t":
			atributos.append("TIPO")
		else:
			pass # argumento inválido
	return atributos

class AtributosNodo:
	var atributos
	func _init(atributos = []):
		self.atributos = atributos
	func nombre_de_nodo(nodo):
		var nombre = nodo.get_name()
		if "TIPO" in atributos:
			nombre += " [" + nodo.get_type() + "]"
		return nombre
	func hijos_de_nodo(nodo):
		var hijos = nodo.get_children()
		if not "TODOS" in atributos:
			for hijo in hijos:
				if hijo.get_name().begins_with("__hidden__"):
					hijos.erase(hijo)
		return hijos

func descripcion():
	return "Muestra la jerarquía de nodos del HUB"

func man():
	var r = "[ HTREE ] - " + descripcion()
	r += "\nUso: htree"
	r += "\nIgnora cualquier argumento."
	return r
