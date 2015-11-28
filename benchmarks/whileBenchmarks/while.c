#include <stdio.h>

int main(int argc, char ** argv)
{
  unsigned long x = 0;
  while (x < 10000000) //10 million
    {
      printf("%lu\n", x);
      x++;
    }

  return 0;
}


