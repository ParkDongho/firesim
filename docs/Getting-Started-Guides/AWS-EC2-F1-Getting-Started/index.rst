.. _AWS-F1-Getting-Started-Guide:

AWS EC2 F1 Getting Started Guide
=====================================

이 페이지에 이어지는 가이드들은 AWS EC2 F1을 사용하여 FireSim 시뮬레이션 예제를 설정하고 실행하는 전체 과정을 안내합니다. 이 가이드의 끝에서는 4MB의 마지막 레벨 캐시, 16GB DDR3, NIC가 없는 쿼드 코어 Rocket Chip 기반의 단일 노드를 시뮬레이션하게 될 것입니다. 이후에는 전 세계적으로 사이클 정확도가 보장된 클러스터 규모의 FireSim 시뮬레이션을 시뮬레이션하는 방법을 보여주는 가이드로 계속 진행할 수 있습니다. 마지막 가이드는 사용자 정의 하드웨어가 포함된 FPGA 이미지를 빌드하는 방법을 설명합니다. 이 가이드들을 완료한 후에는 왼쪽 사이드바의 "Advanced Docs"를 참조할 수 있습니다.

다음은 AWS EC2 F1 시작 가이드에서 수행할 작업의 개요입니다:

#. **Initial Setup/Installation**

   a. Background/Terminology: 나머지 가이드에서 사용될 주요 용어에 대해 설명합니다.

   #. First-time AWS User Setup: 이미 AWS 계정/결제 방법을 설정한 경우 이 부분을 건너뛸 수 있습니다.

   #. Configuring required AWS resources in your account:  FireSim을 실행하는 데 필요한 적절한 VPC/서브넷/보안 그룹을 설정합니다.

   #. "Manager Instance" 설정: 시뮬레이션 빌드 및 배포를 조정할 인스턴스를 설정합니다.

#. **Single-node simulation guide**: 이 가이드는 단일 ``f1.2xlarge`` 로 구성된 Run Farm에서 사전 빌드된 공개 FireSim AGFI를 사용하여 하나의 시뮬레이션을 실행하는 과정을 안내합니다.

#. **Cluster simulation guide**: 이 가이드는 단일 ``f1.16xlarge`` 로 구성된 Run Farm에서 사전 빌드된 공개 FireSim AGFI 및 스위치 모델을 사용하여 8-노드 클러스터 시뮬레이션을 실행하는 과정을 안내합니다.

#. **Building your own hardware designs guide (Chisel to FPGA Image)**: 이 가이드는 Rocket Chip RTL과 Rocket Chip에 연결된 사용자 정의 RTL을 사용하여 FireSim AGFI를 생성하고 시뮬레이션에 연결하는 전체 과정을 안내합니다. 이 과정은 Chisel elaboration, FAME-1 Transformation, Vivado FPGA 흐름을 자동으로 실행합니다.

일반적으로, Chisel RTL을 수정하거나 실행 시간에 구성할 수 없는 하드웨어 매개변수를 변경하는 경우에만 4단계를 따르시면 됩니다.

.. toctree::
   :maxdepth: 2

   Initial-Setup/index
   Running-Simulations/index
   Building-a-FireSim-AFI
