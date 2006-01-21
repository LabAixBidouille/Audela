################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
$(ROOT)/src/jpegmemscr.c \
$(ROOT)/src/libdcjpeg_dll.c 

OBJS += \
./src/jpegmemscr.o \
./src/libdcjpeg_dll.o 

DEPS += \
${addprefix ./src/, \
jpegmemscr.d \
libdcjpeg_dll.d \
}


# Each subdirectory must supply rules for building sources it contributes
src/%.o: $(ROOT)/src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	@echo gcc -I../../jpeg-6b -O3 -Wall -c -fmessage-length=0 -o$@ $<
	@gcc -I../../jpeg-6b -O3 -Wall -c -fmessage-length=0 -o$@ $< && \
	echo -n $(@:%.o=%.d) $(dir $@) > $(@:%.o=%.d) && \
	gcc -MM -MG -P -w -I../../jpeg-6b -O3 -Wall -c -fmessage-length=0  $< >> $(@:%.o=%.d)
	@echo 'Finished building: $<'
	@echo ' '


