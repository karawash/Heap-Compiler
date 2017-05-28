%{
#include <stdlib.h>
#include "HeapMiniCompiler.h"
#include "y.tab.h"
void yyerror(char *);
char itoa1(int x);
void toch(int x);
char xto[10],ss[10];
int gg,xx,tt=0;
%}

%%
"int"        {pushtype2("int");return INT;}//push the word "int" to stack
"float"      {pushtype2("float");return FLOAT;}//push the word "float" to stack
"bool"       {pushtype2("bool");return BOOL;}//push the word "bool" to stack


[a-z]       {  push(yytext);
                yylval.sIndex = *yytext - 'a';
                return VARIABLE;
            }


[0-9]+ {    toch(atoi(yytext));push(xto); 
                yylval.iValue = atoi(yytext);//change characters to integers
                return INTEGER;
            }

[-+*/] {        return *yytext;
             }
[(){}] {        return *yytext;
             }
[<>=] {        return *yytext;
             }
[;,.] {        return *yytext;
             }

"while"         return WHILE;
"do"            return DO;
"if"            return IF;
"else"          return ELSE;
">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;

 

[ \t\n]+        ;       /* ignore whitespace */

.               yyerror("Unknown character");
%%
int yywrap(void) {
    return 1;
}
char itoa1(int x){// called the below function 
if(x==0)return '0';
if(x==1)return '1';
if(x==2)return '2';
if(x==3)return '3';
if(x==4)return '4';
if(x==5)return '5';
if(x==6)return '6';
if(x==7)return '7';
if(x==8)return '8';
if(x==9)return '9';
}
void toch(int x){strcpy(xto,"");// this function is to transform from int to char 
if(x==0)strcpy(xto,"0");
if(x==1)strcpy(xto,"1");
if(x==2)strcpy(xto,"2"); 
if(x==3)strcpy(xto,"3"); 
if(x==4)strcpy(xto,"4"); 
if(x==5)strcpy(xto,"5"); 
if(x==6)strcpy(xto,"6"); 
if(x==7)strcpy(xto,"7"); 
if(x==8)strcpy(xto,"8");
if(x==9)strcpy(xto,"9");
if(x>9){
for(gg=0;gg<10;gg++){
if(x!=0){ss[gg]=x%10;x=x/10;tt++; }

}
tt--;
for(xx=0;xx<=tt;xx++){
xto[xx]=itoa1(ss[tt-xx]);  }
 }tt=0;
}