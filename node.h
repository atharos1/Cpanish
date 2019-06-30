#ifndef NODE_H
#define NODE_H

#include <stdio.h>
#include <stdlib.h>

typedef enum types {TYPE_EMPTY, TYPE_LITERAL, TYPE_STRING, TYPE_INT} type;

typedef struct Node {
	type type;
	char * value;

	struct Node * next;
    struct Node * prev;
	struct Node * leftChild;
    struct Node * parent;
} Node;

Node * newNode(type type, char * value);

void append(Node * parent, Node * node);

void printInorder(Node * node);

/* NO SE SI ESTO VA ACÁ */
FILE * tmpFile;
#define TMP_FILE_NAME ".comp_mid.tmp.c"

#endif