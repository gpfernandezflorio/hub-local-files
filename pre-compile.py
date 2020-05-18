#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Este script convierte los archivos .gd que en
  # realidad no son scripts de godot cambiándoles
  # la extensión a .h y para poder compilar la
  # versión RES (sin acceso a userfs) y luego
  # revierte el cambio

import os

os.chdir("shell")
for f in os.listdir("."):
  if f.endswith(".gd"):
    os.rename(f, f.replace(".gd",".h"))
os.chdir("..")

os.chdir("objetos")
for f in os.listdir("."):
  # TODO: sólo es tipo HUB3DLang
  if f.endswith(".gd"):
    os.rename(f, f.replace(".gd",".h"))
  # TODO: recursivo
os.chdir("..")

raw_input('Conversión completa. Presione ENTER para revertir\n')

os.chdir("shell")
for f in os.listdir("."):
  if f.endswith(".h"):
    os.rename(f, f.replace(".h",".gd"))
os.chdir("..")

os.chdir("objetos")
for f in os.listdir("."):
  # TODO: sólo es tipo HUB3DLang
  if f.endswith(".h"):
    os.rename(f, f.replace(".h",".gd"))
  # TODO: recursivo
os.chdir("..")
