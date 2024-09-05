FireSim Asked Questions
=============================

I just bumped the FireSim repository to a newer commit and simulations aren't running. What is going on?
--------------------------------------------------------------------------------------------------------

AGFI 버전이 변경되면 FireSim 시뮬레이션이 구버전 AGFI로 인해 중단되거나 멈출 수 있습니다.
새로운 기본 AGFI를 얻으려면 매니저 초기화를 다시 수행해야 합니다. 다음 명령어를 실행하세요:

.. code-block:: bash

    cd firesim
    source sourceme-manager.sh
    firesim managerinit

Is there a good way to keep track of what AGFI corresponds to what FireSim commit?
----------------------------------------------------------------------------------

``firesim buildbitstream`` 을 실행할 때, FireSim은 어떤 FireSim 커밋이 AGFI를 생성하는 데 사용되었는지 추적합니다.
빌드한 AGFI 목록과 접근 가능한 AGFI를 확인하려면 다음 명령어를 실행하세요:

.. code-block:: bash

    cd firesim
    source sourceme-manager.sh
    aws ec2 describe-fpga-images --fpga-image-ids # 모든 AGFI 이미지 목록 출력

특정 AGFI 이미지를 보려면 ``deploy/config_hwdb.yaml`` 에 있는 AGFI ID를 사용하여 다음 명령어를 실행하세요:

.. code-block:: bash

    cd firesim
    source sourceme-manager.sh
    aws ec2 describe-fpga-images --filter Name=fpga-image-global-id,Values=agfi-<Your ID Here> # 특정 AGFI 이미지 목록 출력

AGFI를 조회한 후, "Description" 필드에서 AGFI를 빌드하는 데 사용된 FireSim 커밋 해시를 확인할 수 있습니다.

자세한 내용은 AWS 문서 https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-fpga-images.html 를 참고하세요.

Help, My Simulation Hangs!
----------------------------

Oof. 이 문제를 해결하기는 어렵지만, :ref:`debugging-hanging-simulators` 를 참고하여 시작해 보세요.

Should My Simulator Produce Different Results Across Runs?
----------------------------------------------------------

아니요.

사이드 채널을 의도적으로 도입하지 않은 한 (예: 상호작용 시뮬레이션을 실행 중이거나 NIC를 인터넷에 연결한 경우),
이는 사용자 정의 브리지 구현이나 FireSim의 버그일 가능성이 큽니다. 실제로 특정 타겟 디자인에 대해
``printf`` 합성, ``assertion`` 합성, ``autocounter`` 또는 ``Auto ILA`` 를 활성화해도 시뮬레이션된 머신의
동작이 달라지지 않아야 합니다.

Is there a way to compress workload results when copying back to the manager instance?
--------------------------------------------------------------------------------------

FireSim은 작업 결과를 매니저 인스턴스로 복사하기 전에 압축하는 기능을 지원하지 않습니다.
대신, ZFS와 같은 최신 파일 시스템을 사용하여 압축을 수행하는 것을 권장합니다.
예를 들어, 데이터를 투명하게 압축하려면 ZFS를 사용하세요:

1. EC2 인스턴스에 새 볼륨을 연결합니다 (런타임 중이거나 실행 중에 연결).
   이 볼륨에 압축된 형식으로 데이터가 저장됩니다.
2. 볼륨이 연결되었는지 확인합니다 (``lsblk -f`` 같은 명령어를 사용).
   이 새 볼륨에는 파일 시스템 타입이 없어야 하며 마운트되지 않은 상태여야 합니다 (볼륨 이름 예: ``nvme1n1``).
3. ZFS를 `ZFS 문서 <https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL-based%20distro/index.html>`__  에 따라 설치하세요.
   매니저 인스턴스의 CentOS 버전을 확인하려면 ``/etc/redhat-release`` 를 확인하세요.
4. 볼륨을 마운트하고 ZFS 파일 시스템을 압축 옵션으로 설정합니다.

.. warning::
    zpool을 생성하면 해당 파티션의 기존 데이터가 모두 삭제됩니다.
    명령어를 실행하기 전에 디바이스 노드가 올바른지 두 번 확인하세요.

.. code-block:: bash

    # /dev/nvme1n1을 올바른 디바이스 노드로 대체하세요
    zpool create -o ashift=12 -O compression=on <POOL_NAME> /dev/nvme1n1
    zpool list
    zfs list

5. 이제 데이터를 저장하기 위해 ``/<POOL_NAME>`` 디렉토리를 일반 디렉토리처럼 사용할 수 있으며,
   이 디렉토리에 저장된 데이터는 압축됩니다. 압축 비율을 확인하려면 ``zfs get compressratio`` 를 사용하세요.

