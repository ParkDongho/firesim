다음은 FireSim 설정 전에 문서에서 자주 사용될 몇 가지 용어에 대한 설명입니다.

먼저, 시뮬레이션되는 하드웨어와 시뮬레이션을 수행하는 컴퓨터 간의 혼동을 방지하기 위해, 다음과 같이 정의합니다:

**Target**
  시뮬레이션되는 디자인 및 환경을 의미합니다. 일반적으로 하나 이상의 RISC-V SoC 그룹으로, 이들 간의 네트워크가 있을 수도 있고 없을 수도 있습니다.

**Host**
  FireSim 시뮬레이션을 실행하는 컴퓨터/FPGAs를 의미하며, 아래에서 설명할 **Run Farm** 이 이에 해당합니다.

우리는 종종 이러한 용어를 접두어로 사용합니다. 예를 들어, 소프트웨어는 시뮬레이션된 RISC-V 시스템(*target*-software)에서 실행되거나, 호스트 x86 머신(*host*-software)에서 실행될 수 있습니다.

.. figure:: ../../../img/firesim_env.png
   :alt: FireSim Infrastructure Setup

   FireSim Infrastructure Diagram

**FireSim Manager** (``firesim``)
  이 프로그램은 (필요한 스크립트를 소스한 후 ``firesim`` 명령어로 경로에 추가됩니다) FPGA 빌드를 시작하고 시뮬레이션을 실행하는 작업을 자동화합니다. 대부분의 사용자는 대부분의 경우 이 매니저와만 상호작용하면 됩니다. Vagrant 또는 Docker와 같은 도구에 익숙하다면, ``firesim`` 명령어는 VM/컨테이너 대신 FPGA 시뮬레이터를 위한 ``vagrant`` 및 ``docker`` 명령어와 유사합니다.

FireSim 시뮬레이션을 구축하고 실행하는 데 사용되는 머신들은 크게 세 가지 그룹으로 분류됩니다:

|manager_machine|
  이 머신은 주로 작업을 수행하는 주요 호스트 머신입니다 (예: |mach_details|). 여기서 FireSim을 클론하고 FireSim Manager를 사용하여 빌드/시뮬레이션을 배포합니다.

|build_farm_machine|
  이 머신들은 FireSim 매니저가 FPGA 비트스트림 빌드를 실행하는 데 사용되는 머신들의 집합입니다 ("build farm |mach_or_inst_l|"). 매니저는 빌드를 실행하는 데 필요한 모든 소스를 이 |mach_or_inst_l| 에 자동으로 전송하며, Verilog에서 FPGA 비트스트림으로 변환하는 빌드 과정을 이곳에서 실행합니다.

|run_farm_machine|
  이 머신들은 FPGA가 부착된 머신들의 집합으로 ("run farm |mach_or_inst_l|"), 매니저가 관리하며 시뮬레이션을 배포하는 데 사용됩니다. 여러 Run Farms를 병렬로 사용하여 여러 개의 별도 시뮬레이션을 동시에 실행할 수 있습니다.

|simple_setup|

마지막으로, 이 문서 전반에서 참조될 또 하나의 용어가 있습니다:

**Golden Gate**
  FireSim에서 타겟 RTL을 분리된 시뮬레이터로 변환하는 FIRRTL 컴파일러입니다. 이전 이름은 MIDAS였습니다.
