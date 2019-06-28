#include "node.h"

Node * newNode(type type, char * value)
{
	Node * node = malloc(sizeof(Node));
	node->type = type;
	node->value = value;
    node->parent = NULL;
    node->leftChild = NULL;
    node->next = NULL;
    node->prev = NULL;
	return node;
}

void append(Node * parent, Node * node) {
    if (parent == NULL || node == NULL)
        return;

    if (parent->leftChild != NULL){
     	Node * aux = parent->leftChild;
      	while (aux->next != NULL) {
            aux = aux->next;
        }
      	node->prev = aux;
      	aux->next = node;
    } else
      	parent->leftChild = node;
    
    node->parent = parent;
}

void printInorder(Node * node) {
    if (node->type != TYPE_EMPTY)
        printf("%s", node->value);
    else {
        Node * aux = node->leftChild;
        while(aux != NULL) {
            printInorder(aux);
            aux = aux->next;
        }
    }
}