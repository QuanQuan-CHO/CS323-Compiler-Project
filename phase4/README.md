# CS323 Project Phase4

**12011619 Liquan Wang**

**12111744 Wenhui Tao**

**12111611 Ruixiang Jiang**

## How to Run and Test
1. make splc: `make`
2. auto test: `make test`

## Design
### Language
Use python to implement make splc with pyinstaller
### Procedure Call
before the function is called:
1. Store Active Variables in the stack
2. jal in the target function
3. Store ra in the stack

after the function is called:
1. get ra in the stack
2. the result is stored in the stack 
3. the Active Variables are restored from the stack

### Translation processing
check if the three address code has numbers:
1. Support the return value and input as numbers
2. Support multiplication and division containing numbers
3. The positions of registers and numbers can be switched arbitrarily (x := y - #k or x := #y - k is OK)

More efficient: 

1. If there are no unknowns in addition, subtraction, multiplication, and division (that is, all numbers), the result is directly assigned to the target register
2. For commands that use a stack Variable, the variable in the stack is moved to the register using `lw`. Similarly, the variable in the stack can be identified by `sw` to the corresponding position

More secure:

In mips, an addi number greater than 32767 or less than -32767 causes an arithmetic overflow, which we detected and addressed (see test15).

Easier to read:

At the beginning, jal directly jumps to main, obtains the return value of main function and then ends, without adjusting the position of the three-address code function

### Variables
We use specific registers `s6` for reading and writing and a portion of the stack space for storing common variables

Have tried it on multiple platforms, websites, and can run on Mars and various versions of spim

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





