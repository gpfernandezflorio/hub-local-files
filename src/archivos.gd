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

# Crea un nuevo archivo vacío
func crear(ruta, nombre):
	if existe(ruta, nombre):
		return HUB.error(archivo_ya_existe(ruta, nombre), modulo)
	file_system.crear(HUB.ruta_raiz + ruta + nombre)
	return null

# Borrar un archivo
func borrar(ruta, nombre):
	if existe(ruta, nombre):
		file_system.borrar(HUB.ruta_raiz + ruta + nombre)
		return null
	return HUB.error(archivo_inexistente(ruta, nombre))

# Funciones auxiliares

func verificar_encabezado(ruta, archivo, nombre, codigo_tipo):
	# Asume que el archivo existe y por lo tanto, leer no falla
	var contenido = leer(ruta, archivo).split("\n")
	if contenido.size() < 2:
		return HUB.error(encabezado_invalido(archivo), modulo)
	if contenido[0].to_lower() != "## " + nombre.to_lower() or \
		contenido[1] != "## " + codigo_tipo:
		return HUB.error(encabezado_invalido(archivo), modulo)
	if codigo_tipo == "Objeto":
		if not (
			contenido.size() > 2 and \
			contenido[2].begins_with("## ") and \
			contenido[2].substr(3,contenido[2].length()-3) in codigos_objeto
		):
			return HUB.error(encabezado_invalido(archivo), modulo)

func verificar_funciones(archivo, script, codigo_tipo):
	var nodo = Node.new()
	nodo.set_name(archivo)
	nodo.set_script(script)
	if codigo_tipo == "Programa":
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
	return null

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
		return file.file_exists(ruta_al_archivo)
	func crear(ruta_al_archivo):
		file.open(ruta_al_archivo, File.WRITE)
		file.close()
	func borrar(ruta_al_archivo):
		dir.remove(ruta_al_archivo)

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

# Archivo inválido (encabezado inválido)
func encabezado_invalido(archivo, stack_error=null):
	return HUB.errores.error('El encabezado del archivo "' + archivo + \
	'" es inválido.', stack_error)

# Archivo inválido (funciones no implementadas)
func funciones_no_implementadas(archivo, tipo, stack_error=null):
	return HUB.errores.error('El archivo "' + archivo + \
	'" no implementa las funciones necesarias para ser un archivo ' + \
	'válido de tipo "' + tipo + '".', stack_error)