CC=gcc
FLAGS=-pedantic-errors -Wvla -std=c11
SRC=./soln.c
TARGET=./soln
COMPILE=$(FLAGS) $(SRC) -o $(TARGET)

all: debug

debug:
	gcc -g -DDEBUG $(COMPILE)

fast:
	gcc -O3 -DNDEBUG $(COMPILE)