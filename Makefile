CC	=	cc
LD	=	ld
AR	=	ar
INCLUDE	=	-Iinclude
CFLAGS	=	-Wall -Wextra -O2 -g3 -fPIC -pipe $(INCLUDE)
LDFLAGS	=

SRC		=	src/easyconf.c			\
			src/parameter.c

TEST_SRC	=	tests/easyconf_tests.c		\
			tests/parameter_tests.c

OBJ		=	$(SRC:%.c=obj/%.o)
TEST_OBJ	=	$(TEST_SRC:%.c=obj/%.o)
DEP		=	$(OBJ:.o=.d)
TEST_DEP	=	$(TEST_OBJ:.o=.d)

LIB_NAME	=	easyconf
DYNLIB_FILE	=	lib$(LIB_NAME).so
STLIB_FILE	=	lib$(LIB_NAME).a
TEST_FILE	=	$(LIB_NAME)_tests


.PHONY:	all	test	clean

all:	$(DYNLIB_FILE)	$(STLIB_FILE)

test:	$(TEST_FILE)
	@LD_LIBRARY_PATH=. ./$(TEST_FILE)

clean:
	rm -rf obj *.gcda *.gcno vgcore.*

$(DYNLIB_FILE):	$(OBJ)
	$(LD) -shared -o $@ $(OBJ) $(LDFLAGS)

$(STLIB_FILE):	$(OBJ)
	$(AR) rcs $@ $(OBJ)

$(TEST_FILE):	$(DYNLIB_FILE) $(STLIB_FILE)	$(TEST_OBJ)
	$(CC) -o $@ $(TEST_OBJ) -L. -l$(LIB_NAME) -lcriterion $(LDFLAGS)

obj/%.o:	%.c
	@mkdir -p "$(shell dirname $@)"
	$(CC) -MMD $(CFLAGS) -c $<	-o $@

-include $(DEP)
-include $(TEST_DEP)