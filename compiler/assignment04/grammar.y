%{
/* the grammar of lambda expression */
#include "tree.h"

void yyerror (char const *);
/************************************/

char *name_env[MAX_ENV] = {"+", "-", "*", "/", "=", "<"};

AST *ast_env[MAX_ENV];

int current = INIT_POS;

#define YYSTYPE AST *
FILE *texfile;
int is_decl = 0;
%}
%nonassoc '.'
%left THEN ELSE
%left INT LET ID IF FI '(' '@'
%left CONCAT
%%

lines : decl 

| lines decl 
;
 
decl : LET {is_decl = 1;} ID '=' expr ';' {
    name_env[current] = (char *) $3 -> lchild;
    ast_env[current++] = $5;
  }

|  expr ';' {
  print_expression($1, stdout);
  printtree($1);
  free_ast($1);
  printf("\nplease input a lambda term with \";\":\n");  
  }
;

expr : INT 

| ID {
  /* TODO */
    int depth = find_depth((char *)$1->lchild);
    $$ = $1, $$->value = depth;
  }

| IF expr THEN expr ELSE expr FI { /* TODO */ 
    if ($2) $$ = $4;
    else $$ = $6;
  } 

| '(' expr ')' { /* TODO */ 
    $$ = $2;
  }

| '@' ID  { /* TODO (midaction)*/ 
    name_env[current] = (char *)$2->lchild;
    ast_env[current++] = $2;
  } '.'  expr %prec THEN { 
  /* TODO */
    $$ = make_abs((char *)$2->lchild, $5);
    --current;
  } 

| expr expr %prec CONCAT   {/* TODO */
    $$ = make_app($1, $2);
  }
;

%%

void yyerror ( char const *s)
{
  printf ("%s!\n", s);
}

extern FILE * yyin;
int main ()
{
  if ((texfile = fopen("expr.tex", "w")) == NULL) exit(1);

  printf("please input a lambda term with \";\":\n");  
  
  yyparse ();
  fclose(texfile);
  return 0;
}
