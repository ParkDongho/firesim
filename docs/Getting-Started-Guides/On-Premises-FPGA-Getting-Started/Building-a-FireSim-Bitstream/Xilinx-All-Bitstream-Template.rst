Configuring a Build in the Manager
-------------------------------------

``deploy/config_build.yaml`` 파일에서 ``builds_to_run`` 섹션이 여러 줄을 포함하고 있음을 알 수 있습니다. 이는 빌드 시스템에 이 모든 "build recipes"를 병렬로 실행하려고 한다는 것을 나타내며, 각 "build recipe"의 매개변수는 ``deploy/config_build_recipes.yaml`` 파일의 관련 섹션에 나열되어 있습니다.

이 가이드에서는 ``deploy/config_build_recipes.yaml`` 파일의 |hwdb_entry_name| 섹션에서 지정된 |fpga_name|용 기본 FireSim 디자인을 빌드합니다. 이는 시뮬레이션 가이드에서 사용한 사전 빌드된 비트스트림을 빌드하는 데 사용된 동일한 구성입니다.

``deploy/config_build_recipes.yaml`` 의 |hwdb_entry_name| 섹션을 보면 몇 가지 주목할 만한 항목이 있습니다:

* ``TARGET_CONFIG`` 는 이 구성이 단일 DRAM 채널이 있는 단순 단일 코어 RISC-V Rocket임을 지정합니다.

* ``bit_builder_recipe`` 는 :gh-file-ref:`deploy` 디렉토리에서 찾을 수 있는 |bit_builder_path|를 가리키며, FireSim 빌드 시스템에 이 FPGA의 비트스트림을 빌드하는 방법을 알려줍니다.

이 항목을 살펴본 후, 이제 ``deploy/config_build.yaml`` 에서 빌드를 설정해 보겠습니다. 먼저, 사용 가능한 Build Farm Machines을 지정하는 ``build_farm`` 매핑을 설정합니다.

* ``base_recipe`` 는 ``build-farm-recipes/externally_provisioned.yaml`` 에 매핑됩니다. 이는 빌드를 실행하는 머신이 자동으로 프로비저닝 된 클라우드 인스턴스가 아니라 사용자가 설정한 기존 머신임을 FireSim 관리자에게 나타냅니다.

* ``default_build_dir`` 는 Build Farm Machines에서 빌드가 실행될 디렉토리입니다. 기본값인 ``null`` 을 Build Farm Machines에서 임시 빌드 데이터를 저장하려는 경로로 변경하십시오.

* ``build_farm_hosts`` 는 Build Farm에 있는 머신의 IP 주소 또는 호스트 이름 목록을 포함하는 섹션입니다. 기본값으로는 ``localhost`` 가 지정되어 있습니다. 별도의 Build Farm Machine을 사용하는 경우, 여기에서 빌드를 실행하려는 Build Farm Machine의 IP 주소 또는 호스트 이름으로 바꿔야 합니다.

Build Farm을 구성한 후, 빌드하려는 디자인을 지정해 보겠습니다. 이를 위해 ``deploy/config_build.yaml`` 의 ``builds_to_run`` 섹션을 다음과 같이 편집하십시오:

.. code-block:: text
   :substitutions:

   builds_to_run:
       - |hwdb_entry_name_non_code|

즉, ``builds_to_run`` 섹션에서 |hwdb_entry_name| 이외의 모든 항목을 삭제하거나 주석 처리해야 합니다.

Running the Build
----------------------

이제 다음과 같이 빌드를 실행할 수 있습니다:

.. code-block:: bash

    firesim buildbitstream

이는 Chisel (또는 Verilog) RTL을 가져와 |fpga_name| FPGA에서 실행되는 비트스트림을 생성하는 전체 빌드 프로세스를 실행합니다. 이 전체 프로세스는 일반적으로 몇 시간이 걸립니다. 빌드가 완료되면, 빌드 매개변수 설정의 이름을 가진 ``deploy/results-build/`` 디렉토리에 모든 |builder_name| 빌드 프로세스의 출력이 포함된 디렉토리가 생성됩니다. 또한, 관리자는 이 실행 중에 발생한 모든 내용을 자세히 설명하는 로그 파일의 경로를 출력합니다(문제가 발생한 경우 이 파일을 보내는 것이 좋습니다).

관리자는 또한 시뮬레이션을 실행하는 데 사용할 수 있도록 ``config_hwdb.yaml`` 에 추가할 수 있는 항목을 출력합니다. 이 항목에는 최종 생성된 비트스트림 파일의 경로를 값으로 가지는 ``bitstream_tar`` 키가 포함됩니다. ``bitstream_tar`` 에 나열된 파일과 해당 ``config_hwdb.yaml`` 항목을 공유하여 생성된 비트스트림을 다른 사람과 공유할 수 있습니다.

이제 자체 FPGA 이미지를 생성하는 방법을 알았으므로, 대상 디자인을 수정하여 자체 기능을 추가한 후 FireSim과 호환되는 FPGA 이미지를 자동으로 빌드할 수 있습니다!

이것으로 시작 가이드를 마칩니다. 더 고급 FireSim 기능을 알아보려면 왼쪽의 "Advanced Docs" 섹션에서 링크를 선택하십시오.