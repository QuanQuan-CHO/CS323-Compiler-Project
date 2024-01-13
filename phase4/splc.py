#!/usr/bin/python3
import re
import sys

# 总共的reg数量
num_registers = 10
# 预存的reg数，用来转移和计算的为号码大于11的寄存器
save_reg = 11
# 无法通过±实现栈的存取，200及以上为栈中存变量的部分，0-199为调用函数时预留的栈空间，此处没有左移2，在函数中调用时有
max_var_num = 200
register_table = [None] * num_registers
# 留一个0，避免变量或者函数调用占据（也可以去掉）
stack = ['empty']

data = """.data
array: .space 400
_prmpt: .asciiz "Enter an integer:"
_eol: .asciiz "\\n"
.globl main
.text"""
# 用来打印，读取，$8在预存的寄存器中，在调用之后会从$8转移到特定变量
pre = """read:
    li $v0, 4
    move $s6, $a0
    la $a0, _prmpt
    syscall
    move $a0, $8
    li $v0, 5
    syscall
    jr $ra
write:
    li $v0, 1
    syscall
    li $v0, 4
    move $8, $a0
    la $a0, _eol
    syscall
    jr $ra"""

function_params: "dict[str, list[str]]" = {}  # {id->[v1,v2,...]}


# 先读一遍，把函数中要调用的参数收集好
def collect_params(ir_path) -> None:
    with open(ir_path, 'r') as ir:
        params = []
        for tac in ir.read().splitlines():
            if 'FUNCTION' in tac:
                params = []
                func = tac.split()[1]
                function_params[func] = params
            elif 'PARAM' in tac:
                param = tac.split()[1]
                params.append(param)


collect_params(sys.argv[1])
num_var = 0


# the register allocation algorithm
# 分配+查询reg
def reg(var: str) -> str:
    try:
        if var == '0':
            return '$0'
        int(var)
        return var
    except:
        reg = find_reg(var)
        if reg:
            return reg

        # # 尝试分配一个未被使用的寄存器
        # for index, reg in enumerate(register_table):
        #     if not reg:
        #         register_table[index] = var
        #         return f'${index + save_reg +1 }'

        # 如果没有可用寄存器，将变量存储到栈上
        stack.append(var)
        return f'{stack.index(var) + max_var_num << 2}($sp)'


def find_reg(var: str):
    if var in register_table:
        return f'${register_table.index(var) + save_reg}'
    elif var in stack:
        return f'{(stack.index(var) + max_var_num) << 2}($sp)'
    else:
        return None


# 把栈上的变量存到另一个栈上变量
def from_heap2heap(wf, wt, fi_command):
    fi_command.append(f'lw ${save_reg}, {wf}')
    fi_command.append(f'sw ${save_reg}, {wt}')


# 把寄存器的值存到栈上
# 小于$sp原本值进行操作时，不会报错，但不会有效果（可能是我mars的特定效果？）
def lw_stackfreg(fi_command, desreg, reg1=save_reg - 2, reg2=save_reg - 1):
    fi_command.append(f'lw {desreg},0(${reg2})')
    fi_command.append(f'addi ${reg1},${reg1},-4')
    fi_command.append(f'add ${reg2},${reg1},$sp')


# 把在栈的值存到目标寄存器上
def sw_stackfreg(fi_command, desreg, reg1=save_reg - 2, reg2=save_reg - 1):
    fi_command.append(f'addi ${reg1},${reg1},4')
    fi_command.append(f'add ${reg2},${reg1},$sp')
    fi_command.append(f'sw {desreg},0(${reg2})')


# 把在栈的值存到栈上
def lw_stack2stack(fi_command, des, reg1=save_reg - 2, reg2=save_reg - 1):
    fi_command.append(f'lw ${save_reg},0(${reg2})')
    fi_command.append(f'sw ${save_reg},{des}')
    fi_command.append(f'addi ${reg1},${reg1},-4')
    fi_command.append(f'add ${reg2},${reg1},$sp')


# 把在栈上的值存到在栈的变量里
def sw_stack2stack(fi_command, fr, reg1=save_reg - 2, reg2=save_reg - 1):
    fi_command.append(f'addi ${reg1},${reg1},4')
    fi_command.append(f'add ${reg2},${reg1},$sp')
    fi_command.append(f'lw ${save_reg},{fr}')
    fi_command.append(f'sw ${save_reg},0(${reg2})')


arg_stack = []  # store the `ARG x` in order, need to be popped before invoking subfunction
active_vars = set()  # the active variables in current function, need to be stored to memory before invoking subfunction


# Translate TAC to assembly code
def translate(tac: str) -> "list[str]":
    global active_vars
    id = '[^\\d#*]\\w*'
    num = '#\\d+'
    id_num = f'({id}|{num})'
    command = []
    fi_command = []

    if re.fullmatch(f'{id} := .+', tac):  # x := ...
        x, _ = tac.split(' := ')
        active_vars.add(x)
    if re.fullmatch(f'{id} := {num}', tac):  # x := #k
        x, k = tac.split(' := #')
        command.append(f'li {reg(x)}, {k}')
    if re.fullmatch(f'{id} := {id}', tac):  # x := y
        x, y = tac.split(' := ')
        command.append(f'move {reg(x)}, {reg(y)}')
    if re.fullmatch(fr'{id} := {id_num} \+ {num}', tac):  # x := y + #k
        x, y, k = re.split(r' := #?| \+ #', tac)
        if y.isdigit():
            resn = int(y) + int(k)
            if resn > 32767:
                fi_command.append(f'li ${save_reg + 2},0')
                while resn > 32767:
                    command.append(f'addi ${save_reg + 2}, ${save_reg + 2}, {32767}')
                    resn = resn - 32767
                command.append(f'addi ${save_reg + 2}, ${save_reg + 2}, {resn}')
                command.append(f'move {reg(x)}, ${save_reg + 2}')
            else:
                command.append(f'li {reg(x)}, {resn}')
        else:
            n = int(k)
            while n > 32767:
                command.append(f'addi {reg(y)}, {reg(y)}, {32767}')
                n = n - 32767
            command.append(f'addi {reg(x)}, {reg(y)}, {n}')
    elif re.fullmatch(fr'{id} := {num} \+ {id}', tac):  # x := #y + k
        x, y, k = re.split(r' := #| \+ ', tac)
        n = int(y)
        while n > 32767:
            command.append(f'addi {reg(k)}, {reg(k)}, {32767}')
            n = n - 32767
        command.append(f'addi {reg(x)}, {reg(k)}, {n}')
    elif re.fullmatch(fr'{id} := {id_num} \+ {id}', tac):  # x := y + z
        x, y, z = re.split(r' := | \+ ', tac)
        command.append(f'add {reg(x)}, {reg(y)}, {reg(z)}')
    if re.fullmatch(f'{id} := {id_num} - {num}', tac):  # x := y - #k
        x, y, k = re.split(' := #?| - #', tac)
        if reg(y).isdigit():
            resn = int(y) - int(k)
            if resn < -32767:
                fi_command.append(f'li ${save_reg + 2},0')
                while resn < -32767:
                    command.append(f'addi ${save_reg + 2}, ${save_reg + 2}, {-32767}')
                    resn = resn + 32767
                command.append(f'addi ${save_reg + 2}, ${save_reg + 2}, {resn}')
                command.append(f'move {reg(x)}, ${save_reg+2}')
            else:
                command.append(f'li {reg(x)}, {resn}')
        else:
            n = -int(k)
            while n < -32767:
                command.append(f'addi {reg(y)}, {reg(y)}, {-32767}')
                n = n + 32767
            command.append(f'addi {reg(x)}, {reg(y)}, {n}')
    elif re.fullmatch(f'{id} := {num} - {id}', tac):  # x := #y - k
        x, y, k = re.split(' := #| - ', tac)
        n = int(y)
        while n > 32767:
            command.append(f'addi {reg(k)}, {reg(y)}, {32767}')
            n = n - 32767
        command.append(f'addi {reg(x)}, {reg(k)}, -{n}')
        command.append(f'sub {reg(x)}, $0, {reg(x)}')
    elif re.fullmatch(f'{id} := {id_num} - {id}', tac):  # x := y - z
        x, y, z = re.split(' := | - ', tac)
        command.append(f'sub {reg(x)}, {reg(y)}, {reg(z)}')
    if re.fullmatch(fr'{id} := {id_num} \* {id_num}', tac):  # x := y * z
        x, y, z = re.split(r' := #?| \* #?', tac)
        if reg(y).isdigit():
            if reg(z).isdigit():
                command.append(f'li {reg(x)}, {int(y) * int(z)}')
            else:
                fi_command.append(f'li ${save_reg + 1}, {y}')
                fi_command.append(f'lw ${save_reg + 2}, {reg(z)}')
                command.append(f'mul {reg(x)}, ${save_reg + 1}, ${save_reg + 2}')
        else:
            command.append(f'mul {reg(x)}, {reg(y)}, {reg(z)}')
    if re.fullmatch(f'{id} := {id_num} / {id_num}', tac):  # x := y / z
        x, y, z = re.split(' := #?| / #?', tac)
        if z.isdigit():
            if reg(y).isdigit():
                command.append(f'li {reg(x)}, {int(y) // int(z)}')
            else:
                fi_command.append(f'lw ${save_reg},{reg(y)}')
                fi_command.append(f'li ${save_reg + 1},{z}')
                fi_command.append(f'div ${save_reg},${save_reg + 1}')
        else:
            command.append(f'div {reg(y)}, {reg(z)}')
        command.append(f'mflo {reg(x)}')
    if re.fullmatch(fr'{id} := \*{id_num}', tac):  # x := *y
        x, y = tac.split(' := *')
        command.append(f'lw {reg(x)}, 0({reg(y)})')
    if re.fullmatch(fr'\*{id_num} := {id_num}', tac):  # *x := y
        _, x, y = re.split(r'\*| := ', tac)
        command.append(f'sw {reg(y)}, 0({reg(x)})')
    if re.fullmatch(f'GOTO {id}', tac):  # GOTO x
        x = tac.split('GOTO ')[1]
        command.append(f'j {x}')
    if re.fullmatch(f'{id} := CALL {id}', tac):  # x := CALL f
        x, f = tac.split(' := CALL ')
        active_var_list = list(active_vars)
        # 1.store current active variables to memory
        for v in active_var_list:
            sw_stack2stack(fi_command, reg(v))

        # 2.传参
        for p in function_params[f]:
            arg = arg_stack.pop()
            if arg.isdigit():
                fi_command.append(f'li ${save_reg},{arg}')
                fi_command.append(f'sw ${save_reg},{reg(p)}')
            else:
                from_heap2heap(reg(arg), reg(p), fi_command)

        fi_command.append(f'jal {f}')

        # 此时返回的值存在栈上

        # 3.将返回值从栈调出到v0
        lw_stackfreg(fi_command, '$v0')

        # 4.恢复
        for v in reversed(active_var_list):
            lw_stack2stack(fi_command, reg(v))

        command.append(f'move {reg(x)}, $v0')
    if re.fullmatch(f'RETURN {id_num}', tac):  # RETURN x
        _, x = re.split('RETURN #?| ', tac)
        # command.append(f'move $v0, {reg(x)}')

        lw_stackfreg(fi_command, '$ra')
        if x.isdigit():
            fi_command.append(f'li $v0,{x}')
            sw_stackfreg(fi_command, '$v0')
        # 把v0（返回结果）存入栈
        else:
            sw_stack2stack(fi_command, reg(x))
        command.append(f'jr $ra')
    if re.fullmatch(f'IF {id_num} < {id_num} GOTO {id}', tac):  # IF x < y GOTO z
        _, x, y, z = re.split('IF | < #?| GOTO ', tac)
        command.append(f'blt {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'IF {id_num} <= {id_num} GOTO {id}', tac):  # IF x <= y GOTO z
        _, x, y, z = re.split('IF | <= #?| GOTO ', tac)
        command.append(f'ble {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'IF {id_num} > {id_num} GOTO {id}', tac):  # IF x > y GOTO z
        _, x, y, z = re.split('IF | > #?| GOTO ', tac)
        command.append(f'bgt {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'IF {id_num} >= {id_num} GOTO {id}', tac):  # IF x >= y GOTO z
        _, x, y, z = re.split('IF | >= #?| GOTO ', tac)
        command.append(f'bge {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'IF {id_num} != {id_num}+ GOTO {id}', tac):  # IF x != y GOTO z
        _, x, y, z = re.split('IF | != #?| GOTO ', tac)
        command.append(f'bne {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'IF {id_num} == {id_num} GOTO {id}', tac):  # IF x == y GOTO z
        _, x, y, z = re.split('IF | == #?| GOTO ', tac)
        command.append(f'beq {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'FUNCTION {id} :', tac):  # FUNCTION f :
        f = tac.split(' ')[1]
        active_vars = set()  # start new function's active variables
        fi_command.append(f'{f}:')
        sw_stackfreg(fi_command, '$ra')
    if re.fullmatch(f'LABEL {id} :', tac):  # LABEL l :
        l = tac.split(' ')[1]
        command.append(f'{l}:')
    if re.fullmatch(f'PARAM {id}', tac):  # PARAM x
        x = tac.split(' ')[1]
        active_vars.add(x)
    if re.fullmatch(f'ARG {id_num}', tac):  # ARG x
        _, x = re.split('ARG #?| ', tac)
        # FIXME: ARG #10
        arg_stack.append(x)
    if re.fullmatch(f'WRITE {id_num}', tac):  # WRITE x
        _, x = re.split('WRITE #?| ', tac)
        if x.isdigit():
            fi_command.append(f'li $4,{x}')
        else:
            fi_command.append(f'lw $4, {reg(x)}')
        fi_command.append(f'jal write')
    if re.fullmatch(f'READ {id}', tac):  # READ x
        x = tac.split(' ')[1]
        active_vars.add(x)
        fi_command.append(f'jal read')
        fi_command.append(f'sw $2,{reg(x)}')

    for index, c in enumerate(command):
        co = c.replace(',', '')
        regs = [s for s in co.split()[1:] if '$' in s]

        for ind, r in enumerate(regs):
            if '$sp' in r:
                fi_command.append(f'lw ${ind + save_reg},{r}')
                c = c.replace(r, f'${ind + save_reg}')
        fi_command.append(c)
        if ':=' in tac:
            x, _ = tac.split(' := ')
            r = regs[0]
            if '$sp' in r:
                fi_command.append(f'sw ${save_reg},{r}')
    return fi_command


if len(sys.argv) < 2:
    print("Usage: splc <ir_path>")
    sys.exit(1)

# 最后的结果在对应.s文件中
ir_path = sys.argv[1]
assembly_path = ir_path.replace('.ir', '.s')
with open(assembly_path, 'w') as asm:
    asm.write(f'{data}\n'
              f'jal main\n'
              f'j end\n'
              f'{pre}\n')

with open(ir_path, 'r') as ir:
    for tac in ir.read().splitlines():
        res = translate(tac)
        if not res:
            # print(f'no translate: {tac}')
            pass
        else:
            with open(assembly_path, 'a') as asm:
                asm.write("\n".join(res))
                asm.write("\n")
                asm.write("\n")
with open(assembly_path, 'a') as asm:
    asm.write('end:')
