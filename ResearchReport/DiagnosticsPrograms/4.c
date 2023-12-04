struct a {
    virtual int bar();
  };
  
  struct foo : public virtual a {
  };
  
  void test(foo *P) {
    return P->bar() + *P;
  }