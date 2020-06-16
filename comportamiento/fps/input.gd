## FPS/Input
## Comportamiento

# Ingreso de control de jugador
# Requiere para inicializar:
	# -

extends Node

var HUB

var modulo = "FPS/Input"
var yo

var teclas_presionadas = [false, false, false, false]
var input_generado = Vector3(0,0,0)

func inicializar(hub, yo, args):
	HUB = hub
	self.yo = yo
	HUB.eventos.registrar_press(KEY_UP, self, "p_up")
	HUB.eventos.registrar_press(KEY_DOWN, self, "p_down")
	HUB.eventos.registrar_press(KEY_RIGHT, self, "p_right")
	HUB.eventos.registrar_press(KEY_LEFT, self, "p_left")
	HUB.eventos.registrar_release(KEY_UP, self, "r_up")
	HUB.eventos.registrar_release(KEY_DOWN, self, "r_down")
	HUB.eventos.registrar_release(KEY_RIGHT, self, "r_right")
	HUB.eventos.registrar_release(KEY_LEFT, self, "r_left")
	return null

func p_up(): # 0
	teclas_presionadas[0] = true
	input_generado.z = -1
	yo.pone("input_mov", input_generado)
func p_down(): # 1
	teclas_presionadas[1] = true
	input_generado.z = 1
	yo.pone("input_mov", input_generado)
func p_right(): # 2
	teclas_presionadas[2] = true
	input_generado.x = 1
	yo.pone("input_mov", input_generado)
func p_left(): # 3
	teclas_presionadas[3] = true
	input_generado.x = -1
	yo.pone("input_mov", input_generado)

func r_up(): # 0
	teclas_presionadas[0] = false
	if teclas_presionadas[1]:
		input_generado.z = 1
	else:
		input_generado.z = 0
	yo.pone("input_mov", input_generado)
func r_down(): # 1
	teclas_presionadas[1] = false
	if teclas_presionadas[0]:
		input_generado.z = -1
	else:
		input_generado.z = 0
	yo.pone("input_mov", input_generado)
func r_right(): # 2
	teclas_presionadas[2] = false
	if teclas_presionadas[3]:
		input_generado.x = -1
	else:
		input_generado.x = 0
	yo.pone("input_mov", input_generado)
func r_left(): # 3
	teclas_presionadas[3] = false
	if teclas_presionadas[2]:
		input_generado.x = 1
	else:
		input_generado.x = 0
	yo.pone("input_mov", input_generado)