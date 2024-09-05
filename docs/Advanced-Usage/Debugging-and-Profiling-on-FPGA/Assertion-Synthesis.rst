Assertion Synthesis: Catching RTL Assertions on the FPGA  
========================================================================

Golden Gate는 FPGA 합성 흐름에서 손실될 수 있는 FIRRTL에 존재하는 어서션(``stop`` 문으로 구현됨)을 합성할 수 있습니다. Rocket과 BOOM은 수백 개의 이러한 어서션을 포함하고 있으며, 이를 합성하면 타겟이 실패하는 이유에 대한 큰 통찰력을 얻을 수 있습니다.

Assertion Synthesis 활성화  
----------------------------

Assertion 합성을 활성화하려면 ``WithSynthAsserts`` 구성을 PLATFORM_CONFIG에 추가하십시오. 컴파일 중 Golden Gate는 합성된 어서션의 수를 출력합니다. 생성된 헤더에서 모든 합성된 어서션의 정의를 찾을 수 있습니다. ``synthesized_assertions_t`` 브리지 드라이버가 자동으로 인스턴스화됩니다.

Runtime Behavior  
----------------

시뮬레이션 중 어서션이 발생하면 드라이버는 어서션의 원인, 어서션이 발생한 모듈 인스턴스 경로, 소스 로케이터 및 어서션이 발생한 사이클을 출력합니다. 시뮬레이션은 그 후 종료됩니다.

BOOM의 듀얼 코어 인스턴스에서 발생한 어서션 예시는 아래와 같습니다:

.. code-block:: text

    id: 1190, module: IssueSlot_4, path: FireSimNoNIC.tile_1.core.issue_units_0.slots_3]
    Assertion failed
        at issue_slot.scala:214 assert (!slot_p1_poisoned)
        at cycle: 2142042185


Verilator 또는 VCS를 사용하는 소프트웨어 기반의 RTL 시뮬레이션과 마찬가지로, 보고된 사이클은 어서션이 인스턴스화된 클록 도메인에서 경과된 타겟 사이클 수입니다 (Chisel에서는 이는 ``assert`` 를 호출한 시점의 암시적 클록입니다). 동일한 입력으로 FireSim 시뮬레이션을 다시 실행하면 동일한 어서션이 동일한 사이클에서 결정론적으로 발생해야 합니다.

Related Publications  
--------------------

Assertion 합성은 FPL2018 논문, `DESSERT <https://people.eecs.berkeley.edu/~biancolin/papers/dessert-fpl18.pdf>`_ 에서 처음 소개되었습니다.