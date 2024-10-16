Manager Tasks
========================

이 페이지는 FireSim 매니저가 지원하는 모든 작업을 설명합니다.

.. _firesim-managerinit:

``firesim managerinit``
---------------------------------------------

이것은 다음을 수행하는 설정 명령입니다:

* 기존 구성 파일이 존재하면 백업합니다 (``config_runtime.yaml``, ``config_build.yaml``, ``config_build_recipes.yaml``, 및 ``config_hwdb.yaml``).
* 기본 구성 파일들 (``config_runtime.yaml``, ``config_build.yaml``, ``config_build_recipes.yaml``, 및 ``config_hwdb.yaml``) 을 깨끗한 예제 버전으로 교체합니다.

그런 다음, 주어진 ``--platform`` 에 대한 플랫폼별 초기화 단계를 수행합니다.

.. tabs::

   .. tab:: ``f1``

        * ``aws configure`` 를 실행하고 자격 증명 입력을 요청합니다.
        * 사용자에게 이메일 주소를 입력하도록 요청하고 자신의 빌드에 대한 알림을 구독합니다.
        * AWS 실행/빌드 팜 인수로 ``config_runtime.yaml`` 및 ``config_build.yaml`` 파일을 설정합니다.

   .. tab:: All other platforms

        여기에는 ``xilinx_alveo_u200``, ``xilinx_alveo_u250``, ``xilinx_alveo_u280``, ``xilinx_vcu118``, 및 ``rhsresearch_nitefury_ii`` 와 같은 플랫폼들이 포함됩니다.

        * 외부 공급된 실행/빌드 팜 인수로 ``config_runtime.yaml`` 및 ``config_build.yaml`` 파일을 설정합니다.

깨끗한 구성 파일을 얻기 위해 원할 때마다 이것을 다시 실행할 수 있습니다.

.. note:: ``f1`` 의 경우, ``aws configure`` 자격 증명 및 이메일 주소를 입력하라는 메시지가 나타나면 Enter를 눌러 이전에 지정한 값을 그대로 유지할 수 있습니다.

이 명령을 실수로 실행하여 구성 파일을 덮어쓰지 않으려면, 백업 버전을 ``firesim/deploy/sample-backup-configs/backup*`` 에서 찾을 수 있습니다.

.. _firesim-buildbitstream:

``firesim buildbitstream``
--------------------------

이 명령은 지정한 구성에 대해 Chisel RTL에서 **Build Farm**을 사용하여 FireSim 비트스트림을 빌드합니다. 빌드할 구성을 정의하는 과정은 :ref:`config-build` 및 :ref:`config-build-recipes` 문서에 설명되어 있습니다.

각 구성에 대한 빌드 프로세스는 다음과 같습니다:

.. tabs::

   .. tab:: F1

        1. [로컬에서] 하드웨어 구성에 대한 elaboration 과정 실행
        2. [로컬에서] MIDAS를 사용하여 FAME-1 변환 수행
        3. [로컬에서] 시뮬레이션 모델 부착 (I/O widgets, memory model 등)
        4. [로컬에서] FPGA Flow를 통과할 Verilog 생성
        5. 빌드 팜 구성을 사용하여 빌드할 각 구성에 대해 빌드 호스트 시작/사용
        6. [로컬/원격] 빌드 호스트 준비, 생성된 Verilog를 하드웨어 구성 인스턴스로 복사
        7. [로컬/원격] 구성에 대해 Vivado Synthesis 및 P&R 실행
        8. [로컬/원격] Vivado에서 생성된 모든 출력 복사, 최종 tar 파일 포함
        9. [로컬/AWS Infra] 생성된 tar 파일을 AWS 백엔드에 제출하여 AFI로 변환
        10. [로컬] AFI가 사용 가능해질 때까지 대기, 완료 후 사용자에게 이메일로 알림

   .. tab:: XDMA-based On-Prem.

        1. [로컬에서] 하드웨어 구성에 대한 elaboration 과정 실행
        2. [로컬에서] MIDAS를 사용하여 FAME-1 변환 수행
        3. [로컬에서] 시뮬레이션 모델 부착 (I/O widgets, memory model 등)
        4. [로컬에서] FPGA Flow를 통과할 Verilog 생성
        5. 빌드 팜 구성을 사용하여 빌드할 각 구성에 대해 빌드 호스트 시작/사용
        6. [로컬/원격] 빌드 호스트 준비, 생성된 Verilog를 하드웨어 구성 인스턴스로 복사
        7. [로컬/원격] 구성에 대해 Vivado Synthesis 및 P&R 실행
        8. [로컬/원격] Vivado에서 생성된 모든 출력 복사 (``bit`` 비트스트림 포함)

   .. tab:: Vitis-based On-Prem.

        1. [로컬에서] 하드웨어 구성에 대한 elaboration 과정 실행
        2. [로컬에서] MIDAS를 사용하여 FAME-1 변환 수행
        3. [로컬에서] 시뮬레이션 모델 부착 (I/O widgets, memory model 등)
        4. [로컬에서] FPGA Flow를 통과할 Verilog 생성
        5. 빌드 팜 구성을 사용하여 빌드할 각 구성에 대해 빌드 호스트 시작/사용
        6. [로컬/원격] 빌드 호스트 준비, 생성된 Verilog를 하드웨어 구성 인스턴스로 복사
        7. [로컬/원격] 구성에 대해 Vitis Synthesis 및 P&R 실행
        8. [로컬/원격] Vitis에서 생성된 모든 출력 복사 (``xclbin`` 비트스트림을 포함한 ``bitstream_tar`` 포함)

이 과정은 지정한 모든 빌드에 대해 병렬로 진행됩니다. 명령은 모든 빌드가 완료되면 종료되며, 빌드가 개별적으로 완료되면 (F1에서) 이메일로 통지를 받습니다. 완료되면 모든 빌드가 통과했는지 또는 실패했는지를 종료 코드로 나타냅니다.

.. Note:: **이 명령은** ``screen`` **에서 실행하거나** ``mosh`` **를 사용하여 매니저 인스턴스에 접근하는 것이 강력히 권장됩니다. 매니저가 ssh 연결 끊김으로 종료되면 빌드는 완료되지 않습니다.**

특정 구성을 위해 빌드를 실행할 때, ``firesim/deploy/results-build/`` 폴더에 ``LAUNCHTIME-CONFIG_TRIPLET-BUILD_NAME`` 이라는 디렉토리가 생성됩니다.
이 디렉토리에는 다음이 포함됩니다:

.. tabs::

   .. tab:: F1

        - ``AGFI_INFO``: 매니저가 실행 중일 때 빌드된 AFI의 상태를 설명합니다. 빌드 완료 후에는 생성된 AGFI/AFI와 메타데이터가 포함됩니다.
        - ``cl_firesim:``: 이는 FPGA 이미지를 빌드한 Vivado 프로젝트의 상태를 보여주는 디렉토리로, 빌드 완료 시의 상태를 포함합니다. 보고서, 빌드 stdout, Vivado에서 생성된 최종 tar 파일이 포함됩니다. 또한 이 빌드를 생성하는 데 사용된 생성된 verilog (``FireSim-generated.sv``)의 사본도 포함합니다.

   .. tab:: XDMA-based On-Prem.

        Vivado 프로젝트 파일은 Vivado 빌드 프로세스가 완료되었을 때의 상태입니다.
        여기에는 보고서, ``stdout`` 파일, 및 Vivado에서 생성된 최종 ``bitstream_tar`` 비트스트림/메타데이터 파일이 포함됩니다.
        이 빌드를 생성하는 데 사용된 생성된 verilog (``FireSim-generated.sv``)의 사본도 포함됩니다.

   .. tab:: Vitis-based On-Prem.

        Vitis 프로젝트 파일은 Vitis 빌드 과정이 완료되었을 때의 상태입니다.
        여기에는 보고서, ``stdout`` 파일, 및 Vitis에서 생성된 최종 ``bitstream_tar`` (``xclbin`` 비트스트림 포함)이 들어 있습니다.
        이 빌드를 생성하는 데 사용된 생성된 verilog (``FireSim-generated.sv``)의 사본도 포함됩니다.

이 명령이 SIGINT에 의해 취소되면 빌드 인스턴스를 종료할 것인지 확인 메시지를 표시합니다.
종료하려면 확인 응답을 해야 하고, 그렇지 않으면 종료를 진행하지 않습니다.
이 명령을 스크립트에서 사용할 경우 (예: 확인 없이), ``--forceterminate`` 명령행 인수를 사용할 수 있습니다. 예를 들어, 다음 명령은 SIGINT가 수신되면 확인 없이 모든 빌드 인스턴스를 종료합니다:

.. code-block:: bash

    firesim buildbitstream --forceterminate

.. _firesim-builddriver:

``firesim builddriver``
--------------------------------

FPGA 기반 시뮬레이션 (``metasimulation_enabled`` 가 ``config_runtime.yaml`` 에서 ``false`` 일 때)을 위해, 이 명령은 시뮬레이션 호스트를 시작하거나 도달할 수 필요 없이 호스트 측 시뮬레이션 드라이버를 빌드합니다.
복잡한 디자인의 경우, ``firesim launchrunfarm`` 을 실행하기 전에 이를 실행하면 드라이버 빌드를 기다리는 동안 FPGA 호스트를 유휴 상태로 두는 시간을 줄일 수 있습니다.

메타 시뮬레이션 (``metasimulation_enabled`` 가 ``config_runtime.yaml`` 에서 ``true`` 인 경우)을 위해, 이 명령은 시뮬레이션 호스트를 시작하거나 도달할 필요 없이 전체 소프트웨어 시뮬레이터를 빌드합니다.
이는 예를 들어, FireSim 메타 시뮬레이션을 주된 시뮬레이션 도구로 사용하는 경우에 유용하며, 타겟 RTL을 개발하는 동안 Chisel 빌드 플로우를 실행하고 추가적인 머신을 설정하지 않고도 디자인을 반복할 수 있습니다.

.. _firesim-tar2afi:

``firesim tar2afi``
----------------------

.. Note:: F1 플랫폼에서만 사용할 수 있습니다.

이 명령은 수동으로 수정된 ``firesim buildbitstream`` 이 중단된 후에만 9 및 10 단계를 실행하는 데 사용할 수 있습니다.
``firesim tar2afi`` 는 AFI로 변환하기 위해 AWS 백엔드에 제출할 수 있는 ``firesim/deploy/results-build/LAUNCHTIME-CONFIG_TRIPLET-BUILD_NAME/cl_firesim`` 디렉토리 트리가 있다고 가정합니다.

이 명령을 사용할 때는 기존에 존재하는 LAUNCHTIME을 지정하는 ``--launchtime LAUNCHTIME`` 명령행 인수도 제공해야 합니다.

이 명령은 :ref:`config-build` 및 :ref:`config-build-recipes` 에 지정된 구성에 대해 실행됩니다. 이 명령을 실행하기 전에 :ref:`firesim-buildbitstream` 과정을 성공적으로 완료한 빌드 레시피 이름을 주석 처리하는 것이 좋습니다.


.. _firesim-shareagfi:

``firesim shareagfi``
----------------------

.. Note:: F1 플랫폼에서만 사용할 수 있습니다.

이 명령은 이미 빌드된 AGFI를 다른 사용자와 공유할 수 있게 해줍니다 (:ref:`config-hwdb` 에 나열된 AGFI).
이 명령은 ``config_build.yaml`` 의 ``agfis_to_share`` 섹션에 나열된 하드웨어 구성을 가져와 ``config_hwdb.yaml`` 에서 각 AGFI를 가져와, ``share_with_accounts`` 섹션에 나열된 사용자와 모든 F1 지역에서 공유합니다.
또한 ``share_with_accounts`` 에 ``public: public`` 을 지정하여 AGFI를 공개적으로 만들 수도 있습니다.

AGFI를 소유하고 있어야만 이 작업을 수행할 수 있습니다 -- 다른 사용자가 소유하고 당신에게 접근 권한을 준 AGFI를 공유할 수 없습니다.


.. _firesim-launchrunfarm:

``firesim launchrunfarm``
---------------------------

.. Note:: F1 플랫폼에서만 사용할 수 있습니다.

이 명령은 AWS EC2에서 시뮬레이션을 실행할 **Run Farm**을 시작합니다. Run farm은 AWS EC2에서 실행되는 **run farm 인스턴스**의 집합으로 구성됩니다.
``config_runtime.yaml`` 의 ``run_farm`` 매핑이 사용되는 run farm 및 그 구성을 결정합니다 (자세한 내용 :ref:`config-runtime` 참조).
``base_recipe`` 키/값 쌍은 특정 run farm 유형에 사용할 기본 인수 집합을 지정합니다. run farm 유형을 변경하려면 ``deploy/run-farm-recipes`` 에서 새 ``base_recipe`` 파일을 제공해야 합니다.
키/값을 ``recipe_arg_overrides`` 매핑에 추가하여 ``base_recipe`` 에서 제공된 인수를 무시할 수 있습니다. 이러한 키/값은 ``args`` 매핑과 동일한 매핑 구조를 일치시켜야 합니다.
재정의된 인수는 재귀적으로 덮어쓰여 기본 인수의 대응되는 시퀀스를 완전히 대체합니다.

AWS EC2 run farm은 ``f1.16xlarge``, ``f1.4xlarge``, ``f1.2xlarge``, 및 ``m4.16xlarge`` 인스턴스와 같은 AWS 인스턴스로 구성됩니다.
명령을 실행하기 전에 ``config_runtime.yaml`` 의 ``recipe_arg_overrides`` 섹션 또는 ``base_recipe`` 자체에 원하는 개수를 정의합니다.

시작된 run farm은 ``run_farm_tag`` 로 태그 지정되며, 이 태그는 여러 병렬 run farm을 구별하는 데 사용됩니다; 즉, 각각 고유한 ``run_farm_tag`` 와 함께 각각 다른 실험을 동시에 실행할 수 있는 여러 run farms를 실행할 수 있습니다.
AWS 관리 패널에 ``fsimcluster`` 컬럼을 추가하여 ``run_farm_tag`` 값을 확인할 수 있습니다. 자세한 내용은 :ref:`fsimcluster-aws-panel` 섹션을 참조하십시오.

``run_farm`` 섹션의 다른 옵션인 ``run_instance_market``, ``spot_interruption_behavior``, 및 ``spot_max_price`` 는 인스턴스가 어떻게 실행되는지를 정의합니다. 자세한 내용은 ``config_runtime.yaml`` 문서를 참조하십시오 (자세한 내용 :ref:`config-runtime` 참조).

**ERRATA**: 현재 요구 사항 중 하나는 실행할 run farm보다 더 많은 리소스를 요구하지 않는 ``config_runtime.yaml`` 의 ``target_config`` 섹션에 타겟 구성을 정의해야 한다는 것입니다. 따라서, 해당 run farm을 시작하기 전에 ``target_config`` 매개변수를 설정해야 합니다. 이 요구 사항은 추후 제거될 예정입니다.

구성을 설정하고 ``firesim launchrunfarm`` 를 호출하면 명령은 run farm을 시작합니다. 모든 것이 성공하면
명령이 올바른 수/유형의 인스턴스 ID를 출력합니다 (이를 인지하거나 기록할 필요는 없습니다).
오류가 발생하면 콘솔에 출력됩니다.

.. warning:: AWS EC2에서 이 명령을 실행하면, ``firesim terminaterunfarm`` 를 호출할 때까지 run farm은 계속 실행됩니다. 이는 ``terminaterunfarm`` 를 호출할 때까지 run farm의 실행 인스턴스에 대해 요금이 청구됨을 의미합니다. AWS EC2 관리 패널을 확인하여 인스턴스가 원하는 시간에만 실행되도록 해야 할 책임이 있습니다.

.. _firesim-terminaterunfarm:

``firesim terminaterunfarm``
-----------------------------

.. Note:: F1 플랫폼에서만 사용할 수 있습니다.

이 명령은 ``config_runtime.yaml`` 파일의 ``run_farm`` ``base_recipe`` 에 정의된 Run Farm의 일부 또는 모든 인스턴스를 종료합니다, 주어진 명령줄 인수에 따라.

기본적으로, ``firesim terminaterunfarm`` 를 실행하면 지정된 ``run_farm_tag`` 의 모든 인스턴스를 종료합니다. 이 명령을 실행하면 나열된 인스턴스를 종료할 것인지 확인 메시지를 표시합니다. 확인 응답을 해야 종료를 진행합니다.

종료를 확인 응답 없이 진행하려는 경우 (예: 스크립트에서 이 명령을 사용하는 경우), ``--forceterminate`` 명령행 인수를 사용할 수 있습니다. 예를 들어, 다음 명령은 확인 없이 모든 인스턴스를 종료합니다:

.. code-block:: bash

    firesim terminaterunfarm --forceterminate


``--terminatesome=INSTANCE_TYPE:COUNT`` 플래그는 특정 Run Farm에서 특정 유형(``INSTANCE_TYPE``)의 인스턴스 중 일부(``COUNT``)만 종료할 수 있습니다.

다음은 몇 가지 예제입니다:

.. code-block:: bash

    [ 처음에 2개의 f1.16xlarges, 2개의 f1.2xlarges, 2개의 m4.16xlarges가 있습니다 ]

    firesim terminaterunfarm --terminatesome=f1.16xlarge:1 --forceterminate

    [ 이제, 우리는 다음과 같습니다: 1개의 f1.16xlarges, 2개의 f1.2xlarges, 2개의 m4.16xlarges ]


.. code-block:: bash

    [ 처음에 2개의 f1.16xlarges, 2개의 f1.2xlarges, 2개의 m4.16xlarges가 있습니다 ]

    firesim terminaterunfarm --terminatesome=f1.16xlarge:1 --terminatesome=f1.2xlarge:2 --forceterminate

    [ 이제, 우리는 다음과 같습니다: 1개의 f1.16xlarges, 0개의 f1.2xlarges, 2개의 m4.16xlarges ]


.. warning:: AWS EC2에서 ``launchrunfarm`` 를 호출하면, ``terminaterunfarm`` 를 호출할 때까지 run farm의 실행 인스턴스에 대해 요금이 청구됩니다. AWS EC2 관리 패널을 확인하여 인스턴스가 원하는 시간에만 실행되도록 해야 할 책임이 있습니다.

.. _firesim-infrasetup:

``firesim infrasetup``
-------------------------

Run Farm을 시작하고 모든 구성 옵션을 설정한 후, ``infrasetup`` 명령은 시뮬레이션을 실행하는 데 필요한 모든 구성 요소를 빌드하고 해당 구성 요소를 Run Farm의 머신에 배포합니다. 명령은 다음과 같은 작업을 수행합니다:

- 시뮬레이션의 내부 표현을 구성합니다. 이는 시뮬레이션의 구성