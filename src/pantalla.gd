## Pantalla
## SRC

# Script para la controlar lo que se muestra en la pantalla.
# Requiere para inicializar:
	# HUB.eventos

extends Node2D

var HUB
var modulo = "PANTALLA"
# Resolución de la ventana de ejecución
var resolucion

func inicializar(hub):
	HUB = hub
	ventana_escalada(OS.get_window_size())
	HUB.eventos.registrar_ventana_escalada(self, "ventana_escalada")
	return true

# Activa o desactiva el modo pantalla completa
func completa(encendido=true):
	if encendido:
		OS.set_window_fullscreen(true)
		resolucion = OS.get_screen_size()
	else:
		OS.set_window_fullscreen(false)
		resolucion = OS.get_window_size()

# Escala la ventana del HUB
func tamanio(nueva_resolucion):
	OS.set_window_size(nueva_resolucion)
	resolucion = OS.get_window_size()

func coordenadas(x,y):
	return Vector2(resolucion.x*x/100,resolucion.y*y/100)
func centrado(vector):
	return Vector2((resolucion.x-vector.x)/2,(resolucion.y-vector.y)/2)

# Funciones auxiliares

func ventana_escalada(nueva_resolucion):
	resolucion = nueva_resolucion