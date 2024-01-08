#!/usr/bin/python3
import re
import sys
from queue import Queue

# 总共的reg数量
num_registers = 32
# 预存的reg数，用来转移和计算的为号码大于11的寄存器
save_reg = 11
# 无法通过±实现栈的存取，500及以上为栈中存变量的部分，0-499为调用函数时预留的栈空间，此处没有左移2，在函数中调用时有
max_var_num = 500
register_table = [None] * num_registers
# 留一个0，避免变量或者函数调用占据（也可以去掉）
stack = ['empty']
# 存调用函数的参数
queue = []
# 存有label和function的对应变量，或可用于生命周期判断
argmap = {}
# 存有funciton中所有变量，用于调用时存入栈中
varmap = {}

# 为什么要把:后面的空格删掉（
data = """
.data
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


# 先读一遍，把函数中要调用的参数收集好
def read_file(file_path):
    current_paragraph = []
    with open(file_path, 'r') as file:
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


# Translate TAC to assembly code
# 在遇到arg的时候存入queue中，之后对照param lw sw 过去
# queue后来我发现输入参数是按照stack的输入输出，没改名，用法跟stack一致

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
            arg = reg(queue.pop())
            para = reg(p)
            from_heap2heap(arg, para, fi_command)

        fi_command.append(f'jal {f}')

        # 此时返回的值存在栈上

        # 将返回值从栈调出到v0
        lw_stackfreg(fi_command, '$v0')

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

# 最后的结果在对应.s文件中
ir_path = sys.argv[1]
assembly_path = ir_path.replace('.ir', '.s')
with open(assembly_path, 'w') as asm:
    asm.write(data + "\n" + 'jal main\nj end\n' + pre + "\n")

with open(ir_path, 'r') as ir:
    for tac in ir.read().splitlines():
        res = translate(tac)
        if not res:
            # print(f'no translate: {tac}')
            pass
        else:
            with open(assembly_path, 'a') as s:
                s.write("\n".join(res))
                s.write("\n\n")

with open(assembly_path, 'a') as s:
    s.write('end:')

# print(stack)
