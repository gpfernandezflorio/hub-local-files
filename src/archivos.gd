## Archivos
## SRC

# Maneja el acceso a archivos.
# Requiere para inicializar:
	# -

extends Node

var HUB
var modulo = "ARCHIVOS"
# Interfaz para acceder al sistema de archivos del SO
var file_system = FileSystem.new()

# Códigos de subtipo válidos para el tipo Objeto
var codigos_objeto = ["HUB3DLang","Funcion"]
# Códigos válidos de tipo script
var codigos_script = ["SRC"]

func inicializar(hub):
	HUB = hub
	return true

# Carga el contenido de un archivo
func abrir(ruta, nombre, tipo=null):
	if not existe(ruta, nombre):
		return HUB.error(archivo_inexistente(ruta, nombre), modulo)
	if tipo == null: # No hacer verificaciones adicionales
		return load(HUB.ruta_raiz + ruta + nombre)
	var verificacion_encabezado = verificar_encabezado(
		ruta, nombre, nombre.replace(".gd",""), tipo)
	if HUB.errores.fallo(verificacion_encabezado):
		return HUB.error(archivo_invalido(nombre, tipo, verificacion_encabezado), modulo)
	var data_archivo = load(HUB.ruta_raiz + ruta + nombre)
	if tipo in codigos_script:
		var verificacion_funciones = verificar_funciones(
			nombre, data_archivo, tipo)
		if HUB.errores.fallo(verificacion_funciones):
			return HUB.error(archivo_invalido(nombre, tipo, verificacion_funciones), modulo)
	return data_archivo

# Carga el contenido de un archivo como texto
func leer(ruta, nombre):
	if existe(ruta, nombre):
		return file_system.leer(HUB.ruta_raiz + ruta + nombre)
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Escribe texto al final de un archivo existente
func escribir(ruta, nombre, contenido, en_nueva_linea=true):
	if existe(ruta, nombre):
		file_system.escribir(HUB.ruta_raiz + ruta + nombre, contenido, en_nueva_linea)
		return null
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Sobrescribe el contenido de un archivo existente
func sobrescribir(ruta, nombre, contenido):
	if existe(ruta, nombre):
		file_system.sobrescribir(HUB.ruta_raiz + ruta + nombre, contenido)
		return null
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Determina si un archivo existe
func existe(ruta, nombre):
	return file_system.existe(HUB.ruta_raiz + ruta + nombre)

# Determina si un archivo es un archivo (no es un directorio)
func es_archivo(ruta, nombre):
	if existe(ruta, nombre):
		return file_system.es_archivo(HUB.ruta_raiz + ruta + nombre)
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Determina si un archivo es un directorio
func es_directorio(ruta, nombre):
	if existe(ruta, nombre):
		return file_system.es_directorio(HUB.ruta_raiz + ruta + nombre)
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Crea un nuevo archivo vacío
func crear(ruta, nombre):
	if existe(ruta, nombre):
		return HUB.error(archivo_ya_existe(ruta, nombre), modulo)
	file_system.crear(HUB.ruta_raiz + ruta + nombre)
	return null

# Crea una nueva carpeta
func crear_carpeta(ruta, nombre):
	if existe(ruta, nombre):
		return HUB.error(archivo_ya_existe(ruta, nombre), modulo)
	file_system.crear_carpeta(HUB.ruta_raiz + ruta, nombre)
	return null

# Borrar un archivo
func borrar(ruta, nombre):
	if existe(ruta, nombre):
		file_system.borrar(HUB.ruta_raiz + ruta + nombre)
		return null
	return HUB.error(archivo_inexistente(ruta, nombre), modulo)

# Listar archivos en un directorio
func listar(ruta, carpeta):
	if existe(ruta, carpeta):
		if es_directorio(ruta, carpeta):
			return file_system.listar(HUB.ruta_raiz + ruta + carpeta)
		return HUB.error(no_es_un_directorio(ruta, carpeta), modulo)
	return HUB.error(archivo_inexistente(ruta, carpeta), modulo)

# Funciones auxiliares

func verificar_encabezado(ruta, archivo, nombre, codigo_tipo):
	# Asume que el archivo existe y por lo tanto, leer no falla
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
	var file = File.new()
	var dir = Directory.new()
	func leer(ruta_al_archivo):
		file.open(ruta_al_archivo, File.READ)
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
		return file.file_exists(ruta_al_archivo) or dir.dir_exists(ruta_al_archivo)
	func es_archivo(ruta_al_archivo):
		return file.file_exists(ruta_al_archivo)
	func es_directorio(ruta_al_archivo):
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
				if archivo != "." and archivo != "..":
					borrar(ruta_al_archivo+"/"+archivo)
			dir.remove(ruta_al_archivo)
	func listar(ruta):
		var archivos = []
		dir.open(ruta)
		dir.list_dir_begin()
		var archivo = dir.get_next()
		while (archivo != ""):
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