UNAME	=	$(shell uname)
CC	=	cc
LD	=	$(CC)
AR	=	ar
INCLUDE	=	-Iinclude
CFLAGS	=	-Wall -Wextra -O2 -g3 -fPIC -pipe $(INCLUDE)
LDFLAGS	=

INSTALL_PREFIX	=	/usr/local

SRC		=	src/easyconf.c			\
			src/getline.c			\
			src/parameter.c

TEST_SRC	=	tests/easyconf_tests.c		\
			tests/getline_tests.c		\
			tests/parameter_tests.c

OBJ		=	$(SRC:%.c=obj/%.o)
TEST_OBJ	=	$(TEST_SRC:%.c=obj/%.o)
DEP		=	$(OBJ:.o=.d)
TEST_DEP	=	$(TEST_OBJ:.o=.d)

LIB_NAME	=	easyconf
ifeq ($(UNAME), Linux)
	DYNLIB_FILE	=	lib$(LIB_NAME).so
else
	DYNLIB_FILE	=	lib$(LIB_NAME).dll
endif
STLIB_FILE	=	lib$(LIB_NAME).a
TEST_FILE	=	$(LIB_NAME)_tests


.PHONY:	all	test	clean	fclean	install	uninstall

all:	$(DYNLIB_FILE)	$(STLIB_FILE)

test:	$(TEST_FILE)
	@LD_LIBRARY_PATH=. ./$(TEST_FILE)

clean:
	rm -rf obj *.gcda *.gcno vgcore.*

fclean:	clean
	rm -f $(DYNLIB_FILE) $(STLIB_FILE) $(TEST_FILE)

install:	$(DYNLIB_FILE)	$(STLIB_FILE)
	mkdir -p $(INSTALL_PREFIX)/include/
	mkdir -p $(INSTALL_PREFIX)/lib/
	cp -i include/easyconf.h $(INSTALL_PREFIX)/include/
	cp -i $(DYNLIB_FILE) $(STLIB_FILE) $(INSTALL_PREFIX)/lib/

uninstall:
	rm -f $(INSTALL_PREFIX)/include/easyconf.h
	rm -f $(INSTALL_PREFIX)/lib/$(DYNLIB_FILE)
	rm -f $(INSTALL_PREFIX)/lib/$(STLIB_FILE)

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