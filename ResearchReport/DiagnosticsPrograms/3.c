void foo(char **p, char **q)
{
  (p - q)();
  p();
}