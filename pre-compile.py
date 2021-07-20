#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Este script convierte los archivos .gd que en
  # realidad no son scripts de godot cambiándoles
  # la extensión a .h y para poder compilar la
  # versión RES (sin acceso a userfs) y luego
  # revierte el cambio

import os

def main():
  escribir_fs_en_txt()
  for d in os.listdir("."):
    if os.path.isdir(d) and not d.startswith("."):
      renombrar_gd_a_h(d)
  #renombrar_gd_a_h("shell")
  #renombrar_gd_a_h("objetos", objeto_HUB3DLang)

  input('\nConversión completa. Presione ENTER para revertir\n')

  #renombrar_h_a_gd("shell")
  #renombrar_h_a_gd("objetos")
  for d in os.listdir("."):
    if os.path.isdir(d) and not d.startswith("."):
      renombrar_h_a_gd(d)
  os.remove("fs.txt")

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

def escribir_fs_en_txt():
  f = open("fs.txt",'w')
  escribir_dir_en_txt(f, ".")
  f.close()

def escribir_dir_en_txt(f,d):
  for l in os.listdir(d):
    if not l.startswith("."):
      if os.path.isdir(os.path.join(d,l)):
        f.write("D|"+l+"\n")
        escribir_dir_en_txt(f,os.path.join(d,l))
        f.write("||\n")
      elif l.endswith(".gd") or l.endswith(".txt"):
        f.write("F|"+l+"\n")

if __name__ == '__main__':
  main()
