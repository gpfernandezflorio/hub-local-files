## Estructuras
## Biblioteca

# Clases y funciones para manejar estructuras de datos.

extends Node

var HUB

func inicializar(hub):
	HUB = hub

## Array

func copiar_array(array):
	var nuevo_array = []
	for i in array:
		nuevo_array.append(i)
	return nuevo_array

func sub_array(array, desde, hasta=-1):
	var nuevo_array = []
	if hasta == -1:
		hasta = array.size()
	for i in range(desde, hasta):
		nuevo_array.append(array[i])
	return nuevo_array

## Conjunto

func conjunto_vacio():
	return Conjunto.new()

func conjunto_con_elementos(elementos):
	var resultado = conjunto_vacio()
	for i in elementos:
		resultado.agregar(i)
	return resultado

func copiar_conjunto(conjunto):
	return conjunto_con_elementos(conjunto.elementos)

func unir_conjuntos(conjunto_1, conjunto_2):
	var resultado = copiar_conjnunto(conjunto_1)
	resultado.union(conjunto_2)
	return resultado

class Conjunto:
	var elementos = []
	func agregar(x):
		if not x in elementos:
			elementos.append(x)
	func quitar(x):
		if x in elementos:
			elementos.erase(x)
	func union(otro_conjunto):
		for i in otro_conjunto.elementos:
			agregar(i)
	func es_subconjunto_de(otro_conjunto):
		for i in elementos:
			if not i in otro_conjunto.elementos:
				return false
		return true
	func es_igual_a(otro_conjunto):
		return \
			es_subconjunto_de(otro_conjunto) and \
			otro_conjunto.es_subconjunto_de(self) and \
			elementos.size() == otro_conjunto.elementos.size()

func map(funcion, lista):
	var res = []
	for x in lista:
		res.append(funcion.exec(x))
	return res

func filter(funcion, lista):
	var res = []
	for x in lista:
		if funcion.exec(x):
			res.append(x)
	return res