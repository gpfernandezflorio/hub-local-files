## HUB3DLang
## Biblioteca

# Funciones para crear objetos parseando el lenguaje HUB3DLang.
# Requiere:
	# Biblioteca tipos
	# Biblioteca parser

extends Node

var HUB
var tipos
var parser_lib
var parser
var modulo = "HUB3DLang"

var pila_entorno = []

func inicializar(hub):
	HUB = hub
	tipos = HUB.bibliotecas.importar("tipos")
	if HUB.errores.fallo(tipos):
		return HUB.error(HUB.errores.inicializar_fallo(self, tipos), modulo)
	parser_lib = HUB.bibliotecas.importar("parser")
	if HUB.errores.fallo(parser_lib):
		return HUB.error(HUB.errores.inicializar_fallo(self, parser_lib), modulo)
	var tds = HUB3DLangTDS.new(self)
	parser = parser_lib.crear_parser([
		# Un Hobjeto se define a partir de una secuencia de líneas
		# Cada línea puede ser una de estas 3:
		["I",["START","C"]],							# 0
		["I",["$","=","START","C"]],					# 1
		["I",["$","variable","=","START","C"]],			# 2
		# C es un comentario opcional, iniciado con '#'
		# START es una definición. Puede ser un número o un Hobjeto
		# En los primeros dos casos, un número genera un error ya que definen el Hobjeto principal
			# Si hay una línea "$=A", A es el Hobjeto principal (sólo puede haber una de estas)
			# Si hay una única línea "A", A es el Hobjeto principal
			# Si no, el objeto principal será uno que contenga a todos los que se definen de esa forma
				# A menos que la haya exactamente un elemento definido de esta forma, los Hobjetos que ya tienen padre se ignoran
		# En el tercer caso, se define una variable que puede ser accedida por su nombre más adelante
		# Como los últimos dos casos sólo definen variables, devuelven null
		["START",["HOME"]],								# 3
		# HOME es una lista
		# Si tiene más de un elemento, todos ellos deben ser Hobjetos o componentes
			# En tal caso, se devuelve un nuevo Hobjeto cuyos hijos son los Hobjetos de la lista y sus componentes, los componentes de la lista
			# A menos que la lista tenga exactamente un elemento, los Hobjetos que ya tienen padre se ignoran
		# Sólo si la lista tiene un elemento, dicho elemento puede ser un número
		["HOME",["HOME","&","OBJ"]],					# 4
		# En este caso, la lista ya tiene más de un elemento así OBJ debe ser un Hobjeto o un componente
		["HOME",["OBJ"]],								# 5
		# En este caso OBJ puede ser un número, un Hobjeto o un componente pero no una variable
		["OBJ",["EXPR","MODS"]],						# 6
		# Una expresión puede ser de cualquier tipo pero no puede ser null
		# Si tiene modificadores, ya no puede ser un número
		["MODS",["mod","EXPR","MODS"]],					# 7
		["MODS",[]],									# 8
		["ARGS",[]],									# 9
		["ARGS",["(","ARGN",")"]],						# 10
		["ARGN",["ARG"]],								# 11
		["ARGN",["ARGN",",","ARG"]],					# 12
		["EXPR",["EXPR","opT","TERM"]],					# 13
		# Acá me tengo que asegurar que ese TERM sea un número
		["EXPR",["TERM"]],								# 14
		["TERM",["TERM","opF","FACT"]],					# 15
		# Acá me tengo que asegurar que ese FACT sea un número
		["TERM",["FACT"]],								# 16
		["FACT",["opT","FACT"]],							# 17
		# Acá me tengo que asegurar que ese FACT sea un número
		["FACT",["(","START",")"]],						# 18
		["FACT",["PRIM","ARGS"]],						# 19
		# Si tiene argumentos, lo devuelvo como un par
		["PRIM",["variable"]],							# 20
		["PRIM",["numero"]],							# 21
		["ARG",["EXPR"]],								# 22
		["ARG",["variable","=","EXPR"]],				# 23
		["C",[]],										# 24
		["C",["comentario"]]							# 25
	], {
		"variable":"([a-z]|_|/)+",	# Letras y guiones bajos de long > 0
		"numero":"([0-9]*\\.[0-9]+)|[0-9]+", # números
		"mod":":(n|p|s|ox|oy|oz|rx|ry|rz)",
		"comentario":"#.*",			# Cualquier cosa iniciada con un '#'
		"opT":"\\+|-",				# '+' y '-'
		"opF":"\\*|%"				# '*' y '%' (la diagonal '/' la uso para rutas a archivos)
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
			if HUB.objetos.es_un_objeto(nuevo_objeto):
				nuevos_objetos.push_back(nuevo_objeto)
	if "$" in entorno.keys():
		raiz = entorno["$"]
	else:
		if nuevos_objetos.size() == 1:
			raiz = nuevos_objetos[0]
		else:
			var hijos = []
			for hijo in nuevos_objetos:
				if hijo.padre() == null:
					hijos.append(hijo)
			if hijos.size() == 1:
				raiz = nuevos_objetos[0]
			else:
				raiz = HUB.objetos.crear()
				for hijo in hijos:
					raiz.agregar_hijo(hijo)
	pila_entorno.pop_front()
	if raiz.padre() == null and pila_entorno.empty():
		HUB.nodo_usuario.mundo.agregar_hijo(raiz)
	return raiz

class HUB3DLangTDS:
	var modulo
	func _init(modulo):
		self.modulo = modulo
	func reduce(produccion, valores):
		return modulo.reduce(produccion, valores)

func reduce(produccion, valores):
	# I -> START C
	if produccion == 0:
		if HUB.objetos.es_un_objeto(valores[0]):
			definir(valores[0].nombre(), valores[0]) # TODO: Esto hacerlo cuando le doy un nombre con :n
		else:
			return HUB.error(HUB.errores.error("un número no puede ser la raíz"), modulo)
		return valores[0]
	# I -> $ = START C
	if produccion == 1:
		if not HUB.objetos.es_un_objeto(valores[2]):
			return HUB.error(HUB.errores.error("un número no puede ser la raíz"), modulo)
		modulo.definir("$", valores[2])
		return null
	# I -> $ variable = START C
	if produccion == 2:
		definir(valores[1], valores[3])
		return null
	# START -> HOME
	if produccion == 3:
		if valores[0].size() == 1:
			var resultado = valores[0][0]
			if tipos.es_un_componente(resultado):
				resultado = componente_a_objeto(resultado)
			return resultado
		var objetos = []
		var componentes = []
		for elemento in valores[0]:
			if HUB.objetos.es_un_objeto(elemento) and elemento.padre() == null:
				objetos.append(elemento)
			elif tipos.es_un_componente(elemento):
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
		return nuevo_objeto
	# HOME -> HOME & OBJ
	if produccion == 4:
		if HUB.objetos.es_un_objeto(valores[2]) or tipos.es_un_componente(valores[2]):
			valores[0].append(valores[2])
		else:
			return HUB.error(HUB.errores.error("no se pueden unir con '&'"), modulo)
		return valores[0]
	# HOME -> OBJ
	if produccion == 5:
		return [valores[0]]
	# OBJ -> EXPR MODS
	if produccion == 6:
		var resultado = valores[0]
		if tipos.es_un_string(resultado):
			resultado = base(resultado, [[],{}])
			if tipos.es_un_string(resultado):
				if esta_definido(resultado):
					resultado = obtener(valores[0])
				else:
					return HUB.error(identificador_invalido(resultado), modulo)
		if tipos.es_una_lista(resultado):
			resultado = base(resultado[0], resultado[1])
		if valores[1].keys().empty():
			return resultado
		if tipos.es_un_numero(resultado):
			return HUB.error(HUB.errores.error("los modificadores no se pueden aplicar a números"), modulo)
		return aplicar_modificaciones(resultado, valores[1])
	# MODS -> mod EXPR MODS
	if produccion == 7: # TODO: ¿chequear repetidos? :p y :n no tiene sentido pero :s podría tener varios
		var dic = valores[2]
		var i = HUB.varios.str_desde(valores[0], 1)
		if modificador_admite_varios(i):
			if i in dic:
				dic[i].push_front(valores[1])
			else:
				dic[i] = [valores[1]]
		else:
			dic[i] = valores[1] # Por ahora, me quedo con el primero
		return dic
	# MODS -> []
	if produccion == 8:
		return {}
	# ARGS -> []
	if produccion == 9:
		return [[],{}]
	# ARGS -> ( ARGN )
	if produccion == 10:
		return valores[1]
	# ARGN -> ARG
	if produccion == 11:
		if (valores[0][0].empty()):
			return [[valores[0][1]],{}]
		else:
			return [[],{valores[0][0]:valores[0][1]}]
	# ARGN -> ARGN , ARG
	if produccion == 12:
		if (valores[2][0].empty()):
			valores[0][0].append(valores[2][1])
		else:
			valores[0][1][valores[2][0]] = valores[2][1]
		return valores[0]
	# EXPR -> EXPR op TERM
	if produccion == 13:
		if tipos.es_un_numero(valores[0]) and tipos.es_un_numero(valores[2]):
			if valores[1] == '+':
				return valores[0] + valores[2]
			elif valores[1] == '-':
				return valores[0] - valores[2]
		return HUB.error(HUB.errores.error("no se pueden sumar si no son números"), modulo)
	# EXPR -> TERM
	if produccion == 14:
		return valores[0]
	# TERM -> TERM op FACT
	if produccion == 15:
		if tipos.es_un_numero(valores[0]) and tipos.es_un_numero(valores[2]):
			if valores[1] == '*':
				return valores[0] * valores[2]
			elif valores[1] == '%':
				return valores[0] / valores[2]
		return HUB.error(HUB.errores.error("no se pueden multiplicar si no son números"), modulo)
	# TERM -> FACT
	if produccion == 16:
		return valores[0]
	# FACT -> -FACT
	if produccion == 17:
		if tipos.es_un_numero(valores[1]):
			return -1*valores[1]
		return HUB.error(HUB.errores.error("no se puede negar si no es un número"), modulo)
	# FACT -> ( START )
	if produccion == 18:
		return valores[1]
	# FACT -> PRIM ARGS
	if produccion == 19:
		if valores[1][0].empty() and valores[1][1].keys().empty():
			# Lo devuelvo como texto ya que no sé para qué se va a usar
			return valores[0]
		if tipos.es_un_numero(valores[0]):
			return HUB.error(HUB.errores.error("los números no llevan argumentos"), modulo)
		return [valores[0], valores[1]]
	# PRIM -> variable
	if produccion == 20:
		return valores[0]
	# PRIM -> number
	if produccion == 21:
		return HUB.varios.num(valores[0])
	# ARG -> EXPR
	if produccion == 22:
		return ["",valores[0]]
	# ARG -> variable : EXPR
	if produccion == 23:
		return [valores[0],valores[2]]
	return null

# Auxiliares

func aplicar_modificaciones(algo, mods):
	var resultado = algo
	var hijo_de = null
	for modificador in mods.keys():
		# NOMBRE
		if (modificador == "n"):
			if HUB.objetos.es_un_objeto(resultado):
				resultado.nombrar(mods["n"])
			else:
				resultado.set_name(mods["n"])
		# PARENT
		elif (modificador == "p"):
			if esta_definido(mods["p"]):
				hijo_de = obtener(mods["p"])
			else:
				hijo_de = HUB.objetos.localizar(mods["p"])
				if HUB.errores.fallo(hijo_de):
					return HUB.error(parent_invalido(mods["p"], hijo_de), modulo)
		# SCRIPT
		elif (modificador == "s"):
			if tipos.es_un_componente(resultado):
				resultado = componente_a_objeto(resultado)
			var scripts = mods["s"]
			for script in scripts:
				var args = [[],{}]
				if tipos.es_una_lista(script):
					args = script[1]
					script = script[0]
				var c = resultado.agregar_comportamiento(script, args)
				if HUB.errores.fallo(c):
					return HUB.error(HUB.errores.error('No se pudo agregar el comportamiento "' + script + '".', c), modulo)
		# OFFSET
		elif (modificador.begins_with("o")):
			var eje = modificador[1]
			var movimiento = Vector3(0,0,0)
			var valor = mods[modificador]
			if tipos.es_un_string(valor):
				if esta_definido(valor):
					valor = obtener(valor)
				else:
					return HUB.error(HUB.errores.error('La variable "' + valor + '" no está definida.'), modulo)
			if not tipos.es_un_numero(valor):
				return HUB.error(HUB.errores.error('Tipo inválido para el modificador "' + modificador + '".'), modulo)
			if eje == "x":
				movimiento.x = valor
			elif eje == "y":
				movimiento.y = valor
			elif eje == "z":
				movimiento.z = valor
			if HUB.objetos.es_un_objeto(resultado):
				resultado.mover(movimiento)
			else:
				resultado.translate(movimiento)
		else:
			return HUB.error(modificador_invalido(modificador), modulo)
	if hijo_de != null:
		if tipos.es_un_componente(resultado):
			resultado = componente_a_objeto(resultado)
		hijo_de.agregar_hijo(resultado)
	return resultado

func base(texto, argumentos):
	# OJO: "argumentos" es un par lista-diccionario
	var resultado = null
	# Primitivas:
	if has_method("crear_"+texto): # Forma elegante de preguntar si es una primitiva
		var args = HUB.varios.parsear_argumentos_general(arg_map[texto], argumentos, modulo)
		if HUB.errores.fallo(args):
			return HUB.error(HUB.errores.error("No se pudo crear una primitiva de tipo "+texto+".", args), modulo)
		resultado = call("crear_"+texto, args)
	elif esta_definido(texto) and argumentos.empty():
		resultado = obtener(texto)
	elif HUB.archivos.existe("objetos/", texto + ".gd"):
		resultado = desde_archivo(texto, argumentos)
	elif argumentos.empty():
		resultado = texto
	else:
		return HUB.error(HUB.errores.error("primitiva no definida"), modulo)
	return resultado

func definir(clave, valor):
	pila_entorno[0][clave] = valor

func obtener(clave):
	if clave in pila_entorno[0]:
		return pila_entorno[0][clave]
	return null

func esta_definido(clave):
	return pila_entorno[0].has(clave)

func componente_a_objeto(componente):
	var nuevo_objeto = HUB.objetos.crear(null)
	nuevo_objeto.agregar_componente(componente)
	if not componente.get_name().begins_with("@@"):
		nuevo_objeto.nombrar(componente.get_name())
	return nuevo_objeto

func desde_archivo(nombre, argumentos):
	# OJO: "argumentos" es un par lista-diccionario
	var contenido_archivo = HUB.archivos.leer("objetos/", nombre + ".gd", "Objeto")
	if HUB.errores.fallo(contenido_archivo):
		return contenido_archivo
	# La función leer retornó ok, así que esto no puede fallar:
	var tipo_archivo = contenido_archivo.split("\n")[2]
	tipo_archivo = HUB.varios.str_desde(tipo_archivo,3)
	if tipo_archivo == "HUB3DLang":
		var entorno = {}
		var i=1
		for argumento in argumentos[0]:
			entorno[str(i)] = argumento
			i+=1
		for argumento in argumentos[1].keys():
			entorno[argumento] = argumentos[1][argumento]
		return parsear(contenido_archivo, entorno)
	if tipo_archivo == "Funcion":
		var resultado = HUB.objetos.generar(nombre, argumentos)
		if tipos.es_un_string(resultado):
			return parsear(resultado)
		return resultado
	# Nunca debería llegar acá...
	return null

var arg_map = {
	"body":{
		"lista":[
			{"nombre":"tipo", "codigo":"t", "default":"static"}
		]
	},
	"luz":{
		"lista":[
			{"nombre":"tipo", "codigo":"t", "default":"omni"}
		]
	},
	"camara":{
		"lista":[
		]
	},
	"_":{
		"lista":[
		]
	}
}

var tipos_body = {
	"static":StaticBody,
	"kinematic":KinematicBody
}

func crear_body(argumentos):
	var tipo = argumentos["t"]
	if tipo in tipos_body.keys():
		var resultado = tipos_body[tipo].new()
		resultado.set_name("body")
		return resultado
	return HUB.error(HUB.errores.error("Tipo de body inválido: "+tipo), modulo)

var tipos_luz = {
	"omni":OmniLight
}

func crear_luz(argumentos):
	var tipo = argumentos["t"]
	if tipo in tipos_luz.keys():
		var resultado = tipos_luz[tipo].new()
		resultado.set_name("luz")
		return resultado
	return HUB.error(HUB.errores.error("Tipo de luz inválido: "+tipo), modulo)

func crear_camara(argumentos):
	var resultado = Camera.new()
	resultado.set_name("cámara")
	return resultado

func crear__(argumentos):
	return HUB.objetos.crear(null)

func modificador_admite_varios(mod):
	return mod in ["s"]

# Errores

# identificador invalido
func identificador_invalido(id, stack_error = null):
	return HUB.errores.error('El identificador "' +\
	id + '" no está definido.', stack_error)

# modificador invalido
func modificador_invalido(modificador, stack_error = null):
	return HUB.errores.error('El modificador "' +\
	modificador + '" no está definido.', stack_error)

# parent invalido
func parent_invalido(parent, stack_error = null):
	return HUB.errores.error('No se puede anidar el nuevo objeto bajo el padre "' +\
	parent + '".', stack_error)
