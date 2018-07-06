UNAME := $(shell uname)
all-tests := $(basename $(wildcard test/*.lua))

######################################
# Variabes that can be setted:
#   LUA_VERSION    Example: LUA_VERSION="5.3"
#   LUA_INC        Example: LUA_INC="-I/usr/local/include/lua"
#   LUA_LIB        Example: LUA_LIB="-L/usr/local/lib/lua"
#   ROCKSDB_INC        Example: ROCKSDB_INC="-I/usr/local/include/rocksdb"
#   ROCKSDB_LIB        Example: ROCKSDB_LIB="-L/usr/local/lib/rocksdb"
######################################

LUA_LIB_DEF= 
LUA_INC_DEF= -I/usr/include/lua${LUA_VERSION}
ROCKSDB_LIB_DEF=
ROCKSDB_INC_DEF=
EXTRACFLAGS= -std=c99 -undefined -fPIC

LUA_INC := $(if $(LUA_INC),$(LUA_INC), $(LUA_INC_DEF))
LUA_LIB := $(if $(LUA_LIB),$(LUA_LIB), $(LUA_LIB_DEF))
ROCKSDB_INC := $(if $(ROCKSDB_INC),$(ROCKSDB_INC), $(ROCKSDB_INC_DEF))
ROCKSDB_LIB := $(if $(ROCKSDB_LIB),$(ROCKSDB_LIB), $(ROCKSDB_LIB_DEF))

INC= -I/usr/include $(LUA_INC) $(ROCKSDB_INC)
LIB= -L/usr/lib $(LUA_LIB) $(ROCKSDB_LIB)
WARN= -Wall
CFLAGS= -O2 $(WARN) $(INC)


MYNAME= rocksdb
MYLIB= $(MYNAME)
T= $(MYLIB).so
OBJS= src/l$(MYLIB).o \
			src/l$(MYLIB)_helpers.o \
			src/l$(MYLIB)_options.o \
			src/l$(MYLIB)_backup_engine.o \
			src/l$(MYLIB)_writebatch.o \
			src/l$(MYLIB)_iter.o

all: $T

print-%  : ; @echo $* = $($*)

%.o: %.c
	$(CC) $(CFLAGS) -fPIC -c -o $@ $<

$T:	$(OBJS)
	$(CC) $(CFLAGS) $(LIB) $(EXTRACFLAGS) -o $@ -shared $(OBJS)

clean:
	rm -f $T $(OBJS)

tests: $(all-tests)

test/test_%: $T
	lua $@.lua

test: clean all tests

install: $(TARGET)


