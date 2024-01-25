**Research Report**: [Decoding Performance: A Comparative Analysis of Open-Source Compilers(GCC & Clang/LLVM)](ResearchReport/Report.pdf)

<br>

## Phases

- [Phase1: Lexical & Syntax Analysis](phase1)
- [Phase2: Semantic Analysis](phase2)
- [Phase3: Intermediate Code Generation](phase3)
- [Phase4: Target Code Generation(MIPS32)](phase4)

  A useful online MIPS32 simulator for debugging: [github.com/shawnzhong/JsSpim](https://github.com/shawnzhong/JsSpim)

<br>

## Run

```bash
$ make splc #compile the splc compiler
$ make test #compile the splc compiler and run test cases
$ make clean #clean the output
```

To successfully run the above command:

- In Phase1-3, [Flex](https://github.com/westes/flex) and [Bison](https://www.gnu.org/software/bison) should be installed

  ```bash
  $ sudo apt install libfl-dev libbison-dev
  ```

- In Phase4, [PyInstaller](https://github.com/pyinstaller/pyinstaller) and [SPIM](https://spimsimulator.sourceforge.net) should be installed

  ```bash
  $ pip install pyinstaller
  $ sudo apt install spim
  ```

<br>

### Landscape

![compiler-landscape-transparent](https://github.com/QuanQuan-CHO/CS323-Compiler-Project/assets/90035785/c22b64f2-9d82-41ac-8bc1-f08ae3be8c3f)


