.. _manager-configuration-files:

Manager Configuration Files
===============================

This page contains a centralized reference for all of the configuration options
in ``config_runtime.yaml``, ``config_build.yaml``, ``config_build_farm.yaml``,
``config_build_recipes.yaml``, and ``config_hwdb.yaml``. It also contains
references for all build and run farm recipes (in :gh-file-ref:`deploy/build-farm-recipes` and :gh-file-ref:`deploy/run-farm-recipes`).

.. _config-runtime:

``config_runtime.yaml``
--------------------------

Here is a sample of this configuration file:

.. literalinclude:: /../deploy/sample-backup-configs/sample_config_runtime.yaml
   :language: yaml

Below, we outline each mapping in detail.

.. _run-farm-config-in-config-runtime:

``run_farm``
^^^^^^^^^^^^^^^^^^^

``run_farm`` 매핑은 FireSim run farm의 특성을 지정하여 매니저가 이를 자동으로 시작, 워크로드 실행, 종료할 수 있도록 합니다.

``base_recipe``
"""""""""""""""

``base_recipe`` 키/값 쌍은 특정 run farm 타입에 사용할 기본 인수 집합을 지정합니다.
run farm 타입을 변경하려면, ``deploy/run-farm-recipes`` 에서 새로운 ``base_recipe`` 파일을 제공해야 합니다.
``recipe_arg_overrides`` 매핑에 키/값을 추가하여 ``base_recipe`` 에서 제공된 인수를 재정의할 수 있습니다.

``recipe_arg_overrides``
""""""""""""""""""""""""

이 선택적 매핑 키/값은 ``base_recipe`` 에서 제공된 기본 인수를 재정의할 수 있게 합니다.
이 매핑은 제공된 ``base_recipe`` 파일 내의 ``args`` 매핑과 동일한 매핑 구조를 일치시켜야 합니다.
재정의된 인수는 재귀적으로 기본 인수를 대체하며, 시퀀스의 경우 재정의된 시퀀스는 기본 인수의 해당 시퀀스를 완전히 대체합니다.
또한, 이러한 재정의를 통해 기본 run farm 타입을 변경할 수 없습니다.
이는 기본 ``base_recipe`` 를 변경하여 수행해야 합니다.

사용할 수 있는 run farm recipes에 대한 자세한 내용은 :ref:`run-farm-recipe` 를 참조하십시오.

``metasimulation``
^^^^^^^^^^^^^^^^^^

아래의 ``metasimulation`` 옵션을 통해 ``launchrunfarm``, ``infrasetup`` 및 ``runworkload`` 를 실행할 때 FPGA 시뮬레이션 대신 메타시뮬레이션을 실행할 수 있습니다.
자세한 내용은 :ref:`metasimulation` 을 참조하십시오.

``metasimulation_enabled``
"""""""""""""""""""""""""""""

이는 FPGA 가속 시뮬레이션 대신 메타시뮬레이션을 실행하도록 하는 boolean 설정입니다.
특정 Run Farm 호스트에서 실행되는 메타시뮬레이션의 수는 각 run farm 레시피의 ``num_metasims`` 인수에 의해 결정됩니다 (참조 :ref:`run-farm-recipe`).

``metasimulation_host_simulator``
""""""""""""""""""""""""""""""""""

이 키/값 쌍은 메타시뮬레이션에 사용할 RTL 시뮬레이터를 선택합니다.
옵션에는 ``verilator`` 및 파형이 필요 없는 경우 ``vcs`` 와 파형이 필요한 경우 ``*-debug`` 버전이 포함됩니다.

``metasimulation_only_plusargs``
""""""""""""""""""""""""""""""""""

이 키/값 쌍은 메타시뮬레이션에 plusargs(``+`` 로 시작하는 인수)를 전달하는 문자열입니다.

``metasimulation_only_vcs_plusargs``
"""""""""""""""""""""""""""""""""""""

이 키/값 쌍은 ``vcs`` 또는 ``vcs-debug`` 를 사용하는 메타시뮬레이션에 plusargs를 전달하는 문자열입니다.

``target_config``
^^^^^^^^^^^^^^^^^^^

아래의 ``target_config`` 옵션을 사용하여 시뮬레이션 대상의 고급 구성을 지정할 수 있습니다.
Run Farm을 시작한 후 이러한 매개변수를 변경할 수 있지만 
(필요한 인스턴스 수가 맞는 경우), 많은 경우 인스턴스에 올바른 시뮬레이션 인프라가 사용 가능하도록 하려면
``infrasetup`` 명령을 다시 실행해야 합니다.

``topology``
"""""""""""""""""""""""""""""

이 필드는 시뮬레이션된 시스템의 네트워크 토폴로지를 결정합니다. 몇 가지 예:

``no_net_config``: 네트워크 시뮬레이션 없이 N(아래의 ``no_net_num_nodes`` 참조)개의 독립된 시뮬레이션을 실행합니다. 
이 옵션은 현재 FireSim의 NoNIC 하드웨어 구성을 빌드하는 경우에만 사용할 수 있습니다.

``example_8config``: 이는 8개의 시뮬레이션된 서버에 연결된 1개의 ToR 스위치를 시뮬레이트하여 단일 ``f1.16xlarge`` 가 필요합니다.

``example_16config``: 이는 2개의 ToR 스위치 각각 8개의 시뮬레이션된 서버에 연결되고 두 ToR 스위치가 루트 스위치로 연결된 
두 ``f1.16xlarge`` 인스턴스와 하나의 ``m4.16xlarge`` 인스턴스가 필요합니다.

``example_64config``: 이는 8개의 ToR 스위치 각각 8개의 시뮬레이션된 서버(총 64개 노드)에 연결되고 8개의 ToR 스위치가 
루트 스위치로 연결된 8개의 ``f1.16xlarge`` 인스턴스와 하나의 ``m4.16xlarge`` 인스턴스가 필요합니다.

추가 구성은 ``deploy/runtools/user_topology.py`` 에서 사용할 수 있으며 여기에 더 추가할 수 있습니다. 자세한 내용은 :ref:`usertopologies` 섹션을 참조하십시오.

``no_net_num_nodes``
"""""""""""""""""""""""""""""

이는 ``topology: no_net_config`` 를 사용하는 경우 시뮬레이션된 노드의 수를 결정합니다.

``link_latency``
"""""""""""""""""

네트워크 시뮬레이션에서 이는 시뮬레이션된 네트워크의 링크 지연 시간을 
CYCLES 단위로 지정할 수 있습니다. 예를 들어, 6405 사이클은 3.2GHz에서 약 2마이크로초에 해당합니다. 
현재 제한 사항은 이 값(사이클 단위)이 7의 배수여야 한다는 것입니다. 
또한 NIC의 시뮬레이션 위젯에 지정된 버퍼 크기를 초과해서는 안 됩니다.

``switching_latency``
""""""""""""""""""""""

네트워크 시뮬레이션에서 이는 스위치 모델의 포트 간 최소 포트 간 지연 시간을 CYCLES 단위로 지정합니다.

``net_bandwidth``
""""""""""""""""""""""

네트워크 시뮬레이션에서 이는 NIC가 허용하는 최대 출력 대역폭을 Gbit/s 단위의 정수로 지정합니다. 
현재 이 값은 1에서 200 사이의 숫자여야 하며, 이를 통해 1에서 200 Gbit/s 사이의 NIC를 모델링할 수 있습니다.

``profile_interval``
"""""""""""""""""""""""""""""

시뮬레이션 드라이버는 주기적으로 FASED 타이밍 모델 인스턴스에서 성능 카운터를 샘플링하고 호스트에 결과를 파일로 덤프합니다.
``profile_interval`` 은 샘플 간격의 대상 사이클 수를 정의합니다. 이 값을 -1로 설정하면 폴링이 비활성화됩니다.


``default_hw_config``
"""""""""""""""""""""""""""""

이는 위의 토폴로지에서 기본적으로 시작되는 서버 구성을 설정합니다.
이기종 구성은 토폴로지 내에서 다른 이름을 수동으로 지정하여 달성할 수 있지만, 
모든 ``example_Nconfig`` 구성은 동질적이며 모든 노드에 대해 이 값을 사용합니다.

이를 ``config_hwdb.yaml`` 에 이미 정의된 하드웨어 구성 중 하나로 설정해야 합니다.
이를 ``config_hwdb.yaml`` 의 하드웨어 구성의 NAME(매핑 제목)으로 설정해야 합니다. 실제 AGFI 또는 ``bitstream_tar`` 자체는 아닙니다.
(예: ``agfi-XYZ...`` 와 같은 값X)

``tracing``
^^^^^^^^^^^^^^^^^^^

이 섹션은 시뮬레이션 실행 중 TracerV 기반 추적을 관리합니다. 자세한 내용은 :ref:`tracerv` 페이지를 참조하십시오.

``enable``
""""""""""""""""""

이는 추적을 ``yes`` 로 설정하면 켜지고 ``no`` 로 설정하면 꺼집니다. 자세한 내용은 :ref:`tracerv-enabling`.

``output_format``
""""""""""""""""""""

이것은 TracerV 추적의 출력 형식을 설정합니다. 자세한 내용은 :ref:`tracerv-output-format` 섹션을 참조하십시오.

``selector``, ``start``, and ``end``
"""""""""""""""""""""""""""""""""""""

이들은 TracerV 트리거를 구성합니다. 자세한 내용은 :ref:`tracerv-trigger` 섹션을 참조하십시오.

``autocounter``
^^^^^^^^^^^^^^^^^^^^^

이 섹션은 AutoCounter를 구성합니다. 자세한 내용은 :ref:`autocounter` 페이지를 참조하십시오.

``read_rate``
"""""""""""""""""

이는 AutoCounter가 읽히는 속도를 설정합니다. 자세한 내용은 :ref:`autocounter-runtime-parameters` 섹션을 참조하십시오.


``workload``
^^^^^^^^^^^^^^^^^^^

이 섹션은 시뮬레이션된 시스템에서 실행될 소프트웨어를 정의합니다.

``workload_name``
"""""""""""""""""

이는 시뮬레이션된 노드 집합에서 실행할 워크로드를 선택합니다.
워크로드는 시뮬레이션된 노드(노드당 하나의 작업)에서 실행해야 하는 일련의 작업으로 구성됩니다.

워크로드 정의는 ``firesim/deploy/workloads/*.json`` 에 있습니다.

몇 가지 샘플 워크로드:

``br-base-uniform.json``: 이는 ``target_config`` 매개변수를 설정할 때 지정한 
수만큼 기본 FireSim Linux 배포판을 실행합니다.

기타는 위의 디렉토리에서 찾을 수 있습니다. JSON 형식에 대한 설명은 :ref:`deprecated-defining-custom-workloads` 를 참조하십시오.

``terminate_on_completion``
"""""""""""""""""""""""""""

워크로드가 완료된 후 Run Farm을 계속 실행하려면 이를 ``no`` 로 설정하십시오. 
워크로드가 완료되고 결과가 복사된 후 Run Farm을 종료하려면 ``yes`` 로 설정하십시오.

``suffix_tag``
""""""""""""""""""""""""""

이는 동일한 워크로드의 연속 실행을 구별하는 데 유용한 워크로드의 출력 디렉토리 이름에 문자열을 추가할 수 있습니다. 
예를 들어, ``suffix_tag: test-v1`` 을 ``super-application`` 이라는 워크로드에 지정하면 다음과 같은 
워크로드 결과 디렉토리가 생성됩니다. 
이름: ``results-workload/DATE--TIME-super-application-test-v1/``.

``host_debug``
^^^^^^^^^^^^^^^^^^

``zero_out_dram``
"""""""""""""""""""""""""""""

이를 ``yes`` 로 설정하면 시뮬레이션이 시작되기 전에 FPGA에 연결된 DRAM를 초기화합니다.
이 과정은 2-5분 정도 소요됩니다. 일반적으로 이는 타겟 머신에서 리눅스를 실행하는
결정론적 시뮬레이션을 생성하는 데 필요하지 않지만, 시뮬레이션 비결정론이 발생하는 경우 활성화해야 합니다.

``disable_synth_asserts``
"""""""""""""""""""""""""""""

이를 ``yes`` 로 설정하면 시뮬레이션이 합성된 어설션을 무시합니다.
그렇지 않은 경우, 어설션이 발생하면 시뮬레이션이 어설션 메시지를 출력하고 종료합니다.


.. _config-build:

``config_build.yaml``
--------------------------

Here is a sample of this configuration file:

.. literalinclude:: /../deploy/sample-backup-configs/sample_config_build.yaml
   :language: yaml

Below, we outline each mapping in detail.

``build_farm``
^^^^^^^^^^^^^^^^^^^

이 섹션에서는 FPGA 비트스트림을 빌드하는 데 사용할 특정 빌드 팜 구성을 지정합니다.

``base_recipe``
"""""""""""""""

``base_recipe`` 키/값 쌍은 특정 빌드 팜 타입에 사용할 기본 인수 집합을 지정합니다.
빌드 팜 타입을 변경하려면, ``deploy/build-farm-recipes`` 에서 새로운 ``base_recipe`` 파일을 제공해야 합니다.
``recipe_arg_overrides`` 매핑에 키/값을 추가하여 ``base_recipe`` 에서 제공된 인수를 재정의할 수 있습니다.

사용할 수 있는 빌드 팜 recipes에 대한 자세한 내용은 :ref:`build-farm-recipe` 를 참조하십시오.

``recipe_arg_overrides``
""""""""""""""""""""""""

이 선택적 매핑 키/값은 ``base_recipe`` 에서 제공된 기본 인수를 재정의할 수 있게 합니다.
이 매핑은 제공된 ``base_recipe`` 파일 내의 ``args`` 매핑과 동일한 매핑 구조를 일치시켜야 합니다.
재정의된 인수는 재귀적으로 기본 인수를 대체하며, 시퀀스의 경우 재정의된 시퀀스는 기본 인수의 해당 시퀀스를 완전히 대체합니다.
또한, 이러한 재정의를 통해 기본 빌드 팜 타입을 변경할 수 없습니다.
이는 기본 ``base_recipe`` 를 변경하여 수행해야 합니다.

``builds_to_run``
^^^^^^^^^^^^^^^^^^^^^

이 섹션에서는 ``buildbitstream`` 명령을 호출할 때 실행할 원하는 빌드 항목을 여러 개 나열할 수 있습니다. 
예를 들어, ``awesome_firesim_config`` 와 ``quad_core_awesome_firesim_config`` 라는 빌드를 실행하려면 다음과 같이 작성합니다. 

.. code-block:: yaml

    builds_to_run:
        - awesome_firesim_config
        - quad_core_awesome_firesim_config


``agfis_to_share``
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. Note:: This is only used in the AWS EC2 case.

이는 ``shareagfi`` 명령을 사용하여 특정 사용자와 지정된 agfi를 공유하는 데 사용됩니다
다음( ``share_with_accounts``) 섹션에 나와 있습니다. 이 섹션에서는 하드웨어 구성을 ``config_hwdb.yaml`` 에서 섹션 제목(즉, 사용자가 만든 이름)으로 지정해야 합니다.
다음과 같은 하드웨어 구성을 공유하려면:

.. code-block:: yaml

    firesim_rocket_quadcore_nic_l2_llc4mb_ddr3:
        # this is a comment that describes my favorite configuration!
        agfi: agfi-0a6449b5894e96e53
        deploy_quintuplet_override: null
        custom_runtime_config: null

여기서 다음과 같이 사용해야 합니다:

.. code-block:: yaml

    agfis_to_share:
        - firesim_rocket_quadcore_nic_l2_llc4mb_ddr3


``share_with_accounts``
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. Note:: This is only used in the AWS EC2 case.

``agfis_to_share`` 에 나와 있는 AGFI를 매니저의 ``shareagfi`` 명령을 호출할 때 공유할 AWS 계정 ID의 목록을 나열합니다.
이를 ``usersname: AWSACCTID`` 형식의 이름으로 지정해야 합니다. 왼쪽은 독자적 가독성을 위한 것이며, 여기 나열된 실제 계정 ID만 중요합니다.
여기에 ``public: public`` 을 지정하면 여기에 있는 다른 항목과 관계없이 AGFI가 공개적으로 공유됩니다.

.. _config-build-recipes:

``config_build_recipes.yaml``
--------------------------------

Here is a sample of this configuration file:

.. literalinclude:: /../deploy/sample-backup-configs/sample_config_build_recipes.yaml
   :language: yaml

Below, we outline each section and parameter in detail.


Build definition sections, e.g. ``awesome_firesim_config``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

이 파일에서는 원하는 만큼의 빌드 정의 섹션을 지정할 수 있으며, 각각 ``awesome_firesim_config`` 와 같은 헤더를 가집니다
(즉, 사용자가 만든 멋지고 짧은 이름). 이와 같은 섹션에는 다음 필드를 포함해야 합니다:

``DESIGN``
"""""""""""""""""""""""""""""

이는 빌드할 기본 타겟 디자인을 지정합니다. 사용자 정의 시스템을 정의하지 않으면
이는 ``FireSim`` 으로 설정해야 합니다.
자세한 내용은 :ref:`Generating Different
Targets<generating-different-targets>` 을 참조하십시오.

``TARGET_CONFIG``
"""""""""""""""""""

이는 시뮬레이션 대상의 하드웨어 구성을 지정합니다.
몇 가지 예로는 ``FireSimRocketConfig`` 와 ``FireSimQuadRocketConfig`` 등이 있습니다.
자세한 내용은 :ref:`Generating Different
Targets<generating-different-targets>` 을 참조하십시오.


``PLATFORM_CONFIG``
"""""""""""""""""""""

이는 컴파일러(Golden Gate)에 전달할 매개변수를 지정합니다. 
특히, PLATFORM_CONFIG는 어설션 합성 및 인스턴스 멀티스레딩과 같은 리소스 최적화와 같은 디버깅 도구를 활성화하는 데 사용할 수 있습니다. 
결정적으로, 이것은 내부 시뮬레이션 인터페이스의 너비를 정의하고 리소스 한계를 지정하는
호스트 플랫폼(예: F1)을 호출합니다 
(예: 플랫폼에 사용 가능한 DRAM 양).

``platform_build_args``
''''''''''''''''''''''''

이 설정은 비트스트림 빌드를 구성하며, 호스트 플랫폼에 무관합니다. 
Vitis 플랫폼("DEVICE")과 같은 플랫폼별 인수는 비트빌더의 인수로 캡처됩니다.

``fpga_frequency``
~~~~~~~~~~~~~~~~~~~~~~~~

비트스트림 빌드의 호스트 FPGA 주파수를 지정합니다
