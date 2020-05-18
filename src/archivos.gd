## Archivos
## SRC

# Maneja el acceso a archivos.
# Requiere para inicializar:
	# -

extends Node

var HUB
var modulo = "ARCHIVOS"
# Interfaz para acceder al sistema de archivos del SO
var file_system

# Códigos de subtipo válidos para el tipo Objeto
var codigos_objeto = ["HUB3DLang","Funcion"]
# Códigos válidos de tipo script
var codigos_script = ["SRC"]

# ¿Ejecutando la versión compilada?
var compilado
# ¿Los fuentes están en userFS?
var userFS_src
# OS
var os
# La verdadera ubicación de los archivos de usuario
# Si estoy en el editor o usando el FS del usuario, es igual a la ruta raiz
var ruta_user = "user://"

func inicializar(hub):
	HUB = hub
	compilado = not OS.is_debug_build()
	userFS_src = Globals.get("userfs")
	os = OS.get_name()
	if os == "HTML5":
		ruta_user = "/userfs/"
	if userFS_src or not compilado:
		ruta_user = HUB.ruta_raiz
	file_system = FileSystem.new(compilado, userFS_src, os, HUB.ruta_raiz)
	return true

# Carga el contenido de un archivo
func abrir(ruta, nombre, tipo=null):
	if not existe(ruta, nombre):
		return HUB.error(archivo_inexistente(ruta, nombre), modulo)
	var data_archivo = fs_load(ruta + nombre)
	if tipo != null: # Verificaciones adicionales
		var verificacion_encabezado = verificar_encabezado(
			ruta, nombre, nombre.replace(".gd",""), tipo)
		if HUB.errores.fallo(verificacion_encabezado):
			return HUB.error(archivo_invalido(nombre, tipo, verificacion_encabezado), modulo)
		if tipo in codigos_script:
			var verificacion_funciones = verificar_funciones(
				nombre, data_archivo, tipo)
			if HUB.errores.fallo(verificacion_funciones):
				return HUB.error(archivo_invalido(nombre, tipo, verificacion_funciones), modulo)
	return data_archivo

# Carga el contenido de un archivo como texto
func leer(ruta, nombre):
	if existe_user(ruta + nombre):
		return file_system.leer(ruta_user + ruta + nombre)
	if existe_raiz(ruta + nombre):
		# Sólo lo puedo abrir si no es un script
		if file_system.nombre_real(nombre).ends_with(".gdc"):
			return HUB.error(archivo_binario(ruta, nombre), modulo)
		return file_system.leer(HUB.ruta_raiz + ruta + nombre)
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Escribe texto al final de un archivo existente
func escribir(ruta, nombre, contenido, en_nueva_linea=true):
	if existe_user(ruta + nombre):
		file_system.escribir(ruta_user + ruta + nombre, contenido, en_nueva_linea)
		return null
	if existe_raiz(ruta + nombre):
		return HUB.error(solo_lectura(ruta, nombre), modulo)
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Sobrescribe el contenido de un archivo existente
func sobrescribir(ruta, nombre, contenido):
	if existe_user(ruta + nombre):
		file_system.sobrescribir(ruta_user + ruta + nombre, contenido)
		return null
	if existe_raiz(ruta + nombre):
		return HUB.error(solo_lectura(ruta, nombre), modulo)
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Determina si un archivo existe
func existe(ruta, nombre):
	return existe_user(ruta + nombre) or existe_raiz(ruta + nombre)

# Determina si un archivo es un archivo (no es un directorio)
func es_archivo(ruta, nombre):
	if existe_user(ruta + nombre):
		return file_system.es_archivo(ruta_user + ruta + nombre)
	if existe_raiz(ruta + nombre):
		return file_system.es_archivo(HUB.ruta_raiz + ruta + nombre)
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Determina si un archivo es un directorio
func es_directorio(ruta, nombre):
	if existe_user(ruta + nombre):
		return file_system.es_directorio(ruta_user + ruta + nombre)
	if existe_raiz(ruta + nombre):
		return file_system.es_directorio(HUB.ruta_raiz + ruta + nombre)
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Crea un nuevo archivo vacío
func crear(ruta, nombre):
	if existe_user(ruta + nombre):
		return HUB.error(archivo_ya_existe(ruta, nombre), modulo)
	crear_carpetas_intermedias(ruta + nombre)
	file_system.crear(ruta_user + ruta + nombre)
	return null

# Crea una nueva carpeta
func crear_carpeta(ruta, nombre):
	if existe_user(ruta + nombre):
		return HUB.error(archivo_ya_existe(ruta, nombre), modulo)
	crear_carpetas_intermedias(ruta + nombre)
	file_system.crear_carpeta(ruta_user + ruta, nombre)
	return null

# Borrar un archivo
func borrar(ruta, nombre):
	if existe_user(ruta + nombre):
		file_system.borrar(ruta_user + ruta + nombre)
		return null
	if existe_raiz(ruta + nombre):
		return HUB.error(solo_lectura(ruta, nombre), modulo)
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Listar archivos en un directorio
func listar(ruta, carpeta):
	var lista_user = existe_user(ruta + carpeta)
	var lista_raiz = existe_raiz(ruta + carpeta)
	if lista_user or lista_raiz:
		if es_directorio(ruta, carpeta):
			if lista_user:
				return file_system.listar(ruta_user + ruta + carpeta)
			if lista_raiz:
				return file_system.listar(HUB.ruta_raiz + ruta + carpeta)
		return HUB.error(no_es_un_directorio(ruta, carpeta), modulo)
	return HUB.error(archivo_inexistente(ruta, carpeta), modulo)

# Funciones auxiliares

func crear_carpetas_intermedias(ruta):
	var carpetas = (ruta).split("/")
	carpetas.resize(carpetas.size()-1)
	var nueva_ruta = ""
	for carpeta in carpetas:
		if not existe(nueva_ruta, carpeta):
			file_system.crear_carpeta(ruta_user + nueva_ruta, carpeta)
		nueva_ruta += carpeta + "/"

func fs_load(ruta):
	if existe_user(ruta):
		return load(ruta_user + ruta)
	if existe_raiz(ruta):
		return load(HUB.ruta_raiz + ruta)

func existe_user(ruta):
	return file_system.existe(ruta_user + ruta)

func existe_raiz(ruta):
	return file_system.existe(HUB.ruta_raiz + ruta)

func verificar_encabezado(ruta, archivo, nombre, codigo_tipo):
	# Asume que el archivo existe y por lo tanto, leer no falla
	if not existe_user(ruta + archivo):
		# El encabezado fue eliminado, no se puede hacer nada
		return ""
	var contenido = leer(ruta, archivo).split("\n")
	if contenido.size() < 2:
		return HUB.error(encabezado_faltante(archivo), modulo)
	if not (contenido[0].begins_with("## ") and contenido[1].begins_with("## ")):
		return HUB.error(encabezado_faltante(archivo), modulo)
	if contenido[0].to_lower() != "## " + nombre.to_lower():
		return HUB.error(encabezado_invalido_nombre(archivo, nombre), modulo)
	if contenido[1] != "## " + codigo_tipo:
		return HUB.error(encabezado_invalido_tipo(archivo, codigo_tipo), modulo)
	if codigo_tipo == "Objeto":
		if not (
			contenido.size() > 2 and \
			contenido[2].begins_with("## ") and \
			contenido[2].substr(3,contenido[2].length()-3) in codigos_objeto
		):
			return HUB.error(encabezado_invalido_objeto(archivo), modulo)
	return ""

func verificar_funciones(archivo, script, codigo_tipo):
	var nodo = Node.new()
	nodo.set_name(archivo)
	nodo.set_script(script)
	if codigo_tipo == "Programa":
		var verificacion_inicializar = \
			HUB.errores.verificar_implementa_funcion(nodo,"inicializar",3)
		if HUB.errores.fallo(verificacion_inicializar):
			return HUB.error(funciones_no_implementadas(archivo, codigo_tipo, verificacion_inicializar), modulo)
		var verificacion_finalizar = \
			HUB.errores.verificar_implementa_funcion(nodo,"finalizar",0)
		if HUB.errores.fallo(verificacion_finalizar):
			return HUB.error(funciones_no_implementadas(archivo, codigo_tipo, verificacion_finalizar), modulo)
	else:
		var verificacion_inicializar = \
			HUB.errores.verificar_implementa_funcion(nodo,"inicializar",1)
		if HUB.errores.fallo(verificacion_inicializar):
			return HUB.error(funciones_no_implementadas(archivo, codigo_tipo, verificacion_inicializar), modulo)
	if codigo_tipo == "Comando":
		var verificacion_comando = \
			HUB.errores.verificar_implementa_funcion(nodo,"comando",1)
		if HUB.errores.fallo(verificacion_comando):
			return HUB.error(funciones_no_implementadas(archivo, codigo_tipo, verificacion_comando), modulo)
	return ""

class FileSystem:
	var file
	var dir
	var compilado
	var userFS
	var os
	var nombres_compilados
	var ruta_raiz
	func _init(compilado, userFS, os, ruta_raiz):
		self.file = File.new()
		self.dir = Directory.new()
		self.compilado = compilado
		self.userFS = userFS
		self.os = os
		self.nombres_compilados = compilado and (not userFS)
		self.ruta_raiz = ruta_raiz
	func leer(ruta_al_archivo):
		var ruta = nombre_real(ruta_al_archivo)
		file.open(ruta, File.READ)
		var contenido = file.get_as_text()
		file.close()
		return contenido
	func escribir(ruta_al_archivo, contenido, en_nueva_linea=true):
		file.open(ruta_al_archivo, File.READ_WRITE)
		var contenido_a_escribir = contenido
		var contenido_actual = file.get_as_text()
		if en_nueva_linea and not contenido_actual.empty():
			contenido_a_escribir = contenido_actual + "\n" + contenido_a_escribir
		file.store_string(contenido_a_escribir)
		file.close()
	func sobrescribir(ruta_al_archivo, contenido):
		file.open(ruta_al_archivo, File.WRITE)
		file.store_string(contenido)
		file.close()
	func existe(ruta_al_archivo):
		return es_archivo(ruta_al_archivo) or es_directorio(ruta_al_archivo)
	func es_archivo(ruta_al_archivo):
		for ruta in posibles_rutas(ruta_al_archivo):
			if file.file_exists(ruta):
				return true
		return false
	func es_directorio(ruta_al_archivo):
		print(ruta_al_archivo)
		if nombres_compilados and ruta_al_archivo.begins_with(ruta_raiz):
			print("NO SÉ SI ES UNA CARPETA")
			return false
		print(dir.dir_exists(ruta_al_archivo))
		return dir.dir_exists(ruta_al_archivo)
	func crear(ruta_al_archivo):
		file.open(ruta_al_archivo, File.WRITE)
		file.close()
	func crear_carpeta(ruta, archivo):
		dir.open(ruta)
		dir.make_dir(archivo)
	func borrar(ruta_al_archivo):
		if es_archivo(ruta_al_archivo):
			dir.remove(ruta_al_archivo)
		else:
			var archivos = listar(ruta_al_archivo)
			for archivo in archivos:
				borrar(ruta_al_archivo+"/"+archivo)
			dir.remove(ruta_al_archivo)
	func listar(ruta):
		print("LISTAR "+ruta)
		if nombres_compilados and ruta.begins_with(ruta_raiz):
			print("NO PUEDO LISTAR")
			return []
		var archivos = []
		dir.open(ruta)
		dir.list_dir_begin()
		var archivo = dir.get_next()
		while (archivo != ""):
			if not archivo.begins_with("."):
				archivos.append(nombre_abstracto(archivo))
			archivo = dir.get_next()
		dir.list_dir_end()
		return archivos
	# Asume que el archivo existe (en alguna variante)
	func nombre_real(ruta_original):
		if nombres_compilados and \
			ruta_original.begins_with(ruta_raiz) and \
			ruta_original.ends_with(".gd"):
			if file.file_exists(ruta_original + "c"):
				return ruta_original + "c"
			if file.file_exists(ruta_original.replace(".gd",".h")):
				return ruta_original.replace(".gd",".h")
		return ruta_original
	func nombre_abstracto(ruta_real):
		if nombres_compilados:
			if ruta_real.ends_with(".gdc"):
				return ruta_real.substr(0, ruta_real.length()-2)
			if ruta_real.ends_with(".h"):
				return ruta_real.substr(0, ruta_real.length()-2) + "gd"
		return ruta_real
	func posibles_rutas(ruta_al_archivo):
		var resultado = [ruta_al_archivo]
		if ruta_al_archivo.ends_with(".gd") and \
			nombres_compilados and \
			ruta_al_archivo.begins_with(ruta_raiz):
				resultado.append(ruta_al_archivo.replace(".gd",".h"))
				resultado.append(ruta_al_archivo+"c")
		return resultado

# Errores

# Archivo inexistente
func archivo_inexistente(ruta, archivo, stack_error=null):
	return HUB.errores.error('El archivo "' + archivo + \
	'" no se encuentra en la ' + ('ruta raíz.' if ruta.empty() else \
	'carpeta "' + ruta + '".'), stack_error)

# Archivo ya existe
func archivo_ya_existe(ruta, archivo, stack_error=null):
	return HUB.errores.error('No se puede crear el archivo "' + \
	archivo + '" en la ' + ('ruta raíz.' if ruta.empty() else \
	'carpeta "' + ruta + '" porque ya existe.'), stack_error)

# Archivo binario
func archivo_binario(ruta, archivo, stack_error=null):
	return HUB.errores.error('El archivo "' + archivo + \
	'" en la ' + ('ruta raíz.' if ruta.empty() else \
	'carpeta "' + ruta + '" no se puede leer porque es ' + \
	'un archivo binario.'), stack_error)

# Archivo de sólo lectura
func solo_lectura(ruta, archivo, stack_error=null):
	return HUB.errores.error('El archivo "' + archivo + \
	'" en la ' + ('ruta raíz.' if ruta.empty() else \
	'carpeta "' + ruta + '" es de sólo lectura.'), stack_error)

# Archivo inválido
func archivo_invalido(archivo, tipo, stack_error=null):
	return HUB.errores.error('El archivo "' + archivo + \
	'" no es un archivo válido de tipo "' + tipo + '".', stack_error)

# Encabezado faltante
func encabezado_faltante(archivo, stack_error=null):
	return HUB.errores.error('El archivo "' + archivo + \
	'" no tiene encabezado. Las dos primeras líneas deberían ' + \
	'contener empezar con "## ".', stack_error)

# Encabezado inválido nombre
func encabezado_invalido_nombre(archivo, nombre, stack_error=null):
	return HUB.errores.error('El encabezado del archivo "' + archivo + \
	'" es inválido. La primera línea debería ser "## ' + nombre + '".',
	stack_error)

# Encabezado inválido tipo
func encabezado_invalido_tipo(archivo, tipo, stack_error=null):
	return HUB.errores.error('El encabezado del archivo "' + archivo + \
	'" es inválido. La segunda línea debería ser "## ' + tipo + '".',
	stack_error)

# Encabezado inválido objeto
func encabezado_invalido_objeto(archivo, tipo, stack_error=null):
	return HUB.errores.error('El encabezado del archivo "' + archivo + \
	'" es inválido. La tercera línea debería ser "## ", seguido del tipo de objeto.',
	stack_error)

# Archivo inválido (funciones no implementadas)
func funciones_no_implementadas(archivo, tipo, stack_error=null):
	return HUB.errores.error('El archivo "' + archivo + \
	'" no implementa las funciones necesarias para ser un archivo ' + \
	'válido de tipo "' + tipo + '".', stack_error)

# No es un directorio
func no_es_un_directorio(ruta, archivo, stack_error=null):
	return HUB.errores.error('El archivo "' + archivo + \
	'" en la ' + ('ruta raíz' if ruta.empty() else \
	'carpeta "' + ruta + '"') + ' no es una carpeta.', stack_error)