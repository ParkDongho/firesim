.. _plusarg-synthesis:

PlusArg Synthesis: Runtime Modification of RTL
=============================================================================

Golden Gate는 FPGA 합성 흐름에서 손실될 수 있는 Chisel/FIRRTL 내의 Rocket Chip plusargs를 합성할 수 있습니다.
이 plusargs를 사용하면 시뮬레이션 시작 시 특정 값으로 신호를 구동할 수 있습니다.

예:

.. code-block:: scala

    import freechips.rocketchip.util._

    val my_wire = PlusArg("set_my_wire", 0, "Description")

그런 다음 모듈을 다른 값으로 다시 합성할 필요 없이 런타임 동안 ``my_wire`` 의 값을 변경할 수 있습니다.

Enabling PlusArg Synthesis
----------------------------

plusarg를 합성하려면 먼저 Rocket Chip ``plusarg_reader`` 모듈을 직접 사용해야 합니다:

.. code-block:: scala

    import freechips.rocketchip.util._

    // Rocket Chip 소스 코드에서 plusarg_reader의 API를 참조하십시오.
    // 이것은 'set_my_wire' 이름, 기본값 '0', 및 폭 '32'를 가진 plusarg를 추가합니다.
    val my_plusarg_module = Module(new plusarg_reader("set_my_wire=%d", 0, "Description", 32))
    val my_wire = my_plusarg_module.io.out

그런 다음 다음과 같이 Chisel 소스 코드에서 캡처하려는 특정 plusargs를 주석으로 추가할 수 있습니다:

.. code-block:: scala

    midas.targetutils.PlusArg(my_plusarg_module)

컴파일하는 동안 Golden
Gate는 합성한 plusargs의 수를 출력합니다. 타겟의 생성된 헤더(``FireSim-generated.const.h``)에서 Golden Gate가 합성한 각 plusargs에 대한 메타데이터를 찾을 수 있습니다. 이는 bridge 드라이버에 인수로 전달되며, FireSim 드라이버에서 자동으로 인스턴스화됩니다.

Runtime Arguments
---------------------------

기본적으로, plusarg는 주석이 달린 ``plusarg_reader`` 모듈에서 지정된 기본값으로 설정됩니다.
이 값을 변경하려면 시뮬레이션 시작 시 제공할 새로운 값을 동일한 이름의 런타임 인수로 직접 호출할 수 있습니다.

예:

**+set_my_wire=50**
    시뮬레이션 시작 시 값을 '50'으로 설정합니다.

이 값을 ``config_runtime.yaml`` 의 ``target_config`` 의 ``plusarg_passthrough`` 필드에 설정할 수 있습니다.