#
# Title
#
# @file
# @version 0.1

CC := gcc
AR := ar

INCPATHS := include lib/flecs/distr
CFLAGS := 	-g \
			-O2 \
			-Wall \
			-Wextra \
			-pedantic $(foreach dir,$(INCPATHS),-I$(dir))
LDFLAGS := 	-L./lib \
            -lm
SRCS := src/gl.c \
        lib/flecs/distr/flecs.c \
		src/util.c \
		src/main.c
OBJS := $(SRCS:.c=.o)
BIN := test.out

LIBENET_INCPATHS    := lib/enet/include
LIBENET_CFLAGS      := $(CFLAGS) $(foreach dir,$(LIBENET_INCPATHS),-I$(dir))
LIBENET_LDFLAGS     :=
LIBENET_SRCS        :=  lib/enet/callbacks.c \
			            lib/enet/compress.c \
			            lib/enet/host.c \
			            lib/enet/list.c \
                        lib/enet/packet.c \
                        lib/enet/peer.c \
                        lib/enet/protocol.c
LIBENET_OBJS        :=  $(LIBENET_SRCS:.c=.o)
LIBENET_BIN         :=  lib/libenet.a

LIBFLECS_INCPATHS   := lib/flecs/distr
LIBFLECS_CFLAGS     := $(CFLAGS)
LIBFLECS_LDFLAGS    :=
LIBFLECS_SRCS       := lib/flecs/distr/flecs.c
LIBFLECS_OBJS       := $(LIBFLECS_SRCS:.c=.o)
LIBFLECS_BIN        := lib/libflecs.a

use_windows_flags := 0
ifeq '$(findstring ;,$(PATH))' ';'
	detected_OS := Windows
else
	detected_OS := $(shell uname 2>/dev/null || echo Unknown)
	detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
	detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
	detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
endif
ifeq ($(detected_OS),Windows)
	use_windows_flags = 1
endif
ifeq ($(detected_OS),Cygwin)
	use_windows_flags = 1
endif
ifeq ($(detected_OS),MSYS)
	use_windows_flags = 1
endif
ifeq ($(detected_OS),Linux)
    CFLAGS += -D LINUX
    LIBENET_SRCS += lib/enet/unix.c
endif
ifeq ($(detected_OS),FreeBSD)
    CFLAGS += -D FreeBSD
	LIBENET_SRCS += lib/enet/unix.c
endif
ifeq ($(detected_OS),NetBSD)
    CFLAGS += -D NetBSD
	LIBENET_SRCS += lib/enet/unix.c
endif
ifeq ($(detected_OS),DragonFly)
    CFLAGS += -D DragonFly
	LIBENET_SRCS += lib/enet/unix.c
endif
ifeq ($(detected_OS),Haiku)
    CFLAGS += -D Haiku
	LIBENET_SRCS += lib/enet/unix.c
endif
ifeq ($(detected_OS),Darwin)        # Mac OS X
    CFLAGS += -D OSX
	LIBENET_SRCS += lib/enet/unix.c
endif

ifeq ($(use_windows_flags),1)
	CFLAGS 			+=  -D WIN32
    LIBENET_SRCS 	+=  lib/enet/win32.c
    LIBENET_CFLAGS  +=
	LDFLAGS 		+=  -lws2_32 \
                        -lwinmm \
						-lgdi32
    LIBGLFW3_BIN    := lib/glfw/mingw64/libglfw3.a
else
	CFLAGS          += -D POSIX
    LIBGLFW3_BIN    := lib/glfw/linux_amd64/libglfw.a
endif

all: $(BIN)

$(BIN): $(OBJS) $(LIBENET_BIN) $(LIBFLECS_BIN)
	$(CC) -o $@ $^ lib/glfw/linux_amd64/libglfw3.a $(LDFLAGS)
src/%.o: src/%.c
	$(CC) $(CFLAGS) $(foreach dir,$(LIBENET_INCPATHS),-I$(dir)) -c $< -o $@

$(LIBENET_BIN): $(LIBENET_OBJS)
	$(AR) rcs $@ $^
lib/enet/%.o: lib/enet/%.c
	$(CC) $(LIBENET_CFLAGS) -c $< -o $@

$(LIBFLECS_BIN): $(LIBFLECS_OBJS)
	$(AR) rcs $@ $^
lib/flecs/distr/%.o: lib/flecs/distr/%.c
	$(CC) $(LIBFLECS_CFLAGS) -c $< -o $@

.PHONY: clean clean_libenet clean_libflecs

clean: clean_libenet clean_libflecs
	rm -f $(BIN) $(OBJS)

clean_libenet:
	rm -f $(LIBENET_BIN) $(LIBENET_OBJS)

clean_libflecs:
	rm -f $(LIBFLECS_BIN) $(LIBFLECS_OBJS)

# end
