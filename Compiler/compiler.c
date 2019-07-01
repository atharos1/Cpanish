#include "y.tab.h"
#include <ctype.h>
#include <getopt.h>
#include "compiler.h"

extern FILE *yyin;

struct op_values {
    int preserve;
    char * output;
    char * input;
} op;

void argParse(int argc, char *argv[], struct op_values * op) {

    if(argc == 1) {
        fprintf(stderr, "Ingrese la ruta del archivo de código a compilar como primer argumento.\n");
	    exit(1);
    }

    //Valores por defecto
    op->input = argv[1];
    op->preserve = 0;
    op->output = "a.out";

    opterr = 0; //Callar a getopd

    static const struct option op_list[] = {
        {.name = "preserve", .has_arg = no_argument, .val = 'p'},
        {.name = "output", .has_arg = required_argument, .val = 'o'},
        {},
    };
    while(1) {
        int opt = getopt_long(argc, argv, ":o:p", op_list, NULL);
        if (opt == -1)
            break;
        switch (opt) {
        case 'p':
            op->preserve = 1;
            break;
        case 'o':
            op->output = optarg;
            break;
        case ':':
            fprintf(stdout, "Opción '%s' requiere un argumento\n", argv[optind - 1]);
            break;
        case '?': 
        default:
            fprintf(stdout, "Opción '%s' desconocida\n", argv[optind - 1]);
            exit(1);
        }
    }
}

void initializeCompiler(char * inputFile) {
    FILE * read_file = fopen (inputFile, "r");
    if (read_file == NULL) {
        printf ("El archivo de código especificado no se encuentra o no puede abrirse.\n");
        exit(1);
    }

    yyin = read_file;

    tmpFile = fopen(TMP_FILE_NAME, "w");
    if (tmpFile == NULL) {
        printf ("Error al crear archivo temporal. Compilación abortada.\n");
        exit(1);
    }
}

void freeResources() {
    fclose(tmpFile);
    fclose(yyin);
}

void compileC(char * outputFile, int preserveTmp) {
    char commandBuffer[256];
    sprintf(commandBuffer, "gcc %s -o %s", TMP_FILE_NAME, outputFile);

    int gccStatus = system(commandBuffer);

    if(!preserveTmp && remove(TMP_FILE_NAME)) {
        printf ("Error al eliminar el archivo de código intermedio.\n");
        exit(1);
    }

    if(gccStatus != 0) {
        printf ("Error al compilar el código intermedio generado.\n");
        exit(1);
    }
}

int main(int argc, char *argv[]) {

    argParse(argc, argv, &op);

    initializeCompiler(op.input);

    yyparse();

    freeResources();

    //compileC(op.output, op.preserve);
    return 0;
}