Configuring Required Infrastructure in Your AWS Account
===========================================================

AWS 계정을 설정한 후, AWS에서 FireSim에 필요한 리소스를 사전 설정해야 합니다. 기존에 AWS 계정이 있는 경우에도 이 단계는 FireSim에 특화된 것이므로 반드시 따라야 합니다.

Select a region
~~~~~~~~~~~~~~~

`EC2 관리 콘솔 <https://console.aws.amazon.com/ec2/v2/home>`__ 로 이동합니다. 오른쪽 상단에서 올바른 리전을 선택했는지 확인합니다. F1 인스턴스는 ``us-east-1`` (N. Virginia), ``us-west-2`` (Oregon), ``ap-southeast-2`` (Sydney), ``eu-central-1`` (Frankfurt), ``eu-west-1`` (Ireland), ``eu-west-2`` (London) 리전에서만 사용할 수 있으므로 이 중 하나를 선택해야 합니다. F1 인스턴스를 지원하는 최신 리전 목록은 `Amazon EC2 인스턴스 유형별 리전 <https://docs.aws.amazon.com/ec2/latest/instancetypes/ec2-instance-regions.html>`__ 페이지를 참조하십시오.

리전을 선택한 후, EC2 콘솔의 링크를 북마크해 두면 항상 올바른 리전의 콘솔로 이동할 수 있어 유용합니다.

Key Setup
~~~~~~~~~

자동화를 활성화하려면, ``firesim`` 이라는 이름의 키를 생성해야 하며, 이를 사용해 모든 인스턴스(Manager Instance, Build Farm, Run Farm)를 시작합니다.

이를 위해 왼쪽 사이드바의 "Network & Security"에서 "Key Pairs"를 클릭합니다. 안내에 따라 키 이름을 ``firesim`` 으로 지정하고, 개인 키를 ``firesim.pem`` 으로 로컬에 저장합니다. 이 키는 로컬 머신에서 모든 인스턴스에 접근하는 데 사용할 수 있습니다. 이후에 이 파일을 매니저 인스턴스에 복사하여 매니저도 이 키를 사용할 수 있도록 할 것입니다.

Double Check your EC2 Instance Limits
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

AWS는 인프라 보호를 위해 신규/이용 빈도가 낮은 계정에서 특정 인스턴스 유형의 사용을 제한합니다. 이러한 제한/쿼터가 어떻게 작동하는지에 대해서는 `여기 <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html#ec2-on-demand-instances-limits>`__ 에서 자세히 알아볼 수 있습니다.

이 가이드를 따르기 위해 계정이 충분한 인스턴스를 시작할 수 있는지 확인하려면, AWS 콘솔의 "Service Quotas" 페이지를 참조해야 합니다. 해당 페이지는 `여기 <https://console.aws.amazon.com/servicequotas/home/services/ec2/quotas/>`__ 에서 접근할 수 있습니다. 페이지를 열면 올바른 리전이 선택되어 있는지 다시 확인하십시오.

이 페이지에 표시된 값은 동시에 실행할 수 있는 최대 vCPUs 수를 나타내며, 이는 실행할 수 있는 시뮬레이션의 규모(예: 병렬 FPGAs의 수)를 제한합니다. 제한을 늘려야 하는 경우, 아래 지침을 따르십시오.

이 가이드를 완료하려면 다음과 같은 제한이 필요합니다:

* ``Running On-Demand F instances``: 64 vCPUs.

    * 이는 8개의 병렬 FPGA에 충분합니다. 각 8 vCPUs = 1 FPGA입니다.

* ``Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances``: 24 vCPUs.

    * 이는 하나의 ``c5.4xlarge`` 매니저 인스턴스와 하나의 ``z1d.2xlarge`` 빌드 팜 인스턴스에 충분합니다.

제한이 부족한 경우, :ref:`limitincrease` 페이지의 지침을 따르십시오.

Start a t2.nano instance to run the remaining configuration commands
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

로컬 머신에서 패키지를 설치하는 번거로운 과정을 피하기 위해, 매우 저렴한 ``t2.nano`` 인스턴스를 시작하여 AWS 계정을 FireSim에 맞게 설정하기 위한 일회성 AWS 구성 명령을 실행합니다. 이 지침의 마지막에 ``t2.nano`` 인스턴스를 종료할 것입니다. 이미 로컬 머신에 ``boto3`` 와 AWS CLI가 설치되어 있는 경우, 이 작업을 로컬에서 수행할 수 있습니다.

``t2.nano`` 를 시작하려면 다음 지침을 따르십시오:

1. `EC2 관리 콘솔 <https://console.aws.amazon.com/ec2/v2/home>`__ 로 이동하여 "Launch Instance"를 클릭합니다.
2. "Application and OS Images (Amazon Machine Image)"에서 기본값인 "Amazon Linux"를 사용합니다.
3. "Instance type"에서 ``t2.nano`` 를 선택합니다.
4. "Key pair (login)"에서 이전에 생성한 ``firesim`` 키 페어를 선택합니다.
5. 오른쪽 사이드바에서 "Launch Instance"를 클릭합니다 (다른 설정은 변경할 필요가 없습니다).
6. 인스턴스 ID를 클릭하여 인스턴스의 공인 IP 주소를 확인합니다.

.. _run-scripts-t2:

Run scripts from the t2.nano
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``t2.nano`` 에 SSH로 접속합니다:

.. code-block:: bash

    ssh -i firesim.pem ec2-user@INSTANCE_PUBLIC_IP

그러면 다음과 같은 화면이 나타날 것입니다:

.. code-block:: text

       ,     #_
       ~\_  ####_        Amazon Linux 2023
      ~~  \_#####\
      ~~     \###|
      ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
       ~~       V~' '->
        ~~~         /
          ~~._.   _/
             _/ _/
           _/m/'
    [ec2-user@ip-172-31-85-76 ~]$

이 머신에서 다음 명령을 실행합니다:

.. code-block:: bash

    aws configure
    [프로그램의 안내에 따르십시오]

프롬프트 내에서 이전에 선택한 것과 동일한 리전(예: ``us-east-1``, ``us-west-2``, ``eu-west-1`` 중 하나)을 지정하고 기본 출력 형식을 ``json`` 으로 설정하십시오. AWS 액세스 키는 AWS 설정의 "Security Credentials" 메뉴에서 생성해야 하며, 이와 관련된 지침은 `Managing access keys <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey>`__ 에서 확인할 수 있습니다. 생성한 AWS 액세스 키 정보는 매니저 인스턴스를 설정할 때 다시 참조할 수 있도록 안전한 장소에 보관하십시오. ``aws configure`` 명령에 대해 더 알고 싶다면 다음 페이지를 참조하십시오: https://docs.aws.amazon.com/cli/latest/reference/configure/index.html

다시 ``t2.nano`` 인스턴스에서 다음 명령을 실행하십시오:

.. code-block:: bash
   :substitutions:

    sudo yum install -y python3-pip
    sudo python3 -m pip install boto3
    sudo python3 -m pip install --upgrade awscli
    wget https://raw.githubusercontent.com/firesim/firesim/|overall_version|/deploy/awstools/aws_setup.py
    chmod +x aws_setup.py
    ./aws_setup.py

마지막 명령은 다음과 같은 출력을 표시해야 합니다:

.. code-block:: text

    Creating VPC for FireSim...
    Success!
    Creating a subnet in the VPC for each availability zone...
    Success!
    Creating a security group for FireSim...
    Success!

이 명령은 계정에 ``firesim`` 이라는 이름의 VPC와 ``firesim`` 이라는 이름의 보안 그룹을 생성합니다.

Terminate the t2.nano
~~~~~~~~~~~~~~~~~~~~~

이 시점에서, 일반적인 계정 구성이 완료되었습니다. 생성한 ``t2.nano`` 인스턴스는 더 이상 필요하지 않으므로 종료해야 합니다 (중요한 데이터는 포함되어 있지 않아야 합니다).

.. _ami-subscription:

Subscribe to the AWS FPGA Developer AMI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`AWS FPGA Developer AMI의 AWS Marketplace 페이지 <https://aws.amazon.com/marketplace/pp/B06VVYBLZZ>`__ 로 이동합니다. FPGA Dev AMI에 가입(무료) 버튼을 클릭하고, EULA를 수락하기 위한 안내를 따릅니다 (인스턴스를 시작하지 마십시오).

이제, 매니저 인스턴스 설정으로 계속 진행하십시오.


