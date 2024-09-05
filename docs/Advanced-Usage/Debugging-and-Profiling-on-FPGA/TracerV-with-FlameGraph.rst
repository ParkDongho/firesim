.. _tracerv-with-flamegraphs:

TracerV + Flame Graphs: Profiling Software with Out-of-Band Flame Graph Generation
====================================================================================

FireSim은 시뮬레이션된 프로세서에서 실행되는 소프트웨어의 성능을 시각화하기 위해 out-of-band로 `Flame Graphs
<http://www.brendangregg.com/flamegraphs.html>`_ 를 생성하는 기능을 지원합니다. 이 기능은 `FirePerf paper at ASPLOS 2020
<https://sagark.org/assets/pubs/fireperf-asplos2020.pdf>`_ 에서 소개되었습니다.

진행하기 전에, :ref:`tracerv` 섹션을 이해하는 것이 중요합니다.

What are Flame Graphs?
-----------------------

.. figure:: http://www.brendangregg.com/FlameGraphs/cpu-mysql-updated.svg
    :align: center
    :alt: Example Flame Graph

    Example Flame Graph (from http://www.brendangregg.com/FlameGraphs/)

Flame Graphs는 소프트웨어가 시간을 소비하는 위치를 스택 트레이스의 구성 요소별로 분류하여 보여주는 일종의 히스토그램입니다 (예: 함수 호출).
x축은 총 런타임 중 스택 트레이스의 일부에 소비된 비율을 나타내고, y축은 해당 시점에서의 스택 깊이를 나타냅니다. Flame Graph의 항목들은 함수 이름으로 라벨링되고 정렬됩니다 (시간이 아님).

이 시각화를 통해 시간 소모가 많은 루틴을 쉽게 식별할 수 있습니다: 이들은 Flame Graph에서 스택의 상위(최상단 수평 막대)이며 수평 막대의 너비로 표시된 전반적인 런타임의 상당 부분을 차지합니다.

전통적으로 Flame Graph를 생성하는 데이터는 소프트웨어에서 실행 중인 시스템의 스택 트레이스를 샘플링하는 도구인 ``perf`` 같은 툴을 사용하여 수집됩니다. 하지만 이러한 도구는 최종적으로 프로파일링되는 시스템에서 추가 소프트웨어를 실행시키기 때문에 프로파일링이 필요한 소프트웨어의 동작을 변경할 수 있다는 제한이 있습니다. 더구나 샘플링 빈도가 증가하면 이 효과는 악화됩니다.

FireSim에서는 TracerV가 제공하는 out-of-band 트레이스 수집을 사용하여 이 트레이스를 *정확히 사이클 단위로* 수집하고 *실행 중인 소프트웨어를 방해하지 않습니다*. 호스트 소프트웨어 측면에서는, TracerV가 제공한 실행 중인 바이너리에 대한 DWARF 정보를 기반으로 스택을 풀어냅니다. 이 스택 트레이스는 open-source `FlameGraph stack trace visualizer
<https://github.com/brendangregg/FlameGraph>`_ 에 공급되어 Flame Graph를 생성합니다.

Prerequisites
-----------------

#. :ref:`tracerv` 섹션을 이해했는지 확인하세요.
#. TracerV 브리지를 통합한 디자인이 필요합니다. :ref:`tracerv-bridge` 섹션을 참조하세요.

Enabling Flame Graph generation in ``config_runtime.yaml``
--------------------------------------------------------------

시뮬레이션을 위해 Flame Graph 생성을 활성화하려면, ``config_runtime.yaml`` 파일의 ``tracing`` 섹션에서 ``enable: yes`` 와 ``output_format: 2`` 를 설정해야 합니다. 예를 들면 다음과 같습니다:

.. code-block:: yaml

    tracing:
        enable: yes

        # Trace output formats. Only enabled if "enable" is set to "yes" above
        # 0 = human readable; 1 = binary (compressed raw data); 2 = flamegraph (stack
        # unwinding -> Flame Graph)
        output_format: 2

        # Trigger selector.
        # 0 = no trigger; 1 = cycle count trigger; 2 = program counter trigger; 3 =
        # instruction trigger
        selector: 1
        start: 0
        end: -1

트리거 선택기 설정은 :ref:`tracerv-trigger` 섹션에 설명된 대로 설정할 수 있습니다. 특히, 특정 애플리케이션이 실행 중일 때 OS만 프로파일링하는 경우 (예: ``iperf3`` in our `ASPLOS 2020 paper
<https://sagark.org/assets/pubs/fireperf-asplos2020.pdf>`_) 지시어 값 트리거 설정이 매우 유용합니다. :ref:`tracerv-inst-value-trigger` 섹션을 참조하세요.

Producing DWARF information to supply to the TracerV driver
----------------------------------------------------------------

FirePerf 모드에서 실행할 때, TracerV 소프트웨어 드라이버는 스택 풀어내기를 위한 라벨을 얻는 데 사용할 DWARF 디버깅 정보가 포함된 바이너리를 기대합니다.

TracerV는 이 파일이 정확히 ``bootbinary`` 와 같은 이름이지만 ``-dwarf`` 가 접미어로 붙여지기를 기대합니다. 예를 들어, (다음 섹션에서 보시게 될) ``bootbinary`` 의 이름이 ``br-base-bin`` 이라면, TracerV는 ``br-base-bin-dwarf`` 라는 파일을 제공하도록 요구합니다.

FireMarshal을 사용하여 Linux 배포판을 생성 중이라면, 생성된 Linux 커널에 대한 디버깅 정보가 포함된 이 파일이 자동으로 제공되고 (그리고 올바르게 명명됨) 이미지가 포함된 디렉토리에 제공됩니다. 예를 들어, ``br-base.json`` 워크로드를 빌드하면 ``br-base-bin``, ``br-base-bin-dwarf`` (TracerV Flame Graph 생성용), 및 ``br-base.img`` 을 자동으로 생성합니다.

.. _tracerv-flamegraph-workload-description:

Modifying your workload description
-------------------------------------

마지막으로, Flame Graph 흐름을 완료하기 위해 워크로드 설명을 세 가지로 수정해야 합니다. 워크로드 설명에 대한 일반적인 문서는 :ref:`deprecated-defining-custom-workloads` 섹션을 참조하세요.

#. DWARF 정보를 포함하는 파일을 ``simulation_inputs`` 중 하나로 추가하여 시뮬레이션을 실행 중인 원격 F1 인스턴스로 자동으로 복사되도록 해야 합니다.
#. 생성된 트레이스 파일을 되돌려 받기 위해 ``simulation_outputs`` 를 수정해야 합니다.
#. ``post_run_hook`` 을 ``gen-all-flamegraphs-fireperf.sh`` 로 설정해야 합니다 (이는 기본적으로 FireSim이 경로에 넣어둠). 이는 트레이스 파일에서 Flame Graph를 생성할 것입니다.

이것을 구체화하기 위해, Flame Graph 생성 지원이 없는 기본 ``br-base-uniform.json`` 워크로드 대신, 여기서 찾을 수 있는 수정 사항을 포함한 ``br-base-flamegraph.json`` 로 변경하십시오:

.. include:: /../deploy/workloads/br-base-flamegraph.json
   :code: json

``common_simulation_outputs`` 에 ``TRACEFILE*`` 을 추가하여 생성된 모든 트레이스 파일을 워크로드 결과 디렉토리로 복사함에 유의하세요. ``gen-all-flamegraphs-fireperf.sh`` 스크립트는 생성된 각 트레이스에 대해 자동으로 Flame Graph를 생성할 것입니다.

마지막으로, 새로 만든 워크로드 정의가 있는 경우, ``config_runtime.yaml`` 를 업데이트하여 이 새로운 워크로드 정의를 사용하도록 해야 합니다.

Running a simulation
-----------------------

이 시점에서 표준 FireSim 흐름을 따라 워크로드를 실행할 수 있습니다. 워크로드가 완료되면, 스택 트레이스 (명령어 트레이스가 아닌)와 생성된 Flame Graph SVG를 워크로드 출력 디렉토리에서 찾을 수 있습니다.

Caveats
------------

현재 스택 트레이스 구성 코드는 서로 다른 사용자 프로그래을 구분하지 않고 하나의 항목으로 통합합니다. 사용자 프로그램에 대한 확장된 지원은 향후 릴리스에서 제공될 예정입니다.