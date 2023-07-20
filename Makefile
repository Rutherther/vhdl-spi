SIMDIR := sim
BINDIR := bin
SRCDIR := src
TBDIR := testbench
WORKDIR := work
VHDLEX := vhd

WORKFILE := $(WORKDIR)/work-obj93.cf

#####################################################
#                                                   #
#                 Top level entity                  #
#                                                   #
#####################################################
TOP_ENTITY := spi
TESTBENCH ?= $(TOP_ENTITY)_tb # default

WAVEFORM_VIEWER := gtkwave

COMPILER := ghdl
COMPILER_FLAGS := --std=08 --ieee=standard --workdir=$(WORKDIR)

STOP_TIME ?= 1000ns
RUN_FLAGS := --stop-time=$(STOP_TIME) --stats

TBSOURCES := $(wildcard $(TBDIR)/*.$(VHDLEX) $(TBDIR)/**/*.$(VHDLEX))
SOURCES := $(wildcard $(SRCDIR)/*.$(VHDLEX) $(SRCDIR)/**/*.$(VHDLEX))
ALL_SOURCES := $(SOURCES) $(TBSOURCES)

.PHONY: all clean

all: $(SIMDIR)/$(TESTBENCH).ghw

$(BINDIR)/%_tb.out: $(TBDIR)/%_tb.$(VHDLEX) $(WORKFILE) $(BINDIR)
	@$(COMPILER) -m -o $@ $(COMPILER_FLAGS) $(notdir $(basename $@))

$(BINDIR)/%.out: $(SRCDIR)/%.$(VHDLEX) $(WORKFILE) $(BINDIR)
	@$(COMPILER) -m -o $@ $(COMPILER_FLAGS) $(notdir $(basename $@))

$(SIMDIR)/%.ghw: $(BINDIR)/%.out
	$< $(RUN_FLAGS) --wave=$@
	gsettings set com.geda.gtkwave reload 1
	gsettings set com.geda.gtkwave reload 0
	pgrep $(WAVEFORM_VIEWER) || $(WAVEFORM_VIEWER) $@ &

$(WORKFILE): $(WORKDIR) $(ALL_SOURCES)
	@$(COMPILER) -i $(COMPILER_FLAGS) $(ALL_SOURCES)

$(BINDIR) $(WORKDIR) $(SIMDIR):
	@mkdir $@

clean:
	@$(RM) -rf $(SIMDIR) $(WORKDIR) $(BINDIR)
	@$(MAKE) -C ax309 clean

$(ALL_SOURCES):
