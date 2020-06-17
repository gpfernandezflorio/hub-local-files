#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Este script convierte los archivos .gd que en
  # realidad no son scripts de godot cambiándoles
  # la extensión a .h y para poder compilar la
  # versión RES (sin acceso a userfs) y luego
  # revierte el cambio

import os

def main():
  renombrar_gd_a_h("shell")
  renombrar_gd_a_h("objetos", objeto_HUB3DLang)
#  os.chdir("shell")
#  for f in os.listdir("."):
#    if f.endswith(".gd"):
#      os.rename(f, f.replace(".gd",".h"))
#  os.chdir("..")

#  os.chdir("objetos")
#  for f in os.listdir("."):
    # TODO: sólo si es tipo HUB3DLang
#    if f.endswith(".gd"):
#      os.rename(f, f.replace(".gd",".h"))
    # TODO: recursivo
#  os.chdir("..")

  raw_input('\nConversión completa. Presione ENTER para revertir\n')

#  os.chdir("shell")
#  for f in os.listdir("."):
#    if f.endswith(".h"):
#      os.rename(f, f.replace(".h",".gd"))
#  os.chdir("..")

#  os.chdir("objetos")
#  for f in os.listdir("."):
#    if f.endswith(".h"):
#      os.rename(f, f.replace(".h",".gd"))
#    # TODO: recursivo
#  os.chdir("..")
  renombrar_h_a_gd("shell")
  renombrar_h_a_gd("objetos")

def todos(x):
  return True

def renombrar_gd_a_h(carpeta, filtro=todos):
  os.chdir(carpeta)
  for f in os.listdir("."):
    if f.endswith(".gd"):
      if filtro(f):
        os.rename(f, f.replace(".gd",".h"))
    elif os.path.isdir(f):
      renombrar_gd_a_h(f, filtro)
  os.chdir("..")

def renombrar_h_a_gd(carpeta):
  os.chdir(carpeta)
  for f in os.listdir("."):
    if f.endswith(".h"):
      os.rename(f, f.replace(".h",".gd"))
    elif os.path.isdir(f):
      renombrar_h_a_gd(f)
  os.chdir("..")

def objeto_HUB3DLang(x):
  f = open(x, 'r')
  tipo = f.read().split("\n")[2][3:]
  f.close()
  return tipo == "HUB3DLang"

if __name__ == '__main__':
  main()
