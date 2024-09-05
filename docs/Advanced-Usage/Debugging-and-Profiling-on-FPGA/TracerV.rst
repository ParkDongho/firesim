.. _tracerv:

Capturing RISC-V Instruction Traces with TracerV
==================================================

FireSim은 실행 과정에서 목표 CPU의 아키텍처 상태를 주기별로 추적하는 기능을 제공하며, 여기에는 명령어 주소, 원시 명령어 비트, 프리빌리지 레벨, 예외/인터럽트 상태 및 원인, 그리고 유효 신호와 같은 필드가 포함됩니다. 이는 프로파일링이나 디버깅에 유용할 수 있습니다.
**TracerV** 는 이러한 기능을 제공하는 FireSim 브리지입니다. 이 기능은 `FirePerf paper at ASPLOS 2020 <https://sagark.org/assets/pubs/fireperf-asplos2020.pdf>`_ 에서 소개되었습니다.

이 섹션에서는 주로 디버깅 목적으로 이러한 추적을 주기별 형식으로 캡처하는 방법을 자세히 설명합니다.

프로파일링 목적으로 FireSim은 이 데이터를 자동으로 스택 추적으로 변환하고 Flame Graphs를 생성하는 기능도 지원합니다. 이는 :ref:`tracerv-with-flamegraphs` 섹션에서 문서화되었습니다.

.. _tracerv-bridge:

Building a Design with TracerV
-------------------------------

모든 FireChip 디자인에서 TracerV는 기본적으로 포함되어 있습니다. 다른 대상은 추적하고자 하는 각 코어의 RISC-V trace port에 TracerV Bridge를 연결하여 이를 활성화할 수 있습니다(코어당 하나의 브리지가 있어야 합니다). 기본적으로는 주기 번호, 명령어 주소 및 유효 비트만 수집됩니다.

.. _tracerv-enabling:

Enabling Tracing at Runtime
----------------------------

시뮬레이션 성능을 향상시키기 위해, FireSim은 기본적으로 TracerV Bridge에서 데이터를 수집하고 기록하지 않습니다. 수집을 활성화하려면 ``config_runtime.yaml`` 파일의 ``tracing`` 섹션에서 ``enable`` 플래그를 ``no`` 대신 ``yes`` 로 수정하십시오:

.. code-block:: ini

    tracing:
        enable: yes

이제 작업을 실행하면 추적 출력 파일이 F1 인스턴스의 ``sim_slot_<slot #>`` 디렉토리에 ``TRACEFILE-C0`` 라는 이름으로 저장됩니다. ``C0`` 는 시뮬레이션된 SoC의 코어 0을 나타냅니다. 여러 코어가 있는 경우, 각각 고유한 파일(뒤에 ``C1``, ``C2`` 등으로 끝남)을 가지게 됩니다. 모든 TracerV 추적 파일을 관리자에게 복사하려면 작업의 ``.json`` 파일에서 ``common_simulation_outputs`` 또는 ``simulation_outputs`` 에 ``TRACEFILE*`` 을 추가할 수 있습니다. 이러한 선택 사항에 대한 자세한 내용은 :ref:`deprecated-defining-custom-workloads` 섹션을 참조하십시오.

.. _tracerv-output-format:

Selecting a Trace Output Format
---------------------------------

FireSim은 세 가지 추적 출력 형식을 지원하며, 이는 ``config_runtime.yaml`` 파일의 ``tracing`` 섹션에서 ``output_format`` 옵션으로 설정할 수 있습니다:

.. code-block:: ini

   tracing:
       enable: yes

       # Trace output formats. Only enabled if "enable" is set to "yes" above
       # 0 = human readable; 1 = binary (compressed raw data); 2 = flamegraph (stack
       # unwinding -> Flame Graph)
       output_format: 0

아래의 "Interpreting the Trace Result" 섹션에서 이러한 형식에 대한 설명을 참조하십시오.

.. _tracerv-trigger:

Setting a TracerV Trigger
---------------------------

리눅스 기반 작업과 같은 장시간 실행되는 작업의 전체를 추적하는 것은 큰 추적 파일을 생성할 수 있으며 특정 시간 프레임 내의 상태만 신경 쓸 수 있습니다. 따라서 FireSim은 데이터를 수집하기 위한 시작 및 종료 조건을 지정할 수 있는 트리거 조건을 설정할 수 있도록 합니다.

기본적으로 TracerV는 트리거를 사용하지 않으므로 데이터 수집은 주기 0에서 시작하여 시뮬레이션의 마지막 주기에서 종료됩니다. 이를 변경하려면 ``config_runtime.yaml`` 의 ``tracing`` 섹션에서 다음을 수정하십시오. 트리거 유형을 선택하려면 ``selector`` 필드를 사용하고(옵션은 아래에 설명됨), ``start`` 및 ``end`` 필드는 트리거의 시작 및 종료 값을 공급하는 데 사용됩니다.

.. code-block:: ini

   tracing
       enable: yes

       # Trace output formats. Only enabled if "enable" is set to "yes" above
       # 0 = human readable; 1 = binary (compressed raw data); 2 = flamegraph (stack
       # unwinding -> Flame Graph)
       output_format: 0

       # Trigger selector.
       # 0 = no trigger; 1 = cycle count trigger; 2 = program counter trigger; 3 =
       # instruction trigger
       selector: 1
       start: 0
       end: -1

FireSim에서 사용할 수 있는 네 가지 트리거 방법은 다음과 같습니다:

No trigger
^^^^^^^^^^^^^^

전체 시뮬레이션 동안 추적을 기록합니다.

위 ``.yaml`` 에서 옵션 ``0`` 입니다.

``start`` 및 ``end`` 필드는 무시됩니다.

Target cycle trigger
^^^^^^^^^^^^^^^^^^^^^^^

지정된 시작 주기에 도달하면 추적 기록이 시작되고, 지정된 종료 주기에 도달하면 기록이 종료됩니다. 주기는 기본 타겟 클록 주기로 지정됩니다 (ClockBridge의 첫 번째 출력 클록). 예를 들어, 기본 클럭이 언코어를 구동하고 코어 클럭 주파수가 언코어 주파수의 2배인 경우, 시작 및 종료 주기를 100과 200으로 지정하면 코어 클럭 주기 200에서 400 사이의 명령어가 수집됩니다.

위 ``.yaml`` 에서 옵션 ``1`` 입니다.

``start`` 및 ``end`` 필드는 10진수 정수로 해석됩니다.

Program Counter (PC) value trigger
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

지정된 프로그램 카운터 값에 도달하면 추적 기록이 시작되고, 지정된 프로그램 카운터 값에 도달하면 기록이 종료됩니다.

위 ``.yaml`` 에서 옵션 ``2`` 입니다.

``start`` 및 ``end`` 필드는 16진수 값으로 해석됩니다.

.. _tracerv-inst-value-trigger:

Instruction value trigger
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

명령어 추적에서 특정 명령어가 나타나면 기록이 시작되고, 다시 특정 명령어가 나타나면 기록이 종료됩니다. 이 방법은 평가 중인 타겟 소프트웨어 내에서 사용자 정의 "NOP" 명령어를 삽입하여 트리거를 설정할 때 특히 유용합니다. FireSim과 함께 제공되는 리눅스 배포판에는 이 목적을 위해 소형 트리거 프로그램이 기본으로 포함되어 있습니다; 이 하위 섹션의 끝부분을 참조하십시오.

위 ``.yaml`` 에서 옵션 ``3`` 입니다.

``start`` 및 ``end`` 필드는 16진수 값으로 해석됩니다. 각 필드는 64비트 값이며, 상위 32비트는 마스크를 나타내고 하위 32비트는 비교 값을 나타냅니다. 즉, 다음이 참으로 평가될 때 시작 또는 종료 조건이 만족됩니다:

.. code-block:: C

    ((inst value) & (upper 32 bits)) == (lower 32 bits)

즉, ``start: ffffffff00008013`` 을 설정하면 명령어 값이 정확히 ``00008013`` (RISC-V의 ``addi x0, x1, 0`` 명령어)일 때 기록이 시작됩니다.

이 트리거링 방법은 특정 애플리케이션이 리눅스 내에서 실행될 때만 추적을 기록하는 데 유용합니다. 이 트리거링 메커니즘 사용을 간소화하기 위해, FireMarshal에서 ``br-base.json`` 을 기반으로 파생된 작업은 자동으로 ``firesim-start-trigger`` 및 ``firesim-end-trigger`` 명령어를 포함하며, 이는 각각 ``addi x0, x1, 0`` 및 ``addi x0, x2, 0`` 명령어를 실행합니다. ``config_runtime.yaml`` 에서 다음 트리거 설정을 설정한 경우:

.. code-block:: yaml

    selector: 3
    start: ffffffff00008013
    end: ffffffff00010013

그리고 시뮬레이션된 시스템에서 bash 프롬프트에서 다음을 실행하십시오:

.. code-block:: bash

    $ firesim-start-trigger && ./my-interesting-benchmark && firesim-end-trigger

추적은 주로 ``my-interesting-benchmark`` 의 실행 기간 동안에만 포함될 것입니다. ``firesim-start-trigger`` 및 ``firesim-end-trigger`` 의 일부 추가 추적 정보와, 이들 및 ``my-interesting-benchmark`` 간의 OS 전환에 대한 작은 양의 추가 추적 정보가 포함됩니다.

.. Attention::  앞에서 언급한 트리거 명령어가 정상 애플리케이션 코드 내에서 생성되지 않을 가능성이 높지만, 프로파일링하려는 코드 섹션 내에 이러한 명령어가 실수로 존재하지 않는지 확인하는 것이 좋습니다. 이는 작업 중간에 추적 기록이 실수로 꺼지고 켜지는 결과를 초래할 수 있습니다.

   반대로, 개발자는 프로파일링하고자 하는 코드에 앞에서 언급한 ``addi`` 명령어를 고의로 삽입하여 더 세밀한 제어를 가능하게 할 수 있습니다.

Interpreting the Trace Result
------------------------------

Human readable output
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

이 형식은 ``output_format: 0`` 입니다.

사람이 읽을 수 있는 추적 출력 형식은 다음과 같습니다:

.. include:: TRACERV-HUMAN-READABLE-EXAMPLE
   :code: yaml

이 출력에서 각 줄은 명령어가 커밋된 코어의 클록 도메인에서의 주기(10진수)로 시작합니다. 주어진 주기에, 각 커밋된 명령어의 명령어 주소(16진수)는 프로그램 순서에 따라 ``I<#>`` 로 접두어가 붙습니다: ``I0`` 는 가장 오래된 명령어를 의미하고, ``I1`` 은 두 번째로 오래된 명령어를 의미합니다. 주어진 주기에 명령어가 커밋되지 않은 경우, 해당 주기는 출력 파일에서 건너뜁니다.

.. code-block:: ini

    Cycle: 0000000000000337 I0: 0000000000010010
    Cycle: 0000000000000337 I1: 0000000000010014
           |--------------|  ^        |--------|
                  |          |            └ 40 bits of instruction address (hex)
                  |          └ per-cycle commit-order
                  └ 64-bit local-cycle count

Binary output
^^^^^^^^^^^^^^^^^

이 형식은 ``output_format: 1`` 입니다.

이는 단순히 매 주기마다 FPGA로부터 받은 512비트를 바이너리로 출력 파일에 기록합니다. 각 512비트 청크는 little-endian으로 저장됩니다. 가장 낮은 64비트는 주기를 저장하고, 다음 64비트는 커밋된 명령어 0의 주소와 유효 비트를 little-endian으로 저장하며, 그다음 64비트는 커밋된 명령어 1의 주소와 유효 비트를 little-endian으로 저장하며, 최대 7개의 명령어까지 저장됩니다.

Flame Graph output
^^^^^^^^^^^^^^^^^^^^

이 형식은 ``output_format: 2`` 입니다. :ref:`tracerv-with-flamegraphs` 섹션을 참조하십시오.

Caveats
--------------------

현재 특정 조건에서 TracerV를 사용할 때 몇 가지 제한 사항/수동 조정이 필요합니다:

* TracerV는 기본적으로 명령어 주소와 유효 비트만 출력하며, 이 조합이 64비트 내에 맞는다고 가정합니다. 이를 변경하려면 ``sim/firesim-lib/src/main/scala/bridges/TracerVBridge.scala`` 를 수정해야 합니다.
* 추적된 코어의 최대 IPC는 7을 초과할 수 없습니다.
* 이러한 제한 사항에 대한 도움이 필요하면 FireSim 메일링 리스트에 문의하십시오: https://groups.google.com/forum/#!forum/firesim
