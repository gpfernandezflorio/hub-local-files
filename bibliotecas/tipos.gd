## TIPOS
## Biblioteca

# Funciones para verificar tipos de variables

extends Node

var HUB

func inicializar(hub):
	HUB = hub

func es_una_lista(algo):
	return typeof(algo) == TYPE_ARRAY

func es_un_string(algo):
	return typeof(algo) == TYPE_STRING

func es_un_numero(algo):
	return es_un_entero(algo) or es_un_racional(algo)

func es_un_entero(algo):
	return typeof(algo) == TYPE_INT

func es_un_racional(algo):
	return typeof(algo) == TYPE_REAL

func es_un_nodo(algo):
	return typeof(algo) == TYPE_OBJECT and algo.has_method("get_tree")

func es_un_componente(algo):
	return typeof(algo) == TYPE_OBJECT and algo.has_method("get_tree") and not HUB.objetos.es_un_objeto(algo)

func es_un_mesh_rep(algo):
	return typeof(algo) == TYPE_OBJECT and algo.has_method("make")