Complete FPGA Metasimulation
=========================================
일반적으로 사용자는 기존의 метасimulation (이전의 MIDAS 수준 시뮬레이션)만 사용하면 됩니다. 그러나 새로운 FPGA 플랫폼을 실행하거나 기존의 것을 변경할 때는 FPGA 프로젝트에 대한 완전한 사전 합성 RTL 시뮬레이션(이를 FPGA 수준 메타시뮬레이션이라고 함)이 필요할 수 있습니다. 이것은 Vivado에 전달된 전체 RTL 프로젝트를 시뮬레이션하며, FPGA에서 사용되는 호스트 메모리 컨트롤러 및 PCI-E 서브시스템의 정확한 RTL 모델을 포함합니다. 참고로, 일반적으로 사용자가 FPGA-level 메타시뮬레이션을 배포해서는 안 되므로, FPGA-level 수식어 없이 메타시뮬레이션을 지칭할 때는 :ref:`Debugging & Testing with Metasimulation<metasimulation>` 에 설명된 더 빠른 형태를 의미합니다.

FPGA-level 메타시뮬레이션은 :gh-file-ref:`sim/` 에서 실행되며 두 가지 구성 요소로 이루어져 있습니다:

1. FPGA 대신 시뮬레이션된 DUT와 통신하는 FireSim-f1 드라이버
2. 앞서 언급한 FireSim-f1 드라이버로부터 명령을 받는, XSIM 또는 VCS로 컴파일된 시뮬레이터인 DUT

-----
Usage
-----

시뮬레이션을 실행하려면 다음과 같이 DUT와 드라이버 타겟을 생성해야 합니다::

    make xsim
    make xsim-dut <VCS=1> & # DUT를 시작합니다.
    make run-xsim SIM_BINARY=<PATH/TO/BINARY/FOR/TARGET/TO/RUN> # 드라이버를 시작합니다.

이 과정을 따를 때 ``make run-xsim`` 을 실행하기 전에 ``make xsim-dut`` 가 ``opening driver to xsim`` 을 출력할 때까지 기다려야 합니다 (``make xsim-dut`` 에서 이 출력을 얻는 데 시간이 걸릴 수 있습니다).

두 프로세스가 모두 실행되면, 다음과 같은 출력이 나타납니다::

    opening driver to xsim
    opening xsim to driver

이는 DUT와 드라이버가 성공적으로 통신하고 있음을 나타냅니다. 결국, DUT는 Rocket Chip에서의 커밋 트레이스를 출력할 것입니다. 프로그램이 FPGA DRAM에 로드되는 동안 처음 100개의 명령어 후에는 긴 일시 중지가 발생할 수 있습니다 (바이너리 크기에 따라 몇 분에서 한 시간이 걸릴 수 있음).

XSIM은 기본적으로 사용되며, FPGA 개발자 AMI를 사용하는 EC2 인스턴스에서 작동합니다. 라이센스가 있는 경우, ``VCS=1`` 을 설정하면 VCS를 사용하여 DUT를 컴파일할 수 있습니다 (XSIM보다 4배 빠름). 밀레니엄 머신에서 실행 중인 버클리 사용자는 :gh-file-ref:`scripts/setup-vcsmx-env.sh` 을 소싱하여 VCS 기반 FPGA-level 시뮬레이션을 위한 환경을 설정할 수 있습니다.

웨이브폼은 FPGA 빌드 디렉토리에 덤프됩니다 (
``firesim/platforms/f1/aws-fpga/hdk/cl/developer_designs/cl_<DESIGN>-<TARGET_CONFIG>-<PLATFORM_CONFIG>``).

XSIM의 경우::

    <BUILD_DIR>/verif/sim/vivado/test_firesim_c/tb.wdb

VCS의 경우::

    <BUILD_DIR>/verif/sim/vcs/test_firesim_c/test_null.vpd

시뮬레이션이 조기 종료되었을 경우에는 남아있는 프로세스를 반드시 종료해야 합니다.