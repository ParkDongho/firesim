Building Your Own Hardware Designs (FireSim Amazon FPGA Images)
===============================================================

이 섹션에서는 FireSim 시뮬레이션을 위한 Amazon FPGA Image(AFI) 이미지를 빌드하는 과정을 안내합니다.

Amazon S3 Setup
---------------

빌드 과정에서 빌드 시스템은 Amazon의 백엔드 스크립트를 사용하여 Vivado에서 생성된 tar 파일을 AFI로 변환하는 과정에서 이 tar 파일을 Amazon S3에 업로드해야 합니다. 관리자는 이 버킷을 자동으로 생성해 줍니다.

버킷 이름은 전 세계적으로 고유해야 하므로, 관리자가 사용하는 기본 버킷 이름은 ``firesim-(YOUR_AWS_USERNAME)-(REGION)`` 이 됩니다. 관리자가 사용하려는 버킷 이름을 다른 사람이 이미 사용 중이라면, 관리자가 AFI 빌드를 시도할 때 문제가 발생할 수 있습니다.

이러한 경우 기본값에서 버킷 이름을 변경해야 한다면, :gh-file-ref:`deploy/bit-builder-recipes/f1.yaml` 파일에서 ``s3_bucket_name`` 값을 수정하고 ``append_userid_region`` 을 ``false`` 로 설정할 수 있습니다.

Build Recipes
---------------

``deploy/config_build.yaml`` 파일의 ``builds_to_run`` 섹션에는 현재 여러 줄이 포함되어 있습니다. 이는 빌드 시스템에 나열된 모든 빌드를 병렬로 실행하도록 지시하며, 각 빌드의 매개변수는 ``deploy/config_build_recipes.yaml`` 파일의 관련 섹션에 나열됩니다. ``deploy/config_build_recipes.yaml`` 에서 시뮬레이션 시스템의 매개변수를 설정할 수 있습니다.

먼저, 이전 단일 노드 시뮬레이션 가이드에서 사용한 사전 빌드된 버전과 동일한 디자인인 ``firesim_rocket_quadcore_no_nic_l2_llc4mb_ddr3`` 를 빌드해 보겠습니다. 이 디자인은 네 개의 코어를 가지고 있으며, NIC이 없고 4MB LLC + DDR3 메모리 모델을 사용합니다.

이를 위해 ``deploy/config_build.yaml`` 의 ``builds_to_run`` 섹션에서 필요한 빌드 레시피 이름 외의 모든 이름을 삭제하거나 주석 처리해야 합니다. 결과적으로 다음과 같은 내용이 되어야 합니다(``#`` 로 시작하는 줄은 주석입니다):

.. code-block:: yaml

   builds_to_run:
       # this section references builds defined in config_build_recipes.yaml
       # if you add a build here, it will be built when you run buildbitstream
       - firesim_rocket_quadcore_no_nic_l2_llc4mb_ddr3

Build Farm Instance Types
-------------------------------

FireSim은 각 빌드를 ``z1d.2xlarge`` 인스턴스에서 Vivado를 실행하여 수행합니다. 사용되는 인스턴스 유형을 변경하려면 :gh-file-ref:`deploy/build-farm-recipes/aws_ec2.yaml` 의 ``instance_type`` 값을 수정할 수 있습니다. 우리의 실험에 따르면 ``z1d.2xlarge`` 보다 큰 인스턴스를 사용할 경우 이득이 감소합니다. 다른 빌드 인스턴스 유형을 사용하려는 경우, Vivado는 대형 디자인의 경우 32 GiB 이상의 DRAM을 사용한다는 점을 염두에 두십시오.

Running a Build
----------------------

이제 다음과 같이 빌드를 실행할 수 있습니다:

.. code-block:: bash

    firesim buildbitstream

이 명령은 Chisel(또는 Verilog) RTL을 가져와 FPGA에서 실행할 수 있는 AFI/AGFI를 생성하는 전체 빌드 프로세스를 실행합니다. 이 전체 과정은 일반적으로 몇 시간이 소요됩니다. 빌드가 완료되면 ``deploy/results-build/`` 디렉토리에서 빌드 매개변수 설정 이름으로 된 디렉토리를 확인할 수 있으며, 여기에는 AGFI 정보(``AGFI_INFO`` 파일)와 Vivado 빌드 프로세스의 모든 출력물이 포함된 ``cl_firesim`` 하위 디렉토리가 포함됩니다. 또한, 관리자에서 이 실행 중에 발생한 모든 내용을 자세히 설명하는 로그 파일 경로가 출력됩니다(문제가 발생한 경우 이 파일을 보내는 것이 좋습니다). 이메일 주소를 제공한 경우, 빌드가 완료되면 아래와 같은 이메일을 받게 됩니다:

.. figure:: /img/build_complete_email.png
   :alt: Build Completion Email

   Build Completion Email

이메일에 포함되는 것 외에도, 생성된 AGFI를 사용하여 시뮬레이션을 실행할 수 있도록 ``config_hwdb.yaml`` 에 추가할 수 있는 항목이 관리자에 의해 출력됩니다. AWS에서는 물리적인 비트스트림 파일에 접근할 수 없다는 점에 유의하십시오. 최종 비트스트림은 AWS가 관리하는 백엔드에 저장되며, AWS F1 FPGA에 비트스트림을 프로그래밍하는 데 필요한 정보는 ``config_hwdb.yaml`` 항목의 ``agfi:`` 키 값뿐입니다.

이제 FPGA 이미지를 생성하는 방법을 알았으므로, 타겟 디자인을 수정하여 고유한 기능을 추가한 다음, FireSim과 호환되는 FPGA 이미지를 자동으로 빌드할 수 있습니다! 더 고급 FireSim 기능에 대해 알아보려면 왼쪽의 "Advanced Docs" 섹션에서 링크를 선택할 수 있습니다.