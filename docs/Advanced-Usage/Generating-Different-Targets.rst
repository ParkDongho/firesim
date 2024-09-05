Targets
=======

FireSim은 Rocket SoC generator와 같은 Chisel generator에서 생성된 RTL을 변환하여 SoC 모델을 생성합니다. :ref:`rtl-restrictions` 에 설명된 조건에 따라 Chisel로 생성할 수 있는 경우 FireSim에서 시뮬레이션할 수 있습니다.

.. _rtl-restrictions:

Restrictions on Target RTL
--------------------------

Golden Gate의 현재 제한 사항은 FireSim에서 사용할 수 있는 (FIR)RTL에 대해 다음과 같은 제약을 둡니다:

#. 최상위 모듈에는 입력이나 출력이 없어야 합니다. 입력 자극과 출력 캡처는 target RTL 또는 target-to-host Bridges를 사용하여 구현해야 합니다.
#. 모든 target 클록은 단일 ``RationalClockBridge`` 에 의해 생성되어야 합니다.
#. 블랙박스는 입력 클록을 게이트된 동등한 클록으로 교체하여 시뮬레이션 시간을 중지할 수 있도록 "clock-gateable"해야 합니다.

   a. 따라서, target clock-gating은 블랙박스 프리미티브를 사용하여 구현할 수 없으며, 대신 게이트된 클록 도메인의 모든 상태 요소에 클록 인에이블을 추가하여 모델링해야 합니다(즉, 레지스터에 인에이블 또는 피드백 멀티플렉서를 추가하여 조건부로 업데이트를 차단하고 메모리의 쓰기 인에이블을 게이팅하여야 합니다).
#. 비동기 리셋은 Rocket Chip의 블랙박스 비동기 리셋을 사용하여만 구현해야 합니다. 이는 FIRRTL 변환을 통해 동기식으로 리셋되는 레지스터로 교체됩니다.

.. _verilog-ip:

--------------------
Including Verilog IP
--------------------

FireSim은 이제 표준 ``BlackBox`` `Chisel 인터페이스 <https://github.com/freechipsproject/chisel3/wiki/Blackboxes>`_ 를 사용하여 Verilog IP를 통합하는 target 디자인을 지원합니다. Rocket Chip을 기반으로 한 target 시스템에 Verilog IP를 추가하는 방법에 대한 예는 Chipyard 문서의 `Incorporating Verilog Blocks <https://chipyard.readthedocs.io/en/latest/Customization/Incorporating-Verilog-Blocks.html>`_ 섹션을 참조하십시오.

#. 변환이 작동하려면 Verilog IP를 감싸는 Chisel Blackbox는 안전하게 클록-게이팅할 수 있는 입력 클록을 가져야 합니다.
#. 디커플링된 시뮬레이터를 생성하는 컴파일러("FAME Transform")는 target 디자인 내의 이러한 블랙박스를 자동으로 인식합니다.
#. 컴파일러는 Verilog IP의 각 클록을 자동으로 게이팅하여 시뮬레이터의 나머지 부분과 동기적으로 진행되도록 보장합니다.
#. 위의 제약 조건에 따라, 표준 Chisel Blackbox 인터페이스를 사용하여 target 디자인 내 어디에서나 Verilog 모듈을 인스턴스화할 수 있습니다.

----------------------------
Multiple Clock Domains
----------------------------

FireSim은 여러 클록 도메인이 있는 target을 시뮬레이션하는 것을 지원할 수 있습니다. 앞서 언급했듯이, 모든 클록은 단일 ``RationalClockBridge`` 를 사용하여 생성되어야 합니다. 대부분의 사용자에게는 Chipyard에서 기본 제공되는 FireSim 테스트 하네스가 충분하지만, 사용자 정의 테스트 하네스를 정의해야 하는 경우 ``RationalClockBridge`` 를 다음과 같이 인스턴스화하십시오:

.. literalinclude:: ../../sim/src/main/scala/midasexamples/TrivialMulticlock.scala
    :language: scala
    :start-after: DOC include start: RationalClockBridge Usage
    :end-before: DOC include end: RationalClockBridge Usage

추가 문서는 소스 파일(``sim/midas/src/main/scala/midas/widgets/ClockBridge.scala``)에서 찾을 수 있습니다.

=================
The Base Clock
=================
관례에 따라, target 시간은 `base clock` 의 주기(사이클)로 지정됩니다. `base clock` 은 클록 비율(승수/제수)이 1인 ``RationalClockBridge`` 의 클록으로 정의됩니다. 시스템에서 가장 빠른 클록을 base clock으로 설정하는 것이 좋지만, 마이크로프로세서 기반 시스템에서는 core 클록 주파수에 해당할 가능성이 높습니다. 이는 필수 사항은 아닙니다.

============
Limitations:
============
* FireSim이 시뮬레이션할 수 있는 target 클록의 수는 각 target 클록을 독립적으로 클록-게이팅하는 데 사용되는 호스트 FPGA의 BUFGCE 리소스 수에 의해 제한됩니다.
* ``RationalClockBridge`` 라는 이름에서 알 수 있듯이, 이 모듈은 합리적으로 관련된 클록만 생성할 수 있습니다. 구체적으로, 모든 요청된 주파수는 다음과 같은 형태로 표현될 수 있어야 합니다:

  .. math::
    f_{i} = \frac{f_{lcm}}{k_{i}}

  여기서,
    * :math:`f_{i}` 는 :math:`i^{th}` 클록의 원하는 주파수입니다.
    * :math:`f_{lcm}`, 은 모든 요청된 주파수의 최소공배수입니다.
    * :math:`k_{i}` 는 16비트 부호 없는 정수입니다.

  임의의 주파수는 충분히 정밀한 유리수 배수를 사용하여 모델링할 수 있습니다. Golden Gate는 지원할 수 없는 주파수가 있을 경우 컴파일 시 오류를 발생시킵니다.
* 각 브리지 모듈은 단일 클록 도메인 내에 완전히 있어야 합니다. 브리지의 target 인터페이스는 단일 입력 클록을 포함해야 하며, 브리지 모듈의 모든 입력과 출력은 동일한 클록 도메인의 레지스터에 의해 각각 래치되고 런치되어야 합니다.

.. _generating-different-targets:

Target-Side FPGA Constraints
----------------------------

FireSim은 target의 Chisel에서 문자열 스니펫으로부터 Xilinx Design Constraints (XDC)를 생성하는 유틸리티를 제공합니다. Golden Gate는 이러한 주석을 수집하여 합성 및 구현을 위한 별도의 xdc 파일을 생성합니다. FPGA 컴파일에 사용되는 출력 파일의 전체 목록은 :ref:`fpga-build-files` 를 참조하십시오.

-----------------------------
RAM Inference Hints
-----------------------------

Vivado는 일반적으로 FireSim에서 생성된 RTL로부터 임베디드 메모리를 추론하는 데 있어 합리적인 성능을 보이지만, 몇 가지 경우에는 보완이 필요할 수 있습니다. 예를 들어:

* BRAM 리소스가 부족한 경우, BRAM으로 추론될 메모리를 URAM으로 사용하고 싶을 수 있습니다.
* Vivado가 URAM으로 흡수할 파이프라인 레지스터를 찾을 수 없거나 target에 존재하지 않는 경우, 다음과 같은 경고를 받을 수 있습니다::

    [Synth 8-6057] Memory: "<memory>" defined in module: "<module>" implemented as Ultra-Ram
    has no pipeline registers. It is recommended to use pipeline registers to achieve high
    performance.

Golden Gate는 모듈 계층 구조를 광범위하게 수정하기 때문에, 이러한 메모리를 Chisel 소스에서 주석으로 표시하여 메모리 인스턴스와 함께 힌트가 이동하도록 하는 것이 매우 바람직합니다. 이는 정적 XDC 사양의 와일드카드/글롭 매치에 의존하는 것보다 더 견고한 대안입니다.

Chisel 메모리는 다음과 같이 *in situ* 로 주석을 달 수 있습니다:

.. literalinclude:: ../../sim/midas/targetutils/src/test/scala/RAMStyleHintSpec.scala
    :language: scala
    :start-after: DOC include start: Basic RAM Hint
    :end-before: DOC include end: Basic RAM Hint

또는, Scala 클래스 계층 구조의 공개 멤버를 순회하여 하위 모듈의 메모리에 주석을 달 수 있습니다. 다음은 그 예입니다:

.. literalinclude:: ../../sim/midas/targetutils/src/test/scala/RAMStyleHintSpec.scala
    :language: scala
    :start-after: DOC include start: RAM Hint From Parent
    :end-before: DOC include end: RAM Hint From Parent

이러한 주석은 target, 브리지 모듈 및 내부 FireSim RTL 어디에서나 배포할 수 있습니다. 결과 제약 조건은 Golden Gate가 생성한 합성 xdc 파일에 나타나야 합니다. 자세한 내용은 ``RAMStyleHint`` 의 ScalaDoc을 참조하거나 소스를 읽어보십시오:
:gh-file-ref:`sim/midas/targetutils/src/main/scala/midas/xdc/RAMStyleHint.scala`.

Provided Target Designs
-----------------------

-----------------------------
Target Generator Organization
-----------------------------

FireSim은 다양한 target 유형에 대해 각기 다른 `projects` 를 제공합니다. 각 프로젝트는 Golden Gate를 호출하는 자체 Chisel generator, 자체 드라이버 소스 및 ``sim/`` 에 위치한 Make 기반 빌드 시스템에 플러그인되는 Makefrag을 포함합니다. 이러한 프로젝트는 다음과 같습니다:
1. **firesim** (Default): Rocket Chip 기반 타겟들입니다. 여기에는 BOOM 또는 Rocket 파이프라인을 포함한 타겟이 있으며, Rocket Chip generator를 사용하여 SoC를 구축하려는 경우 이 프로젝트가 시작점이 되어야 합니다.
2. **midasexamples**: Golden Gate 예제 디자인입니다. :gh-file-ref:`sim/src/main/scala/midasexamples` 에 위치한 이 프로젝트는 GCD와 같은 간단한 Chisel 회로를 포함하며 Golden Gate 사용법을 설명합니다. 새로운 Golden Gate 기능을 도입할 때 유용한 테스트 케이스입니다.
3. **bridges**: firesim-lib bridges를 테스트하는 프로젝트입니다. 이 프로젝트는 더 많은 종속성과 더 복잡한 논리를 포함하며 `midasexamples` 보다 더 복잡합니다.
4. **fasedtests**: FASED 메모리 시스템 타이밍 모델의 통합 테스트를 위한 디자인을 포함합니다.

Projects have the following directory structure:

.. code-block:: text

    sim/
    ├-Makefile # FireSim이 최상위 저장소인 프로젝트를 위한 최상위 makefile
    ├-Makefrag # 타겟에 무관한 makefrag으로, 드라이버와 RTL 시뮬레이터를 생성하기 위한 레시피를 포함
    ├-src/main/scala/{target-project}/
    │                └─Makefrag # 타겟 특정 Make 변수와 레시피 정의
    ├-src/main/cc/{target-project}/
    │             ├─{driver-csrcs}.cc # 타겟의 시뮬레이션 드라이버 및 소프트웨어 모델 소스
    │             └─{driver-headers}.h
    └-src/main/makefrag/{target-project}/
                         ├─Generator.scala # 타겟 RTL을 생성하고 Golden Gate를 호출하는 메인 클래스 포함
                         └─{other-scala-sources}.scala

----------------------------
Specifying A Target Instance
----------------------------

특정 타겟 인스턴스를 생성하려면 빌드 시스템에서 다섯 가지 Make 변수를 사용합니다:

1. ``TARGET_PROJECT``: Makefile(``sim/Makefile``)을 타겟 특정 Makefrag에 연결합니다. 이 Makefrag는 생성 및 메타 시뮬레이션 소프트웨어 레시피를 정의합니다. 기본 타겟 프로젝트의 Makefrag는 ``sim/src/main/makefrag/firesim`` 에 정의되어 있습니다.

2. ``DESIGN``: 생성할 최상위 Chisel 모듈의 이름(Scala 클래스 이름)을 지정합니다. 이는 FireChip Chipyard generator에서 정의됩니다.

3. ``TARGET_CONFIG``: 타겟 디자인의 generator가 사용하는 ``Config`` 인스턴스를 지정합니다. 기본 firesim 타겟 프로젝트의 사전 정의된 구성은 FireChip Chipyard generator에서 설명되어 있습니다.

4. ``PLATFORM_CONFIG``: Golden Gate에서 사용되는 ``Config`` 인스턴스를 지정하여 컴파일러 수준 및 호스트-랜드 파라미터(예: 어서션 합성 활성화 또는 다중 포트 RAM 최적화 여부 등)를 지정합니다. 일반적인 플랫폼 구성은 ``firesim-lib/sim/src/main/scala/configs/CompilerConfigs.scala`` 에서 설명됩니다.

5. ``PLATFORM``: Makefile(``sim/Makefile``)을 빌드할 FPGA 플랫폼에 연결합니다. 이는 :gh-file-ref:`platforms` 에서 정의된 플랫폼과 일치해야 합니다.

``TARGET_CONFIG`` 및 ``PLATFORM_CONFIG`` 는 ``Config`` 인스턴스를 구성하는 데 사용되는 문자열입니다. 이 인스턴스는 RocketChip의 파라미터화 시스템(``Config``)에서 파생되며, 자세한 내용은 `CDE repo <https://github.com/chipsalliance/cde>`_ 를 참조하십시오. 이 문자열의 형식은 "{..._}{<Class Name>\_}<Class Name>" 와 같습니다. 마지막 기본 클래스 이름만 필수이며, "_" 로 시작하는 클래스 이름은 복합 Config 인스턴스를 만드는 데 사용됩니다.

.. code-block:: scala

    // TARGET_CONFIG=Base로 지정
    class Base extends Config((site, here, up) => {...})
    class Override1 extends Config((site, here, up) => {...})
    class Override2 extends Config((site, here, up) => {...})
    // TARGET_CONFIG=Compound로 지정
    class Compound extends Config(new Override2 ++ new Override1 ++ new Base)
    // 또는 TARGET_CONFIG=Override2_Override1_Base로 지정
    // 정의되지 않은 클래스도 이렇게 지정할 수 있습니다. 예: TARGET_CONFIG=Override2_Base

이 방식으로 인스턴스를 생성하려는 모든 경우에 대해 Config 클래스를 정의할 필요가 없어지므로, 파라미터화 공간을 스윕하는 데 매우 유용합니다.

**Config의 우선순위는 문자열의 왼쪽에서 오른쪽으로 갈수록 낮아집니다**. 기존 Config에 Config를 추가하는 것은 상위 우선순위 Config에서 이미 설정되지 않은 필드에만 영향을 미칩니다. 예를 들어, "BaseF1Config_SetFieldAtoX"는 "BaseF1Config_SetFieldAtoX_SetFieldAtoY"와 동일합니다.

특정 Config가 ``Field``를 어떻게 해결하는지 직관적이지 않을 수 있습니다. 복잡한 복합 ``Config``의 경우 이를 확인하는 가장 정확한 방법은 Scala REPL을 열어 원하는 ``Config`` 인스턴스를 생성하고 그 필드를 검사하는 것입니다.

.. code-block:: shell

    $ make sbt # FireSim 인수를 추가하여 SBT의 쉘로 진입

    sbt:firechip> console # REPL 실행

    scala> val inst = (new firesim.firesim.FireSimRocketChipConfig).toInstance # 인스턴스 생성

    inst: freechips.rocketchip.config.Config = FireSimRocketChipConfig

    scala> import freechips.rocketchip.subsystem._ # 중요한 필드 가져오기

    import freechips.rocketchip.subsystem.RocketTilesKey

    scala> inst(RocketTilesKey).size # 코어 수 조회

    res2: Int = 1

    scala> inst(RocketTilesKey).head.dcache.get.nWays # L1 D$ 연관도 조회

    res3: Int = 4


Rocket Chip Generator-based SoCs (firesim project)
--------------------------------------------------

위의 Make 변수를 사용하여 기본 Rocket Chip 기반 타겟 프로젝트에서 다양한 타겟을 생성하는 예를 제공합니다.

-----------------
Rocket-based SoCs
-----------------

세 가지 디자인 클래스는 Rocket 스칼라 인오더 파이프라인을 사용합니다.

싱글 코어, Rocket 파이프라인 (기본값)

.. code-block:: bash

    make TARGET_CONFIG=FireSimRocketConfig


싱글 코어, Rocket 파이프라인, 네트워크 인터페이스 포함

.. code-block:: bash

    make TARGET_CONFIG=WithNIC_FireSimRocketChipConfig


쿼드 코어, Rocket 파이프라인

.. code-block:: bash

    make TARGET_CONFIG=FireSimQuadRocketConfig


---------------
BOOM-based SoCs
---------------

BOOM(`Berkeley Out-of-Order Machine <https://github.com/ucb-bar/riscv-boom>`_) 슈퍼스칼라 비순차 파이프라인도 Rocket 파이프라인을 사용하는 동일한 디자인 클래스에서 사용할 수 있습니다. TARGET_CONFIG만 아래와 같이 변경하면 됩니다:

싱글 코어 BOOM

.. code-block:: bash

    make TARGET_CONFIG=FireSimLargeBoomConfig

싱글 코어 BOOM, 네트워크 인터페이스 포함

.. code-block:: bash

    make TARGET_CONFIG=WithNIC_FireSimBoomConfig


----------------------------------------------------------
Generating A Different FASED Memory-Timing Model Instance
----------------------------------------------------------

Golden Gate의 메모리 타이밍 모델 생성기, FASED는 다양한 DRAM 모델 인스턴스를 제공할 수 있습니다. 여기 몇 가지 예시를 제공합니다. 이러한 타겟은 ``DESIGN=FireSim PLATFORM_CONFIG=BaseF1Config`` 로 설정된 Makefile 기본값을 사용합니다.

쿼드 랭크 DDR3 선착순 메모리 액세스 스케줄러

.. code-block:: bash

    make TARGET_CONFIG=DDR3FRFCFS_FireSimRocketConfig


위와 동일하지만, 4 MiB의 최종 레벨 캐시 모델이 있는 경우(최대 시뮬레이션 가능한 용량)

.. code-block:: bash

    make TARGET_CONFIG=DDR3FRFCFSLLC4MB_FireSimRocketConfig

FASED *timing-model* 구성은 Target의 FIRRTL에서 FASED Bridges로 전달되므로 ``TARGET_CONFIG`` 앞에 추가되어야 합니다.


Midas Examples (midasexamples project)
--------------------------------------------------
이 프로젝트는 몇 가지 장난감 타겟 디자인을 생성할 수 있습니다(``DESIGN`` 변수를 사용하여 설정). 이 디자인들은 각각 자체 Chisel 소스 파일을 가지고 있으며 Golden Gate의 기능을 보여줍니다.

몇 가지 주목할 만한 예시는 다음과 같습니다:

#. ``GCD``: 하드웨어의 "Hello World!"입니다.
#. ``WireInterconnect``: Golden Gate를 사용하여 조합 경로를 모델링하는 방법을 보여줍니다.
#. ``PrintfModule``: 합성 가능한 printf를 보여줍니다.
#. ``AssertModule``: 합성 가능한 어서션을 보여줍니다.

타겟을 생성하려면 Make 변수를 ``TARGET_PROJECT=midasexamples`` 로 설정하여 올바른 프로젝트 Makefrag가 소싱되도록 합니다.

--------
Examples
--------

GCD midasexample을 생성하려면:

.. code-block:: bash

    make DESIGN=GCD TARGET_PROJECT=midasexamples

FASED Tests (fasedtests project)
--------------------------------------------------
이 프로젝트는 현재 FireSim 타겟보다 AXI4-메모리 슬레이브에 훨씬 더 많은 대역폭을 구동할 수 있는 타겟 디자인을 생성합니다. 이러한 디자인들은 FASED 인스턴스의 통합 및 스트레스 테스트에 사용됩니다.

--------
Examples
--------

합성 가능한 AXI4Fuzzer(로켓 칩의 TL fuzzer를 기반으로 함)를 생성하여 DDR3 FR-FCFS 기반 FASED 인스턴스를 구동합니다.

.. code-block:: bash

    make TARGET_PROJECT=fasedtests DESIGN=AXI4Fuzzer TARGET_CONFIG=FRFCFSConfig

위와 동일하나 1천만 건의 트랜잭션을 인스턴스를 통해 구동하도록 구성합니다.

.. code-block:: bash

    make TARGET_PROJECT=fasedtests DESIGN=AXI4Fuzzer TARGET_CONFIG=NT10e7_FRFCFSConfig
