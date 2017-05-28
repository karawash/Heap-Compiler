# mini-C-language-compiler-based-on-Heap-allocation
This project is mini compiler for C language (under enhancement). It is based on heap allocation (LinkedList).

# Use
For the current version you can try initializing variables, (like : int x; x= x+1;), if statements, while loops.

# Installation requirements
- Download Flex
- Download Bison
- Download DevC++
- Install Flex at "C:\GnuWin32"
- Install Bison at "C:\GnuWin32"
- Install DevC++ at "C:\Dev-Cpp"
- Open Environment Variables.
- Add "C:\GnuWin32\bin;C:\Dev-Cpp\bin;" to path.

# Test
- Open Command prompt and switch to your working directory where you have stored your lex file (".l") and yacc file (".y")
- Let your lex and yacc files be "pro.l" and "pro.y".
- For Compiling Lex file only:
- flex hello.l
- gcc lex.yy.c
- For Compiling Lex & Yacc file both:
- flex hello.l
- bison -dy hello.y
- gcc lex.yy.c y.tab.c
- For Executing the Program
- a.exe
