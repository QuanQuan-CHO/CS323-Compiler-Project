# CS323 Project Phase4

**12011619 Liquan Wang**

**12111744 Wenhui Tao**

**12111611 Ruixiang Jiang**



## Language
Instead of using the provided C starter code, we use **Python** to implement the compiler, which is easy to develop

Use **PyInstaller** to compile `splc.py` to executable binary file `bin/splc`, and the provided judging environment has already installed `pyinstaller` 

```makefile
#Makefile
splc: splc.py
	pyinstaller --log-level WARN --distpath bin -F splc.py
```



## Translation

`translate()` is the core function to translate TAC to MIPS32 assembly code, and we use regex to match the TAC's pattern type

```python
def translate(tac: str) -> "list[str]":
    id = '[^\\d#*]\\w*'
    num = '#\\d+'
    if re.fullmatch(f'{id} := {num}', tac):  # x := #k
        x, k = tac.split(' := #')
        command.append(f'li {reg(x)}, {k}')
    if re.fullmatch(f'{id} := {id}', tac):  # x := y
        x, y = tac.split(' := ')
        command.append(f'move {reg(x)}, {reg(y)}')
    ...
```

Besides the basic translation scheme, we also do the following work:

Check if the three address code has numbers:
1. Support the return value and input as numbers
2. Support multiplication and division containing numbers
3. The positions of registers and numbers can be switched arbitrarily (`x := y - #k` or `x := #y - k` is OK)

**Efficiency**: 

- If there are no unknowns in addition, subtraction, multiplication, and division (that is, all numbers), the result is directly assigned to the target register

- For commands that use a stack variable, the variable in the stack is moved to the register using `lw`.

  Similarly, the variable in the stack can be identified by `sw` to the corresponding position

**Security**:

If the integers are not in the contraint range $[−2^{16}, 2^{16}−1)$, we can't translate them directly to MIPS32 immediates. So we do the additional translation logic like below, to avoid Arithmetic Overflow error in SPIM simulator

```python
def translate(tac: str) -> "list[str]":
    ...
	if re.fullmatch(fr'{id} := {num} \+ {id}', tac):  # x := #y + k
        x, y, k = re.split(r' := #| \+ ', tac)
        n = int(y)
        while n > 32767:
            command.append(f'addi {reg(k)}, {reg(k)}, {32767}')
            n = n - 32767
        command.append(f'addi {reg(x)}, {reg(k)}, {n}')
```



## Procedure Call

Before the function is called:

1. Store Active Variables in the stack
2. `jal` in the target function
3. Store `$ra` in the stack

After the function is called:

1. Get `$ra` in the stack
2. The result is stored in the stack 
3. The Active Variables are restored from the stack



### Active Variables

Before function invokation, we only need to store the active variables before invoking the function

The active variables are stored in the set `active_vars`, which is easy to maintain

The set will be updated only in three cases:

- `x := ...`
- `PARAM x`
- `READ x`

We only need to add `x` to `active_vars` while translating the TAC

When we get TACs like `IF x [op] y GOTO label`, we **don't** need to add `x` and `y` to `active_vars`, because `x` and `y` must be already declared in the form of the above three cases

Finally, clear the set after getting a new function TAC `FUNCTION f :`

```python
active_vars = set()  # the active variables in current function, need to be stored to memory before invoking subfunction
def translate(tac: str) -> "list[str]":
    if re.fullmatch(f'{id} := .+', tac):  # x := ...
        x, _ = tac.split(' := ')
        active_vars.add(x)
    if re.fullmatch(f'PARAM {id}', tac):  # PARAM x
        x = tac.split(' ')[1]
        active_vars.add(x)
    if re.fullmatch(f'READ {id}', tac):  # READ x
        x = tac.split(' ')[1]
        active_vars.add(x)
    if re.fullmatch(f'FUNCTION {id} :', tac):  # FUNCTION f :
        active_vars = set()  # start new function's active variables
```



## Register Allocation

For register allocation, we use a trivial strategy. If there isn't avaliable register, the variable will be stored to the stack

```python
# `var` can be variable or integer
def reg(var: str) -> str:
    try:
        if var == '0':
            return '$0'
        int(var) #check integer
        return var #directly return integer
    except: #variable case
        reg = find_reg(var)
        if reg:
            return reg
        # If there isn't avaliable register, the variable will be stored to the stack
        stack.append(var)
        return f'{stack.index(var) + max_var_num << 2}($sp)'

def find_reg(var: str) -> str:
    if var in register_table:
        return f'${register_table.index(var) + save_reg}'
    elif var in stack:
        return f'{(stack.index(var) + max_var_num) << 2}($sp)'
    else:  # No avaliable register
        return None
```



## Flexibility

If we need more than one register for the output of floating point numbers, we can adjust the special register by adjusting the number of pre-stored registers, and move the registers used for all operations back (the normally used register `$11` can easily be changed to `$12`)



