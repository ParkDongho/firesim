Running NoC Partition Mode Simulations
======================================

이 섹션에서는 링 NoC를 포함한 네 개의 타일로 구성된 SoC를 세개의 링으로 연결된 FPGA로 분할하는 방법에 대한 단계별 튜토리얼을 제공합니다.
이 튜토리얼은 로컬 Xilinx Alveo U250 FPGA에서 실행할 것입니다.
이 기능은 *매우 실험적이며 EC2 F1에서 테스트되지 않았습니다*.
이전의 :ref:`FireAxe running fast-mode simulations<FIREAXE-FAST-MODE>` 을 읽었다고 가정합니다.

이 모드의 몇 가지 주의 사항:

* ``TARGET_CONFIG`` 에 ``WithNoTraceIO`` 구성 조각을 혼합하여 *TracerV를 비활성화*해야 합니다.

* 각 FPGA가 정확히 2개의 다른 FPGA에 연결된 메쉬 또는 링 기반 NoC 토폴로지에서만 작동합니다.

1. Building Partitioned Sims: Setting up FireAxe Target configs
----------------------------------------------------------------

:ref:`fast-mode<FIREAXE-FAST-MODE>` 와 유사하게, FireAxe 타겟 구성을 설정해야 합니다.
변경 사항 중 하나는 이제 ``WithQSFP`` 구성 조각을 사용한다는 점입니다.
이 정보를 통해 FireAxe는 QSFP 인터커넥트를 사용하여 여러 FPGA 간에 데이터를 교환하기 위해 FPGA 셸에 Aurora IP를 생성합니다.
또한, ``WithFireAxeNoCPart`` 를 추가했음을 주의하세요.
이는 컴파일러에게 라우터 노드와 해당 라우터 노드에 연결된 모듈들을 그룹화하여 NoC 분할 통과를 수행하도록 지시합니다.
``WithPartitionGlobalInfo`` 의 인덱스는 이제 라우터 노드 인덱스를 나타냅니다.

.. literalinclude:: ../../../sim/firesim-lib/src/main/scala/configs/FireAxeTargetConfigs.scala
   :language: scala
   :start-after: DOC include start: Xilinx U250 Ring NoC Partition
   :end-before: DOC include end: Xilinx U250 Ring NoC Partition

2. Building Partitioned Sims: `config_build_recipes.yaml`
-----------------------------------------------------------

이 시점에서 ``config_build_recipes.yaml`` 을 지정할 수 있습니다.

.. literalinclude:: ../../../deploy/sample-backup-configs/sample_config_build_recipes.yaml
   :language: yaml
   :start-after: DOC include start: Xilinx U250 NoC Partition Build Recipe
   :end-before: DOC include end: Xilinx U250 NoC Partition Build Recipe

3. Running Partitioned Simulations: `user_topology.py`
--------------------------------------------------------

다시 한 번, 시뮬레이션을 실행하기 위해 FireAxe 토폴로지를 지정해야 합니다.

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: user_topology.py fireaxe_ring_noc_config
   :end-before: DOC include end: user_topology.py fireaxe_ring_noc_config

이 예제에서 FireAxe 토폴로지가 설정되는 방법을 살펴봅시다.
파티션 ``N`` 의 브리지 0이 항상 파티션 ``(N + 1) % NFPGAs`` 의 브리지 1에 연결되고, 
파티션 ``N`` 의 브리지 1이 항상 파티션 ``(N + NFPGAs - 1) % NFPGAs`` 의 브리지 0에 연결됨을 알 수 있습니다.

.. image:: ./fireaxe-nocmode.svg
   :width: 400

위의 토폴로지를 아래와 같이 지정할 수 있습니다:

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: fireaxe_ring_noc_config edges
   :end-before: DOC include end: fireaxe_ring_noc_config edges

4. Running Partitioned Simulations: `config_runtime.yaml`
-----------------------------------------------------------

이제 ``config_runtime.yaml`` 을 업데이트하여 FireAxe 시뮬레이션을 실행할 수 있습니다.

.. code-block:: yaml

  target_config:
      topology: fireaxe_rocket_ring_noc_config