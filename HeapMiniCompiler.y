%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "HeapMiniCompiler.h"

/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *con(int value);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

void yyerror(char *s);
int sym[26];                    /* symbol table */
static int lbl;
char a[10];int s=0, t=0,c=0,stypecount=0,scount=0;
char stack[50][10],stacktype2[50][10];
%}

%union {
    int iValue;                 /* integer value */
    char sIndex;                /* symbol table index */
    nodeType *nPtr;             /* node pointer */
};

%token <iValue> INTEGER
%token <sIndex> VARIABLE
%token WHILE IF DO INT FLOAT BOOL
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> stmt expr stmt_list

%%

prog:
        decl_list                 {exit(0);}
      | decl_list stmt            { printtree($2); freeNode($2); }
      ;

 decl_list : decl_list decl 
       |  {printf("");}
;

decl : type id_assign_list ';'  
    ;

id_assign_list : id_assign_list ',' id_assign  
      | id_assign   
      ;

id_assign :  VARIABLE    { printf("%s %s ;\n",stacktype2[stypecount-1],stack[--scount]);}
      |  VARIABLE '=' expr             { printf("%s %s;\n%s =  %s;\n",stacktype2[stypecount-1],stack[scount-1],stack[scount-1],stack[--scount] );}
;

type :  INT          
      | FLOAT     
      | BOOL
      ; 

stmt_list:
          stmt                  { $$ = $1; }
        | stmt_list  stmt        { $$ = opr(';', 2, $1, $2); }
        ;

stmt:
         ';'                             { $$ = opr(';', 2, NULL, NULL); }
        | expr ';'                       { $$ = $1; }
        | VARIABLE '=' expr ';'          { $$ = opr('=', 2, id($1), $3); }
        | WHILE '(' expr ')' stmt        { $$ = opr(WHILE, 2, $3, $5); }
        | DO stmt WHILE '(' expr ')'     { $$ = opr(DO, 2, $2, $5); }
        | IF '(' expr ')' stmt %prec IFX { $$ = opr(IF, 2, $3, $5); }
        | IF '(' expr ')' stmt ELSE stmt { $$ = opr(IF, 3, $3, $5, $7); }
        | '{' stmt_list '}'              { $$ = $2; }
        ;



expr:
          INTEGER               { $$ = con($1); }
        | VARIABLE              { $$ = id($1); }
        | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
        | expr '+' expr         { $$ = opr('+', 2, $1, $3); }
        | expr '-' expr         { $$ = opr('-', 2, $1, $3); }
        | expr '*' expr         { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr         { $$ = opr('/', 2, $1, $3); }
        | expr '<' expr         { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr         { $$ = opr('>', 2, $1, $3); }
        | expr GE expr          { $$ = opr(GE, 2, $1, $3); }
        | expr LE expr          { $$ = opr(LE, 2, $1, $3); }
        | expr NE expr          { $$ = opr(NE, 2, $1, $3); }
        | expr EQ expr          { $$ = opr(EQ, 2, $1, $3); }
        | '(' expr ')'          { $$ = $2; }
        ;

%%
void push(char *s)
{ 
	strcpy(stack[scount++],s);
}
void pushtype2(char *s)
{ 
	strcpy(stacktype2[stypecount++],s);
}


#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *con(int value) {
    nodeType *p;
    size_t nodeSize;

    /* allocate node */
    nodeSize =  sizeof(conNodeType);
    if ((p = malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *id(int i) {
    nodeType *p;
    size_t nodeSize;

    /* allocate node */
    nodeSize =  sizeof(idNodeType);
    if ((p = malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeId;
    p->id.i = i;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    size_t nodeSize;
    int i;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(oprNodeType) +
        (nops - 1) * sizeof(nodeType*);
    if ((p = malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}


int printtree(nodeType *p) {
int lbl1, lbl2;
if (!p) return 0;
switch(p->type) {
case typeCon:
printf("\tpush\t%d\n", p->con.value);
break;

case typeId:
 if(s%2==0){a[s]=p->id.i  ;s++;}
else {a[s]=p->id.i+'a'; s++;}
break;

case typeOpr:
switch(p->opr.oper) {

case WHILE:
printf("L%03d:\n", lbl1 = lbl++);
printtree(p->opr.op[0]);
printf("\t\tif(!var%d_0) GOTO L%03d\n",c, lbl2 = lbl++);
printtree(p->opr.op[1]);
printf("\t\tGOTO L%03d\n", lbl1);
printf("L%03d:\n", lbl2);
break;

case DO:
printf("L%03d:\n", lbl1 = lbl++);
printtree(p->opr.op[0]);
printtree(p->opr.op[1]);
printf("\t\tif(var%d_0) GOTO L%03d\n",c, lbl1);
printf("L%03d:\n", lbl2);
break;

case IF:
printtree(p->opr.op[0]);
if (p->opr.nops > 2) {
/* if else */
printf("\t\tif(!var%d_0) GOTO L%03d\n",c, lbl1 = lbl++);
printtree(p->opr.op[1]);
printf("\t\tGOTO L%03d\n", lbl2 = lbl++);
printf("L%03d:\n", lbl1);
printtree(p->opr.op[2]);
printf("L%03d:\n", lbl2);
} else {
/* if */
printf("\t\tif(!var%d_0) GOTO L%03d\n",c, lbl1 = lbl++);
printtree(p->opr.op[1]);
printf("L%03d:\n", lbl1);
}
break;
case '=':
printtree(p->opr.op[1]);
printf("\t\t%c=var%d;\n", p->opr.op[0]->id.i + 'a',c);
break;
case UMINUS:
printtree(p->opr.op[0]);
printf("\tnot\n");
break;
default:
printtree(p->opr.op[0]);
printtree(p->opr.op[1]);
switch(p->opr.oper) {
case '+': c++;printf("\t\tvar%d_0;\n\t\tvar%d_0=%c + %c ;\n",c,c, a[t] + 'a',a[t+1]);t+=2; break;
case '-': c++;printf("\t\tvar%d_0;\n\t\tvar%d_0=%c - %c ;\n",c,c, a[t] + 'a',a[t+1]);t+=2; break;
case '*': c++;printf("\t\tvar%d_0;\n\t\tvar%d_0=%c * %c ;\n",c,c, a[t] + 'a',a[t+1]);t+=2; break;
case '/': c++;printf("\t\tvar%d_0;\n\t\tvar%d_0=%c / %c ;\n",c,c, a[t] + 'a',a[t+1]);t+=2; break; 
case '<': c++;printf("\t\tvar%d_0;\n\t\tvar%d_0=%c < %c ;\n",c,c, a[t] + 'a',a[t+1]);t+=2; break;
case '>': c++;printf("\t\tvar%d_0;\n\t\tvar%d_0=%c > %c ;\n",c,c, a[t] + 'a',a[t+1]);t+=2; break;
case GE:  c++;printf("\t\tvar%d_0;\n\t\tvar%d_0=%c >= %c ;\n",c,c, a[t] + 'a',a[t+1]);t+=2; break;
case LE:  c++;printf("\t\tvar%d_0;\n\t\tvar%d_0=%c <= %c ;\n",c,c, a[t] + 'a',a[t+1]);t+=2; break;
case NE:  c++;printf("\t\tvar%d_0;\n\t\tvar%d_0=%c != %c ;\n",c,c, a[t] + 'a',a[t+1]);t+=2; break;
case EQ:  c++;printf("\t\tvar%d_0;\n\t\tvar%d_0=%c == %c ;\n",c,c, a[t] + 'a',a[t+1]);t+=2; break;
}
}
}
return 0;
}

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
