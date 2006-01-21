################################################################################
# Automatically-generated file. Do not edit!
################################################################################

S_UPPER_SRCS += \
${addprefix $(ROOT)/jpeg-6b/, \
}

C_SRCS += \
${addprefix $(ROOT)/jpeg-6b/, \
jcapimin.c \
jcmarker.c \
jcmaster.c \
jcomapi.c \
jcparam.c \
jcphuff.c \
jcprepct.c \
jcsample.c \
jctrans.c \
jdapimin.c \
jdapistd.c \
jdatadst.c \
jdatasrc.c \
jdcoefct.c \
jdcolor.c \
jddctmgr.c \
jdhuff.c \
jdinput.c \
jdmarker.c \
jdmaster.c \
jdmerge.c \
jdphuff.c \
jdpostct.c \
jdsample.c \
jdtrans.c \
jerror.c \
jfdctflt.c \
jfdctfst.c \
jfdctint.c \
jidctflt.c \
jidctfst.c \
jidctint.c \
jidctred.c \
jmemmgr.c \
jquant1.c \
jquant2.c \
jutils.c \
}

S_SRCS += \
${addprefix $(ROOT)/jpeg-6b/, \
}

# Each subdirectory must supply rules for building sources it contributes
jpeg-6b/%.o: $(ROOT)/jpeg-6b/%.c
	@echo 'Building file: $<'
	@echo gcc -I../../jpeg-6b -O0 -g3 -Wall -c -fmessage-length=0 -fPIC -o$@ $<
	@gcc -I../../jpeg-6b -O0 -g3 -Wall -c -fmessage-length=0 -fPIC -o$@ $< && \
	echo -n $(@:%.o=%.d) $(dir $@) > $(@:%.o=%.d) && \
	gcc -MM -MG -P -w -I../../jpeg-6b -O0 -g3 -Wall -c -fmessage-length=0 -fPIC  $< >> $(@:%.o=%.d)
	@echo 'Finished building: $<'
	@echo ' '


