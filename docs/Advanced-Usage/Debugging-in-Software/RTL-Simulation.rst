.. _metasimulation:

Debugging & Testing with Metasimulation  
=========================================

FireSim의 RTL 시뮬레이션을 논할 때, 우리는 일반적으로 `metasimulation` 을 지칭합니다. 즉, VCS 또는 Verilator를 사용하여 FireSim 시뮬레이터의 RTL을 시뮬레이션하는 것입니다. 반면, GoldenGate 디커플링, 호스트 및 타겟 변환 없이 타겟의 수정되지 않은 RTL을 시뮬레이션하는 것을 `target-level` 시뮬레이션이라고 합니다. Chipyard에서 타겟 레벨 시뮬레이션은 `여기 <https://chipyard.readthedocs.io/en/latest/Simulation/Software-RTL-Simulation.html>`_ 에 자세히 설명되어 있습니다.

Metasimulation은 AGFI를 생성하기 전에 버그를 잡을 수 있는 가장 생산적인 방법이며, FPGA에서 발견된 버그를 재현할 수 있는 수단입니다. 기본적으로 metasimulation은 호스트의 추상적이지만 빠른 모델을 사용합니다. FPGA의 DRAM 컨트롤러는 단일 사이클 메모리 시스템으로 모델링되고, PCI-E 서브시스템은 시뮬레이션되지 않으며, 드라이버는 DMA 및 MMIO 트래픽을 직접 FPGATop 인터페이스에 제공합니다. FireSim 시뮬레이션은 호스트 간의 타이밍 차이에 강하므로, FPGA에서의 타겟 동작은 metasimulation에서도 정확히 재현될 수 있습니다.

마지막으로, metasimulation은 일반적으로 target-level 시뮬레이션보다 약간 느릴 뿐입니다. 성능에 대한 예시는 :ref:`metasimulation-performance` 에서 확인할 수 있습니다.

.. _metasimulation-supported-host-sims:

Supported Host Simulators  
----------------------------------------------------

현재 metasimulation을 지원하는 호스트 시뮬레이터는 다음과 같습니다:

* `Verilator <https://www.veripool.org/verilator/>`_

  * FOSS, FireSim 설정 중 자동으로 설치됩니다.

  * 코드베이스에서 ``verilator`` 로 참조됩니다.

* `Synopsys VCS <https://www.synopsys.com/verification/simulation/vcs.html>`_

  * 라이선스 필요.

  * 코드베이스에서 ``vcs`` 로 참조됩니다.

다른 시뮬레이터에 대한 지원을 추가하는 Pull Request는 환영합니다.

Running Metasimulations using the FireSim Manager  
----------------------------------------------------

FireSim 매니저는 FPGA 가속 시뮬레이션에서 사용하는 표준 ``firesim {launchrunfarm, infrasetup, runworkload, terminaterunfarm}`` 플로우를 사용하여 metasimulation을 실행할 수 있습니다. FPGA 대신 소프트웨어 시뮬레이터(:ref:`metasimulation-supported-host-sims`)에서 이러한 metasimulation이 실행되며, 일반적인 컴퓨팅 호스트(즉, FPGA가 없는 호스트)에서 실행됩니다. 이를 통해 사용자는 타겟의 단일 정의(구성된 설계 및 소프트웨어 워크로드)를 작성하면서 소프트웨어 전용 metasimulation과 FPGA 가속 시뮬레이션 간에 원활하게 이동할 수 있습니다.

예를 들어, :ref:``cluster-sim`` 섹션에서 사용된 8노드 네트워크 시뮬레이션을 위한 FPGA 가속 시뮬레이션에 설정된 기본 ``config_runtime.yaml`` 파일이 있다면, 구성 파일을 약간 수정하여 분산된 metasimulation을 실행할 수 있습니다.

먼저, 기존 ``config_runtime.yaml`` 의 ``metasimulation`` 매핑을 다음과 같이 수정하십시오:

.. code-block:: yaml

    metasimulation:
        metasimulation_enabled: true
        # vcs 또는 verilator 사용. 파형 생성을 위해서는 vcs-debug 또는 verilator-debug 사용
        metasimulation_host_simulator: verilator
        # 모든 metasimulation에 시뮬레이터에 전달되는 plusargs
        metasimulation_only_plusargs: "+fesvr-step-size=128 +max-cycles=100000000"
        # vcs metasimulation에만 전달되는 plusargs
        metasimulation_only_vcs_plusargs: "+vcs+initreg+0 +vcs+initmem+0"

이렇게 하면 ``config_runtime.yaml`` 에 지정된 타겟에 대해 파형 생성 없이 Verilator 호스트 metasimulation을 실행하도록 매니저가 구성됩니다. Metasimulation 모드에서는 ``target_config`` 에서 지정한 ``default_hw_config`` 이 ``config_hwdb.yaml`` 의 항목 대신 ``config_build_recipes.yaml`` 의 항목을 참조합니다.

FPGA 가속 시뮬레이션을 실행할 때와 마찬가지로, 실행할 metasimulation의 수는 ``target_config`` 섹션의 매개변수(예: ``topology`` 및 ``no_net_num_nodes``)에 의해 결정됩니다. 그런 다음 여러 개의 병렬 metasimulation을 FireMarshal 워크로드에 작성된 여러 개의 작업과 함께 실행할 수 있습니다.

Metasimulation 모드에서는 실행 팜 구성이 요구되는 metasimulation의 수를 지원할 수 있어야 합니다(세부 사항은 :ref:`run-farm-config-in-config-runtime` 참조). 실행 팜 호스트 사양의 ``num_metasims`` 매개변수는 특정 호스트에서 실행할 수 있는 metasimulation의 수를 정의합니다. 이는 FPGA 가속 시뮬레이션 모드에서 사용되는 ``num_fpgas`` 매개변수와 유사합니다. 그러나 ``num_metasims`` 는 호스트의 물리적 속성에 엄격히 대응하지 않으며, 설계의 복잡도와 호스트의 컴퓨팅/메모리 리소스에 따라 조정될 수 있습니다.

예를 들어, AWS EC2 실행 팜(``aws_ec2.yaml``)의 경우, 기본적으로 ``f1.{2, 4, 16}xlarge`` 인스턴스와 유사하지만 FPGA가 없고 오직 metasims만 실행하는 세 가지 인스턴스 유형(``z1d.{3, 6, 12}xlarge``)을 정의합니다(물론 ``f1.*`` 인스턴스가 metasims를 실행할 수 있지만, 이는 낭비입니다):

.. code-block:: yaml

    run_farm_hosts_to_use:
        - z1d.3xlarge: 0
        - z1d.6xlarge: 0
        - z1d.12xlarge: 1

    run_farm_host_specs:
        - z1d.3xlarge:
            num_fpgas: 0
            num_metasims: 1
            use_for_switch_only: false
        - z1d.6xlarge:
            num_fpgas: 0
            num_metasims: 2
            use_for_switch_only: false
        - z1d.12xlarge:
            num_fpgas: 0
            num_metasims: 8
            use_for_switch_only: false

이 경우, 실행 팜은 ``z1d.12xlarge`` 인스턴스를 사용하여 8개의 metasimulation을 호스팅합니다.

Metasimulation에서 파형을 생성하려면, ``metasimulation_host_simulator`` 를 ``-debug`` 로 끝나는 시뮬레이터(예: ``verilator-debug``)로 변경하십시오. 파형 생성 시뮬레이터를 사용할 때는 시뮬레이션이 완료되면 파형이 관리자 호스트로 복사되도록 워크로드 JSON 파일의 ``common_simulation_outputs`` 영역에 ``waveform.vpd`` 를 추가하십시오.



Metasimulation의 경우, FPGA 시뮬레이션과 달리 두 개의 출력 로그가 존재합니다. 하나는 FPGA 기반 시뮬레이션에서와 마찬가지로 metasimulation의 ``stdout`` 을 저장하는 ``uartlog`` 파일이고, 다른 하나는 RTL에서 발생하는 ``printf`` 호출(특히 ``printf`` 합성으로 표시되지 않은 것들)을 포함하는 ``stderr`` 출력이 저장되는 ``metasim_stderr.out`` 파일입니다. 만약 시뮬레이션이 완료된 후 ``metasim_stderr.out`` 을 관리자 호스트로 복사하고 싶다면, 워크로드 JSON 파일의 ``common_simulation_outputs`` 에 추가해야 합니다.

이 섹션에서 논의된 변경 사항을 제외하면, 매니저의 동작은 FPGA 기반 시뮬레이션과 metasimulation 간에 동일합니다. 예를 들어, 시뮬레이션 출력은 관리자 호스트의 ``deploy/results-workload/`` 에 저장되며, FireMarshal 워크로드 정의는 타겟 소프트웨어를 제공하는 데 사용됩니다. 또한 네트워크 시뮬레이션을 실행하고 기존 FireSim 디버깅 도구(예: AutoCounter, TracerV 등)를 사용하는 것을 포함한 모든 표준 매니저 기능이 metasimulation에서도 지원됩니다.

이 섹션에서 논의된 구성 변경 사항을 완료하면, 표준 ``firesim {launchrunfarm, infrasetup, runworkload, terminaterunfarm}`` 명령 세트를 사용하여 metasimulation을 실행할 수 있습니다.

FireSim metasimulation을 주요 시뮬레이션 도구로 사용하여 새로운 타겟 디자인을 개발하려고 한다면, (선택 사항인) ``firesim builddriver`` 명령을 사용할 수 있습니다. 이 명령은 실행 팜 호스트를 시작하거나 접근할 필요 없이 매니저를 통해 metasimulation을 빌드할 수 있습니다. 이 명령에 대한 자세한 내용은 :ref:`firesim-builddriver` 섹션에서 확인할 수 있습니다.

Understanding a Metasimulation Waveform  
----------------------------------------

Module Hierarchy  
++++++++++++++++  
시뮬레이터를 빌드하기 위해 Golden Gate는 타겟 디자인에 여러 계층의 모듈 계층 구조를 추가하고, 브릿지 구현과 리소스 최적화를 위해 추가적인 계층 구조 변형을 수행합니다. Metasimulation은 최상위 모듈로 ``FPGATop`` 모듈을 사용하며, 플랫폼 셤 레이어(``F1Shim``, EC2 F1의 경우)는 제외됩니다. 입력 디자인의 원래 최상위 모듈은 FPGATop 아래 세 레벨에 중첩됩니다:

.. figure:: /img/metasim-module-hierarchy.png

    일반적인 metasimulation에서 볼 수 있는 모듈 계층 구조.

타겟마다 다르긴 하지만, ``FPGATop`` 아래에서 여러 브릿지, 채널 구현, 그리고 최적화된 모델들이 존재할 수 있습니다. ``FAMETop`` 모듈 인스턴스 아래에는 원래의 최상위 모듈(``FireSimPDES_``, 이 경우)이 있지만, 이제는 기본 LI-BDN FAME 변환을 사용하여 호스트로부터 디커플링되어 `허브 모델` 로 불립니다. 이 모델은 모든 채널에 대한 준비-유효(ready-valid) I/O 인터페이스를 가지고 있으며, 내부적으로 시뮬레이션 시간의 진행을 제어하기 위해 추가적인 채널 인큐와 클럭 발동 논리를 포함하고 있습니다. 또한, 브릿지 및 최적화된 모델의 모듈은 더 이상 이 하위 모듈 계층 구조 내에 포함되지 않습니다. 대신, 이러한 추출된 모듈의 I/O는 이제 채널 인터페이스로 제공됩니다.

Clock Edges and Event Timing  
++++++++++++++++++++++++++++  
FireSim은 호스트 클럭을 게이팅하여 타겟 클럭을 생성하기 때문에, 그리고 브릿지 및 최적화된 모델이 자체적인 정지를 도입할 수 있기 때문에, metasimulation에서 타겟 클럭 에지의 타이밍은 기존의 타겟 시뮬레이션과는 다르게 왜곡된 형태로 나타납니다. 구체적으로, 클럭 에지 간의 호스트 시간은 해당 간격 동안 경과한 타겟 시간에 비례하지 않으며, 시뮬레이터의 정지에 따라 달라집니다.

Finding The Source Of Simulation Stalls  
+++++++++++++++++++++++++++++++++++++++  
이상적인 경우, FireSim 시뮬레이터는 모든 호스트 클럭 주기마다 새로운 타겟 클럭 펄스를 시작할 수 있어야 합니다. 즉, 단일 클럭 타겟의 경우, 시뮬레이션은 FMR = 1로 실행될 수 있습니다. 단일 클럭의 경우, 지연은 브릿지(예: FASED 메모리 타이밍 모델)와 최적화된 모델(예: 다중 사이클 레지스터 파일 모델)에 의해 도입됩니다. 허브 모델에서 ``*sink_valid`` 와 ``*source_ready`` 를 필터링하여 어떤 브릿지가 추가적인 지연을 일으키는지 확인할 수 있습니다. ``<channel>_sink_valid`` 가 비활성화되면, 브릿지나 모델이 현재 타임스텝에 대한 토큰을 아직 생성하지 못했음을 나타내며, 허브가 정지됩니다. ``<channel>_source_ready`` 가 비활성화되면, 브릿지나 모델이 채널에 대해 백프레셔를 가하고 있음을 나타냅니다.

Scala Tests  
-----------  
Metasimulation 기반의 회귀 테스트를 쉽게 수행할 수 있도록 ScalaTests는 Makefile 호출을 래핑하고, MIDAS 예제와 몇 가지 Chipyard 기반 설계를 포함한 선택된 설계 세트에 대해 제한된 테스트 세트를 실행합니다. 이는 :ref:`Developer documentation <Scala Integration Tests>` 에서 더 자세히 설명됩니다.

Running Metasimulations through Make  
------------------------------------

.. Warning:: 이 섹션은 고급 개발자를 위한 것입니다. 대부분의 metasimulation 사용자들은 위에서 설명한 매니저 기반 metasimulation 흐름을 사용해야 합니다.

Metasimulation은 ``firesim/sim`` 디렉토리에서 실행됩니다.

.. code-block:: bash

    [in firesim/sim]
    make <verilator|vcs>

파형 전체 가시성을 가진 시뮬레이터를 컴파일하려면 다음 명령을 입력하십시오:

.. code-block:: bash

    make <verilator|vcs>-debug

``Rocket Chip`` 의 타겟 생성의 일환으로, MIDAS는 어셈블리 테스트 모음을 실행하기 위한 Makefile 조각을 생성합니다. 이 Makefile 조각은 ``firesim/sim/generated-src/f1/<DESIGN>-<TARGET_CONFIG>-<PLATFORM_CONFIG>/firesim.d`` 에 저장됩니다. ``$RISCV`` 환경 변수가 설정되어 있는지 확인하려면 ``firesim/sourceme-manager.sh`` 또는 ``firesim/env.sh`` 를 소싱한 후 다음 명령을 입력하십시오:

.. code-block:: bash

    make run-<asm|bmark>-tests EMUL=<vcs|verilator>

단일 테스트만 실행하려면, 전체 경로를 사용하여 해당 테스트를 실행하는 Make 타겟을 사용해야 합니다. 구체적으로는:

.. code-block:: bash

    make EMUL=<vcs|verilator> $PWD/output/f1/<DESIGN>-<TARGET_CONFIG>-<PLATFORM_CONFIG>/<RISCV-TEST-NAME>.<vpd|out>

``.vpd`` 타겟은 파형 덤프를 사용한 시뮬레이터를 사용하며, 필요하다면 파형 덤프를 활성화한 시뮬레이터를 빌드합니다. 반면 ``.out`` 타겟은 파형 없이 더 빠른 시뮬레이터를 사용합니다.

또한, 고유한 바이너리를 다음과 같이 실행할 수 있습니다:

.. code-block:: bash

    make SIM_BINARY=<PATH_TO_BINARY> run-<vcs|verilator>
    make SIM_BINARY=<PATH_TO_BINARY> run-<vcs|verilator>-debug

Examples  
++++++++

Verilator 시뮬레이터에서 모든 RISCV-tools 어셈블리 및 벤치마크 테스트를 실행합니다.

.. code-block:: bash

    [in firesim/sim]
    make
    make -j run-asm-tests
    make -j run-bmark-tests

파형 덤프를 사용하여 Verilator 시뮬레이터에서 모든 RISCV-tools 어셈블리 및 벤치마크 테스트를 실행합니다.

.. code-block:: bash

    make verilator-debug
    make -j run-asm-tests-debug
    make -j run-bmark-tests-debug

Verilator 시뮬레이터에서 ``rv64ui-p-simple`` (단일 어셈블리 테스트)를 실행합니다.

.. code-block:: bash

    make
    make $(pwd)/output/f1/FireSim-FireSimRocketConfig-BaseF1Config/rv64ui-p-simple.out

VCS 시뮬레이터에서 파형 덤프를 사용하여 ``rv64ui-p-simple`` (단일 어셈블리 테스트)를 실행합니다.

.. code-block:: bash

    make vcs-debug
    make EMUL=vcs $(pwd)/output/f1/FireSim-FireSimRocketConfig-BaseF1Config/rv64ui-p-simple.vpd

.. _metasimulation-performance:

Metasimulation vs. Target simulation performance  
---------------------------------------------------------

일반적으로, metasimulation은 target-level 시뮬레이션보다 약간 느립니다. 아래 표는 이를 보여줍니다.

====== ===== =======  ========= ============= =============
타입   파형  VCS      Verilator Verilator -O1 Verilator -O2
====== ===== =======  ========= ============= =============
Target Off   4.8 kHz  3.9 kHz   6.6 kHz       N/A  
Target On    0.8 kHz  3.0 kHz   5.1 kHz       N/A  
Meta   Off   3.8 kHz  2.4 kHz   4.5 kHz       5.3 kHz  
Meta   On    2.9 kHz  1.5 kHz   2.7 kHz       3.4 kHz  
====== ===== =======  ========= ============= =============

Verilator 디자인을 컴파일할 때 더 공격적인 최적화 레벨을 사용하는 것은 컴파일 시간을 상당히 늘립니다:

====== ===== =======  ========= ============= =============
타입   파형  VCS      Verilator Verilator -O1 Verilator -O2
====== ===== =======  ========= ============= =============
Meta   Off   35s      48s       3m32s         4m35s  
Meta   On    35s      49s       5m27s         6m33s  
====== ===== =======  ========= ============= =============

주: 기본 구성의 단일 코어, Rocket 기반 인스턴스가 ``rv64ui-v-add``를 실행 중입니다. 주파수는 타겟-Hz 단위로 표시됩니다. 현재 Verilator와 VCS에 전달되는 기본 컴파일러 플래그는 최적화 레벨마다 다릅니다. 따라서 이 숫자는 시뮬레이터 간의 과학적인 비교보다는 대략적인 시뮬레이션 속도를 제공하기 위한 것입니다. VCS 수치는 Berkeley의 로컬 머신에서 수집되었고, Verilator 수치는 ``c4.4xlarge`` 에서 수집되었습니다. (metasimulation Verilator 버전: 4.002, target-level Verilator 버전: 3.904)