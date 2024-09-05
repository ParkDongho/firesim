Output Files
============

Golden Gate generates many output files, we describe them here.  Note, the GG CML-argument ``--output-filename-base=<BASE>`` defines defines a common prefix for all output files.

Core Files
-------------------------------------
These are used in nearly all flows.

* **<BASE>.sv**: 시뮬레이터의 Verilog 구현으로, FPGA에 합성됩니다. 최상위 모듈은 ``PLATFORM_CONFIG`` 에서 지정된 Shim 모듈입니다.
* **<BASE>.const.h**: 브리지 드라이버를 인스턴스화하는 데 필요한 모든 메타데이터를 포함하는 타겟 전용 헤더입니다. 이 파일은 시뮬레이터 드라이버와 메타 시뮬레이터(FPGA 수준 / MIDAS 수준)에 링크됩니다. 종종 "헤더"라고도 불립니다.

FPGA Build Files
-------------------------------------
These are additional files passed to the FPGA build directory.

* **<BASE>.defines.vh**: FPGA 합성을 위한 Verilog 매크로 정의입니다.
* **<BASE>.ila_insert_vivado.tcl**: 디자인을 위한 ILA를 합성합니다. FireSim에서 ILA를 사용하는 자세한 방법은 :ref:`auto-ila` 를 참조하세요.
* **<BASE>.ila_insert_{inst, ports, wires}.v**: 생성된 ILA를 인스턴스화하기 위해 ```include``` 지시문을 통해 FPGA 프로젝트에 인스턴스화됩니다.
* **<BASE>.synthesis.xdc**: 수집된 XDCAnnotations에서 유래한 합성을 위한 Xilinx 디자인 제약 조건입니다.
* **<BASE>.implementation.xdc**: 수집된 XDCAnnotations에서 유래한 구현을 위한 Xilinx 디자인 제약 조건입니다.

Metasimulation Files
-------------------------------------
These are additional sources used only for compiling metasimulators.

* **<BASE>.const.vh**: 가변 폭 필드를 정의하기 위한 Verilog 매크로입니다.