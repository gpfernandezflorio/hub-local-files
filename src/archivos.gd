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

var carpeta_recursos = "recursos"

func inicializar(hub):
	HUB = hub
	file_system = FileSystem.new(HUB.ruta_raiz)
	if not OS.is_debug_build() and not Globals.get("userfs"):
		carpeta_recursos = Globals.get("res_dir").plus_file(carpeta_recursos)
	else:
		carpeta_recursos = HUB.ruta_raiz.plus_file(carpeta_recursos)
	return true

# Carga el contenido de un archivo
func abrir(ruta, nombre, tipo=null):
	if not existe(ruta, nombre):
		return HUB.error(archivo_inexistente(ruta, nombre), modulo)
	if tipo != null: # Verificaciones adicionales
		var contenido = leer(ruta, nombre).split("\n")
		var verificacion_encabezado = verificar_encabezado(
			contenido, ruta, nombre, nombre.replace(".gd",""), tipo)
		if HUB.errores.fallo(verificacion_encabezado):
			return HUB.error(archivo_invalido(nombre, tipo, verificacion_encabezado), modulo)
		if tipo in codigos_script:
			var verificacion_funciones = verificar_funciones(
				nombre, fs_load(ruta.plus_file(nombre)), tipo, verificacion_encabezado)
			if HUB.errores.fallo(verificacion_funciones):
				return HUB.error(archivo_invalido(nombre, tipo, verificacion_funciones), modulo)
	return fs_load(ruta.plus_file(nombre))

# Carga el contenido de un archivo como texto
func leer(ruta, nombre, tipo=null):
	var contenido = ""
	if existe(ruta, nombre):
		contenido = file_system.leer(ruta.plus_file(nombre))
	else:
		return HUB.error(archivo_inexistente(ruta, nombre), modulo)
	if tipo != null: # Verificaciones adicionales
		var verificacion_encabezado = verificar_encabezado(
			contenido.split("\n"), ruta, nombre, nombre.replace(".gd",""), tipo)
		if HUB.errores.fallo(verificacion_encabezado):
			return HUB.error(archivo_invalido(nombre, tipo, verificacion_encabezado), modulo)
	return contenido

# Escribe texto al final de un archivo existente
func escribir(ruta, nombre, contenido, en_nueva_linea=true):
	if existe(ruta, nombre):
		file_system.escribir(ruta.plus_file(nombre), contenido, en_nueva_linea)
		return null
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Sobrescribe el contenido de un archivo existente
func sobrescribir(ruta, nombre, contenido):
	if existe(ruta, nombre):
		file_system.sobrescribir(ruta.plus_file(nombre), contenido)
		return null
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Determina si un archivo existe
func existe(ruta, nombre):
	return file_system.existe(ruta.plus_file(nombre))

# Determina si un archivo existe como archivo
func existe_archivo(ruta, nombre):
	return file_system.es_archivo(ruta.plus_file(nombre))

# Determina si un archivo existe como directorio
func existe_directorio(ruta, nombre):
	return file_system.es_directorio(ruta.plus_file(nombre))

# Determina si un archivo existente es un archivo (no es un directorio)
func es_archivo(ruta, nombre):
	if existe(ruta, nombre):
		return file_system.es_archivo(ruta.plus_file(nombre))
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Determina si un archivo existente es un directorio
func es_directorio(ruta, nombre):
	if existe(ruta, nombre):
		return file_system.es_directorio(ruta.plus_file(nombre))
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Crea un nuevo archivo vacío
func crear(ruta, nombre):
	if existe(ruta, nombre):
		return HUB.error(archivo_ya_existe(ruta, nombre), modulo)
	crear_carpetas_intermedias(ruta.plus_file(nombre))
	file_system.crear(ruta.plus_file(nombre))
	return null

# Crea una nueva carpeta
func crear_carpeta(ruta, nombre):
	if existe(ruta, nombre):
		return HUB.error(archivo_ya_existe(ruta, nombre), modulo)
	crear_carpetas_intermedias(ruta.plus_file(nombre))
	file_system.crear_carpeta(ruta, nombre)
	return null

# Borrar un archivo
func borrar(ruta, nombre):
	if existe(ruta, nombre):
		file_system.borrar(ruta.plus_file(nombre))
		return null
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Listar archivos en un directorio
func listar(ruta, nombre):
	if existe(ruta, nombre):
		if es_directorio(ruta, nombre):
			return file_system.listar(ruta.plus_file(nombre))
		return HUB.error(no_es_un_directorio(ruta, nombre), modulo)
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Recursos
func abrir_recurso(nombre):
	if not existe_recurso(nombre):
		return HUB.error(recurso_inexistente(nombre), modulo)
	return load(carpeta_recursos.plus_file(nombre))
func existe_recurso(nombre):
	return File.new().file_exists(carpeta_recursos.plus_file(nombre))

# Funciones auxiliares

func crear_carpetas_intermedias(ruta):
	var carpetas = ruta.split("/")
	carpetas.resize(carpetas.size()-1)
	var nueva_ruta = ""
	for carpeta in carpetas:
		if not existe(nueva_ruta, carpeta):
			file_system.crear_carpeta(nueva_ruta, carpeta)
		nueva_ruta += carpeta + "/"

func fs_load(ruta):
	return load(HUB.ruta_raiz.plus_file(ruta))

func verificar_encabezado(contenido, ruta, archivo, nombre, codigo_tipo):
	var subtipo = null # En caso de éxito, devuelvo el subtipo, si hay uno
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
		subtipo = contenido[2].substr(3,contenido[2].length()-3)
	return subtipo

func verificar_funciones(archivo, script, codigo_tipo, codigo_subtipo=null):
	var nodo = Spatial.new()
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
	elif codigo_tipo == "Comportamiento":
		var verificacion_inicializar = \
			HUB.errores.verificar_implementa_funcion(nodo,"inicializar",3)
		if HUB.errores.fallo(verificacion_inicializar):
			return HUB.error(funciones_no_implementadas(archivo, codigo_tipo, verificacion_inicializar), modulo)
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
	if codigo_tipo == "Objeto":
		if codigo_subtipo == "Funcion":
			var verificacion_gen = HUB.errores.verificar_implementa_funcion(nodo,"gen",1)
			if HUB.errores.fallo(verificacion_gen):
				return HUB.error(funciones_no_implementadas(archivo, codigo_subtipo, verificacion_gen), modulo)
	return ""

class FileSystem:
	var file
	var dir
	var ruta_raiz
	func _init(ruta_raiz):
		self.file = File.new()
		self.dir = Directory.new()
		self.ruta_raiz = ruta_raiz
	func leer(ruta):
		file.open(ruta_raiz.plus_file(ruta), File.READ)
		var contenido = file.get_as_text()
		file.close()
		return contenido
	func escribir(ruta, contenido, en_nueva_linea=true):
		file.open(ruta_raiz.plus_file(ruta), File.READ_WRITE)
		var contenido_a_escribir = contenido
		var contenido_actual = file.get_as_text()
		if en_nueva_linea and not contenido_actual.empty():
			contenido_a_escribir = contenido_actual + "\n" + contenido_a_escribir
		file.store_string(contenido_a_escribir)
		file.close()
	func sobrescribir(ruta, contenido):
		file.open(ruta_raiz.plus_file(ruta), File.WRITE)
		file.store_string(contenido)
		file.close()
	func existe(ruta):
		return es_archivo(ruta) or es_directorio(ruta)
	func es_archivo(ruta):
		return file.file_exists(ruta_raiz.plus_file(ruta))
	func es_directorio(ruta):
		return dir.dir_exists(ruta_raiz.plus_file(ruta))
	func crear(ruta):
		file.open(ruta_raiz.plus_file(ruta), File.WRITE)
		file.close()
	func crear_carpeta(ruta, nombre):
		dir.open(ruta_raiz.plus_file(ruta))
		dir.make_dir(nombre)
	func borrar(ruta):
		var ruta_completa = ruta_raiz.plus_file(ruta)
		if es_archivo(ruta):
			dir.remove(ruta_completa)
		elif es_directorio(ruta):
			var archivos = listar(ruta)
			for archivo in archivos:
				borrar(ruta.plus_file(archivo))
			dir.remove(ruta_completa)
	func listar(ruta):
		var archivos = []
		dir.open(ruta_raiz.plus_file(ruta))
		dir.list_dir_begin()
		var archivo = dir.get_next()
		while (archivo != ""):
			if not archivo.begins_with("."):
				archivos.append(archivo)
			archivo = dir.get_next()
		dir.list_dir_end()
		return archivos

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
func encabezado_invalido_objeto(archivo, stack_error=null):
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

# Recurso inexistente
func recurso_inexistente(archivo, stack_error=null):
	return HUB.errores.error('El recurso "' + archivo + \
	'" no se encuentra en la carpeta de recursos.', stack_error)