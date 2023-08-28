from vunit import VUnit
from pathlib import Path

vu = VUnit.from_argv(compile_builtins = False)

vu.add_vhdl_builtins()
vu.add_json4vhdl()

testbench_lib = vu.add_library('spi_tb')
testbench_lib.add_source_files(Path(__file__).parent / 'testbench/*.vhd')

spi_lib = vu.add_library('spi')
spi_lib.add_source_files(Path(__file__).parent / 'src/**/*.vhd')

vu.main()
