# For automatic testing
# This script should run in the `test/` directory
import subprocess

spim_header = """SPIM Version 8.0 of January 8, 2010
Copyright 1990-2010, James R. Larus.
All Rights Reserved.
See the file README for a full copyright notice.
Loaded: /usr/lib/spim/exceptions.s
"""
input_prompt = 'Enter an integer:'

for i in range(3):
    id = f'test_4_r0{i:0}'
    with open(f'{id}.test', 'r') as tests:
        subprocess.run(f'../bin/splc {id}.ir > {id}.s', shell=True)
        for test in tests.read().split('\n\n'):
            input, expect_out = test.split('\n----------\n')
            actual_out = (subprocess.run(f'echo {input} | spim -file {id}.s', shell=True, capture_output=True, text=True).stdout
                                    .replace(spim_header, '') # remove SPIM's header
                                    .replace(input_prompt,'') # remove input prompt
                                    .strip())
            if actual_out != expect_out:
                print(f'----------{id} failed----------')
                print(f'[input] {input}')
                print(f'[expect] {expect_out}')
                print(f'[actual] {actual_out}')
                exit(1)
print('All tests passed!')
