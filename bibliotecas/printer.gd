## Printer
## Biblioteca

# Funciones para imprimir estructuras.
# Requiere:
	# Biblioteca estructuras

extends Node

var HUB
var estructuras
var modulo = "PRINTER"

var funciones_print = {
	"GDScript":"get_name"
}

func inicializar(hub):
	HUB = hub
	estructuras= HUB.bibliotecas.importar("estructuras")
	if HUB.errores.fallo(estructuras):
		return HUB.error(HUB.errores.inicializar_fallo(self, estructuras), modulo)

# Imprime la jerarquía de un árbol. Requiere un objeto que implemente
	# 'nombre_de_nodo' que dado un arbol devuelva su nombre y
	# 'hijos_de_nodo' que dado un arbol devuelva la lista de sus hijos.
func imprimir_arbol(arbol, function_object, nivel = ""):
	var mensaje = function_object.nombre_de_nodo(arbol)
	var hijos = function_object.hijos_de_nodo(arbol)
	for hijo in hijos:
		var nombre = function_object.nombre_de_nodo(hijo)
	if hijos.size() > 0:
		for i in range(0, hijos.size()):
			var hijo = hijos[i]
			var nuevo_nivel = nivel + "|    "
			if i == hijos.size()-1:
				nuevo_nivel = nivel + "      "
			mensaje += "\n" + nivel + "|__" + imprimir_arbol(hijo, function_object, nuevo_nivel)
	return mensaje

func imprimir(objeto):
	if typeof(objeto) == 18: # No es un built-in type
		var tipo = objeto.get_type()
		if tipo in funciones_print.keys():
			return objeto.call(funciones_print[tipo])
	return str(objeto)