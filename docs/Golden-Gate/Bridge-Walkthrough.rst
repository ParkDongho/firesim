.. _bridge-walkthrough:

Bridge Walkthrough
==================
In this section, we'll walkthrough a simple Target-to-Host bridge, the UARTBridge, provided with FireSim
to demonstrate how to integrate your own. The UARTBridge uses host-MMIO to model
a UART device.

Reading the Bridges section is a prerequisite to reading these sections.

UART Bridge (Host-MMIO)
-----------------------

Source code for the UART Bridge lives in the following directories:

.. code-block:: text

    sim/
    ├-firesim-lib/src/main/
    │                 ├-scala/bridges/UARTBridge.scala # Target-Side Bridge and BridgeModule Definitions
    │                 ├-cc/brides/uart.cc # Bridge Driver source
    │                 └-cc/brides/uart.h  # Bridge Driver header
    ├-src/main/cc/firesim/firesim_top.cc  # Driver instantiation in the main simulation driver
    └-src/main/makefrag/firesim/          # Target-specific build rules
        ├ build.mk                        # Definition of the Chisel elaboration step
        ├ config.mk                       # Target-specific configuration and path setup
        ├ driver.mk                       # Build rules for the driver
        └ run.mk                          # Custom run commands for meta-simulation

Target Side
+++++++++++
새로운 브리지를 설계할 때 첫 번째 작업은 타겟 사이드를 구현하는 것입니다. UART의 경우, Bridge를 확장하는 Chisel BlackBox [#]_ 를 정의했습니다.
이 BlackBox를 인스턴스화하고 UART IO에 상위 레벨의 칩에 연결합니다. 먼저 Bridge의 타겟 사이드 인터페이스를 캡처하는 클래스를 정의합니다:

.. literalinclude:: ../../sim/firesim-lib/src/main/scala/bridges/UARTBridge.scala
    :language: scala
    :start-after: DOC include start: UART Bridge Target-Side Interface
    :end-before: DOC include end: UART Bridge Target-Side Interface


.. [#] 비-BlackBox Chisel Module을 확장할 수도 있지만, 포함된 Chisel 소스는 Golden Gate에 의해 제거됩니다. 다른 시뮬레이션 백엔드에서 Bridge의 합성 가능한 모델을 포함하려거나
    호스트 측에 모델링하고자 하는 더 큰 RTL 청크를 래핑하려는 경우 이를 수행할 수 있습니다.

여기에서 호스트 사이드 BridgeModule에 추가 메타데이터를 전달하는 case class를 정의합니다. UART의 경우, 이는 단순히 baudrate를 생성하는 데 필요한 클럭 분할입니다:

.. literalinclude:: ../../sim/firesim-lib/src/main/scala/bridges/UARTBridge.scala
    :language: scala
    :start-after: DOC include start: UART Bridge Constructor Arg
    :end-before: DOC include end: UART Bridge Constructor Arg

마지막으로 실제 타겟 사이드 모듈(특히 BlackBox)을 정의합니다:

.. literalinclude:: ../../sim/firesim-lib/src/main/scala/bridges/UARTBridge.scala
    :language: scala
    :start-after: DOC include start: UART Bridge Target-Side Module
    :end-before: DOC include end: UART Bridge Target-Side Module

타겟 사이드 모듈을 더 쉽게 인스턴스화할 수 있도록 선택적 companion object도 정의했습니다:

.. literalinclude:: ../../sim/firesim-lib/src/main/scala/bridges/UARTBridge.scala
    :language: scala
    :start-after: DOC include start: UART Bridge Companion Object
    :end-before: DOC include end: UART Bridge Companion Object

이로써 타겟 사이드 정의가 완료되었습니다.

Host-Side BridgeModule
++++++++++++++++++++++

파일의 나머지는 호스트 사이드 BridgeModule 정의에 할애됩니다. 여기서는 타겟에서 생성된 토큰을 처리하고
브리지 드라이버에 메모리 맵 인터페이스를 노출해야 합니다.

클래스 상단을 검사합니다:

.. literalinclude:: ../../sim/firesim-lib/src/main/scala/bridges/UARTBridge.scala
    :language: scala
    :start-after: DOC include start: UART Bridge Header
    :end-before: DOC include end: UART Bridge Header


이후 대부분은 UART의 타이밍을 모델링하는 역할을 합니다.
브리지 설계자로서 토큰을 처리하는 데 필요한 만큼의 호스트 사이클을 자유롭게 사용할 수 있습니다.
이와 같은 더 간단한 모델에서는 단일 사이클로 작동하는 논리를 작성하되 필요한 토큰이 사용할 수 있을 때 어설션되는
“fire” 신호를 사용하여 상태 업데이트를 제어하는 것이 가장 쉬운 경우가 많습니다.

이제 브리지 드라이버에서 MMIO를 사용하여 액세스할 수 있는 시뮬레이터의 메모리 맵에 레지스터를 추가하는 방법을 보기 위해 끝으로 넘어갑니다:

.. literalinclude:: ../../sim/firesim-lib/src/main/scala/bridges/UARTBridge.scala
    :language: scala
    :start-after: DOC include start: UART Bridge Footer
    :end-before: DOC include end: UART Bridge Footer


Host-Side Driver
++++++++++++++++

호스트 사이드 정의를 완료하려면 CPU에 호스트된 브리지 드라이버를 정의해야 합니다.
Bridge Drivers는 5개의 가상 메서드를 선언하는 ``bridge_driver_t`` 인터페이스를 확장하며, 구체적인 브리지 드라이버는 이를 구현해야 합니다:

.. literalinclude:: ../../sim/midas/src/main/cc/core/bridge_driver.h
    :language: c++
    :start-after: DOC include start: Bridge Driver Interface
    :end-before: DOC include end: Bridge Driver Interface

Uart 브리지 드라이버의 선언은 :gh-file-ref:`sim/firesim-lib/src/main/cc/bridges/uart.h` 에 있습니다. 아래에 인라인으로 포함되어 있습니다:

.. include:: ../../sim/firesim-lib/src/main/cc/bridges/uart.h
   :code: c++

드라이버 작업의 대부분은 ``tick()`` 메서드에서 수행됩니다. 여기서 드라이버는 BridgeModule을 폴링하고 일부 작업을 수행합니다. 참고로, ``tick`` 이라는 이름은 유물로 남아 있습니다: tick()의 한 번의 호출은 임의의 수의 타겟 사이클에 해당하는 작업을 수행할 수 있습니다. tick은 BridgeModule의 작업을 기다리며 블로킹되지 않도록 하는 것이 중요합니다. 그렇지 않으면 시뮬레이터가 교착 상태에 빠질 수 있습니다.

Build-System Modifications
++++++++++++++++++++++++++

브리지를 추가할 때 마지막으로 고려해야 할 사항은 빌드 시스템입니다. 다른 타겟 RTL과 함께 브리지의 Scala 소스를 호스팅할 수 있어야 합니다: SBT는 런타임 클래스 경로에 해당 클래스가 있는지 확인합니다. 기존 디렉터리 외부에서 브리지 드라이버 소스를 호스팅하는 경우, 타겟 프로젝트 메이크 프래그먼트를 수정하여 포함해야 합니다. 기본 Chipyard/Rocket Chip 기반 프래그먼트는 여기 있습니다:
:gh-file-ref:`sim/src/main/makefrag/firesim`.

여기서 주요 작업은 아래 라인을 수정하여 헤더 파일과 소스 파일을 각각 `driver.mk` 의 ``DRIVER_H`` 와 ``DRIVER_CC`` 에 추가하는 것입니다:

.. literalinclude:: ../../sim/src/main/makefrag/firesim/driver.mk
    :language: make
    :start-after: DOC include start: Bridge Build System Changes
    :end-before: DOC include end: Bridge Build System Changes

이게 전부입니다! 이 시점에서 메타시뮬레이션을 사용하여 소프트웨어 시뮬레이션에서 브리지를 테스트하거나 FPGA에 배포할 수 있어야 합니다.
