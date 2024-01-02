#!/usr/bin/python3
import re
import sys
from queue import Queue

num_registers = 32
save_reg = 11
register_table = [None] * num_registers
stack = []
queue = Queue()
argmap = {}
data="""
.data
array: .space 400
_prmpt: .asciiz "Enter an integer:"
_eol: .asciiz "\\n"
.globl main
.text"""

pre="""read:
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
    with open(file_path, 'r') as file:
        for line in file:
            if (line.startswith("LABEL") or line.startswith("FUNCTION")) and ":" in line:
                current_paragraph = []
                argmap[line.split()[1]] = current_paragraph
            if 'PARAM' in line:
                current_paragraph.append(line.split()[1])
    return argmap


read_file(sys.argv[1])
num_var=0
# the register allocation algorithm
#分配+查询reg
def reg(var: str) -> str:
    global num_var
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
    return f'{stack.index(var)<<2}($sp)'

def find_Reg(var: str):
    if var in register_table:
        return f'${register_table.index(var) + save_reg}'
    elif var in stack:
        return f'{stack.index(var) << 2}($sp)'
    else:
        return None
# Translate TAC to assembly code
# 在遇到arg的时候存入queue中，之后对照param lw sw 过去
def translate(tac: str):
    id = '[^\\d#*]\\w*'
    num = '\\d+'
    command = []
    fi_command = []
    if re.fullmatch(f'{id} := #{num}', tac):  # x := #k
        x, k = tac.split(' := #')
        command.append(f'li {reg(x)}, {k}')
    if re.fullmatch(f'{id} := {id}', tac):  # x := y
        x, y = tac.split(' := ')
        command.append(f'move {reg(x)}, {reg(y)}')
    if re.fullmatch(f'{id} := {id} \\+ #{num}', tac):  # x := y + #k
        x, y, k = re.split(' := | \\+ #', tac)
        command.append(f'addi {reg(x)}, {reg(y)}, {k}')
    if re.fullmatch(f'{id} := {id} \\+ {id}', tac):  # x := y + z
        x, y, z = re.split(' := | \\+ ', tac)
        command.append(f'add {reg(x)}, {reg(y)}, {reg(z)}')
    if re.fullmatch(f'{id} := {id} - #{num}', tac):  # x := y - #k
        x, y, k = re.split(' := | - #', tac)
        command.append(f'addi {reg(x)}, {reg(y)}, -{k}')
    if re.fullmatch(f'{id} := {id} - {id}', tac):  # x := y - z
        x, y, z = re.split(' := | - ', tac)
        command.append(f'sub {reg(x)}, {reg(y)}, {reg(z)}')
    if re.fullmatch(f'{id} := {id} \\* {id}', tac):  # x := y * z
        x, y, z = re.split(' := | \\* ', tac)
        command.append(f'mul {reg(x)}, {reg(y)}, {reg(z)}')
    if re.fullmatch(f'{id} := {id} / {id}', tac):  # x := y / z
        x, y, z = re.split(' := | / ', tac)
        command.append(f'div {reg(y)}, {reg(z)}')
        command.append(f'mflo {reg(x)}')
    if re.fullmatch(f'{id} := \\*{id}', tac):  # x := *y
        x, y = tac.split(' := *')
        command.append(f'lw {reg(x)}, 0({reg(y)})')
    if re.fullmatch(f'\\*{id} := {id}', tac):  # *x := y
        _, x, y = re.split('\\*| := ', tac)
        command.append(f'sw {reg(y)}, 0({reg(x)})')
    if re.fullmatch(f'GOTO {id}', tac):  # GOTO x
        x = tac.split('GOTO ')[1]
        command.append(f'j {x}')
    if re.fullmatch(f'{id} := CALL {id}', tac):  # x := CALL f
        x, f = tac.split(' := CALL ')
        for p in argmap[f]:
            arg = reg(queue.get())
            para = reg(p)
            fi_command.append(f'lw ${save_reg}, {arg}')
            fi_command.append(f'sw ${save_reg}, {para}')
        fi_command.append(f'jal {f}')
        command.append(f'move {reg(x)}, $v0')
    if re.fullmatch(f'RETURN {id}', tac):  # RETURN x
        x = tac.split('RETURN ')[1]
        command.append(f'move $v0, {reg(x)}')
        fi_command.append('lw $ra,0($10)')
        fi_command.append('addi $9,$9,4')
        fi_command.append('add $10,$9,$sp')
        command.append(f'jr $ra')
    if re.fullmatch(f'IF {id} < {id} GOTO {id}', tac):  # IF x < y GOTO z
        _, x, y, z = re.split('IF | < | GOTO ', tac)
        command.append(f'blt {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'IF {id} <= {id} GOTO {id}', tac):  # IF x <= y GOTO z
        _, x, y, z = re.split('IF | <= | GOTO ', tac)
        command.append(f'ble {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'IF {id} > {id} GOTO {id}', tac):  # IF x > y GOTO z
        _, x, y, z = re.split('IF | > | GOTO ', tac)
        command.append(f'bgt {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'IF {id} >= {id} GOTO {id}', tac):  # IF x >= y GOTO z
        _, x, y, z = re.split('IF | >= | GOTO ', tac)
        command.append(f'bge {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'IF {id} != {id} GOTO {id}', tac):  # IF x != y GOTO z
        _, x, y, z = re.split('IF | != | GOTO ', tac)
        command.append(f'bne {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'IF {id} == {id} GOTO {id}', tac):  # IF x == y GOTO z
        _, x, y, z = re.split('IF | == | GOTO ', tac)
        command.append(f'beq {reg(x)}, {reg(y)}, {z}')
    if re.fullmatch(f'FUNCTION {id} :', tac):  # IF x == y GOTO z
        _, n, _ = re.split('FUNCTION | :', tac)
        fi_command.append(f'{n} :')
        fi_command.append('addi $9,$9,-4')
        fi_command.append('add $10,$9,$sp')
        fi_command.append('sw $ra,0($10)')

    if re.fullmatch(f'LABEL {id} :', tac):  # IF x == y GOTO z
        _, n, _ = re.split('LABEL | :', tac)
        command.append(f'{n}:')
    # if re.fullmatch(f'PARAM {id}', tac):  # IF x == y GOTO z
    #     _, n = re.split('PARAM | ', tac)
    #     command.append(f'{n}')
    if re.fullmatch(f'ARG {id}', tac):  # IF x == y GOTO z
        _, n = re.split('ARG | ', tac)
        queue.put(n)
    if re.fullmatch(f'WRITE {id}', tac):  # IF x == y GOTO z
        _, n = re.split('WRITE | ', tac)
        fi_command.append(f'lw $4, {reg(n)}')
        fi_command.append(f'jal write')

    if re.fullmatch(f'READ {id}', tac):  # IF x == y GOTO z
        _, n = re.split('READ | ', tac)
        fi_command.append(f'jal read')
        fi_command.append(f'sw $5,{reg(n)}')

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


print(data)
print('j main')
print('j end')
print(pre)

with open(sys.argv[1], 'r') as ir:
    for tac in ir.read().splitlines():
        res=translate(tac)
        if res:
            print("\n".join(res))
print('end:')


