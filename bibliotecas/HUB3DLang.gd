## HUB3DLang
## Biblioteca

# Funciones para crear objetos parseando el lenguaje HUB3DLang.
# Requiere:
	# Biblioteca parser

extends Node

var HUB
var parser_lib
var parser
var modulo = "HUB3DLang"

var pila_entorno = []

func inicializar(hub):
	HUB = hub
	parser_lib = HUB.bibliotecas.importar("parser")
	if HUB.errores.fallo(parser_lib):
		return HUB.error(HUB.errores.inicializar_fallo(self, parser_lib), modulo)
	var tds = HUB3DLangTDS.new(HUB, self)
	parser = parser_lib.crear_parser([
		["I",["START","C"]],							# 0
		["I",["$","=","START","C"]],					# 1
		["I",["$","string","=","START","C"]],			# 2
		["START",["HOME","HOMEMODS"]],					# 3
		["HOMEMODS",[":","string","HOMEMODS"]],			# 4
		["HOMEMODS",[]],								# 5
		["HOME",["BASE"]],								# 6
		["BASE",["string","ARGS","BASEMODS"]],			# 7
		["ARGS",[]],									# 8
		["ARGS",["(","ARGN",")"]],						# 9
		["ARGN",["EXPR"]],								# 10
		["ARGN",["EXPR",",","ARGN"]],					# 11
		["BASEMODS",[]],								# 12
		["I",["$","string","=","EXPR","C"]],			# 13
		["C",[]],										# 14
		["C",["comentario"]],							# 15
		["EXPR",["0"]]									# 16
	], {
		"string":"([a-z]|_)+",
		"comentario":"#.*"
	}, tds)

func parsear(texto, entorno={}):
	var nuevos_objetos = [] # El texto podría contener varias líneas
	var raiz = null
	pila_entorno.push_front(entorno)
	for linea in texto.split("\n"):
		if not linea.begins_with("#") and linea.length() > 0:
			var nuevo_objeto = parser_lib.parsear_cadena(parser, linea)
			if HUB.errores.fallo(nuevo_objeto):
				pila_entorno.pop_front()
				return HUB.error(HUB.errores.error('No se pudo generar el objeto "' + linea + '".', nuevo_objeto), modulo)
			nuevo_objeto = nuevo_objeto["valor"]
			if not nuevo_objeto == null:
				nuevos_objetos.push_back(nuevo_objeto)
	if "$" in entorno.keys():
		raiz = entorno["$"]
	else:
		if nuevos_objetos.size() == 1:
			raiz = nuevos_objetos[0]
		else:
			raiz = HUB.objetos.crear()
			for hijo in nuevos_objetos:
				raiz.agregar_hijo(hijo)
	pila_entorno.pop_front()
	if raiz.padre() == null:
		HUB.nodo_usuario.mundo.agregar_hijo(raiz)
	return raiz

class HUB3DLangTDS:
	var HUB
	var modulo
	func _init(hub, modulo):
		HUB = hub
		self.modulo = modulo
	func reduce(produccion, valores):
		if produccion == 0: # I -> START C
			if not valores[0] == null:
				modulo.definir(valores[0].nombre(), valores[0])
			return valores[0]
		if produccion == 1: # I -> $ = START C
			modulo.definir("$", valores[2])
			return null
		if produccion == 2: # I -> $ string = START C
			modulo.definir(valores[1], valores[3])
			return null
		if produccion == 3: # START -> HOME HOMEMODS
			# La lista HOME puede contener Objetos y Componentes
			var objetos = []
			var componentes = []
			for elemento in valores[0]:
				if HUB.objetos.es_un_objeto(elemento) and not elemento.padre() == null:
					objetos.append(elemento)
				else:
					componentes.append(elemento)
			var nuevo_objeto = null
			if objetos.size() == 1:
				nuevo_objeto = objetos[0]
				objetos = []
			else:
				nuevo_objeto = HUB.objetos.crear(null)
			for componente in componentes:
				nuevo_objeto.agregar_componente(componente)
			for objeto in objetos:
				nuevo_objeto.agregar_hijo(objeto)
			var hijo_de = null
			for modificador in valores[1].keys():
				if (modificador == "n"):
					nuevo_objeto.nombrar(valores[1]["n"])
				if (modificador == "p"):
					hijo_de = modulo.obtener(valores[1]["p"])
					if hijo_de == null:
						hijo_de = HUB.objetos.localizar(valores[1]["p"])
						if HUB.errores.fallo(hijo_de):
							return HUB.error(modulo.parent_invalido(valores[1]["p"], hijo_de), modulo.modulo)
			if hijo_de == null:
				return nuevo_objeto
			else:
				hijo_de.agregar_hijo(nuevo_objeto)
				return null
		if produccion == 4: # HOMEMODS -> : string HOMEMODS
			var i = valores[1][0]
			if not i in ["n","p"]:
				return HUB.error(modulo.modificador_invalido(i), modulo.modulo)
			var dic = valores[2]
			dic[i] = valores[1].substr(1,valores[1].length()-1)
			return dic
		if produccion == 5: # HOMEMODS -> []
			return {}
		if produccion == 6: # HOME -> BASE
			return valores[0]
		if produccion == 7: # BASE -> string ARGS BASEMODS
			var resultado = null
			# Primitivas:
			if valores[0] in ["_","luz","body","camara"]:
				resultado = modulo.call("crear_"+valores[0], valores[1], valores[2])
			else:
				resultado = modulo.desde_archivo(valores[0], valores[1], valores[2])
			if resultado == null:
				return HUB.error(modulo.primitiva_invalida(valores[0]), modulo.modulo)
			if HUB.errores.fallo(resultado):
				return resultado
			return [resultado]
		if produccion == 8: # ARGS -> []
			return []
		if produccion == 9: # ARGS -> ( ARGN )
			return valores[0]
		if produccion == 10: # ARGN -> EXPR
			return [valores[0]]
		if produccion == 11: # ARGN -> EXPR , ARGN
			valores[2].append(valores[0])
			return valores[2]
		if produccion == 12: # BASEMODS -> []
			return {}
		if produccion == 13: # I -> $ string = EXPR C
			modulo.definir(valores[1], valores[3])
			return null
		if produccion == 14: # C -> []
			return null
		if produccion == 15: # C -> comentario
			return null
		if produccion == 16: # EXPR -> ...
			return 0
		return null

# Auxiliares

func definir(clave, valor):
	pila_entorno[0][clave] = valor

func obtener(clave):
	if pila_entorno[0].has(clave):
		return pila_entorno[0][clave]
	return null

func desde_archivo(nombre, argumentos, modificadores):
	var contenido_archivo = HUB.archivos.leer("objetos/", nombre + ".gd")
	if HUB.errores.fallo(contenido_archivo):
		return HUB.error(primitiva_invalida(nombre, contenido_archivo), modulo)
	var entorno = {}
	var i=1
	for argumento in argumentos:
		entorno[str(i)] = argumento
		i+=1
	return parsear(contenido_archivo, entorno)


var tipos_body = {
	"static":StaticBody,
	"kinematic":KinematicBody
}

func crear_body(argumentos, modificadores):
	var resultado = null
	if argumentos.size() == 1:
		var tipo = argumentos[0]
		if tipo in tipos_body.keys():
			resultado = tipos_body[tipo].new()
		else:
			return HUB.error(HUB.errores.error("Tipo de body inválido: "+tipo), modulo)
	else:
		resultado = StaticBody.new()
	return resultado

var tipos_luz = {
	"omni":OmniLight
}

func crear_luz(argumentos, modificadores):
	var resultado = null
	if argumentos.size() == 1:
		var tipo = argumentos[0]
		if tipo in tipos_luz.keys():
			resultado = tipos_luz[tipo].new()
		else:
			return HUB.error(HUB.errores.error("Tipo de luz inválido: "+tipo), modulo)
	else:
		resultado = OmniLight.new()
	return resultado

func crear_camara(argumentos, modificadores):
	return Camera.new()

func crear__(argumentos, modificadores):
	return HUB.objetos.crear(null)

# Errores

# primitiva invalida
func primitiva_invalida(primitiva, stack_error = null):
	return HUB.errores.error('La primitiva "' +\
	primitiva + '" no está definida.', stack_error)

# modificador invalido
func modificador_invalido(modificador, stack_error = null):
	return HUB.errores.error('El modificador "' +\
	modificador + '" no está definido.', stack_error)

# parent invalido
func parent_invalido(parent, stack_error = null):
	return HUB.errores.error('No se puede anidar el nuevo objeto bajo el padre "' +\
	parent + '".', stack_error)