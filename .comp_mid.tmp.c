#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char * _strconcat(char * str1, char * str2) {
	char * newstr = malloc(strlen(str1) + strlen(str2) + 1);
	strcpy(newstr, str1);
	strcat(newstr, str2);
	return newstr;
}
char * _strintconcat(char * str, int num, int sort) {
	char * newstr = malloc(strlen(str) + 20);
	if (sort > 0)
		sprintf(newstr, "%s%d", str, num);
	else
		sprintf(newstr, "%d%s", num, str);
	return newstr;
}
char * _strintmult(char * str, int num) {
	int len = strlen(str);
	char * newstr = malloc(len * num + 1);
	newstr[0] = 0;
	for (int i = 0; i < num; i++)
		strcpy(newstr + i * len, str);
}
void _getchar_to_var(char * str) {
	char buff[2];
	buff[0] = getchar();
	buff[1] = 0;
	strcpy(str, buff);
}
int SumaPrueba(int A, char * B);
int main() {
char * hola_mundo_a;
int A = 12;
char * B = "asd";
A = 50;
B = _strconcat(B, B);
printf("%s", "HolaChau");
printf("%s", "\n");
_getchar_to_var(B);
;
printf("%s", _strconcat("B vale: ", B));
printf("%s", "\n");
if(strcmp(B, "a") == 0 && A >= 15){
A = 3;
printf("%s", "Yay!");
}
while(A > 0){
A--;
printf("%s", "Decrementando");
}
A++;
}
int SumaPrueba(int A, char * B) {
A++;
return (A + 1);
}
