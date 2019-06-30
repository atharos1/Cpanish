#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char * strconcat(char * str1, char * str2) {
	char * newstr = malloc(strlen(str1) + strlen(str2) + 1);
	strcpy(newstr, str1);
	strcat(newstr, str2);
	return newstr;
}
char * strintconcat(char * str, int num, int sort) {
	char * newstr = malloc(strlen(str) + 20);
	if (sort > 0)
		fprintf("%s%d", str, num);
	else
		fprintf("%d%s", num, str);
	return newstr;
}
char * strintmult(char * str, int num) {
	int len = strlen(str);
	char * newstr = malloc(len * num + 1);
	newstr[0] = 0;
	for (int i = 0; i < num; i++)
		strcpy(newstr + i * len, str);
}
