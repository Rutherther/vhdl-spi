.PHONY: reload list

WAVEFORM_VIEWER = gtkwave

reload:
	@gsettings set com.geda.gtkwave reload 1
	@gsettings set com.geda.gtkwave reload 0

list:
	@python -m run.py -l

run:
	python -m run.py

%.run:
	python -m run.py --exit-0 --gtkwave-fmt ghw $(basename $@)

%.open: %.run
	make reload
	pgrep $(WAVEFORM_VIEWER) || $(WAVEFORM_VIEWER) $(shell find vunit_out/test_output/$(basename $@)* -maxdepth 0 -type d)/ghdl/wave.ghw &

%.all: %.open
