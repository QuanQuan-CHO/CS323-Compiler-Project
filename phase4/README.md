# CS323 Project Phase4

**12011619 Liquan Wang**

**12111744 Wenhui Tao**

**12111611 Ruixiang Jiang**



## Design

### Procedure Call

#### Active Variables

Before function call, we only need to store the active variables before invoking the function

The active variables are stored in the set `active_vars`, which is easy to maintain

The set will be updated only in three cases:

- `x := ...`
- `PARAM x`
- `READ x`

We only need to add `x` to `active_vars` while translating the TACs

When we get TACs like `IF x [op] y GOTO label`, we **don't** need to add `x` and `y` to `active_vars`, because `x` and `y` must be already declared in the form of the above three cases

Finally, clear the set after getting a new function TAC `FUNCTION f :`



