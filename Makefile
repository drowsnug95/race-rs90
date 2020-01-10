#
# race-od for the RetroFW
#
# by pingflood; 2019
#

TARGET = race-od/race-od.dge

# Define compilation type
#OSTYPE=msys
OSTYPE=opendingux

# define regarding OS, which compiler to use
TOOLCHAIN = /opt/mipsel-linux-uclibc/usr
CC  = $(TOOLCHAIN)/bin/mipsel-linux-gcc
LD  = $(TOOLCHAIN)/bin/mipsel-linux-gcc

# add SDL dependencies
SYSROOT		:= $(shell $(CC) --print-sysroot)
SDL_CFLAGS	:= $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS	:= $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

F_OPTS = -falign-functions -falign-loops -falign-labels -falign-jumps \
		-ffast-math -fsingle-precision-constant -funsafe-math-optimizations \
		-fomit-frame-pointer -fno-builtin -fno-common \
		-fstrict-aliasing  -fexpensive-optimizations \
		-finline -finline-functions -fpeel-loops

CC_OPTS		= -O3 -mips32 -G0 -D_OPENDINGUX_ $(F_OPTS)
CFLAGS      = -I$(SDL_INCLUDE) -DOPENDINGUX -DZ80 -DTARGET_OD -D_MAX_PATH=2048 -DHOST_FPS=60 $(CC_OPTS)
CXXFLAGS	= $(CFLAGS)
LDFLAGS     = -L$(SDL_LIB) $(CC_OPTS) -lstdc++ -lSDL -lSDL_image -lpng

# Files to be compiled
SRCDIR	= ./emu ./opendingux .
VPATH	= $(SRCDIR)
SRC_C	= $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.cpp))
OBJ_C	= $(notdir $(patsubst %.cpp, %.o, $(SRC_C)))
OBJS	= $(OBJ_C)

# Rules to make executable
all: $(OBJS)
	$(LD) $(LDFLAGS) -o $(TARGET) $^

$(OBJ_C): %.o : %.cpp
	$(CC) $(CXXFLAGS) -c -o $@ $<

ipk: all
	@rm -rf /tmp/.race-od-ipk/ && mkdir -p /tmp/.race-od-ipk/root/home/retrofw/emus/race-od /tmp/.race-od-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators /tmp/.race-od-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators.systems
	@cp -r race-od/race-od.dge race-od/*.png race-od/race-od.man.txt /tmp/.race-od-ipk/root/home/retrofw/emus/race-od
	@cp race-od/race-od.lnk /tmp/.race-od-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators
	@cp race-od/ngp.race-od.lnk /tmp/.race-od-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators.systems
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" race-od/control > /tmp/.race-od-ipk/control
	@cp race-od/conffiles /tmp/.race-od-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.race-od-ipk/control.tar.gz -C /tmp/.race-od-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.race-od-ipk/data.tar.gz -C /tmp/.race-od-ipk/root/ .
	@echo 2.0 > /tmp/.race-od-ipk/debian-binary
	@ar r race-od/race-od.ipk /tmp/.race-od-ipk/control.tar.gz /tmp/.race-od-ipk/data.tar.gz /tmp/.race-od-ipk/debian-binary

opk: all
	@mksquashfs \
	race-od/default.retrofw.desktop \
	race-od/ngp.retrofw.desktop \
	race-od/race-od.dge \
	race-od/race-od.png \
	race-od/race-od.man.txt \
	race-od/race_background.png \
	race-od/race_load.png \
	race-od/race_skin.png \
	race-od/race-od.opk \
	-all-root -noappend -no-exports -no-xattrs

clean:
	rm -f $(TARGET) *.o
