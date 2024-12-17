C_SRC       = $(sort $(wildcard *.c))  # wildcard funciton to get all .c files
OBJ         = $(patsubst %.c,%.o,$(C_SRC))  # patsubst function to replace .c with .o

all: $(OBJ)  # all target, compile all .c files to .o files

%.o: %.c  # rule to generate .o file from .c file
	${GCC} ${CFLAG} -c $< -o $@

clean:  # clean target, remove all .o files
	$(shell rm -f *.o 2>/dev/null)

