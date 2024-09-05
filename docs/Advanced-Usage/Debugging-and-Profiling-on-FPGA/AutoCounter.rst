.. _autocounter:

AutoCounter: Profiling with Out-of-Band Performance Counter Collection  
========================================================================

FireSim은 카운터를 사용하여 시뮬레이션된 CPU의 아키텍처 및 마이크로아키텍처 상태를 실행 과정 동안 가시화할 수 있습니다. 이러한 카운터는 프로세서 제조업체가 제공하는 성능 카운터 및 아키텍처 시뮬레이터가 제공하는 일반적인 카운터와 유사합니다.

이 기능은 AutoCounter 기능(ASPLOS 2020에서 발표된 `FirePerf 논문 <https://sagark.org/assets/pubs/fireperf-asplos2020.pdf>`_ 에서 소개됨)을 통해 제공되며, 프로파일링 및 디버깅에 사용될 수 있습니다. AutoCounter는 시뮬레이션에서만 카운터를 삽입하기 때문에(타겟 수준의 성능 카운터와는 달리) 이러한 카운터는 샘플링 빈도와 상관없이 시뮬레이션된 머신의 동작에 영향을 미치지 않습니다.

Chisel Interface  
----------------

AutoCounter는 `midas.targetutils` 패키지의 ``PerfCounter`` 객체를 사용하여 임의의 카운터를 추가할 수 있도록 합니다. PerfCounter 카운터는 두 가지 모드 중 하나로 추가할 수 있습니다:

1. ``Accumulate`` 모드: 표준 ``PerfCounter.apply`` 메서드를 사용합니다. 여기서 주석이 달린 UInt(1비트 이상)는 64비트 누산 레지스터에 추가됩니다. 타겟은 N비트의 UInt로 취급되며, 사이클당 [0, 2^n - 1] 값으로 카운터를 증가시킵니다.
2. ``Identity`` 모드: ``PerfCounter.identity`` 메서드를 사용합니다. 여기서 주석이 달린 UInt는 직접 샘플링됩니다. 이는 누산기와 유사하지 않은 값을 주석으로 달기 위해 사용할 수 있으며(예: PC), 타겟 자체에서 더 복잡한 계측 로직을 정의할 수 있습니다.

아래는 PerfCounter를 사용하는 예제입니다:

.. code-block:: scala

    // 표준 불리언 이벤트. 로컬 클럭 사이클마다 1 또는 0으로 증가합니다.
    midas.targetutils.PerfCounter(en_clock, "gate_clock", "Core clock gated")

    // 멀티비트 예제. 코어가 사이클당 세 개의 명령어를 완료할 수 있는 경우, 이를 두 비트 단위로 인코딩합니다.
    // 추가 비트폭은 괜찮지만, UInt로의 인코딩(예: pop count 수행)은 사용자가 직접 해야 합니다.
    midas.targetutils.PerfCounter(insns_ret, "iret", "Instructions retired")

    // Identity 값. 주의: 여기서 PC는 64비트 이하이어야 합니다.
    midas.targetutils.PerfCounter.identity(pc, "pc", "The value of the program counter at the time of a sample")

자세한 내용은 `PerfCounter Scala API docs <https://fires.im/firesim/latest/api/midas/targetutils/PerfCounter$.html>`_ 을 참조하십시오.

Enabling AutoCounter in Golden Gate  
-------------------------------------

기본적으로 주석이 달린 이벤트는 AutoCounter로 합성되지 않습니다. 디자인을 컴파일할 때 AutoCounter를 활성화하려면 ``WithAutoCounter`` 구성을 ``PLATFORM_CONFIG`` 에 추가하십시오. 컴파일 중 Golden Gate는 카운터를 생성하는 신호를 출력합니다.

Rocket Chip Cover Functions  
------------------------------

Cover 함수는 Rocket Chip 제너레이터 리포지토리에서 다양한 신호에 적용되어 RTL에서 관심 지점을 표시합니다 (즉, 흥미로운 신호들). 도구는 이러한 신호를 원하는 방식으로 처리하기 위해 Cover 함수를 구현할 수 있습니다. FireSim에서는 이러한 함수를 자동으로 카운터를 생성하는 훅으로 사용할 수 있습니다.

Cover 함수가 Rocket Chip 코드 (및 다른 코드 리포지토리) 전반에 걸쳐 포함되어 있기 때문에, AutoCounter는 모듈 단위로 필터링 메커니즘을 제공합니다. 따라서 선택된 모듈 내에서만 Cover 함수가 카운터를 생성합니다.

필터링된 모듈은 두 가지 방법 중 하나로 지정할 수 있습니다:

1. Cover 함수가 AutoCounter로 변환되어야 하는 모듈에 첨부된 주석을 사용합니다. 주석에는 디자인의 임의 모듈을 가리킬 수 있는 ``ModuleTarget`` 이 필요합니다. 또는 현재 모듈을 다음과 같이 주석 처리할 수 있습니다:

.. code-block:: scala

  class SomeModule(implicit p: Parameters) extends Module
  {
    chisel3.experimental.annotate(AutoCounterCoverModuleAnnotation(
        Module.currentModule.get.toTarget))
  }

2. 모듈 이름 목록이 포함된 입력 파일을 사용합니다. 이 입력 파일의 이름은 ``autocounter-covermodules.txt`` 이며, 새 줄로 구분된 모듈 이름 목록이 포함되어 있습니다 (쉼표는 사용하지 않음).

.. _autocounter-runtime-parameters:

AutoCounter Runtime Parameters  
---------------------------------

AutoCounter는 현재 ``config_runtime.yaml`` 파일의 ``autocounter:`` 섹션에 정의된 하나의 런타임 구성 가능한 매개변수를 사용합니다. ``read_rate`` 매개변수는 카운터를 읽어야 하는 주기를 정의하며, 기본 타겟 클럭 (ClockBridge가 생성한 클럭 0)의 타겟 사이클로 측정됩니다. 따라서 ``read_rate`` 가 100으로 정의되고 타일 주파수가 기본 클럭의 2배인 경우(예: 언코어를 구동하는 주파수), 시뮬레이터는 200 코어 클럭 사이클마다 카운터 값을 읽고 출력합니다. 코어 도메인 클럭이 기본 클럭인 경우, 매 100 사이클마다 수행됩니다. 기본적으로 ``read_rate`` 는 0 사이클로 설정되어 AutoCounter가 비활성화됩니다.

.. code-block:: yaml

   autocounter:
       # 100 사이클마다 카운터를 읽습니다
       read_rate: 100


.. Note:: AutoCounter는 모든 카운터를 샘플링하기 위해 두 번의 (차단) MMIO 읽기(각 읽기는 EC2 F1에서 약 O(100) ns 소요)가 필요한 거친 그레인 관측 메커니즘으로 설계되었습니다. 따라서 O(10000) 사이클 미만의 간격으로 샘플링하면 많은 수의 카운터에 대해 시뮬레이션 성능에 악영향을 미칠 수 있습니다. 더 세밀한 간격으로 카운터를 읽어야 하는 경우, 합성 가능한 printf를 사용하는 것이 좋습니다.

AutoCounter CSV Output Format  
---------------------------------

AutoCounter 출력 파일은 시뮬레이터가 호출된 작업 디렉토리에 생성된 CSV 형식입니다(메타 시뮬레이터에도 적용됨). 기본 이름은 ``AUTOCOUNTERFILE<i>.csv`` 이며, 클럭 도메인별로 하나씩 생성됩니다. 아래는 ``N`` 기본 클럭 사이클의 샘플링 주기를 가정한 CSV 출력 형식입니다.

.. csv-table:: AutoCounter CSV Format
    :file: autocounter-csv-format.csv

컬럼 설명:

#. 첫 번째 두 컬럼 이후의 각 컬럼은 클럭 도메인의 PerfCounter 인스턴스에 해당합니다.
#. 헤더 이후 첫 번째 컬럼(열 0)은 샘플의 기본 클럭 사이클에 해당합니다.
#. ``local_cycle`` 카운터(컬럼 1)는 항상 활성화된 단일 비트 이벤트로 구현되며, 타겟이 리셋 상태일 때도 증가합니다.

행 설명:

#. 헤더 행 0: AutoCounter CSV 형식 버전, 정수형.
#. 헤더 행 1: 클럭 도메인 정보.
#. 헤더 행 2: PerfCounter에 제공된 레이블 파라미터, 인스턴스 경로가 접미사로 추가됨.
#. 헤더 행 3: PerfCounter에 제공된 설명 파라미터. 인용됨.
#. 헤더 행 4: 타겟에서 주석이 달린 필드의 비트폭.
#. 헤더 행 5: 누산 레지스터의 비트폭. 구성 불가능하지만 롤오버 예상 시점을 명확히 함.
#. 헤더 행 6: 누산 스킴을 나타냅니다. "Identity" 또는 "Accumulate"일 수 있습니다.
#. 샘플 행 0: 누산 레지스터의 비트폭으로 샘플링된 값.
#. 샘플 행 k: 위와 동일, k * N 기본 사이클 후

Using TracerV Trigger with AutoCounter  
-----------------------------------------

시뮬레이션에서 특정 관심 영역에서만 AutoCounter 결과를 수집하려면 TracerV 트리거와 통합된 AutoCounter를 사용할 수 있습니다. 자세한 내용은 :ref:`tracerv-trigger` 섹션을 참조하십시오.


AutoCounter using Synthesizable Printfs  
------------------------------------------------

Golden Gate의 AutoCounter 변환에는 이벤트 기반 모드가 포함되어 있으며, 이는 전용 브리지를 통해 주기적으로 샘플링하는 대신, `합성 가능한 Printfs` (:ref:`printf-synthesis` 참조)를 사용하여 카운터 결과를 `업데이트될 때` 바로 출력할 수 있습니다. 이 모드는 ``WithAutoCounterCoverPrintf`` 구성을 ``PLATFORM_CONFIG`` 에 추가하여 활성화할 수 있으며, ``WithAutoCounterCover`` 대신 사용할 수 있습니다. 선택된 이벤트 모드에 따라 Printf의 런타임 동작은 다음과 같습니다:

* `Accumulate`: 값이 0이 아닌 경우 카운터가 증가할 때마다 로컬 사이클 수와 새로운 카운터 값이 출력됩니다. 이로 인해 단조롭게 증가하는 값들의 시리즈가 출력됩니다.
* `Identity`: 주석이 달린 타겟이 전이될 때마다 로컬 사이클 수와 새로운 값이 출력됩니다. 따라서 타겟이 매 사이클마다 전이되는 경우 매 사이클마다 Printf 트래픽이 발생합니다.

이 모드는 카운터의 시간적으로 더 세밀한 관측을 위해 유용할 수 있습니다. 카운터 값은 다른 합성 가능한 printf와 동일한 출력 스트림으로 출력됩니다. 이 모드는 카운터당 상당히 더 많은 FPGA 자원을 사용하며, 매 사이클 카운터가 증가할 때마다 출력을 생성하기 때문에 상당한 양의 DMA 대역폭을 사용할 수 있어 시뮬레이션 성능에 영향을 미칠 수 있습니다(증가된 FMR).

Reset & Timing Considerations  
------------------------------

* 로컬 리셋 상태이거나 ``GlobalResetCondition`` 이 어설트된 상태에서 제공되는 이벤트와 Identity 값은 모두 0으로 처리됩니다. 마찬가지로 리셋 상태에서 활성화될 수 있는 Printf도 마스킹 처리됩니다.
* 느린 클럭 도메인에서의 샘플링 주기는 기본 클럭 도메인의 주기에서 소수점 이하를 절삭한 나눗셈을 사용하여 계산됩니다. 따라서 기본 클럭 주기가 정수로 나눌 수 없는 경우, 느린 클럭 도메인에서의 샘플은 기본 클럭 도메인 샘플과 점차적으로 상이한 페이즈로 진행됩니다. 모든 경우에서 "local_cycle" 열이 샘플 시간의 가장 정확한 측정값입니다.
