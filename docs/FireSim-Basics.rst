.. _firesim-basics:

FireSim Basics
===================================

FireSim은 10MHz에서 100MHz 이상의 속도로 RTL 하드웨어 구현을 검증, 프로파일링 및 디버깅하기 쉽게 만들어주는 오픈 소스 FPGA 가속 전체 시스템 하드웨어 시뮬레이션 플랫폼입니다. FireSim은 ASIC RTL을 다른 시스템 구성 요소(예: I/Os)의 사이클 정확한 하드웨어 및 소프트웨어 모델과 공동 시뮬레이션하는 과정을 단순화합니다. FireSim은 개별 SoC 시뮬레이션을 로컬 데스크톱에 연결된 단일 Xilinx Alveo 보드와 같은 온프레미스 FPGA에서 호스팅하는 것부터 수백 개의 클라우드 FPGA를 활용하는 대규모 데이터센터 수준의 시뮬레이션까지 생산적으로 확장할 수 있습니다(예: Amazon EC2 F1).

전 세계 20개 이상의 학술 및 산업 기관에서 FireSim을 사용해 40편 이상의 논문을 발표했으며, 컴퓨터 아키텍처, 시스템, 네트워킹, 보안, 과학 컴퓨팅, 회로, 설계 자동화 등 다양한 분야에 사용되었습니다(FireSim 웹사이트의 `Publications page <https://fires.im/publications>`__ 참조). FireSim은 상업적으로 사용 가능한 실리콘 개발에도 활용되었습니다. FireSim은 원래 캘리포니아 대학교 버클리의 전기 공학 및 컴퓨터 과학부에서 개발되었으며, 현재는 전 세계 산업 및 학계 기여자들이 함께하고 있습니다.

이 문서에서는 사용자가 FireSim을 플랫폼에서 사용하는 방법을 안내하고, 고급 FireSim 기능에 대한 참고 자료 역할을 합니다. FireSim에 대한 고급 기술 논의는 `FireSim website <https://fires.im>`__ 를 참조하세요.


Common FireSim usage models
---------------------------------------

아래는 FireSim의 세 가지 일반적인 사용 모델입니다. 처음 두 가지가 가장 일반적이며, 세 번째 모델은 주로 대규모 컴퓨터 연구에 관심이 있는 사람들을 위한 것입니다. 이 문서 사이트의 시작 가이드에서는 세 가지 모델 모두를 다룹니다.

1. Single-Node Simulations Using One or More On-Premises FPGAs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

이 사용 모델에서 FireSim은 개별 SoC 설계(예: `Chipyard <https://chipyard.readthedocs.io/>`__ 에서 생성된 것)로 구성된 타겟을 온프레미스 FPGA(로컬 데스크톱, 노트북, 클러스터에 연결된 FPGA 등)에서 150MHz 이상의 속도로 시뮬레이션할 수 있도록 합니다. 클라우드와 마찬가지로 FireSim 매니저는 복잡한 워크로드(SPECInt2017의 전체 참조 입력 포함)를 실행하는 작업을 하나 이상의 온프레미스 FPGA에 자동으로 분배하고 관리할 수 있습니다.

2. Single-Node Simulations Using Cloud FPGAs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

이 사용 모델은 이전의 온프레미스 경우와 유사하지만, 사용자가 온프레미스 FPGA를 구입하고 설정할 필요 없이 클라우드 인스턴스에 연결된 FPGA에서 시뮬레이션을 배포합니다. 이를 통해 워크로드 요구 사항에 맞게 사용 중인 FPGA 수를 동적으로 확장할 수 있습니다. 예를 들어, AWS EC2 F1에서는 SPECInt2017의 10개 워크로드를 10개의 클라우드 FPGA에서 병렬로 실행하는 것이 하나의 클라우드 FPGA에서 순차적으로 실행하는 것과 비용 효율이 동일합니다.

.. note::
    FireSim의 모든 자동화는 온프레미스와 클라우드 사용 모델 모두에서 작동하므로 초기 개발은 하나(또는 소규모 클러스터)의 온프레미스 FPGA에서 수행하면서 높은 병렬 처리가 필요한 경우 클라우드 FPGA로 확장하는 **하이브리드 사용 모델** 을 사용할 수 있습니다.

3. Datacenter/Cluster Simulations on On-Premises or Cloud FPGAs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

이 모드에서 FireSim은 현재 및 미래의 데이터센터 규모 시스템을 정확하게 모델링하기 위해 파라미터화 가능한 대역폭, 링크 지연 시간, 구성 가능한 토폴로지를 갖춘 사이클 정확한 네트워크도 모델링합니다. 예를 들어, FireSim은 200Gbps, 2us 이더넷 네트워크로 상호 연결된 1024개의 쿼드 코어 RISC-V Rocket Chip 기반 노드를 시뮬레이션하는 데 사용되었습니다. 이 사용 사례에 대해 자세히 알아보려면 `ISCA 2018 paper <https://sagark.org/assets/pubs/firesim-isca2018.pdf>`__ 를 참조하세요.


Other Use Cases
---------------------

다른 사용 사례가 있거나 위의 범주에 속하지 않는 경우 언제든지 저희에게 문의하세요!

Choose your platform to get started
--------------------------------------

FireSim은 다양한 유형의 FPGA 및 FPGA 플랫폼을 지원합니다! 특정 플랫폼에 대한 시작 가이드를 보려면 아래 링크 중 하나를 클릭하세요.

* :doc:`/Getting-Started-Guides/AWS-EC2-F1-Getting-Started/index`

  * 상태: ✅ FireSim의 모든 기능이 지원됩니다.

* :doc:`/Getting-Started-Guides/On-Premises-FPGA-Getting-Started/Xilinx-Alveo-U200-FPGAs`

  * 상태: ✅ FireSim의 모든 기능이 지원됩니다.

* :doc:`/Getting-Started-Guides/On-Premises-FPGA-Getting-Started/Xilinx-Alveo-U250-FPGAs`

  * 상태: ✅ FireSim의 모든 기능이 지원됩니다.

* :doc:`/Getting-Started-Guides/On-Premises-FPGA-Getting-Started/Xilinx-Alveo-U280-FPGAs`

  * 상태: ✅ FireSim의 모든 기능이 지원됩니다.

* :doc:`/Getting-Started-Guides/On-Premises-FPGA-Getting-Started/Xilinx-VCU118-FPGAs`

  * 상태: ✅ FireSim의 모든 기능이 지원됩니다.

* :doc:`/Getting-Started-Guides/On-Premises-FPGA-Getting-Started/RHS-Research-Nitefury-II-FPGAs`

  * 상태: ✅ FireSim의 모든 기능이 지원됩니다.

* :doc:`Getting-Started-Guides/On-Premises-FPGA-Getting-Started/Xilinx-Vitis-FPGAs`

  * 상태: ⚠️ DMA 기반 브릿지가 지원되지 않습니다. Vitis 기반 U250 흐름은 특정 제약 조건으로 인해 Vitis를 사용해야 하는 경우가 아니라면 **권장되지 않습니다**. 특히 Vitis 기반 흐름은 DMA 기반 FireSim 브릿지(예: TracerV, Synthesizable Printfs 등)를 지원하지 않으며, 위에 표시된 것처럼 XDMA 기반 흐름은 FireSim의 모든 기능을 지원합니다. 확신이 없다면 XDMA 기반 U250 흐름을 대신 사용하세요: :doc:`/Getting-Started-Guides/On-Premises-FPGA-Getting-Started/Xilinx-Alveo-U250-FPGAs`.
