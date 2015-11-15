#include <stdio.h>

int fib(int i)
{
  if(i <= 2)
    {
      return 1;
    }
  else
    {
      return fib(i - 1) + fib(i - 2);
    }
}

int main(int argc, char ** argv)
{
  printf("%d\n", fib(36));

  return 0;
}

