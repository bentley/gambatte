.SUFFIXES: .c .cpp .o

CC ?= gcc
CXX ?= g++
AR ?= ar
RANLIB ?= ranlib
PKG_CONFIG = pkg-config

LIB = libgambatte/libgambatte.a
SDL = gambatte_sdl/gambatte_sdl
TEST = test/testrunner

PYTHON ?= python

SDL_OBJECTS = \
	gambatte_sdl/src/audiosink.o \
	gambatte_sdl/src/blitterwrapper.o \
	gambatte_sdl/src/gambatte_sdl.o \
	gambatte_sdl/src/parser.o \
	gambatte_sdl/src/sdlblitter.o \
	gambatte_sdl/src/str_to_sdlkey.o \
	gambatte_sdl/src/usec.o \
	common/adaptivesleep.o \
	common/resample/src/chainresampler.o \
	common/resample/src/i0.o \
	common/resample/src/kaiser50sinc.o \
	common/resample/src/kaiser70sinc.o \
	common/resample/src/makesinckernel.o \
	common/resample/src/resamplerinfo.o \
	common/resample/src/u48div.o \
	common/rateest.o \
	common/skipsched.o \
	common/videolink/rgb32conv.o \
	common/videolink/vfilterinfo.o \
	common/videolink/vfilters/catrom2x.o \
	common/videolink/vfilters/catrom3x.o \
	common/videolink/vfilters/kreed2xsai.o \
	common/videolink/vfilters/maxsthq2x.o \
	common/videolink/vfilters/maxsthq3x.o

LIB_OBJECTS = \
	libgambatte/src/bitmap_font.o \
	libgambatte/src/cpu.o \
	libgambatte/src/gambatte.o \
	libgambatte/src/initstate.o \
	libgambatte/src/interrupter.o \
	libgambatte/src/interruptrequester.o \
	libgambatte/src/loadres.o \
	libgambatte/src/memory.o \
	libgambatte/src/sound.o \
	libgambatte/src/state_osd_elements.o \
	libgambatte/src/statesaver.o \
	libgambatte/src/tima.o \
	libgambatte/src/file/file_zip.o \
	libgambatte/src/file/unzip/unzip.o \
	libgambatte/src/file/unzip/ioapi.o \
	libgambatte/src/mem/cartridge.o \
	libgambatte/src/mem/memptrs.o \
	libgambatte/src/mem/pakinfo.o \
	libgambatte/src/mem/rtc.o \
	libgambatte/src/sound/channel1.o \
	libgambatte/src/sound/channel2.o \
	libgambatte/src/sound/channel3.o \
	libgambatte/src/sound/channel4.o \
	libgambatte/src/sound/duty_unit.o \
	libgambatte/src/sound/envelope_unit.o \
	libgambatte/src/sound/length_counter.o \
	libgambatte/src/video.o \
	libgambatte/src/video/ly_counter.o \
	libgambatte/src/video/lyc_irq.o \
	libgambatte/src/video/next_m0_time.o \
	libgambatte/src/video/ppu.o \
	libgambatte/src/video/sprite_mapper.o

TEST_OBJECTS = \
	test/testrunner.o

all: $(SDL)

SDL_LFLAGS != $(PKG_CONFIG) --libs sdl
$(SDL): $(SDL_OBJECTS) $(LIB)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ -pthread $(SDL_OBJECTS) $(LIB) -lz \
		$(SDL_LFLAGS)

$(LIB): $(LIB_OBJECTS)
	$(AR) $(ARFLAGS) $@ $(LIB_OBJECTS)
	$(RANLIB) $@

PKGCONFIG_CFLAGS != $(PKG_CONFIG) --cflags sdl libpng
.c.o:
	$(CC) $(CXXFLAGS) -c $< -o $*.o
.cpp.o:
	$(CXX) -Ilibgambatte/src -Ilibgambatte/include -Igambatte_sdl/src \
		-Icommon $(CXXFLAGS) -c $< -o $*.o \
		-DGAMBATTE_SDL_VERSION_STR=\"r571\" -DHAVE_STDINT_H \
		$(PKGCONFIG_CFLAGS)

TEST_GBS = \
		test/hwtests/*.gb* \
		test/hwtests/*/*.gb* \
		test/hwtests/*/*/*.gb* \
		test/hwtests/*/*/*/*.gb*

test: $(TEST)
	$(PYTHON) test/qdgbas.py \
		test/hwtests/*.asm \
		test/hwtests/*/*.asm \
		test/hwtests/*/*/*.asm \
		test/hwtests/*/*/*/*.asm
	$(TEST) $(TEST_GBS)

PNG_LFLAGS != $(PKG_CONFIG) --libs libpng
$(TEST): $(TEST_OBJECTS) $(LIB)
	$(CXX) $(CXXFLAGS) -o $@ $(TEST_OBJECTS) $(LIB) \
		$(PNG_LFLAGS)

clean:
	rm -f $(TEST) $(TEST_OBJECTS) $(TEST_GBS)
	rm -f $(SDL) $(SDL_OBJECTS)
	rm -f $(LIB) $(LIB_OBJECTS)
