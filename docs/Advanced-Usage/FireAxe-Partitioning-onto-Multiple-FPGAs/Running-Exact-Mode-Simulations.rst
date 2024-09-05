Running Exact Mode Simulations
===================================

In this section, we provide a step-by-step tutorial on how to partition a
*RocketTile* out from the *SoC* and run exact-mode simulations on EC1 F1.
Similar steps can be applied to perform locally partitioned FPGA simulations.
This assumes that you have read the :ref:`FireAxe running fast-mode simulations<FIREAXE-FAST-MODE>`.

1. Building Partitioned Sims: Setting up FireAxe Target configs
----------------------------------------------------------------

우리는 :ref:`fast-mode<FIREAXE-FAST-MODE>` 에서 사용한 FireAxe 타겟 설정을 재사용할 것입니다.

.. literalinclude:: ../../../sim/firesim-lib/src/main/scala/configs/FireAxeTargetConfigs.scala
   :language: scala
   :start-after: DOC include start: F1 Rocket Partition
   :end-before: DOC include end: F1 Rocket Partition

2. Building Partitioned Sims: `config_build_recipes.yaml`
----------------------------------------------------------

이 시점에서 ``config_build_recipes.yaml`` 을 지정할 수 있습니다.
여기서 주목할 점은 ``PLATFORM_CONFIG`` 필드에 ``ExactMode_`` 를 추가했다는 점입니다.
이는 FireAxe 컴파일러에게 분할하는 동안 추가 단계를 수행하여 타겟 동작이 사이클 정확하게 시뮬레이션될 수 있도록 지시합니다.

.. literalinclude:: ../../../deploy/sample-backup-configs/sample_config_build_recipes.yaml
   :language: yaml
   :start-after: DOC include start: F1 Exact Rocket Partition Build Recipe
   :end-before: DOC include end: F1 Exact Rocket Partition Build Recipe

3. Running Partitioned Simulations: `user_topology.py`
--------------------------------------------------------

다시 한 번, FireAxe 시뮬레이션을 실행하기 위해 :gh-file-ref:`deploy/runtools/user_topology.py` 를 지정해야 합니다.

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: user_topology.py fireaxe_rocket_exactmode_config
   :end-before: DOC include end: user_topology.py fireaxe_rocket_exactmode_config

몇 가지 변경된 사항을 빠르게 살펴보겠습니다.

우선, ``edges`` 로 지정된 FireAxe 토폴로지가 변경되었습니다.
이는 정확 모드에서 컴파일러가 조합 논리를 올바르게 모델링하기 위해 파티션 간에 여러 통신 채널(또는 엣지)을 생성해야 하기 때문입니다.

파티셔닝 토폴로지는 이제 다음과 같습니다:

.. image:: ./fireaxe-exactmode.svg
   :width: 400

파티션 0의 브리지 0에서 파티션 1의 브리지 0으로 연결되는 상단 엣지는 다음과 같이 설명할 수 있습니다:

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: fireaxe_rocket_exactmode_config edge 0
   :end-before: DOC include end: fireaxe_rocket_exactmode_config edge 0

파티션 0의 브리지 1에서 파티션 1의 브리지 1으로 연결되는 하단 엣지는 다음과 같이 설명할 수 있습니다:

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: fireaxe_rocket_exactmode_config edge 1
   :end-before: DOC include end: fireaxe_rocket_exactmode_config edge 1

우리는 또한 파티션 모드를 ``EXACT_MODE`` 로 변경했습니다:

.. literalinclude:: ../../../deploy/runtools/user_topology.py
   :language: python
   :start-after: DOC include start: fireaxe_rocket_exactmode_config mode
   :end-before: DOC include end: fireaxe_rocket_exactmode_config mode

4. Running Partitioned Simulations: `config_runtime.yaml`
-----------------------------------------------------------

이제 FireAxe 시뮬레이션을 실행하도록 ``config_runtime.yaml`` 을 업데이트할 수 있습니다.

.. code-block:: yaml

  target_config:
      topology: fireaxe_rocket_exactmode_config
