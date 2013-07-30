# Simple Makefile for Raspberry Pi Projects
# Prototype M 2013
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

CROSSCOMPILE=1

ifeq ($(CROSSCOMPILE),1)
TOOLCHAIN=arm-unknown-linux-gnueabihf
TOOLCHAIN_PREFIX=../../toolchains/$(TOOLCHAIN)/bin/$(TOOLCHAIN)-
VC_DIR=../../vc/opt/vc
else
TOOLCHAIN_PREFIX=
VC_DIR=/opt/vc
endif

CC      = $(TOOLCHAIN_PREFIX)gcc
LD      = $(TOOLCHAIN_PREFIX)gcc
CCFLAGS = -O0 -g -Wall
LDFLAGS = -g
LIBS    =
TARGET  = pires
OBJECTS = main.o

# VC Includes/Libraries
CCFLAGS += -I$(VC_DIR)/include \
           -I$(VC_DIR)/include/interface/vcos/pthreads \
           -I$(VC_DIR)/include/interface/vmcs_host/linux
LDFLAGS += -L$(VC_DIR)/lib
LIBS    += -lvcos -lbcm_host -lEGL -lGLESv2 -lvchiq_arm

# For testing on the device
#------------------------------------------------------------------------------
ifeq ($(CROSSCOMPILE),1)
REMOTE_HOST=192.168.0.18
REMOTE_USER=pi
REMOTE_DEST=~/$(TARGET)/
endif

# Typical Makefile Recipes
#------------------------------------------------------------------------------
all : $(TARGET)
.PHONY : all

$(TARGET) : $(OBJECTS)
	@echo "ld $^"
	@$(LD) -o $(TARGET) $(LDFLAGS) $^ $(LIBS)

%.o : %.c
	@echo "cc $^"
	@$(CC) $(CCFLAGS) -o $@ -c $^

clean :
	@echo "rm $(TARGET) $(OBJECTS)"
	@rm -f $(TARGET) $(OBJECTS)
.PHONY : clean


# Deployment and Test Recipes
#------------------------------------------------------------------------------
ifeq ($(CROSSCOMPILE),1)
deploy : $(TARGET)
	@echo "Copying $^ to $(REMOTE_HOST)"
	@rsync -t $^ $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_DEST)
.PHONY : deploy
endif

test :
ifeq ($(CROSSCOMPILE),1)
	@echo "Starting $(TARGET) on $(REMOTE_HOST)"
	@ssh $(REMOTE_USER)@$(REMOTE_HOST) "cd $(REMOTE_DEST); ./$(TARGET)"
else
	@echo "Starting $(TARGET)"
	@./$(TARGET)
endif
.PHONY : test
