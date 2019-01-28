## Testing
## SRC

# Script para testear funcionalidad.
# Requiere para inicializar:
	# -

extends Node

var HUB

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
		return HUB.error(condicion_fallida(condicion))
	if condicion:
		return true
	return HUB.error(condicion_fallida())

# Verifica el resultado (devuelto e impreso) de ejecutrar un comando
func resultado_comando(comando_ingresado, verificador_resultado, mensajes_esperados):
	testeando = true
	mensajes_guardados = []
	var resultado_obtenido = HUB.terminal.ejecutar(comando_ingresado)
	testeando = false
	var exito = asegurar(verificador_resultado.verificar(resultado_obtenido))
	if HUB.errores.fallo(exito):
		return HUB.error(test_fallido_resultado(exito))
	if mensajes_esperados == mensajes_guardados:
		HUB.mensaje("Test exitoso!")
		return true
	return HUB.error(test_fallido_salida(exito))

# Verifica que la ejecución de un comando genere un error
func comando_fallido(comando_ingresado, error_esperado, mensaje_esperado):
	var verificador = VerificadorError.new(HUB, error_esperado)
	return resultado_comando(comando_ingresado, verificador, mensaje_esperado)

# Funciones auxiliares

func redirigir_mensaje(texto):
	mensajes_guardados.append(texto)

# Verificadores

func verificador_trivial():
	return VerificadorTrivial.new()
func verificador_nulo():
	return VerificadorNulo.new()

class VerificadorTrivial:
	func verificar(resultado):
		return true

class VerificadorNulo:
	func verificar(resultado):
		return resultado == null

class VerificadorError:
	var HUB
	var error_esperado
	func _init(hub, error_esperado):
		HUB = hub
		self.error_esperado = error_esperado
	func verificar(resultado):
		if HUB.errores.fallo(resultado):
			var primer_error = resultado
			while primer_error.stack_error != null:
				primer_error = primer_error.stack_error
			#print(error_esperado.mensaje)
			#print(primer_error.mensaje)
			return (primer_error.mensaje == error_esperado.mensaje)
		else:
			return false

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