.. _FIREAXE-FAST-MODE:

Running Fast Mode Simulations
===================================

이 섹션에서는 *SoC*에서 *RocketTile*을 분리하고 EC2 F1에서 2개의 FPGA를 사용하여 빠른 모드 시뮬레이션을 실행하는 단계별 튜토리얼을 제공합니다.
이 튜토리얼은 :ref:`AWS F1 Getting Started Guide<AWS-F1-Getting-Started-Guide>` 를 완료했으며 FireSim 워크플로우에 익숙하다는 가정을 합니다.

1. Building Partitioned Sims: Setting up FireAxe Target configs
----------------------------------------------------------------

분할된 시뮬레이션을 위한 bitstream을 빌드하려면 분할하고자 하는 모듈을 지정해야 합니다.
이를 :gh-file-ref:`sim/firesim-lib/src/main/scala/configs/FireAxeTargetConfigs.scala` 에서 수행할 수 있습니다.

.. literalinclude:: ../../../sim/firesim-lib/src/main/scala/configs/FireAxeTargetConfigs.scala
   :language: scala
   :start-after: DOC include start: F1 Rocket Partition
   :end-before: DOC include end: F1 Rocket Partition

``WithPartitionGlobalInfo`` 프래그먼트는 ``Seq[Seq[String]]`` 타입의 인수를 받습니다.
각 ``Seq[String]`` 은 동일한 파티션으로 추출될 모듈 그룹을 나타냅니다.

.. code-block:: scala

    new WithPartitionGlobalInfo(Seq(
      Seq("A", "B"),
      Seq("C", "D"))

예를 들어, 위의 예에서 모듈 "A", "B"는 그룹으로 묶여 하나의 FPGA로 추출되고,
"C", "D"는 그룹으로 묶여 다른 FPGA로 추출되며, 기본 SoC는 세 번째 FPGA에 배치됩니다.

위의 예와 같이 ``WithPartitionBase`` 및 ``WithPartitionIndex(idx)`` 를 사용하여 파티션을 지정할 수 있습니다.
예를 들어, ``WithPartitionIndex(0)`` 은 ``Seq("A", "B")`` 을 분할할 모듈 그룹으로 선택합니다.
각 파티션 그룹을 FPGA에 매핑하는 방법은 :gh-file-ref:`deploy/runtools/user_topology.py` 에 지정되어 있습니다.

2. Building Partitioned Sims: `config_build_recipes.yaml`
------------------------------------------------------------

이제 ``config_build_recipes.yaml`` 을 지정할 수 있습니다.
``TARGET_CONFIG`` 을 빌드하고자 하는 FireChip 구성으로 설정하고, ``PLATFORM_CONFIG`` 을 위 단계에서 정의한 파티션 구성으로 설정해야 합니다.

.. literalinclude:: ../../../deploy/sample-backup-configs/sample_config_build_recipes.yaml
   :language: yaml
   :start-after: DOC include start: F1 Rocket Partition Build Recipe
   :end-before: DOC include end: F1 Rocket Partition Build Recipe

이제 ``firesim buildbitstream`` 명령을 사용하여 이러한 파티션 구성의 bitstream을 빌드할 수 있습니다.

3. Running Partitioned Simulations: `user_topology.py`
--------------------------------------------------------

bitstream이 빌드되고 hwdb 항목이 ``config_hwdb.yaml`` 에 복사되면,
``config_runtime.yaml`` 및 :gh-file-ref:`deploy/runtools/user_topology.py` 를 설정하여 FireAxe 시뮬레이션을 실행해야 합니다.

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: user_topology.py fireaxe_rocket_fastmode_config
   :end-before: DOC include end: user_topology.py fireaxe_rocket_fastmode_config

이것은 SoC에서 RocketTile을 분리할 때의 FireAxe 토폴로지를 나타내는 것입니다.
각 줄을 개별적으로 살펴보겠습니다.

``hwdb_entries`` 는 파티션 인덱스를 ``hwdb`` 이름에 매핑하는 사전입니다.

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: fireaxe_fastmode_config hwdb_entries
   :end-before: DOC include end: fireaxe_fastmode_config hwdb_entries

``slot_to_pidx`` 는 파티션 인덱스를 FPGA slotid에 매핑하는 리스트입니다.
리스트 항목은 파티션 인덱스이며 slotid는 리스트의 위치에 의해 결정됩니다.
예를 들어, ``slotid_to_pidx = [2, 1, 0]`` 은 파티션 인덱스 2를 시뮬레이션 슬롯 0에, 파티션 인덱스 1을 시뮬레이션 슬롯 1에, 파티션 인덱스 0을 시뮬레이션 슬롯 2에 매핑합니다.

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: fireaxe_fastmode_config slot_to_pidx
   :end-before: DOC include end: fireaxe_fastmode_config slot_to_pidx

FireAxe 시뮬레이션을 실행하기 위해 SoC 파티션 토폴로지를 지정해야 합니다.
아래 그림은 현재 SoC 파티션 토폴로지를 나타냅니다.
``pidx`` 는 파티션 인덱스를 나타냅니다: 인덱스 0은 ``f1_rocket_split_soc_fast`` 에 해당하고 인덱스 1은 ``f1_rocket_split_tile_fast`` 에 해당합니다.
FireAxe에서는 각 파티션이 다른 파티션과 통신하는 데 사용되는 다리(브리지) 세트를 포함합니다. 각 파티션에 첨부된 다리는 고유한 ID를 가지며 0부터 시작합니다.
우리 예에서는, 파티션 0과 파티션 1이 단일 엣지(bridge id가 둘 다 0인 경우)를 통해 통신합니다.

.. image:: ./fireaxe-fastmode.svg
   :width: 400

``FireAxeEdge`` 클래스는 파티션 간의 연결을 나타내는 데 사용됩니다.
파티션 ``X`` 를 파티션 ``Y`` 에 연결할 때, ``X`` 와 ``Y`` 를 연결하는 bridge 인덱스(``Xbidx``, ``Ybidx``)를 알아야 합니다.
엣지의 꼭짓점은 파티션 인덱스와 bridge 인덱스의 튜플로 설명될 수 있습니다: ``Xpair = FireAxeNodeBridgedPair(X, Xbidx)`` 및 ``Ypair = FireAxeNodeBridgedPair(Y, Ybidx)``.
그런 다음 엣지는 ``FireAxeEdge(Xpair, Ypair)`` 로 설명될 수 있습니다.
따라서 위 그림의 엣지는 다음과 같이 설명될 수 있습니다:

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: fireaxe_fastmode_config edges
   :end-before: DOC include end: fireaxe_fastmode_config edges

다음으로, bitstream을 빌드할 때 선택한 파티션 모드를 지정해야 합니다.
이 예에서는 ``FAST_MODE`` 를 선택했습니다.

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: fireaxe_fastmode_config mode
   :end-before: DOC include end: fireaxe_fastmode_config mode

이 시점에서, 위의 매개변수로 ``fireaxe_topology_config`` 를 호출하기만 하면 됩니다.

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: fireaxe_fastmode_config summing it all up
   :end-before: DOC include end: fireaxe_fastmode_config summing it all up

사용자는 이 코드를 염려하지 않아도 됩니다.
이 코드는 단지 파티션 토폴로지를 생성하고 ``PartitionConfig`` 인스턴스를 생성하여
토폴로지에 대한 정보를 포함하고 이를 ``FireSimServerNode`` 에 전달합니다.

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: user_topology.py fireaxe_topology_config
   :end-before: DOC include end: user_topology.py fireaxe_topology_config

4. Running Partitioned Simulations: config_runtime.yaml
--------------------------------------------------------

이제 FireAxe 시뮬레이션을 실행하기 위해 ``config_runtime.yaml`` 을 설정해야 합니다.
``config_runtime[target_config][topology]`` 를 3단계에서 정의한 토폴로지로 변경하기만 하면 됩니다.

.. code-block:: yaml

  target_config:
      topology: fireaxe_rocket_fastmode_config

이 시점에서, ``firesim runworkload`` 를 실행하여 시뮬레이션을 시작할 수 있습니다.

