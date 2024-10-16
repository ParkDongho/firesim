Setting up your Manager Instance
================================

Launching a "Manager Instance"
------------------------------

.. warning::
    이 지침은 EC2의 새로운 인스턴스 시작 마법사의 필드를 참조합니다.
    이전 마법사에 대한 참조는 문서의 `version 1.13.4 <https://docs.fires.im/en/1.13.4/>`__ 를 참조하되, AMI ID 선택과 같은 세부 사항이 오래되었을 수 있음을 유의하십시오.

이제 작업을 수행할 "head" 노드 역할을 하는 "Manager Instance" 를 시작해야 합니다. 나중에 ``z1d.2xlarge`` 및 ``f1`` 인스턴스에 작업을 배포할 것이므로 Manager Instance는 상대적으로 저렴한 인스턴스를 사용할 수 있습니다. 그러나 이 가이드에서는 AWS FPGA Developer AMI를 실행하는 ``c5.4xlarge`` 를 사용할 것입니다. (아직 AMI에 구독하지 않았다면, :ref:`ami-subscription` 를 참조하여 구독하십시오. 구독 후 인스턴스를 시작할 수 있게 되기까지 몇 분 정도 소요될 수 있습니다.)

`EC2 관리 콘솔 <https://console.aws.amazon.com/ec2/v2/home>`__ 로 이동합니다. 오른쪽 상단에서 올바른 리전을 선택했는지 확인하십시오.

Manager Instance를 시작하려면 다음 단계를 따르십시오:

#. EC2 관리 콘솔의 메인 페이지에서 *Launch Instance ▼* 버튼을 클릭하고, 나타나는 드롭다운에서 *Launch Instance* 를 클릭합니다. 여기서는 온디맨드 인스턴스를 사용하여 인스턴스를 중지/시작할 때 데이터가 보존되고, 스팟 시장에서 가격 급등 시 데이터가 손실되지 않도록 합니다.
#. *Name* 필드에 인스턴스를 인식할 수 있는 이름을 지정합니다. 예를 들어 ``firesim-manager-1`` 과 같은 이름을 사용할 수 있습니다. 이는 개인의 편의를 위한 것이므로 비워둘 수도 있습니다.
#. *Application and OS Images* 검색 상자에 ``FPGA Developer AMI - 1.12.2-40257ab5-6688-4c95-97d1-e251a40fd1fc`` 를 검색하고 **Community AMIs** 탭에서 나타나는 AMI를 선택합니다 (하나만 나타나야 합니다).

   * 검색 결과가 없으면 검색 문자열의 **버전 번호** 마지막 부분(``Z`` in ``X.Y.Z``)을 증가시켜 시도해 보십시오. 예: ``1.12.2 -> 1.12.3``. 검색 문자열의 다른 부분은 변경하지 마십시오.
   * **AWS Marketplace AMIs** 탭의 `FPGA Developer AMI` 를 사용하지 마십시오. 잘못된 버전의 AMI를 얻을 가능성이 큽니다.

#. *Instance Type* 드롭다운에서 원하는 인스턴스 유형을 선택합니다. ``c5.4xlarge`` (16 코어, 32 GiB DRAM) 또는 ``z1d.2xlarge`` (8 코어, 64 GiB DRAM)를 선택하는 것이 좋습니다.
#. *Key pair (login)* 드롭다운에서 이전에 설정한 ``firesim`` 키 페어를 선택합니다.
#. *Network settings* 드롭다운에서 *edit* 를 클릭하고 다음 설정을 수정합니다:

   #. *VPC - required* 에서 ``firesim`` VPC를 선택합니다. ``firesim`` VPC 내의 서브넷은 어느 것이든 괜찮습니다.
   #. *Firewall (security groups)* 에서 *Select existing security group* 을 클릭하고, 나타나는 *Common security groups* 드롭다운에서 이전에 자동 생성된 ``firesim`` 보안 그룹을 선택합니다. ``for-farms-only-firesim`` 보안 그룹을 선택하지 마십시오(리스트에 나타나지 않아도 괜찮습니다).

#. *Configure storage* 섹션에서 루트 볼륨 크기를 최소 300GB로 늘립니다. 기본값인 120GB는 Vivado 보고서/출력, 대형 파형, XSim 출력 및 시뮬레이션용 대형 루트 파일 시스템이 누적되면서 빠르게 부족해질 수 있습니다. 기본으로 추가된 작은 (5-8GB) 보조 볼륨은 제거해야 합니다.
#. *Advanced details* 드롭다운에서 다음 사항을 변경합니다:

   #. *Termination protection* 에서 Enable을 선택합니다. 이는 Manager Instance가 실수로 종료되는 것을 방지하기 위한 보호 계층을 추가합니다. 일반적인 방법으로 인스턴스를 종료하기 전에 이 설정을 비활성화해야 합니다.
   #. *User data* 에 다음 스크립트를 제공된 텍스트 상자에 붙여넣습니다:

      .. include:: /../scripts/machine-launch-script.sh
         :code: bash

   인스턴스가 부팅되면 Conda를 사용하여 FireSim을 실행하는 데 필요한 모든 종속성을 설치합니다.

#. 구성을 다시 확인하십시오. 이 프로세스를 반복해야 할 수 있는 가장 일반적인 잘못된 구성은 다음과 같습니다:

   #. ``firesim`` VPC를 선택하지 않음.
   #. ``firesim`` 보안 그룹을 선택하지 않음.
   #. ``firesim`` 키 페어를 선택하지 않음.
   #. 잘못된 AMI 선택.

#. 주황색 *Launch Instance* 버튼을 클릭합니다.

.. warning::
    최근 AWS 사용자 중 일부는 인스턴스 시작 과정(``Launch Instance`` 클릭 후)에서 AMI에 이미 구독된 경우에도 "Subscribe"에서 멈추는 문제가 발생하고 있습니다. AWS Marketplace에서 FPGA Developer AMI 페이지로 이동하여, 구독을 클릭한 후(이미 구독된 경우에도), "Continue to Configuration"을 클릭한 다음, 올바른 AMI 버전 및 리전이 선택되었는지 확인하고 "Continue to Launch"를 클릭하면 이 문제를 우회할 수 있었습니다. 마지막으로 "Launch from Website" 드롭다운을 "Launch through EC2"로 변경하고 "Launch"를 클릭하십시오. 이 시점에서 일반적인 인스턴스 시작 페이지로 돌아오지만, AMI가 미리 선택되어 있으며, 나머지 옵션을 업데이트한 후 성공적으로 시작할 수 있습니다.

Access your instance
~~~~~~~~~~~~~~~~~~~~

``ssh`` 대신 `mosh <https://mosh.org/>`__ 를 사용하거나, 매니저 인스턴스에서 실행 중인 화면/tmux 세션과 함께 ``ssh`` 를 사용하는 것을 강력히 권장합니다. 이렇게 하면 매니저 인스턴스와의 네트워크 연결이 불안정할 때 장기 실행 작업이 종료되지 않습니다. 이 인스턴스에서 이전에 붙여넣은 설정 스크립트의 일부로 ``mosh`` 서버가 설치되므로, 먼저 인스턴스에 ``ssh`` 로 접속하여 설정이 완료되었는지 확인해야 합니다.

어느 경우든, 인스턴스에 ``ssh`` 로 접속합니다 (예: ``ssh -i firesim.pem centos@YOUR_INSTANCE_IP``) 그리고 ``/tmp/machine-launchstatus`` 파일에 다음 텍스트가 포함되어 있는지 확인합니다:

.. code-block:: bash

    $ cat /tmp/machine-launchstatus
    machine launch script started
    machine launch script completed

설치 프로세스의 실시간 출력을 보려면 ``tail -f /tmp/machine-launchstatus.log`` 명령을 실행할 수도 있습니다.

``machine launch script completed`` 가 ``/tmp/machine-launchstatus`` 에 나타나면, 시스템에서 종료하고 다시 ``ssh`` 로 접속합니다. ``mosh`` 를 사용하려면 ``mosh`` 로 다시 접속하십시오.

Key Setup, Part 2
~~~~~~~~~~~~~~~~~

매니저 인스턴스가 시작되었으므로, AWS에서 이전에 다운로드한 개인 키(``firesim.pem``)를 매니저 인스턴스의 ``~/firesim.pem`` 으로 복사합니다. 이 단계는 매니저가 인스턴스를 시작할 때 해당 인스턴스에 접근할 수 있도록 하기 위해 필요합니다.

.. _setting-up-firesim-repo:

Setting up the FireSim Repo
---------------------------

이제 FireSim 소스를 가져올 준비가 되었습니다. 다음 명령을 실행합니다:

.. code-block:: bash

    git clone https://github.com/firesim/firesim
    cd firesim
    # 최신 공식 FireSim 릴리스 체크아웃
    # 참고: 문서 버전이 "stable"이 아닌 경우 최신 릴리스가 아닐 수 있습니다.
    git checkout |overall_version|
    ./build-setup.sh

``build-setup.sh`` 스크립트는 태그된 브랜치에 있는지 확인하고, 그렇지 않은 경우 확인을 요청합니다. 이 스크립트는 서브모듈을 초기화하고 RISC-V 도구 및 기타 종속성을 설치합니다.

다음 명령을 실행합니다:

.. code-block:: bash

    source sourceme-manager.sh

이 명령은 AWS 셸을 초기화하고, RISC-V 도구를 경로에 추가하며, ``ssh-agent`` 를 시작하여 다른 노드에 접근할 때 ``~/firesim.pem`` 을 자동으로 제공하도록 합니다. 이 파일을 처음으로 소싱할 때는 시간이 걸리지만, 그 이후에는 즉시 완료됩니다. 또한 ``firesim.pem`` 키에 암호가 필요한 경우, 여기서 암호를 요청하며 ``ssh-agent`` 가 이를 캐시할 것입니다.

**FireSim을 사용하기 위해 매니저 인스턴스에 로그인할 때마다** ``cd`` **명령으로 firesim 디렉토리로 이동한 후 이 파일을 다시 소싱해야 합니다.**

Completing Setup Using the Manager
----------------------------------

FireSim 매니저에는 나머지 FireSim 설정 과정을 인터랙티브하게 안내하는 명령이 포함되어 있습니다. 다음 명령을 실행하여 시작합니다:

.. code-block:: bash

    firesim managerinit --platform f1

이 명령은 먼저 인스턴스에서 AWS 자격 증명을 설정하도록 요청하며, 이는 매니저가 빌드/시뮬레이션 노드를 자동으로 관리할 수 있도록 합니다. ``t2.nano`` 인스턴스에서 설정 명령을 실행할 때 생성한 것과 동일한 AWS 액세스 키를 사용할 수 있습니다(:ref:`run-scripts-t2` 참조). 프롬프트에서 지금까지 선택한 것과 동일한 리전(예: ``us-east-1``, ``us-west-2``, ``ap-southeast-2``, ``eu-central-1``, ``eu-west-1`` 또는 ``eu-west-2`` 중 하나)을 지정하고, 기본 출력 형식을 ``json`` 으로 설정해야 합니다.

다음으로 이메일 주소를 입력하라는 메시지가 표시되며, FPGA 빌드 완료 시 알림을 이메일로 받고자 하는 경우 입력합니다. 알림을 받고 싶지 않다면 이 항목을 비워둘 수 있지만, 이는 권장되지 않습니다. 다음으로 초기 구성 파일이 생성되며, 이 파일은 나중에 수정할 것입니다.

이제 FireSim 시뮬레이션을 시작할 준비가 되었습니다! Next를 클릭하여 단일 노드 시뮬레이션을 실행하는 방법을 알아보십시오.

