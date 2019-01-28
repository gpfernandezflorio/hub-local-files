## Archivos
## SRC

# Maneja el acceso a archivos.
# Requiere para inicializar:
	# -

extends Node

var HUB
# Interfaz para acceder al sistema de archivos del SO
var file_system = File.new()

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
		return HUB.error(archivo_inexistente(ruta, nombre))
	if tipo == null: # No hacer verificaciones adicionales
		return load(HUB.ruta_raiz + ruta + nombre)
	var verificacion_encabezado = verificar_encabezado(
		ruta, nombre, nombre.replace(".gd",""), tipo)
	if HUB.errores.fallo(verificacion_encabezado):
		return HUB.error(archivo_invalido(nombre, tipo, verificacion_encabezado))
	var data_archivo = load(HUB.ruta_raiz + ruta + nombre)
	if tipo in codigos_script:
		var verificacion_funciones = verificar_funciones(
			nombre, data_archivo, tipo)
		if HUB.errores.fallo(verificacion_funciones):
			return HUB.error(archivo_invalido(nombre, tipo, verificacion_funciones))
	return data_archivo

# Carga el contenido de un archivo como texto
func leer(ruta, nombre):
	if existe(ruta, nombre):
		file_system.open(HUB.ruta_raiz + ruta + nombre, File.READ)
		var contenido = file_system.get_as_text()
		file_system.close()
		return contenido
	return HUB.error(archivo_inexistente(ruta, nombre))

# Determina si un archivo existe
func existe(ruta, nombre):
	return file_system.file_exists(HUB.ruta_raiz + ruta + nombre)

# Funciones auxiliares

func verificar_encabezado(ruta, archivo, nombre, codigo_tipo):
	# Asume que el archivo existe y por lo tanto, leer no falla
	var contenido = leer(ruta, archivo).split("\n")
	if contenido.size() < 2:
		return HUB.error(encabezado_invalido(archivo))
	if contenido[0].to_lower() != "## " + nombre.to_lower() or \
		contenido[1] != "## " + codigo_tipo:
		return HUB.error(encabezado_invalido(archivo))
	if codigo_tipo == "Objeto":
		if not (
			contenido.size() > 2 and \
			contenido[2].begins_with("## ") and \
			contenido[2].substr(3,contenido[2].length()-3) in codigos_objeto
		):
			return HUB.error(encabezado_invalido(archivo))

func verificar_funciones(archivo, script, codigo_tipo):
	var nodo = Node.new()
	nodo.set_name(archivo)
	nodo.set_script(script)
	if codigo_tipo == "Programa":
		var verificacion_inicializar = \
			HUB.errores.verificar_implementa_funcion(nodo,"inicializar",3)
		if HUB.errores.fallo(verificacion_inicializar):
			return HUB.error(funciones_no_implementadas(archivo, codigo_tipo, verificacion_inicializar))
	else:
		var verificacion_inicializar = \
			HUB.errores.verificar_implementa_funcion(nodo,"inicializar",1)
		if HUB.errores.fallo(verificacion_inicializar):
			return HUB.error(funciones_no_implementadas(archivo, codigo_tipo, verificacion_inicializar))
	if codigo_tipo == "Comando":
		var verificacion_comando = \
			HUB.errores.verificar_implementa_funcion(nodo,"comando",1)
		if HUB.errores.fallo(verificacion_comando):
			return HUB.error(funciones_no_implementadas(archivo, codigo_tipo, verificacion_comando))
	return null

# Errores

# Archivo inexistente
func archivo_inexistente(ruta, archivo, stack_error=null):
	return HUB.errores.error('El archivo "' + archivo + \
	'" no se encuentra ' + 'en la carpeta "' + ruta + '".', stack_error)

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