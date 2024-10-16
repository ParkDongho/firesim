Supernode - Multiple Simulated SoCs Per FPGA
============================================

Supernode는 FPGA 자원 활용도를 개선하고 비용을 절감하기 위해 FPGA당 여러 개의 SoC를 시뮬레이션할 수 있게 해줍니다. 예를 들어, FireSim을 사용하여 데이터센터 규모의 시스템을 시뮬레이션할 경우, 슈퍼노드 모드는 단일 ``f1.16xlarge`` 인스턴스(8개의 FPGA)를 사용하여 32개의 시뮬레이션 노드를 포함한 실제 랙 토폴로지를 시뮬레이션할 수 있습니다.

아래에서는 슈퍼노드 디자인을 활용하기 위해 필요한 빌드 및 런타임 구성 변경 사항을 설명합니다. 현재 슈퍼노드는 NIC가 있는 RocketChip 디자인에서만 활성화됩니다. 슈퍼노드에 대한 자세한 내용은 `FireSim ISCA 2018 Paper <https://sagark.org/assets/pubs/firesim-isca2018.pdf>`__ 에서 확인할 수 있습니다.

Introduction
-------------

기본적으로 슈퍼노드는 하나의 FPGA에 4개의 동일한 디자인을 패킹하며, AWS F1 인스턴스에서 사용 가능한 4개의 DDR 채널을 모두 활용합니다. 현재는 4개의 시뮬레이션 타겟 노드를 캡슐화하는 래퍼 최상위 타겟을 생성하여 이를 수행합니다. 패킹된 노드는 4개의 별도 노드로 간주되며, 각각 고유한 MAC 주소가 할당되고, 개별 노드가 할 수 있는 모든 작업을 수행할 수 있습니다: 서로 다른 프로그램 실행, 네트워크 상호작용, 서로 다른 블록 디바이스 이미지 사용 등. 네트워크 연결의 경우, 4개의 별도 네트워크 링크가 스위치 측에 제공됩니다.

Building Supernode Designs
--------------------------

여기에서는 슈퍼노드 디자인을 빌드하는 데 필요한 변경 사항을 설명합니다.

슈퍼노드 타겟 구성 래퍼는 Chipyard의 ``chipyard/generators/firechip/src/main/scala/TargetConfigs.scala`` 에 있습니다. 예시 래퍼 구성은 다음과 같습니다:

.. code-block:: scala

    class SupernodeFireSimRocketConfig extends Config(
       new WithNumNodes(4) ++
       new freechips.rocketchip.subsystem.WithExtMemSize((1 << 30) * 8L) ++ // 8 GB
       new FireSimRocketConfig)

이 예시에서 ``SupernodeFireSimRocketConfig`` 은 래퍼이고, ``FireSimRocketConfig`` 은 타겟 노드 구성입니다. 다른 타겟 구성을 시뮬레이션하려면, 새로운 타겟 구성으로 슈퍼노드 래퍼를 생성해야 합니다. 예를 들어, 하나의 FPGA에서 4개의 쿼드 코어 노드를 시뮬레이션하려면 다음을 사용할 수 있습니다:

.. code-block:: scala

    class SupernodeFireSimQuadRocketConfig extends Config(
       new WithNumNodes(4) ++
       new freechips.rocketchip.subsystem.WithExtMemSize((1 << 30) * 8L) ++ // 8 GB
       new FireSimQuadRocketConfig)

다음으로 빌드 레시피를 정의할 때, 슈퍼노드 구성을 사용하는 것을 잊지 마세요. ``DESIGN`` 매개변수는 항상 ``FireSim`` 으로 설정해야 하며, ``TARGET_CONFIG`` 매개변수는 ``chipyard/generators/firechip/src/main/scala/TargetConfigs.scala`` 에서 정의한 래퍼 구성으로 설정해야 합니다. ``PLATFORM_CONFIG`` 는 일반적인 FireSim 구성과 동일하게 선택할 수 있습니다. 예를 들어:

.. code-block:: yaml

    DESIGN: FireSim
    TARGET_CONFIG: SupernodeFireSimQuadRocketConfig
    PLATFORM_CONFIG: BaseF1Config
    deploy_quintuplet: null

현재 DDR3 메모리 모델을 사용하는 4개의 쿼드 코어 RocketChip에 대한 단일 사전 빌드된 AGFI를 제공하고 있습니다. 제공된 샘플을 사용하여 직접 AGFI를 빌드할 수도 있습니다. 중요한 점은 FPGA 타이밍 제약을 충족하기 위해 슈퍼노드 타겟은 낮은 호스트 클럭 주파수가 필요할 수 있습니다. 호스트 클럭 주파수는 ``config_build_recipes.yaml`` 의 ``platform_config_args`` (F1을 사용하지 않는 경우 ``PLATFORM_CONFIG`` 에서 설정해야 함)에서 구성할 수 있습니다.

Running Supernode Simulations
-----------------------------

슈퍼노드 모드에서 FireSim을 실행하는 방법은 "일반" 모드와 동일합니다. 현재 유일한 차이점은 메인 시뮬레이션 화면이 ``fsim0`` 이라는 이름으로 유지되고, 나머지 세 개의 시뮬레이션 화면은 ``uartpty1``, ``uartpty2``, ``uartpty3`` 에 각각 연결하여 접근할 수 있다는 점입니다. 모든 시뮬레이션 화면은 UART 로그(``uartlog1``, ``uartlog2``, ``uartlog3``)를 생성합니다. ``sudo`` 명령어를 사용해야만 uartpty에 연결하거나 uart 로그를 볼 수 있습니다. 추가적인 uart 로그는 기본적으로 관리자 인스턴스로 복사되지 않으므로, 워크로드 정의에서 추가적인 uart 로그(uartlog1, uartlog2, uartlog3)의 복사를 지정해야 합니다.

슈퍼노드 토폴로지는 하나의 FPGA 매핑을 나타내는 4개의 시뮬레이션된 타겟 노드 중 하나를 나타내기 위해 ``FireSimSuperNodeServerNode`` 클래스를 사용하며, FPGA 매핑을 나타내지 않는 나머지 세 개의 시뮬레이션된 타겟 노드를 나타내기 위해 ``FireSimDummyServerNode`` 클래스를 사용합니다. 슈퍼노드 모드에서는 항상 4개의 노드를 쌍으로 추가해야 하며, 하나의 ``FireSimSuperNodeServerNode`` 와 세 개의 ``FireSimDummyServerNode`` 로 구성됩니다.

4개의 시뮬레이션된 타겟 노드에서 1024개의 시뮬레이션된 타겟 노드까지 다양한 슈퍼노드 토폴로지 예제가 제공됩니다.

다음은 사용자 정의 슈퍼노드 토폴로지를 작성하기 위한 유용한 예제들입니다.

단일 ``f1.2xlarge`` 에 맞출 수 있는 4개의 시뮬레이션된 타겟 노드를 가진 슈퍼노드 토폴로지 예제:

.. code-block:: python

    def supernode_example_4config(self):
        self.roots = [FireSimSwitchNode()]
        servers = [FireSimSuperNodeServerNode()] + [FireSimDummyServerNode() for x in range(3)]
        self.roots[0].add_downlinks(servers)

단일 ``f1.16xlarge`` 에 맞출 수 있는 32개의 시뮬레이션된 타겟 노드를 가진 슈퍼노드 토폴로지 예제:

.. code-block:: python

    def supernode_example_32config(self):
        self.roots = [FireSimSwitchNode()]
        servers = UserTopologies.supernode_flatten([[FireSimSuperNodeServerNode(), FireSimDummyServerNode(), FireSimDummyServerNode(), FireSimDummyServerNode()] for y in range(8)])
        self.roots[0].add_downlinks(servers)

슈퍼노드 ``config_runtime.yaml`` 파일은 정의된 슈퍼노드 토폴로지와 함께 슈퍼노드 AGFI를 선택해야 합니다.

Work in Progress!
-----------------

현재 슈퍼노드는 더 다양한 사용 사례(비네트워크 사용 사례 및 노드 패킹 증가 포함)를 지원하도록 재구성 작업을 진행 중입니다. 추가 문서가 곧 제공될 예정입니다. 현재 모든 FireSim 기능이 슈퍼노드에서 지원되는 것은 아닙니다. 일반적으로 타겟 관련 기능은 "바로 사용 가능한(out-of-the-box)" 상태로 지원될 가능성이 더 높지만, TracerV와 같은 외부 인터페이스를 포함하는 기능은 "바로 사용 가능한" 상태로 지원되지 않을 가능성이 더 큽니다.
