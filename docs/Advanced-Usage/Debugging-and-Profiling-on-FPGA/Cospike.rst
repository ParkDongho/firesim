.. _spike:

Spike Co-simulation with BOOM designs
==================================================

TracerV 대신에 타겟 CPU의 아키텍처 상태를 사이클 단위로 추적하기 위해 `Spike co-simulator <https://github.com/riscv-software-src/riscv-isa-sim>`_ 를 사용하여 BOOM 디자인의 기능을 검증할 수 있습니다.

.. note:: 이 작업은 현재 단일 코어 BOOM 디자인에서만 작동합니다.

.. note:: Cospike는 현재 블록 장치 시뮬레이션을 지원하지 않습니다.


.. _cospike-bridge:

Building a Design with Cospike
-------------------------------

모든 FireChip 디자인에서 TracerV는 기본적으로 포함되어 있습니다.
Cospike를 활성화하려면, BOOM 타겟 디자인 설정에 Cospike bridge (``WithCospikeBridge``)를 추가하기만 하면 됩니다 (기본 설정은 ``$CHIPYARD/generators/firechip/src/main/scala/TargetConfigs.scala`` 에 위치합니다).
Cospike를 포함한 예제 설정은 아래와 같습니다:

.. code-block:: scala

    class FireSimLargeBoomConfig extends Config(
      new WithCospikeBridge ++ // add Cospike bridge to simulation
      new WithDefaultFireSimBridges ++
      new WithDefaultMemModel ++
      new WithFireSimConfigTweaks ++
      new chipyard.LargeBoomV3Config)

이 시점에서, 원하는 BOOM 설정에 대해 ``firesim buildbitstream`` 명령을 실행해야 합니다.
이제 기본적으로 Cospike가 활성화된 상태로 시뮬레이션을 실행할 준비가 되었습니다.

Troubleshooting Cospike Simulations with Meta-Simulations
----------------------------------------------------------

Cospike를 사용한 FPGA 시뮬레이션이 실패하면, 메타시뮬레이션을 사용하여 Cospike 설정이 올바른지 확인할 수 있습니다.
먼저 메타시뮬레이션에 대한 자세한 정보는 :ref:`metasimulation` 를 참조하십시오.

.. note:: VCS 플래그에 ``+define+RANDOM=0`` 이 추가되지 않으면 VCS에서 시뮬레이션이 가끔씩 일관성을 잃을 수 있습니다. 이를 위해 ``sim/midas/src/main/cc/rtlsim/Makefrag-vcs`` 파일에 플래그를 추가하십시오.
