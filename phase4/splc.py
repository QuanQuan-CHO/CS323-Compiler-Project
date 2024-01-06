#!/usr/bin/python3
import re
import sys
from queue import Queue

num_registers = 32
save_reg = 11
max_var_num = 500
register_table = [None] * num_registers
stack = ['empty']
queue = []
argmap = {}
varmap = {}
fun_save = []
data = """
.data
array: .space 400
_prmpt: .asciiz "Enter an integer:"
_eol: .asciiz "\\n"
.globl main
.text"""

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


def read_file(file_path):
    current_paragraph = []
    with open(file_path+'.ir', 'r') as file:
        for line in file:
            if (line.startswith("LABEL") or line.startswith("FUNCTION")) and ":" in line:
                current_paragraph = []
                argmap[line.split()[1]] = current_paragraph
            if (line.startswith("FUNCTION")) and ":" in line:
                current_var = set()
                varmap[line.split()[1]] = current_var
            if 'PARAM' in line:
                current_paragraph.append(line.split()[1])
            vars = line.split()
            for v in vars:
                if re.fullmatch(r'[vt]\d+', v):
                    current_var.add(v)
    return argmap


read_file(sys.argv[1])
num_var = 0
# print(varmap)


# the register allocation algorithm
# 分配+查询reg
def reg(var: str) -> str:
    try:
        if var == '0':
            return '$0'
        int(var)
        return var
    except:
        res = find_Reg(var)
        if res:
            return res

        # # 尝试分配一个未被使用的寄存器
        # for index, reg in enumerate(register_table):
        #     if not reg:
        #         register_table[index] = var
        #         return f'${index + save_reg}'
        # 如果没有可用寄存器，将变量存储到栈上
        stack.append(var)
        return f'{stack.index(var) + max_var_num << 2}($sp)'


def find_Reg(var: str):
    if var in register_table:
        return f'${register_table.index(var) + save_reg}'
    elif var in stack:
        return f'{(stack.index(var) + max_var_num) << 2}($sp)'
    else:
        return None


def from_heap2heap(wf, wt, fi_command):
    fi_command.append(f'lw ${save_reg}, {wf}')
    fi_command.append(f'sw ${save_reg}, {wt}')


def lw_stackfreg(fi_command, desreg, reg1=save_reg - 2, reg2=save_reg - 1):
    fi_command.append(f'lw {desreg},0(${reg2})')
    fi_command.append(f'addi ${reg1},${reg1},-4')
    fi_command.append(f'add ${reg2},${reg1},$sp')


def sw_stackfreg(fi_command, desreg, reg1=save_reg - 2, reg2=save_reg - 1):
    fi_command.append(f'addi ${reg1},${reg1},4')
    fi_command.append(f'add ${reg2},${reg1},$sp')
    fi_command.append(f'sw {desreg},0(${reg2})')


def lw_stack2stack(fi_command, des, reg1=save_reg - 2, reg2=save_reg - 1):
    fi_command.append(f'lw ${save_reg},0(${reg2})')
    fi_command.append(f'sw ${save_reg},{des}')
    fi_command.append(f'addi ${reg1},${reg1},-4')
    fi_command.append(f'add ${reg2},${reg1},$sp')


def sw_stack2stack(fi_command, fr, reg1=save_reg - 2, reg2=save_reg - 1):
    fi_command.append(f'addi ${reg1},${reg1},4')
    fi_command.append(f'add ${reg2},${reg1},$sp')
    fi_command.append(f'lw ${save_reg},{fr}')
    fi_command.append(f'sw ${save_reg},0(${reg2})')


# Translate TAC to assembly code
# 在遇到arg的时候存入queue中，之后对照param lw sw 过去
def translate(tac: str):
    id = '[^\\d#*]\\w*'
    command = []
    fi_command = []
    if re.fullmatch(r'(\w+)\s*:=\s*#(\w+)', tac):  # x := #k
        x, k = tac.split(' := #')
        command.append(f'li {reg(x)}, {k}')
    if re.fullmatch(r'(\w+)\s*:=\s*(\w+)', tac):  # x := y
        x, y = tac.split(' := ')
        command.append(f'move {reg(x)}, {reg(y)}')
    if re.fullmatch(r'(\w+)\s*:=\s*(\w+)\s*\+\s*#(\w+)', tac):  # x := y + #k
        x, y, k = re.split(' := | \\+ #', tac)
        command.append(f'addi {reg(x)}, {reg(y)}, {k}')
    if re.fullmatch(r'(\w+)\s*:=\s*(\w+)\s*\+\s*(\w+)', tac):  # x := y + z
        x, y, z = re.split(' := | \\+ ', tac)
        command.append(f'add {reg(x)}, {reg(y)}, {reg(z)}')
    if re.fullmatch(r'(\w+)\s*:=\s*(\w+)\s*-\s*#(\w+)', tac):  # x := y - #k
        x, y, k = re.split(' := | - #', tac)
        command.append(f'addi {reg(x)}, {reg(y)}, -{k}')
    if re.fullmatch(r'(\w+)\s*:=\s*#?(\w+)\s*-\s*(\w+)', tac):  # x := y - z
        x, y, z = re.split(' := #?| - ', tac)
        command.append(f'sub {reg(x)}, {reg(y)}, {reg(z)}')
    if re.fullmatch(r'(\w+)\s*:=\s*(\w+)\s*\*\s*(\w+)', tac):  # x := y * z
        x, y, z = re.split(' := | \\* ', tac)
        command.append(f'mul {reg(x)}, {reg(y)}, {reg(z)}')
    if re.fullmatch(r'(\w+)\s*:=\s*(\w+)\s*/\s*(\w+)', tac):  # x := y / z
        x, y, z = re.split(' := | / ', tac)
        command.append(f'div {reg(y)}, {reg(z)}')
        command.append(f'mflo {reg(x)}')
    if re.fullmatch(r'(\w+)\s*:=\s*\*(\w+)', tac):  # x := *y
        x, y = tac.split(' := *')
        command.append(f'lw {reg(x)}, 0({reg(y)})')
    if re.fullmatch(r'\*(\w+)\s*:=\s*(\w+)', tac):  # *x := y
        _, x, y = re.split('\\*| := ', tac)
        command.append(f'sw {reg(y)}, 0({reg(x)})')
    if re.fullmatch(r'GOTO\s+(\w+)', tac):  # GOTO x
        x = tac.split('GOTO ')[1]
        command.append(f'j {x}')
    if re.fullmatch(r'(\w+)\s*:=\s*CALL\s+(\w+)', tac):  # x := CALL f
        x, f = tac.split(' := CALL ')
        var_list = list(varmap[f])
        # 存档
        for v in var_list:
            sw_stack2stack(fi_command, reg(v), )

        # 传参
        for p in argmap[f]:
            # arg = reg(queue.get())
            arg=reg(queue.pop())
            para = reg(p)
            from_heap2heap(arg, para, fi_command)

        fi_command.append(f'jal {f}')

        # 此时返回的值存在栈上

        # 直接将返回值从栈调出到v0
        lw_stackfreg(fi_command,'$v0')
        # 恢复
        for v in reversed(var_list):
            lw_stack2stack(fi_command, reg(v), )

        command.append(f'move {reg(x)}, $v0')
    if re.fullmatch('RETURN\s+#?(\w+)', tac):  # RETURN x
        _, x = re.split('RETURN #?| ', tac)
        # command.append(f'move $v0, {reg(x)}')

        lw_stackfreg(fi_command, '$ra')
        if x.isdigit():
            fi_command.append(f'li $v0,{x}')
            lw_stackfreg(fi_command, '$v0')
        # 把v0（返回结果）存入栈
        else:
            sw_stack2stack(fi_command, reg(x))
        command.append(f'jr $ra')
    if re.fullmatch(r'IF\s+(\w+)\s*<\s*#?(\w+)\s*GOTO\s+(\w+)', tac):  # IF x < y GOTO z
        _, x, y, z = re.split('IF | < #?| GOTO ', tac)
        command.append(f'blt {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(r'IF\s+(\w+)\s*<=\s*#?(\w+)\s*GOTO\s+(\w+)', tac):  # IF x <= y GOTO z
        _, x, y, z = re.split('IF | <= #?| GOTO ', tac)
        command.append(f'ble {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(r'IF\s+(\w+)\s*>\s*#?(\w+)\s*GOTO\s+(\w+)', tac):  # IF x > y GOTO z
        _, x, y, z = re.split('IF | > #?| GOTO ', tac)
        command.append(f'bgt {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(r'IF\s+(\w+)\s*>=\s*#?(\w+)\s*GOTO\s+(\w+)', tac):  # IF x >= y GOTO z
        _, x, y, z = re.split('IF | >= #?| GOTO ', tac)
        command.append(f'bge {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(r'IF\s+(\w+)\s*!=\s*#?(\w+)\s*GOTO\s+(\w+)', tac):  # IF x != y GOTO z
        _, x, y, z = re.split('IF | != #?| GOTO ', tac)
        command.append(f'bne {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(r'IF\s+(\w+)\s*==\s*#?(\w+)\s*GOTO\s+(\w+)', tac):  # IF x == y GOTO z
        _, x, y, z = re.split('IF | == #?| GOTO ', tac)
        command.append(f'beq {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'FUNCTION {id} :', tac):  # IF x == y GOTO z
        _, n, _ = re.split('FUNCTION | :', tac)
        fi_command.append(f'{n} :')
        sw_stackfreg(fi_command, '$ra')

    if re.fullmatch(f'LABEL {id} :', tac):  # IF x == y GOTO z
        _, n, _ = re.split('LABEL | :', tac)
        command.append(f'{n}:')
    # if re.fullmatch(f'PARAM {id}', tac):  # IF x == y GOTO z
    #     _, n = re.split('PARAM | ', tac)
    #     command.append(f'{n}')
    if re.fullmatch(f'ARG {id}', tac):  # IF x == y GOTO z
        _, n = re.split('ARG | ', tac)
        # queue.put(n)
        queue.append(n)
    if re.fullmatch(f'WRITE {id}', tac):  # IF x == y GOTO z
        _, n = re.split('WRITE | ', tac)
        fi_command.append(f'lw $4, {reg(n)}')
        fi_command.append(f'jal write')
    if re.fullmatch(f'READ {id}', tac):  # IF x == y GOTO z
        _, n = re.split('READ | ', tac)
        fi_command.append(f'jal read')
        fi_command.append(f'sw $2,{reg(n)}')

    for index, c in enumerate(command):
        co = c.replace(',', '')
        regs = [s for s in co.split()[1:] if '$' in s]

        for ind, r in enumerate(regs):
            if '$sp' in r:
                fi_command.append(f'lw ${ind + save_reg},{r}')
                c = c.replace(r, f'${ind + save_reg}')
        fi_command.append(c)
        for ind, r in enumerate(regs):
            if '$sp' in r:
                fi_command.append(f'sw ${ind + save_reg},{r}')
    return fi_command


if len(sys.argv) < 2:
    print("Usage: splc <ir_path>")
    sys.exit(1)


with open(sys.argv[1] + '.s', 'w') as s:
    s.write(data+"\n"+'jal main\nj end\n'+pre+"\n")

with open(sys.argv[1]+'.ir', 'r') as ir:
    for tac in ir.read().splitlines():
        res = translate(tac)
        if not res:
            # print(f'no translate: {tac}')
            pass
        else:
            with open(sys.argv[1]+'.s','a') as s:
                s.write("\n".join(res))
                s.write("\n\n")

with open(sys.argv[1] + '.s', 'a') as s:
    s.write('end:')


# print(stack)
