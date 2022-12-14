%option noyywrap
%option never-interactive
%option yylineno

%{

#define _CRT_SECURE_NO_WARNINGS
//#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <string.h>

void printMLComment(const char* comment);
void printONComment(const char* comment);
void printKeyword(const char* keyword);
void printLogicOperator(const char* o);
void printComparisonOperator(const char* o);
void printArithmeticOperator(const char* o);
void printInteger(int i);
void printHex(int i);
void printBin(int i);
void printLong(long int i);
void printFloat(float f);
void printDouble(double d);
void printChar(const char c);
void printString(const char* str);
void printRawString(const char* str);
void printIdentifier(const char* id);
void printBackticksIdentifier(const char* id);
void printErr(const char* errMsg, int lineNum);
void removeChar(char * str, char charToRemmove);

%}

/* Note: There's no octal integer literals in Kotlin */

DEC_DIGIT[0-9]
HEX_DIGIT[0-9A-Fa-f]
BIN_DIGIT[01]
DEC_NUMBER({DEC_DIGIT}+[_]*)*{DEC_DIGIT}+
EXPONENT[eE][+-]?{DEC_NUMBER}
DOUBLE({DEC_NUMBER})?\.{DEC_NUMBER}|({DEC_NUMBER})?\.?{DEC_NUMBER}{EXPONENT}
DOUBLEF({DEC_NUMBER})?\.?{DEC_NUMBER}[fF]

%x RAW_STRING
%x BACKTICKS_IDENTIFIER
%x MULTILINE_COMMENT
%x STRING
%x CHAR

%%

%{

int currentInteger;
long int currentLong;
double currentDouble;
float currentFloat;
char currentString[1000];
char buffer[100];

%}

\`                                      {
                                            currentString[0] = '\0';
                                            BEGIN(BACKTICKS_IDENTIFIER);
                                        }

<BACKTICKS_IDENTIFIER>[^\`.:\/\[\]<>]+  {
                                            strcat(currentString, yytext);
                                        }

<BACKTICKS_IDENTIFIER>[.:\/\[\]<>]+     {
                                            printErr("Error! Name contains illegal characters", yylineno);
                                        }

<BACKTICKS_IDENTIFIER>\`                {
                                            printBackticksIdentifier(currentString);
                                            BEGIN(INITIAL);
                                        }


\"\"\"                                  {
                                            currentString[0] = '\0';
                                            BEGIN(RAW_STRING);
                                        }

<RAW_STRING>[^\"]*                      {
                                            strcat(currentString, yytext);
                                        }

<RAW_STRING>(\\?\"){1,2}                {
                                            strcat(currentString, yytext);
                                        }

<RAW_STRING>\"\"\"                      {
                                            printRawString(currentString);
                                            BEGIN(INITIAL);
                                        }

\/\*                                    {
                                            currentString[0] = '\0';
                                            BEGIN(MULTILINE_COMMENT);
                                        }

<MULTILINE_COMMENT>[^*]*                {
                                            strcat(currentString, yytext);
                                        }

<MULTILINE_COMMENT>\*+[^*/\n]*          {
                                            strcat(currentString, yytext);
                                        }

<MULTILINE_COMMENT>\*+\/                {
                                            printMLComment(currentString);
                                            BEGIN(INITIAL);
                                        }

\/\/.*                                  {
                                            printONComment(yytext);
                                        }

\"                                      {
                                            currentString[0] = '\0';
                                            BEGIN(STRING);
                                        }

\'                                      {
                                            currentString[0] = '\0';
                                            BEGIN(CHAR);
                                        }

<STRING>\"                              {
                                            printString(currentString);
                                            BEGIN(INITIAL);
                                        }

<CHAR>\'                                {
                                            if (currentString[1] != '\0')
                                            {
                                                printErr("Error! More than one character in a char literal", yylineno);
                                            }
                                            else
                                            {
                                                printChar(currentString[0]);
                                            }
                                            BEGIN(INITIAL);
                                        }

<STRING,CHAR>[^\\\"\'\n]+               {
                                            strcat(currentString, yytext);
                                        }

<STRING,CHAR>\\u[0-9a-fA-F]{1,4}        {
                                            sscanf(yytext, "%c", &buffer);
                                            strcat(currentString, buffer);
                                        }
                                        
<STRING,CHAR>\\n                        {
                                            strcat(currentString, "\n");
                                        }

<STRING,CHAR>\\t                        {
                                            strcat(currentString, "\t");
                                        }


<STRING,CHAR>\\b                        {
                                            strcat(currentString, "\b");
                                        }

<STRING,CHAR>\\$                        {
                                            strcat(currentString, "\$");
                                        }

<STRING>\n                              {
                                            printErr("Error! Expected end of string/char but found end of line!", yylineno);
                                            BEGIN(INITIAL);
                                        }

<STRING,CHAR,MULTILINE_COMMENT><<EOF>>  {
                                            printErr("Error! expected end of string but found end of file!", yylineno);
                                            BEGIN(INITIAL);
                                        }

<STRING,CHAR>\\r                        {
                                            strcat(currentString, "\r");
                                        }

<STRING,CHAR>\\0                        {
                                            strcat(currentString, "\0");
                                        }

<STRING,CHAR>\\\\                       {
                                            strcat(currentString, "\\");
                                        }

<STRING,CHAR>\\\"                       {
                                            strcat(currentString, "\"");
                                        }

<STRING,CHAR>\\\'                       {
                                            strcat(currentString, "\'");
                                        }

<STRING,CHAR>\\.                        {
                                             printErr("Error! Illegal escape ", yylineno);
                                             printf("Illegal escape: %s\n", yytext);
                                        }


as                                      { printKeyword(yytext); }
as\?                                    { printKeyword(yytext); }
break                                   { printKeyword(yytext); }
class                                   { printKeyword(yytext); }
continue                                { printKeyword(yytext); }
do                                      { printKeyword(yytext); }
else                                    { printKeyword(yytext); }
false                                   { printKeyword(yytext); }
for                                     { printKeyword(yytext); }
fun                                     { printKeyword(yytext); }
if                                      { printKeyword(yytext); }
in                                      { printKeyword(yytext); }
!in                                     { printKeyword(yytext); }
interface                               { printKeyword(yytext); }
is                                      { printKeyword(yytext); }
!is                                     { printKeyword(yytext); }
null                                    { printKeyword(yytext); }
object                                  { printKeyword(yytext); }
package                                 { printKeyword(yytext); }
return                                  { printKeyword(yytext); }
super                                   { printKeyword(yytext); }
this                                    { printKeyword(yytext); }
throw                                   { printKeyword(yytext); }
true                                    { printKeyword(yytext); }
try                                     { printKeyword(yytext); }
typealias                               { printKeyword(yytext); }
typeof                                  { printKeyword(yytext); }
val                                     { printKeyword(yytext); }
var                                     { printKeyword(yytext); }
when                                    { printKeyword(yytext); }
while                                   { printKeyword(yytext); }

by                                      { printKeyword(yytext); }
catch                                   { printKeyword(yytext); }
constructor                             { printKeyword(yytext); }
delegate                                { printKeyword(yytext); }
dynamic                                 { printKeyword(yytext); }
field                                   { printKeyword(yytext); }
file                                    { printKeyword(yytext); }
finally                                 { printKeyword(yytext); }
get                                     { printKeyword(yytext); }
import                                  { printKeyword(yytext); }
init                                    { printKeyword(yytext); }
param                                   { printKeyword(yytext); }
property                                { printKeyword(yytext); }
receiver                                { printKeyword(yytext); }
set                                     { printKeyword(yytext); }
setparam                                { printKeyword(yytext); }
value                                   { printKeyword(yytext); }
where                                   { printKeyword(yytext); }

abstract                                { printKeyword(yytext); }
actual                                  { printKeyword(yytext); }
annotation                              { printKeyword(yytext); }
companion                               { printKeyword(yytext); }
const                                   { printKeyword(yytext); }
crossinline                             { printKeyword(yytext); }
data                                    { printKeyword(yytext); }
enum                                    { printKeyword(yytext); }
expect                                  { printKeyword(yytext); }
external                                { printKeyword(yytext); }
final                                   { printKeyword(yytext); }
infix                                   { printKeyword(yytext); }
inline                                  { printKeyword(yytext); }
inner                                   { printKeyword(yytext); }
internal                                { printKeyword(yytext); }
lateinit                                { printKeyword(yytext); }
noinline                                { printKeyword(yytext); }
open                                    { printKeyword(yytext); }
operator                                { printKeyword(yytext); }
out                                     { printKeyword(yytext); }
override                                { printKeyword(yytext); }
private                                 { printKeyword(yytext); }
protected                               { printKeyword(yytext); }
public                                  { printKeyword(yytext); }
reified                                 { printKeyword(yytext); }
sealed                                  { printKeyword(yytext); }
suspend                                 { printKeyword(yytext); }
tailrec                                 { printKeyword(yytext); }
vararg                                  { printKeyword(yytext); }

"+"                                     { printArithmeticOperator(yytext); }
"-"                                     { printArithmeticOperator(yytext); }
"*"                                     { printArithmeticOperator(yytext); }
"/"                                     { printArithmeticOperator(yytext); }
"%"                                     { printArithmeticOperator(yytext); }

"="                                     { printf("Found assign operator: %s\n", yytext); }

"+="                                    { printArithmeticOperator(yytext); }
"-="                                    { printArithmeticOperator(yytext); }
"*="                                    { printArithmeticOperator(yytext); }
"/="                                    { printArithmeticOperator(yytext); }
"%="                                    { printArithmeticOperator(yytext); }

"++"                                    { printArithmeticOperator(yytext); }
"--"                                    { printArithmeticOperator(yytext); }

"&&"                                    { printLogicOperator(yytext); }
"||"                                    { printLogicOperator(yytext); }
"!"                                     { printLogicOperator(yytext); }

"=="                                    { printComparisonOperator(yytext); }
"!="                                    { printComparisonOperator(yytext); }
"==="                                   { printComparisonOperator(yytext); }
"!=="                                   { printComparisonOperator(yytext); }
"<="                                    { printComparisonOperator(yytext); }
">="                                    { printComparisonOperator(yytext); }
">"                                     { printf("Found right angle bracket: %s\n", yytext); }
"<"                                     { printf("Found left angle bracket: %s\n", yytext); }

\[                                      { printf("Found token: %s\n", yytext); }
\]                                      { printf("Found token: %s\n", yytext); }

"?"                                     { printf("Found token: %s\n", yytext); }
":"                                     { printf("Found token: %s\n", yytext); }
";"                                     { printf("Found token: %s\n", yytext); }
","                                     { printf("Found token: %s\n", yytext); }
"."                                     { printf("Found token: %s\n", yytext); }

"?:"                                    { printf("Found token: %s\n", yytext); }
"::"                                    { printf("Found token: %s\n", yytext); }
"!!"                                    { printf("Found token: %s\n", yytext); }
".."                                    { printf("Found token: %s\n", yytext); }
"?."                                    { printf("Found token: %s\n", yytext); }

"_"                                     { printf("Found token: %s\n", yytext); }

\{                                      { printf("Found token: %s\n", yytext); }
\}                                      { printf("Found token: %s\n", yytext); }

\(                                      { printf("Found token: %s\n", yytext); }
\)                                      { printf("Found token: %s\n", yytext); }

->                                      { printf("Found token: %s\n", yytext); }
@                                       { printf("Found token: %s\n", yytext); }

0x{HEX_DIGIT}+                          {
                                            buffer[0] = '\0';
                                            strcat(buffer, yytext);
                                            char *p;
                                            currentLong = strtol(buffer, &p, 16);
                                            printHex(currentLong);
                                        }

0b{BIN_DIGIT}+                          {
                                            buffer[0] = '\0';
                                            strcat(buffer, yytext);
                                            char dest[1000];
                                            strcpy(dest, buffer+2);
                                            char *p;
                                            currentLong = strtol(dest, &p, 2);
                                            printBin(currentLong);
                                        }

{DEC_DIGIT}L                            {
                                            buffer[0] = '\0';
                                            strcat(buffer, yytext);
                                            removeChar(buffer, '_');
                                            char *p;
                                            currentLong = strtol(buffer, &p, 10);;
                                            printLong(currentLong);
                                        }

{DOUBLEF}                               {
                                            buffer[0] = '\0';
                                            strcat(buffer, yytext);
                                            removeChar(buffer, '_');
                                            currentFloat = atof(buffer);
                                            printFloat(currentFloat);
                                        }

{DOUBLE}                                {
                                            buffer[0] = '\0';
                                            strcat(buffer, yytext);
                                            removeChar(buffer, '_');
                                            currentFloat = atof(buffer);
                                            printDouble(currentFloat);
                                        }

{DEC_NUMBER}                            {
                                            buffer[0] = '\0';
                                            strcat(buffer, yytext);
                                            removeChar(buffer, '_');
                                            currentInteger = atoi(buffer);
                                            printInteger(currentInteger);
                                        }

[a-zA-Z_][a-zA-Z0-9_]*                  {
                                            printIdentifier(yytext);
                                        }


[\s\n]+                                 { /* no action */ }

%%

void removeChar(char * str, char charToRemmove){
    int i, j;
    int len = strlen(str);
    for(i=0; i<len; i++)
    {
        if(str[i] == charToRemmove)
        {
            for(j=i; j<len; j++)
            {
                str[j] = str[j+1];
            }
            len--;
            i--;
        }
    }
    
}

void printMLComment(const char* comment)
{
    printf("Found multiline comment: \n\"%s\"\n\n", comment);
}

void printONComment(const char* comment)
{
    printf("Found one line comment: \n\"%s\"\n\n", comment);
}

void printKeyword(const char* keyword)
{
    printf("Found keyword: %s\n", keyword);
}

void printLogicOperator(const char* o)
{
    printf("Found logic operator: %s\n", o);
}

void printComparisonOperator(const char* o)
{
    printf("Found comparison operator: %s\n", o);
}

void printArithmeticOperator(const char* o)
{
    printf("Found arithmetic operator: %s\n", o);
}

void printInteger(int i)
{
    printf("Found integer: %d\n", i);
}

void printHex(int i)
{
    printf("Found hex: %d\n", i);
}

void printBin(int i)
{
    printf("Found bin: %d\n", i);
}

void printLong(long int i)
{
    printf("Found long integer: %ld\n", i);
}

void printFloat(float f)
{
    printf("Found float: %f\n", f);
}

void printDouble(double d)
{
    printf("Found double: %lf\n", d);
}

void printChar(const char c)
{
    printf("Found char: %c\n", c);
}

void printString(const char* str)
{
    printf("Found string: \n%s\n\n", str);
}

void printRawString(const char* str)
{
    printf("Found RAW string: \n\"\"\"%s\"\"\"\n\n", str);
}

void printIdentifier(const char* id)
{
    printf("Found identifier: %s\n", id);
}

void printBackticksIdentifier(const char* id)
{
    printf("Found identifier in backticks: %s\n", id);
}

void printErr(const char* errMsg, int lineNum)
{
    if (lineNum >= 0)
    {
        printf("Error in line %d\n", lineNum);
    }

    printf("Error message: %s\n", errMsg);
}

int main(int argc, char* argv[])
{
    //yyin = fopen(argv[1], "r");
    yyin = fopen("text.txt", "r");
    yylex();
    return 0;
}