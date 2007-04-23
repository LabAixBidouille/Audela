################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: libgphoto2.so

# Tool invocations
libgphoto2.so: $(OBJS) $(USER_OBJS)
	@echo 'Building target: $@'
	@echo "*lib:" > libgphoto2.specs
	@echo "    -rpath ." >> libgphoto2.specs
	@echo 'Invoking: GCC C Linker'
	gcc -L../../libgphoto2_port/libgphoto2_port/linux  -specs libgphoto2.specs -shared -o"libgphoto2.so" $(OBJS) $(USER_OBJS) $(LIBS)
	@$(RM) libgphoto2.specs
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(EXECUTABLES)$(C_DEPS) libgphoto2.so
	-@echo ' '

install: all
	cp libgphoto2.so     ../../../../../bin/libgphoto2.so
	-@echo ' '

.PHONY: all clean dependents install
.SECONDARY:

-include ../makefile.targets
