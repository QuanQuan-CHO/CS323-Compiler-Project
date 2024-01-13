# For automatic testing
# This script should run in the `test/` directory
import subprocess
import os

spim_header = """SPIM Version 8.0 of January 8, 2010
Copyright 1990-2010, James R. Larus.
All Rights Reserved.
See the file README for a full copyright notice.
Loaded: /usr/lib/spim/exceptions.s
"""
input_prompt = 'Enter an integer:'

test_num = len([f for f in os.listdir('.') if f.endswith('.test')])
for i in range(test_num):
    id = f'test_4_r{i:02}'
    with open(f'{id}.test', 'r') as tests:
        subprocess.run(f'../bin/splc {id}.ir', shell=True)
        for test in tests.read().split('\n\n'):
            input, expect_out = test.split('\n----------\n')
            input=input.replace(' ','\n')
            actual_out = (subprocess.run(f'echo "{input}" | spim -file {id}.s', shell=True, capture_output=True, text=True).stdout
                                    .replace(spim_header, '') # remove SPIM's header
                                    .replace(input_prompt,'') # remove input prompt
                                    .strip())
            if actual_out != expect_out:
                print(f'----------{id} failed----------')
                print(f'[input] {input}')
                print(f'[expect] {expect_out}')
                print(f'[actual] {actual_out}')
                exit(1)
    print(f'{id} passed')
print('All tests passed!')
