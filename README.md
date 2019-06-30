# Cpanish

*Cpanish* es un lenguaje de programación imperativo y fuertemente tipado que pretende facilitar un primer acercamiento al mundo de la programación a hispanohablantes sin experiencia. 
Su sintaxis pretende ser fácilmente comprensible para novicios, siendo este su principal objetivo.
Programas escritos en *Cpanish* se compilan a *C* para ser posteriormente procesados por *GCC*.
El compilador que se presenta traduce el código a *C* por medio de *YACC* y *LEX*, y ofrece una interfaz para interactuar con *GCC* y producir código máquina en un solo paso.

#### Dependencias de compilación:
- Make
- Yacc / Bison
- Lex / Flex
- GCC

#### Dependencias funcionales:
- GCC

#### Instrucciones para compilar el compilador
1. Descargar el repositorio y descomprimirlo
2. Posicionarse dentro de la carpeta que contiene los archivos extraídos
4. Ejecutar el comando:
> $ make all
5. Se genera el ejecutable *cspanish* en el directorio raíz del proyecto

#### Instrucciones compilar un programa
Al compilador debe proveérsele como primer argumento la ruta del archivo de código escrito en *Cpanish*. Si se verifica esta condición, se procesará el archivo y, de superarse las validaciones, se generará un archivo ejecutable de nombre *a.out*. 
Adicionalmente, el compilador acepta, a continuación del nombre del archivo de entrada, los siguientes parámetros:
- -p, -\-preserve: Evita que se elimine el archivo temporal en C.
- -o nombre, -\-output nombre: Modifica el nombre del archivo ejecutable de salida.
