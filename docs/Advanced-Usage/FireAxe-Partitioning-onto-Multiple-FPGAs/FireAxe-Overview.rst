FireAxe Overview
=============================================

FireSim의 초기 릴리스 이후, 오픈 하드웨어 IP의 확산으로 인해 연구자들이 더 이상 단일 FPGA에 맞지 않는 새로운 SoC 구성을 생성할 수 있게 되었습니다. FireAxe는 FireSim을 기반으로 *대규모 디자인을 여러 FPGA에 분할*하여 단일 FPGA의 한계를 극복합니다.

Partition Modes
==================
FireAxe는 사용자가 파티셔닝을 수행할 수 있는 세 가지 옵션(모드)을 제공합니다: exact-mode, fast-mode, 그리고 NoC-partition-mode. 이 옵션들은 컴파일러에 전달되어 파티션 인터페이스에서 발생하는 특이한 문제를 처리할 올바른 회로를 생성합니다.
더 상세한 설명은 `the FireAxe paper <https://joonho3020.github.io/assets/ISCA2024-FireAxe.pdf>`_ 에서 확인할 수 있습니다. 그러나 FireAxe를 사용하기 원한다면, 아래 설명이 시작하는데 충분합니다.

Exact-Mode
-----------
Exact-mode에서는 사용자가 분할할 모듈을 선택하여 별도의 FPGA에 배치할 수 있습니다.
분할된 시뮬레이션은 타겟을 소프트웨어 RTL 시뮬레이터에서 실행하는 것과 *정확히* 동일하게 동작합니다. 이는 파티션 경계가 지연 민감성이 없을 때(즉, 인터페이스가 ready-valid 인터페이스나 credit-based가 아닐 때) 유용하며, 경계에 조합 논리가 포함된 경우에 적합합니다.

예를 들어, page-table-walker 경계에 연결된 포트가 서로 조합적으로 의존적인 RoCC accelerator는 exact-mode를 사용하여 분할할 수 있는 모듈의 좋은 예입니다.

Fast-Mode
----------
파티션 경계가 지연 민감성이 없는 경우(즉, 인터페이스가 ready-valid 또는 credit 기반), fast-mode를 사용하여 분할된 시뮬레이션을 수행할 수 있습니다.
Exact-mode와 유사하게, 사용자는 분할할 모듈을 선택할 수 있습니다.
그러나 fast-mode는 시뮬레이션 정확도를 성능과 맞바꾸어 더 높은 시뮬레이션 처리량을 제공합니다. 파티션 경계에 단일 사이클의 지연을 주입함으로써, 시뮬레이트된 디자인은 exact-mode보다 거의 2배 빠르게 실행됩니다.

예를 들어, 코어 타일은 타일에서 버스 연결이 ready-valid이고 인터럽트 신호도 지연 민감성이 없기 때문에 분할할 수 있는 모듈의 좋은 예입니다. 실제로, 파티션 경계에 사이클의 지연을 추가하는 것은 정확성에 거의 영향을 주지 않습니다.

NoC-Partition-Mode
------------------
NoC 파티션 모드에서는 NoC 라우터 경계가 지연 민감성이 없다는 것(credit 기반)을 활용합니다. 사용자는 라우터 노드를 그룹으로 지정하기만 하면 컴파일러가 자동으로 모듈을 선택한 라우터와 함께 그룹화하여 분할합니다. NoC-partition-mode는 타일을 분할할 때만 작동합니다.

Supported Platforms
=====================

모든 FireSim 시뮬레이션과 마찬가지로, FireAxe는 F1과 local FPGA에서 실행될 수 있습니다.

EC2 F1
-------
AWS EC2 F1 클라우드 FPGA에서 시뮬레이션 성능을 향상시키기 위해, 우리는 peer-to-peer inter-FPGA PCIe 통신 메커니즘을 사용하여 토큰 교환 지연을 줄입니다 `AWS PCIe Peer to Peer Guides <https://github.com/awslabs/aws-fpga-app-notes/tree/master/Using-PCIe-Peer2Peer>`_.
f1.16xlarge 및 f1.4xlarge 인스턴스는 각각 여러 FPGA(8 또는 2개)를 포함하고 있으며, 이들은 호스트를 거치지 않고 직접 AXI4 트랜잭션을 송수신할 수 있습니다. 이를 통해 시뮬레이터는 최대 1MHz의 시뮬레이션 처리량을 제공합니다.

Local FPGAs w/ QSFP Cables
---------------------------
온프레미스 FPGA의 경우, 저렴한 상용 `QSFP direct-attach-cables <https://www.10gtek.com/qsfp28dac>`_ 를 사용하고 FPGA 쉘에 `Aurora <https://docs.amd.com/v/u/en-US/aurora_64b66b_ds528>`_ 프로토콜을 통합하여 더 낮은 링크 지연을 달성합니다. 이를 통해 FireAxe에 AXI4-Stream 인터페이스를 노출시킵니다. 이 초저지연 인터커넥트는 2MHz의 시뮬레이션 처리량을 달성할 수 있게 했습니다.