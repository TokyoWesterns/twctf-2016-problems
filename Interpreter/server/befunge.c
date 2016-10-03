#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
const int dc[4] = {1, 0, -1, 0}, dr[4] = {0, 1, 0, -1};
int posR = 0, posC = 0, direction = 0;
char program[25][80];
int skips = 0, strmode = 0;
long stack[100000];
int stack_pos = 0;

void stack_push(long x) {
  stack[stack_pos++] = x;
  if(stack_pos == sizeof(stack) / sizeof(long)) {
    puts("Stack overflow.");
    exit(0);
  }
}

long stack_pop() {
  if(stack_pos == 0) {
    puts("Stack underflow.");
    exit(0);
  }
  return stack[--stack_pos];
}

void handler() {
  puts("Time out");
  exit(0);
}

int main() {
  alarm(40);
  signal(SIGALRM, handler);

  setvbuf(stdin, NULL, _IONBF, 0);
  setvbuf(stdout, NULL, _IONBF, 0);
  long tmp;
  long tmp2;
  int input;
  char buf[82];
  puts("Welcome to Online Befunge(93) Interpreter");
  puts("Please input your program.");
  for(int i = 0; i < 25; i++) {
    printf("> ");
    memset(buf, 0, sizeof(buf));
    if(fgets(buf, 82, stdin) == NULL) break;
    if(strlen(buf) > 0 && buf[strlen(buf) - 1] == '\n') {
      buf[strlen(buf) - 1] = '\0';
    }
    for(int j = 0; j < 80; j++) {
      program[i][j] = buf[j];
    }
  }

  for(int steps = 0; steps <= 10000; steps++) {
    tmp = tmp2 = 0;
    if(strmode) {
      if(program[posR][posC] == '"') {
        strmode = 0;
      }else{
        stack_push(program[posR][posC]);
      }
    }else if(skips > 0) {
      skips--;
    }else{
      switch(program[posR][posC]) {
        case '<':
          direction = 2;
          break;
        case '>':
          direction = 0;
          break;
        case 'v':
          direction = 1;
          break;
        case '^':
          direction = 3;
          break;
        case '_':
          if(stack_pop() == 0) {
            direction = 0;
          }else{
            direction = 2;
          }
          break;
        case '|':
          if(stack_pop() == 0) {
            direction = 1;
          }else {
            direction = 3;
          }
          break;
        case ' ':
          break;
        case '#':
          skips = 1;
          break;
        case '@':
          puts("\n");
          puts("Program exited");
          exit(0);
        case '"':
          strmode = 1;
          break;
        case '&':
          scanf("%d", &input);
          stack_push(input);
          break;
        case '~':
          tmp = getchar();
          stack_push(tmp);
          break;
        case '.':
          tmp = stack_pop();
          printf("%d ", tmp);
          break;
        case ',':
          tmp = stack_pop();
          putchar(tmp);
          break;
        case '+':
          tmp = stack_pop();
          tmp2 = stack_pop();
          stack_push(tmp2 + tmp);
          break;
        case '-':
          tmp = stack_pop();
          tmp2 = stack_pop();
          stack_push(tmp2 - tmp);
          break;
        case '*':
          tmp = stack_pop();
          tmp2 = stack_pop();
          stack_push(tmp2 * tmp);
          break;
        case '/':
          tmp = stack_pop();
          tmp2 = stack_pop();
          stack_push(tmp2 / tmp);
          break;
        case '%':
          tmp = stack_pop();
          tmp2 = stack_pop();
          stack_push(tmp2 % tmp);
          break;
        case '`':
          tmp = stack_pop();
          tmp2 = stack_pop();
          stack_push(tmp2 > tmp ? 1 : 0);
          break;
        case '!':
          tmp = stack_pop();
          stack_push(tmp == 0 ? 1 : 0);
          break;
        case ':':
          tmp = stack_pop();
          stack_push(tmp);
          stack_push(tmp);
          break;
        case '\\':
          tmp = stack_pop();
          tmp2 = stack_pop();
          stack_push(tmp);
          stack_push(tmp2);
          break;
        case '$':
          stack_pop();
          break;
        case 'g':
          tmp = stack_pop();
          tmp2 = stack_pop();
          stack_push(program[tmp][tmp2]);
          break;
        case 'p':
          tmp = stack_pop();
          tmp2 = stack_pop();
          program[tmp][tmp2] = stack_pop();
          break;
        default:
          if(program[posR][posC] >= '0' && program[posR][posC] <= '9') {
            stack_push(program[posR][posC] - '0');
          }
      }
    }
    posR += dr[direction];
    posC += dc[direction];
    if(posR == -1) posR = 24;
    if(posR == 25) posR = 0;
    if(posC == -1) posC = 79;
    if(posC == 80) posC = 0;
  }
  puts("Too many steps. Is there any infinite loops?");
  return 0;
}
