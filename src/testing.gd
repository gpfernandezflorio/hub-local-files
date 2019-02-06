## Testing
## SRC

# Script para testear funcionalidad.
# Requiere para inicializar:
	# -

extends Node

var HUB
var modulo = "TESTING"

# Indica si se está testeando y los mensajes de error deben ignorarse
var testeando = false
# Lista de mensajes enviados al HUB durante el test
var mensajes_guardados = []

func inicializar(hub):
	HUB = hub
	return true

# Verifica una condición
func asegurar(condicion):
	if HUB.errores.fallo(condicion):
		return HUB.error(condicion_fallida(condicion), modulo)
	if not condicion:
		return HUB.error(condicion_fallida(), modulo)
	return null

# Ejecuta un test y verifica el resultado y/o los mensajes escritos
func test(tester, verificador, mensajes_esperados=null):
	testeando = true
	mensajes_guardados = []
	var resultado_obtenido = tester.test()
	testeando = false
	var verificacion = verificador.verificar(resultado_obtenido)
	var exito = asegurar(verificacion == "")
	if HUB.errores.fallo(exito):
		HUB.mensaje(verificacion)
		return HUB.error(test_fallido_resultado(exito), modulo)
	if mensajes_esperados != null:
		if mensajes_esperados.size() != mensajes_guardados.size():
			mostrar_diff_mensajes(mensajes_esperados, mensajes_guardados)
			return HUB.error(test_fallido_salida(), modulo)
		for i in range(mensajes_esperados.size()):
			if mensajes_esperados[i] != mensajes_guardados[i]:
				mostrar_diff_mensajes(mensajes_esperados, mensajes_guardados)
				return HUB.error(test_fallido_salida(), modulo)
	return null

# Ejecuta un test y verifica que genere un error
func test_genera_error(tester, error_esperado, mensaje_esperado=null):
	var verificador = verificador_error(error_esperado)
	return test(tester, verificador, mensaje_esperado)

# Verifica el resultado (devuelto e impreso) de ejecutrar un comando
func resultado_comando(comando_ingresado, verificador, mensajes_esperados=null):
	return test(tester_comando(comando_ingresado), verificador, mensajes_esperados)

# Verifica que la ejecución de un comando genere un error
func comando_fallido(comando_ingresado, error_esperado, mensaje_esperado=null):
	var verificador = verificador_error(error_esperado)
	return resultado_comando(comando_ingresado, verificador, mensaje_esperado)

# Funciones auxiliares

func redirigir_mensaje(texto):
	mensajes_guardados.append(texto)

func mostrar_diff_mensajes(esperados, obtenidos):
	var texto = "Se esperaban los siguientes mensajes:"
	for mensaje in esperados:
		texto += "\n\t" + mensaje.replace("\n","\n\t")
	texto += "\nPero se obtuvieron los siguientes mensajes:"
	for mensaje in obtenidos:
		texto += "\n\t" + mensaje.replace("\n","\n\t")
	HUB.mensaje(texto)

# Testers

func tester_comando(comando_a_ejecutar):
	return TesterComando.new(HUB, comando_a_ejecutar)

class TesterComando:
	var HUB
	var comando_a_ejecutar
	func _init(hub, comando_a_ejecutar):
		HUB = hub
		self.comando_a_ejecutar = comando_a_ejecutar
	func test():
		return HUB.terminal.ejecutar(comando_a_ejecutar)

# Verificadores

func verificador_trivial():
	return VerificadorTrivial.new()
func verificador_nulo():
	return VerificadorNulo.new()
func verificador_por_igualdad(resultado_esperado):
	return VerificadorIgualdad.new(HUB, resultado_esperado)
func verificador_error(error_esperado):
	return VerificadorError.new(HUB, error_esperado)

class VerificadorTrivial:
	var HUB
	func _init(hub):
		HUB = hub
	func verificar(resultado):
		if HUB.errores.fallo(resultado):
			return "El resultado generó un error inesperado."
		return ""

class VerificadorNulo:
	var HUB
	func _init(hub):
		HUB = hub
	func verificar(resultado):
		if HUB.errores.fallo(resultado):
			return "El resultado generó un error inesperado."
		if resultado == null:
			return ""
		return "El resultado no es null."

class VerificadorIgualdad:
	var HUB
	var resultado_esperado
	func _init(hub, resultado):
		HUB = hub
		resultado_esperado = resultado
	func verificar(resultado):
		if HUB.errores.fallo(resultado):
			return "El resultado generó un error inesperado."
		if resultado == resultado_esperado:
			return ""
		return 'Se esperaba que el resultado sea "' + str(resultado_esperado) + \
		'" pero se obtuvo "' + str(resultado) + '".'

class VerificadorError:
	var HUB
	var error_esperado
	func _init(hub, error_esperado):
		HUB = hub
		self.error_esperado = error_esperado
	func verificar(resultado):
		if HUB.errores.fallo(resultado):
			var error_encontrado = resultado
			while error_encontrado.stack_error != null:
				error_encontrado = error_encontrado.stack_error
			if error_encontrado.mensaje == error_esperado.mensaje:
				return ""
			return "Se esperaba el error\n\t" + error_esperado.mensaje.replace("\n","\n\t") + \
			"\nPero se obtuvo el error\n\t" + error_encontrado.mensaje.replace("\n","\n\t")
		return "Se esperaba el error\n\t" + error_esperado.mensaje.replace("\n","\n\t") + \
		"\nPero no se generó ningún error."

# Errores

# Condición fallida
func condicion_fallida(stack_error = null):
	return HUB.errores.error('La condición resulto ser falsa', stack_error)

# Test fallido por resultado
func test_fallido_resultado(stack_error = null):
	return HUB.errores.error('El test falló. El resultado no cumple la condición del verificador.', stack_error)

# Test fallido por salida
func test_fallido_salida(stack_error = null):
	return HUB.errores.error('El test falló. La salida no fue la esperada.', stack_error)