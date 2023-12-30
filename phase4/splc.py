#!/usr/bin/python3
import re
import sys


# the register allocation algorithm
def reg(var: str) -> str:
    return var


# Translate TAC to assembly code
def translate(tac: str) -> str:
    id = '[^\\d#*]\\w*'
    num = '\\d+'
    if re.fullmatch(f'{id} := #{num}', tac):  # x := #k
        x, k = tac.split(' := #')
        return f'li {reg(x)}, {k}'
    if re.fullmatch(f'{id} := {id}', tac):  # x := y
        x, y = tac.split(' := ')
        return f'move {reg(x)}, {reg(y)}'
    if re.fullmatch(f'{id} := {id} \\+ #{num}', tac):  # x := y + #k
        x, y, k = re.split(' := | \\+ #', tac)
        return f'addi {reg(x)}, {reg(y)}, {k}'
    if re.fullmatch(f'{id} := {id} \\+ {id}', tac):  # x := y + z
        x, y, z = re.split(' := | \\+ ', tac)
        return f'add {reg(x)}, {reg(y)}, {reg(z)}'
    if re.fullmatch(f'{id} := {id} - #{num}', tac):  # x := y - #k
        x, y, k = re.split(' := | - #', tac)
        return f'addi {reg(x)}, {reg(y)}, -{k}'
    if re.fullmatch(f'{id} := {id} - {id}', tac):  # x := y - z
        x, y, z = re.split(' := | - ', tac)
        return f'sub {reg(x)}, {reg(y)}, {reg(z)}'
    if re.fullmatch(f'{id} := {id} \\* {id}', tac):  # x := y * z
        x, y, z = re.split(' := | \\* ', tac)
        return f'mul {reg(x)}, {reg(y)}, {reg(z)}'
    if re.fullmatch(f'{id} := {id} / {id}', tac):  # x := y / z
        x, y, z = re.split(' := | / ', tac)
        return f'div {reg(y)}, {reg(z)}\n' \
               f'mflo {reg(x)}'
    if re.fullmatch(f'{id} := \\*{id}', tac):  # x := *y
        x, y = tac.split(' := *')
        return f'lw {reg(x)}, 0({reg(y)})'
    if re.fullmatch(f'\\*{id} := {id}', tac):  # *x := y
        _, x, y = re.split('\\*| := ', tac)
        return f'sw {reg(y)}, 0({reg(x)})'
    if re.fullmatch(f'GOTO {id}', tac):  # GOTO x
        x = tac.split('GOTO ')[1]
        return f'j {x}'
    if re.fullmatch(f'{id} := CALL {id}', tac):  # x := CALL f
        x, f = tac.split(' := CALL ')
        return f'jal {f}\n' \
               f'move {reg(x)}, $v0'
    if re.fullmatch(f'RETURN {id}', tac):  # RETURN x
        x = tac.split('RETURN ')[1]
        return f'move $v0, {reg(x)}\n' \
               f'jr $ra'
    if re.fullmatch(f'IF {id} < {id} GOTO {id}', tac):  # IF x < y GOTO z
        _, x, y, z = re.split('IF | < | GOTO ', tac)
        return f'blt {reg(x)}, {reg(y)}, {z}'
    if re.fullmatch(f'IF {id} <= {id} GOTO {id}', tac):  # IF x <= y GOTO z
        _, x, y, z = re.split('IF | <= | GOTO ', tac)
        return f'ble {reg(x)}, {reg(y)}, {z}'
    if re.fullmatch(f'IF {id} > {id} GOTO {id}', tac):  # IF x > y GOTO z
        _, x, y, z = re.split('IF | > | GOTO ', tac)
        return f'bgt {reg(x)}, {reg(y)}, {z}'
    if re.fullmatch(f'IF {id} >= {id} GOTO {id}', tac):  # IF x >= y GOTO z
        _, x, y, z = re.split('IF | >= | GOTO ', tac)
        return f'bge {reg(x)}, {reg(y)}, {z}'
    if re.fullmatch(f'IF {id} != {id} GOTO {id}', tac):  # IF x != y GOTO z
        _, x, y, z = re.split('IF | != | GOTO ', tac)
        return f'bne {reg(x)}, {reg(y)}, {z}'
    if re.fullmatch(f'IF {id} == {id} GOTO {id}', tac):  # IF x == y GOTO z
        _, x, y, z = re.split('IF | == | GOTO ', tac)
        return f'beq {reg(x)}, {reg(y)}, {z}'


if len(sys.argv) < 2:
    print("Usage: splc <ir_path>")
    sys.exit(1)
with open(sys.argv[1], 'r') as ir:
    for tac in ir.read().splitlines():
        print(translate(tac))
