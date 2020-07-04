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

# CACHE:
var pila_entorno = []	# Diccionarios con "path", "pid", "caching", "data" (sólo argumentos)
var cache = {}			# Variables y objetos generados en estructura tipo FS

func inicializar(hub):
	HUB = hub
	tipos = HUB.bibliotecas.importar("tipos")
	if HUB.errores.fallo(tipos):
		return HUB.error(HUB.errores.inicializar_fallo(self, tipos), modulo)
	parser_lib = HUB.bibliotecas.importar("parser")
	if HUB.errores.fallo(parser_lib):
		return HUB.error(HUB.errores.inicializar_fallo(self, parser_lib), modulo)
	var tds = HUB3DLangTDS.new(self)
	var regex_int = "[0-9]+"
	var regex_float = "[0-9]*\\.[0-9]+"
	var regex_num = "("+regex_float+")|("+regex_int+")"
	var regex_letr = "[a-zA-Z]|_"
	var regex_var = "("+regex_letr+")("+regex_letr+"|/|[0-9])*"
	var regex_opT = "\\+|-|!"
	var regex_num_letrs = "("+regex_num+")("+regex_letr+")+"
	var regex_letrs_float = "("+regex_letr+")+("+regex_float+")"
	var regex_valid = "("+regex_var+")|("+regex_num+")"
	var regex_ex1 = "("+regex_opT+")?"+"(("+regex_num_letrs+")|("+regex_letrs_float+"))"
	var regex_any = "(("+regex_opT+")?("+regex_valid+"))|("+regex_ex1+")"
	var regex_ex = "("+regex_any+")*"+regex_ex1+"("+regex_any+")*"
	var valid_mods = "n|p|s|ox|oy|oz|olx|oly|olz|rx|ry|rz|c|m"
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
		["FACT",["opT","FACT"]],						# 17
		# Acá me tengo que asegurar que ese FACT sea un número
		["FACT",["(","START",")"]],						# 18
		["FACT",["PRIM","ARGS"]],						# 19
		# Si tiene argumentos, lo devuelvo como un par
		["PRIM",["variable"]],							# 20
		["PRIM",["numero"]],							# 21
		["ARG",["LARG"]],								# 22
		["ARG",["variable","=","LARG"]],				# 23
		["LARG",["LARG",";","STRING"]],					# 24
		["LARG",["STRING"]],							# 25
		["STRING",["EXPR"]],							# 26
		["STRING",["string"]],							# 27
		["ARG",["=","variable"]],						# 28 # Bool
		["C",[]],										# 29
		["C",["comentario"]]							# 30
	], {
		"variable":regex_var,		# variables
		"numero":regex_num, 		# números
		"mod":":("+valid_mods+")",	# ':' seguido de un identificador de modificador
		"comentario":"#.*",			# Cualquier cosa iniciada con un '#'
		"opT":regex_opT,			# '+', '-' y '!'
		"opF":"\\*|%",				# '*' y '%' (la diagonal '/' la uso para rutas a archivos)
		"string":regex_ex
	}, tds)

func crear(texto, entorno={}):
	if not "caching" in entorno:
		entorno["caching"] = true
	if not "pid" in entorno:
		entorno["pid"] = "HUB" # TODO: Pedir el pid a HUB.procesos (¿actual o en foco?)
	if not "path" in entorno:
		entorno["path"] = null
	if not "data" in entorno:
		entorno["data"] = {}
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
	if "$" in entorno["data"].keys(): # OJO: ¿Dónde guardo la variable "$"?
		raiz = entorno["data"]["$"]
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
		definir("$", valores[2])
		return null
	# I -> $ variable = START C
	if produccion == 2:
		definir(valores[1], valores[3])
		return null
	# START -> HOME
	if produccion == 3:
		if valores[0].size() == 1:
			var resultado = valores[0][0]
			if tipos.es_un_mesh_rep(resultado):
				resultado = resultado.make()
			if tipos.es_un_componente(resultado):
				resultado = componente_a_objeto(resultado)
			return resultado
		var objetos = []
		var componentes = []
		var meshes = []
		for elemento in valores[0]:
			if HUB.objetos.es_un_objeto(elemento) and elemento.padre() == null:
				objetos.append(elemento)
			elif tipos.es_un_componente(elemento):
				componentes.append(elemento)
			elif tipos.es_un_mesh_rep(elemento):
				meshes.append(elemento)
		if not meshes.empty():
			componentes.append(mesh_a_partir_de_reps(meshes))
		var nuevo_objeto = HUB.objetos.crear(null)
		for componente in componentes:
			nuevo_objeto.agregar_componente(componente)
		for objeto in objetos:
			nuevo_objeto.agregar_hijo(objeto)
		return nuevo_objeto
	# HOME -> HOME & OBJ
	if produccion == 4:
		if HUB.objetos.es_un_objeto(valores[2]) or tipos.es_un_componente(valores[2]) or tipos.es_un_mesh_rep(valores[2]):
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
			if HUB.errores.fallo(resultado):
				return resultado
			if tipos.es_un_string(resultado):
				resultado = obtener(valores[0])
				if resultado == null:
					return HUB.error(identificador_invalido(resultado), modulo)
		if tipos.es_una_lista(resultado):
			resultado = base(resultado[0], resultado[1])
			if HUB.errores.fallo(resultado):
				return resultado
		if valores[1].keys().empty():
			return resultado
		if tipos.es_un_numero(resultado):
			return HUB.error(HUB.errores.error("los modificadores no se pueden aplicar a números"), modulo)
		return aplicar_modificaciones(resultado, valores[1])
	# MODS -> mod EXPR MODS
	if produccion == 7:
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
		var valor1 = valores[0]
		if tipos.es_un_string(valor1):
			valor1 = obtener_si_esta(valor1)
		var valor2 = valores[2]
		if tipos.es_un_string(valor2):
			valor2 = obtener_si_esta(valor2)
		if tipos.es_un_numero(valor1) and tipos.es_un_numero(valor2):
			if valores[1] == '+':
				return valor1 + valor2
			elif valores[1] == '-':
				return valor1 - valor2
			else: # !
				return HUB.error(HUB.errores.error("no se puede usar '!' como operador entre números"), modulo)
		return str(valores[0])+str(valores[1])+str(valores[2])
	# EXPR -> TERM
	if produccion == 14:
		return valores[0]
	# TERM -> TERM op FACT
	if produccion == 15:
		var valor1 = valores[0]
		if tipos.es_un_string(valor1):
			valor1 = obtener_si_esta(valor1)
		var valor2 = valores[2]
		if tipos.es_un_string(valor2):
			valor2 = obtener_si_esta(valor2)
		if tipos.es_un_numero(valor1) and tipos.es_un_numero(valor2):
			if valores[1] == '*':
				return valor1 * valor2
			elif valores[1] == '%':
				return valor1 / valor2
		return HUB.error(HUB.errores.error("no se puede operar si no son números"), modulo)
	# TERM -> FACT
	if produccion == 16:
		return valores[0]
	# FACT -> op FACT
	if produccion == 17:
		var valor = valores[1]
		if tipos.es_un_string(valor):
			valor = obtener_si_esta(valor)
		if tipos.es_un_numero(valor):
			if valores[0] == '+':
				return valor
			elif valores[0] == '-':
				return -1*valor
			else: # !
				return "!" + str(valor)
		return str(valores[0])+str(valores[1])
	# FACT -> ( START )
	if produccion == 18:
		return valores[1]
	# FACT -> PRIM ARGS
	if produccion == 19:
		if tipos.es_un_string(valores[0]) and valores[0] == "random":
			return random(valores[1][0])
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
	# ARG -> LARG
	if produccion == 22:
		var resultado = valores[0]
		if resultado.size() == 1:
			resultado = resultado[0]
		return ["",resultado]
	# ARG -> variable : LARG
	if produccion == 23:
		var resultado = valores[2]
		if resultado.size() == 1:
			resultado = resultado[0]
		return [valores[0],resultado]
	# LARG -> LARG ; STRING
	if produccion == 24:
		var resultado = valores[0]
		resultado.append(valores[2])
		return resultado
	# LARG -> STRING
	if produccion == 25:
		return [valores[0]]
	# STRING -> EXPR
	if produccion == 26:
		return valores[0]
	# STRING -> string
	if produccion == 27:
		return valores[0]
	# ARG -> = variable
	if produccion == 28:
		return [valores[1],""]
	return null

# Auxiliares

func aplicar_modificaciones(algo, mods):
	var resultado = algo
	var hijo_de = null
	for modificador in mods.keys():
		if tipos.es_un_mesh_rep(resultado) and modificador_invalido_en_mesh_rep(modificador):
			resultado = resultado.make()
		# NOMBRE
		if (modificador == "n"):
			if HUB.objetos.es_un_objeto(resultado):
				resultado.nombrar(mods["n"])
			else:
				resultado.set_name(mods["n"])
		# PARENT
		elif (modificador == "p"):
			pass # Revisar: lo que está en el cache son definiciones de objetos, no objetos.
				 # Debería usar sólo el "localizar" pero puede fallar si todavía no lo agregué al árbol.
				 # Solución: Guardar otro diccionario de nombres -> objetos 
			#if esta_definido(mods["p"]):
			#	hijo_de = obtener(mods["p"])
			#else:
			#	hijo_de = HUB.objetos.localizar(mods["p"])
			#	if HUB.errores.fallo(hijo_de):
			#		return HUB.error(parent_invalido(mods["p"], hijo_de), modulo)
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
			var local = false # ¿relativo a la rotación?
			var eje = modificador[1]
			if eje == "l":
				local = true
				eje = modificador[2]
			var movimiento = Vector3(0,0,0)
			var valor = mods[modificador]
			if tipos.es_un_string(valor):
				valor = obtener_como_numero(valor)
				if HUB.errores.fallo(valor):
					return valor
			if not tipos.es_un_numero(valor):
				return HUB.error(HUB.errores.error('Tipo inválido para el modificador "' + modificador + '".'), modulo)
			if eje == "x":
				movimiento.x = valor
			elif eje == "y":
				movimiento.y = valor
			elif eje == "z":
				movimiento.z = valor
			else:
				return HUB.error(HUB.errores.error('Eje inválido para el modificador "' + modificador + '".'), modulo)
			if local or tipos.es_un_mesh_rep(resultado):
				resultado.translate(movimiento)
			else:
				resultado.set_translation(resultado.get_transform().origin + movimiento)
		# ROTATE
		elif (modificador.begins_with("r")):
			var eje = modificador[1]
			var valor = mods[modificador]
			if tipos.es_un_string(valor):
				valor = obtener_como_numero(valor)
				if HUB.errores.fallo(valor):
					return valor
			if not tipos.es_un_numero(valor):
				return HUB.error(HUB.errores.error('Tipo inválido para el modificador "' + modificador + '".'), modulo)
			if eje == "x":
				resultado.rotate_x(valor)
			elif eje == "y":
				resultado.rotate_y(valor)
			elif eje == "z":
				resultado.rotate_z(valor)
			else:
				return HUB.error(HUB.errores.error('Eje inválido para el modificador "' + modificador + '".'), modulo)
		# COLLIDER
		elif (modificador == "c"):
			var body = null
			if tipos.es_un_componente(resultado):
				if resultado.has_method("add_shape"):
					body = resultado
				else:
					return HUB.error(HUB.errores.error('No se puede agregar el colisionador si el componente no es un body'), modulo)
			else:
				# revisar si algún componente es de tipo body y si no:
				return HUB.error(HUB.errores.error('No se puede agregar el colisionador si el objeto no tiene un componente body'), modulo)
			var resultado_colision = agregar_colisionador(body, mods["c"])
			if HUB.errores.fallo(resultado_colision):
				return resultado_colision
		# MATERIAL
		elif (modificador == "m"):
			var meshes = []
			if tipos.es_un_componente(resultado):
				if resultado.has_method("set_material_override"):
					meshes.append(resultado)
				else:
					return HUB.error(HUB.errores.error('No se puede agregar el material si el componente no es una malla'), modulo)
			else:
				# agregar a "meshes" todos los componentes de tipo meshInstance y luego:
				if meshes.empty():
					return HUB.error(HUB.errores.error('No se puede agregar el material si el objeto no tiene un componente malla'), modulo)
			var resultado_material = agregar_material(meshes, mods["m"])
			if HUB.errores.fallo(resultado_material):
				return resultado_material
		else:
			return HUB.error(modificador_invalido(modificador), modulo)
	if hijo_de != null:
		if tipos.es_un_componente(resultado):
			resultado = componente_a_objeto(resultado)
		hijo_de.agregar_hijo(resultado)
	return resultado

func base(texto, argumentos):
	# OJO: "argumentos" es un par lista-diccionario
	if texto == "_":
		return HUB.objetos.crear(null)
	var sin_argumentos = argumentos[0].empty() and argumentos[1].keys().empty()
	if sin_argumentos:
		var valor = obtener(texto)
		if valor != null:
			return valor
	var archivo = buscar_archivo(texto)
	if archivo != null:
		return desde_archivo(archivo, argumentos)
	if sin_argumentos:
		return texto
	return HUB.error(HUB.errores.error('primitiva "'+texto+'" no definida'), modulo)

func definir(clave, valor):
	var path = pila_entorno[0]["path"]
	if path == null:
		pila_entorno[0]["data"][clave] = valor
	else:
		definir_path(path, clave, valor)

func definir_path(path, clave, valor):
	pass # TODO: Definir en el FS de "cache"

func obtener(clave):
	# Primero la busco en el entorno
	for e in pila_entorno:
		if clave in e["data"]:
			var valor = e["data"][clave]
			if tipos.es_un_nodo(valor):
				return valor.duplicate()
			else:
				return valor
	# Si no está en el entorno, la busco en la cache
	var path = pila_entorno[0]["path"]
	if path != null:
		obtener_path(path, clave)
	return null

func obtener_path(path, clave):
	pass # TODO: Explorar en el FS de "cache"

func obtener_si_esta(clave):
	var valor = obtener(clave)
	if valor == null:
		return clave
	return valor

func obtener_como_numero(clave):
	if clave.is_valid_integer():
		return int(clave)
	if clave.is_valid_float():
		return float(clave)
	var valor = obtener(clave)
	if valor == null:
		return HUB.error(identificador_invalido(clave), modulo)
	return valor

func componente_a_objeto(componente):
	var nuevo_objeto = HUB.objetos.crear(null)
	nuevo_objeto.agregar_componente(componente)
	if not componente.get_name().begins_with("@@"):
		nuevo_objeto.nombrar(componente.get_name())
	return nuevo_objeto

func buscar_archivo(nombre):
	var ruta_actual = pila_entorno[0]["path"]
	if ruta_actual != null:
		var recorrido = ruta_actual.split("/")
		for i in range(recorrido.size()-1):
			var ruta = ""
			for j in range(recorrido.size()-1-i):
				ruta += recorrido[j] + "/"
			ruta = ruta.plus_file(nombre)
			if HUB.archivos.existe("objetos", ruta + ".gd"):
				return ruta
	if HUB.archivos.existe("objetos", nombre + ".gd"):
		return nombre
	return null

func desde_archivo(ruta_completa, argumentos):
	# OJO: "argumentos" es un par lista-diccionario
	var nombre = ruta_completa
	# DELETE::
	# TODO: "nombre" podría ser sólo el último eslabón del path.
		# Todo lo que viene debería estar en un ciclo explorando el path hacia arriba.
#	if caching:
#		if nombre in cache["FILE"]:
#			var cached = cache["FILE"][nombre]
#			if cached[0] == "OBJ":
#				return desde_archivo_obj(cached[1], argumentos)
#			elif cached[0] == "FUNC":
#				return desde_archivo_func(nombre, argumentos)

	# TODO: Explorar distintas rutas posibles
	var contenido_archivo = HUB.archivos.leer("objetos", nombre + ".gd", "Objeto")
	if HUB.errores.fallo(contenido_archivo):
		return contenido_archivo
	# La función leer retornó ok, así que esto no puede fallar:
	var tipo_archivo = contenido_archivo.split("\n")[2]
	tipo_archivo = HUB.varios.str_desde(tipo_archivo,3)
	if tipo_archivo == "HUB3DLang":
		#if caching: # OJO: "nombre" acá tiene que ser el path global
		#	cache["FILE"][nombre] = ["OBJ", contenido_archivo]
		return desde_archivo_obj(contenido_archivo, argumentos)
	if tipo_archivo == "Funcion":
		#if caching: # OJO: "nombre" acá tiene que ser el path global
		#	cache["FILE"][nombre] = ["FUNC", contenido_archivo]
		return desde_archivo_func(nombre, argumentos)
	# Nunca debería llegar acá...
	return null

func desde_archivo_obj(contenido_archivo, argumentos):
	var data_entorno = {}
	var i=1
	for argumento in argumentos[0]:
		data_entorno[str(i)] = argumento
		i+=1
	for argumento in argumentos[1].keys():
		data_entorno[argumento] = argumentos[1][argumento]
	var path = null # TODO: Si el de pila_entorno[0] no es null, concatenarlo a nombre
	var caching = true # TODO: Ver si lleva argumentos, ver el de pila_entorno[0], etc
	var entorno = {
		"data":data_entorno,
		"pid":pila_entorno[0]["pid"],
		"path":path,
		"caching":caching
	}
	return crear(contenido_archivo, entorno)

func desde_archivo_func(nombre, argumentos):
	var resultado = HUB.objetos.generar(nombre, argumentos)
	if tipos.es_un_string(resultado):
		var path = null # TODO: Si el de pila_entorno[0] no es null, concatenarlo a nombre
		var entorno = {
			"data":{}, # ¿No debería pasarle también lo generado en la versión _obj?
			"pid":pila_entorno[0]["pid"],
			"path":path,
			"caching":false # ¿Siempre?
		}
		return crear(resultado, entorno)
	return resultado

func modificador_admite_varios(mod):
	return mod in ["s","c"]

func modificador_invalido_en_mesh_rep(mod):
	return not mod[0] in ["o","r"]

var valid_colls = {
	"plane":{"arg_map":
		{"lista":[
		]},
		"clase":PlaneShape, "nombre":"Plane Collider",
	},
	"box":{"arg_map":
		{"lista":[
			{"nombre":"ancho", "codigo":"w", "default":"!1"},
			{"nombre":"alto", "codigo":"h", "default":"1"},
			{"nombre":"profundidad", "codigo":"p", "default":"!1"}
		]},
		"clase":BoxShape, "nombre":"Box Collider"
	},
	"ball":{"arg_map":
		{"lista":[
			{"nombre":"radio", "codigo":"r", "default":"!1"}
		]},
		"clase":SphereShape, "nombre":"Ball Collider"
	},
	"capsule":{"arg_map":
		{"lista":[
			{"nombre":"radio", "codigo":"r", "default":"!1"},
			{"nombre":"alto", "codigo":"h", "default":"1"},
			{"nombre":"vertical", "codigo":"v", "validar":"BOOL","default":false}
		]},
		"clase":CapsuleShape, "nombre":"Capsule Collider"
	}
}

func agregar_colisionador(body, cs):
	for c in cs:
		var id = c
		var args = [[],{}]
		if tipos.es_una_lista(c):
			id = c[0]
			args = c[1]
		if id in valid_colls.keys():
			args = HUB.varios.parsear_argumentos_general(valid_colls[id]["arg_map"], args, modulo)
			if HUB.errores.fallo(args):
				return args
			var collider = CollisionShape.new()
			var shape = valid_colls[id]["clase"].new()
			var t = Transform()
			var pos = Vector3(0,0,0)
			if id == "box":
				var coordenadas = HUB.varios.coordenadas_cubo(args["w"],args["h"],args["p"], self, tipos, false)
				if HUB.errores.fallo(coordenadas):
					return coordenadas
				pos.x = coordenadas[0]
				var w = coordenadas[1]
				pos.y = coordenadas[2]
				var h = coordenadas[3]
				pos.z = coordenadas[4]
				var p = coordenadas[5]
				shape.set_extents(Vector3(w/2.0,h/2.0,p/2.0))
			elif id in ["ball","capsule"]:
				var r = args["r"]
				var center_r = false
				if tipos.es_un_string(r):
					if r[0] == "!":
						center_r = true
						r = HUB.varios.str_desde(r,1)
					r = obtener_como_numero(r)
					if HUB.errores.fallo(r):
						return r
				if tipos.es_un_numero(r):
					shape.set_radius(r)
				else:
					return HUB.error(HUB.errores.error('Argumento inválido: '+r), modulo)
				if not center_r:
					pos.y = r/2
				if id == "capsule":
					var rotated = args["v"]
					var h = args["h"]
					var center_h = false
					if tipos.es_un_string(h):
						if h[0] == "!":
							center_h = true
							h = HUB.varios.str_desde(h,1)
						h = obtener_como_numero(h)
						if HUB.errores.fallo(h):
							return h
					if tipos.es_un_numero(h):
						shape.set_height(h-2*r)
						if not center_h:
							if rotated:
								pos.z = h/2
							else:
								pos.x = h/2
					else:
						return HUB.error(HUB.errores.error('Argumento inválido: '+h), modulo)
					if rotated:
						t = t.rotated(Vector3(1,0,0),PI/2)
			collider.set_name(valid_colls[id]["nombre"])
			collider.set_shape(shape)
			t = t.translated(pos)
			body.add_shape(shape, t)
			body.add_child(collider)		# DEBUG
			collider.set_transform(t)		# DEBUG
		else:
			return HUB.error(HUB.errores.error('Identificador de colisionador inválido: '+id), modulo)

var material_arg_map = {"lista":[
	{"nombre":"color", "codigo":"c", "default":Color("ffffff"), "validar":"COLOR"}
]}

func agregar_material(meshes, mat):
	var id = mat
	var args = [[],{}]
	if tipos.es_una_lista(mat):
		id = mat[0]
		args = mat[1]
	var material = obtener(id)
	if material != null:
		if typeof(material) != 18 or material.get_type() != "FixedMaterial":
			return HUB.error(HUB.errores.error('No es un material: '+id), modulo)
	elif id != "fixed":
		return HUB.error(HUB.errores.error('Identificador de material inválido: '+id), modulo)
	args = HUB.varios.parsear_argumentos_general(material_arg_map, args, modulo)
	if HUB.errores.fallo(args):
		return HUB.error(HUB.errores.error('No se pudo generar el material', args), modulo)
	if material == null:
		material = FixedMaterial.new()
	material.set("params/diffuse", args["c"])
	for mi in meshes:
		var m = mi.get_mesh()
		for i in range(m.get_surface_count()):
			m.surface_set_material(i, material)

func mesh_a_partir_de_reps(meshes):
	var resultado = meshes[0]
	meshes.pop_front()
	while(not meshes.empty()):
		resultado.merge(meshes[0])
		meshes.pop_front()
	return resultado.make()

func random(argumentos):
	var tipo = "f"
	var rango = [0,1]
	if not argumentos.empty():
		if tipos.es_un_string(argumentos[0]):
			tipo = argumentos[0]
			argumentos.pop_front()
		else:
			tipo = "i"
	if tipo == "f":
		if argumentos.size() == 1:
			rango[1] = argumentos[0]
		else:
			if argumentos.size() > 1:
				rango[0] = argumentos[0]
				rango[1] = argumentos[1]
		return rango[0] + randf()*(rango[1]-rango[0])
	if tipo == "i":
		var step = 1
		if argumentos.size() == 1:
			rango[0] = 1
			rango[1] = argumentos[0]
		else:
			if argumentos.size() > 1:
				rango[0] = argumentos[0]
				rango[1] = argumentos[1]
			if argumentos.size() > 2:
				step = argumentos[2]
		return rango[0] + step*(randi() % ((rango[1]+step-rango[0])/step))
	if tipo == "h":
		return random_hex(argumentos)
	if tipo == "c":
		var args_r = []
		var args_g = []
		var args_b = []
		if argumentos.size() > 0:
			args_r = argumentos[0]
		if argumentos.size() > 1:
			args_g = argumentos[1]
		if argumentos.size() > 2:
			args_b = argumentos[2]
		var r = random_hex(args_r)
		var g = random_hex(args_g)
		var b = random_hex(args_b)
		return r+g+b

func random_hex(argumentos):
	var rango = [0,15]
	if argumentos.size() == 1:
		rango[1] = argumentos[0]
	elif argumentos.size() > 1:
		rango[0] = argumentos[0]
		rango[1] = argumentos[1]
	return int_to_hex(rango[0] + randi() % (rango[1]+1-rango[0]))

func int_to_hex(i):
	if i <= 0:
		return "0"
	if i < 10:
		return str(i)
	if i < 16:
		return ["a","b","c","d","e","f"][i-10]
	return "0"

class MeshRep:
	var vertexes	# Vector3
	var uvs			# Vector2
	var faces		# FaceRep
	var pi_180 = PI/180.0
	func _init(vs, fs, uvs):
		self.vertexes = vs
		self.faces = fs
		self.uvs = uvs
	func merge(otro):
		for f in otro.faces:
			f.plus(vertexes.size(),uvs.size())
			faces.append(f)
		for v in otro.vertexes:
			vertexes.append(v)
		for uv in otro.uvs:
			uvs.append(uv)
		# TODO: Eliminar vértices repetidos
	func rotate_x(a):
		for i in range(vertexes.size()):
			vertexes[i] = vertexes[i].rotated(Vector3(1.0,0.0,0.0),a*pi_180)
	func rotate_y(a):
		for i in range(vertexes.size()):
			vertexes[i] = vertexes[i].rotated(Vector3(0.0,1.0,0.0),a*pi_180)
	func rotate_z(a):
		for i in range(vertexes.size()):
			vertexes[i] = vertexes[i].rotated(Vector3(0.0,0.0,1.0),a*pi_180)
	func translate(a):
		for i in range(vertexes.size()):
			vertexes[i] += a
	func make():
		var mesh = Mesh.new()
		var st = SurfaceTool.new()
		st.begin(VS.PRIMITIVE_TRIANGLES)
		for f in faces:
			if (f.size()==3 or f.size()==4):
				if (f.uvs[2] > -1):
					st.add_uv(uvs[f.uvs[2]])
				st.add_vertex(vertexes[f.vertexes[2]])
				if (f.uvs[1] > -1):
					st.add_uv(uvs[f.uvs[1]])
				st.add_vertex(vertexes[f.vertexes[1]])
				if (f.uvs[0] > -1):
					st.add_uv(uvs[f.uvs[0]])
				st.add_vertex(vertexes[f.vertexes[0]])
			if (f.size()==4):
				if (f.uvs[0] > -1):
					st.add_uv(uvs[f.uvs[0]])
				st.add_vertex(vertexes[f.vertexes[0]])
				if (f.uvs[3] > -1):
					st.add_uv(uvs[f.uvs[3]])
				st.add_vertex(vertexes[f.vertexes[3]])
				if (f.uvs[2] > -1):
					st.add_uv(uvs[f.uvs[2]])
				st.add_vertex(vertexes[f.vertexes[2]])
		st.generate_normals()
		st.index()
		st.commit(mesh)
		var obj = MeshInstance.new()
		obj.set_name("malla")
		obj.set_mesh(mesh)
		return obj

class FaceRep:
	var vertexes	# int
	var uvs			# int
	#var groups		# ??
	func _init(vs, uvs):
		self.vertexes = vs
		self.uvs = uvs
		# Me aseguro que los tamaños coincidan:
		for i in range(vs.size() - uvs.size()):
			self.uvs.append(-1)
	func plus(v, u):
		for i in range(vertexes.size()):
			vertexes[i] += v
		for i in range(uvs.size()):
			uvs[i] += u
	func size():
		return vertexes.size()

func nuevo_mesh_rep(vs, fs, uvs=[]):
	return MeshRep.new(vs, fs, uvs)

func nueva_cara(vs, uvs=[]):
	return FaceRep.new(vs, uvs)

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
