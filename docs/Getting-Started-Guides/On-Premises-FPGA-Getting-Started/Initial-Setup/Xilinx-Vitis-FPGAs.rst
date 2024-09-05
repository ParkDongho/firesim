.. |fpga_name| replace:: Xilinx Vitis-enabled U250
.. |vitis_version| replace:: 2022.1
.. |vitis_link| replace:: https://www.xilinx.com/products/design-tools/vitis/vitis-whats-new.html#20221
.. |platform_name| replace:: vitis
.. |tool_type| replace:: Xilinx XRT/Vitis
.. |example_var| replace:: XILINX_XRT

.. |manager_machine| replace:: **Manager Machine**
.. |build_farm_machine| replace:: **Build Farm Machines**
.. |run_farm_machine| replace:: **Run Farm Machines**

Initial Setup/Installation
==============================

.. warning:: ⚠️  **We highly recommend using the XDMA-based U250 flow instead of this
   Vitis-based flow. You can find the XDMA-based flow here:** :ref:`u250-standard-flow`.
   The Vitis-based flow does not support DMA-based FireSim bridges (e.g.,
   TracerV, Synthesizable Printfs, etc.), while the XDMA-based flows support
   all FireSim features. If you're unsure, use the XDMA-based U250 flow
   instead: :ref:`u250-standard-flow`

Background/Terminology
--------------------------

.. |mach_or_inst| replace:: Machine
.. |mach_or_inst_l| replace:: machines
.. |mach_details| replace:: your local desktop or server
.. |mach_or_inst2| replace:: local machines
.. |simple_setup| replace:: In the simplest setup, a single host machine (e.g. your desktop) can serve the function of all three of these: as the manager machine, the build farm machine (assuming Vivado is installed), and the run farm machine (assuming an FPGA is attached).

.. include:: ../../Terminology-Template.rst

FPGA and Tool Setup
------------------------------

Requirements and Installations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

|fpga_name|와 Xilinx Vitis를 지원할 수 있는 기본 머신이 필요합니다.
이 가이드에서는 |fpga_name|를 사용하고 있다고 가정합니다.
다음 링크에서 제공하는 최소 시스템 요구 사항을 참조하십시오: https://docs.xilinx.com/r/en-US/ug1301-getting-started-guide-alveo-accelerator-cards/Minimum-System-Requirements.
|fpga_name| 및 해당 소프트웨어가 설치될 때를 제외하고는 ``sudo`` 권한이 필요하지 않습니다.

다음으로, 다음 지침에 따라 |fpga_name|를 설치하십시오: https://docs.xilinx.com/r/en-US/ug1301-getting-started-guide-alveo-accelerator-cards/Card-Installation-Procedures

물리적인 |fpga_name| 설치 외에도 Xilinx 웹사이트에서 다음 프로그램/패키지를 설치해야 합니다:

* Xilinx Vitis |vitis_version|

  * 설치 링크: |vitis_link|

* Xilinx XRT 및 |fpga_name| 보드 패키지 (Vitis |vitis_version|에 해당)

  * 다음 링크에서 "배포 소프트웨어 설치" 및 "카드 기동 및 검증" 섹션을 완료하십시오: https://docs.xilinx.com/r/en-US/ug1301-getting-started-guide-alveo-accelerator-cards/Installing-the-Deployment-Software

Setup Validation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Xilinx 지침에 따라 |fpga_name|를 설치하고 특정 버전의 Vitis/XRT를 설치한 후, |fpga_name|가 에뮬레이션에 사용될 수 있는지 확인해 보겠습니다.
다음 XRT 명령을 오류 없이 실행할 수 있는지 확인하십시오:

.. code-block:: bash
   :substitutions:

   xbutil examine # 설치된 |fpga_name|와 관련된 BDF를 얻습니다
   xbutil validate --device <CARD_BDF_INSTALLED> --verbose

``xbutil validate`` 명령은 XRT를 사용하여 비트스트림으로 FPGA를 올바르게 플래시할 수 있는지 확인하기 위해 간단한 테스트를 실행합니다.

.. Warning:: 호스트 컴퓨터를 재부팅할 때마다 설정 프로세스의 일부를 다시 실행해야 할 수 있습니다 (예: 셸을 다시 플래시).
     호스트 컴퓨터 재부팅 후 FireSim 시뮬레이션을 계속하기 전에 앞서 언급한 ``xbutil`` 명령이 성공적으로 실행되는지 확인하십시오.

이제 다른 FireSim 설정을 계속할 준비가 되었습니다!


Setting up your On-Premises Machine
--------------------------------------

이 가이드는 FireSim 사용을 위해 단일 노드 클러스터(즉, 단일 머신에서 FPGA 비트스트림 빌드 및 시뮬레이션을 실행)를 설정하는 방법을 안내합니다.
이 단일 머신은 모든 작업이 완료될 "Manager Machine" 역할을 합니다.

마지막으로, 셸 설정(예: ``.bashrc`` 및 또는 ``.bash_profile``)에서 |tool_type| 도구가 소싱되었는지 확인하십시오.
환경 변수는 생성된 비대화형 셸에 표시되어야 합니다.
다음 명령의 출력이 |tool_type| 도구가 환경 변수(즉, "|example_var|")에 있는지 여부를 보여주는지 확인하십시오:

.. code-block:: bash

    ssh localhost printenv

Other Miscellaneous Setup
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

추가로, 비밀번호 없이 ``ssh localhost`` 를 실행할 수 있어야 합니다.
FireSim 관리자 프로그램은 주어진 IP 주소의 BuildFarm/RunFarm 머신으로 ``ssh`` 를 통해 명령을 실행합니다.
비대화형으로 이를 수행하려면 비밀번호 없이 머신(우리의 경우 ``localhost``)에 접근할 수 있어야 합니다.
비밀번호 없이 안전하게 접근하려면 먼저 고유한 SSH 키를 생성하고 이를 ``~/.ssh/authorized_keys`` 파일에 추가할 수 있습니다.
예를 들어, 다음 지침은 ``id_rsa_local`` 이라는 SSH 키를 생성하고 이를 승인된 키에 추가합니다:

.. code-block:: bash

   cd ~/.ssh

   # `id_rsa_local` 이라는 이름과 주석으로 새 키 생성
   # 다른 이름을 사용하고 주석을 수정할 수 있습니다
   ssh-keygen -f id_rsa_local -C "@localhost"

   # 키를 `authorized_keys` 파일에 추가
   cat id_rsa_local.pub >> authorized_keys
   chmod 600 authorized_keys

다음으로, SSH 에이전트가 해당 SSH 키를 사용할 수 있도록 ``~/.ssh/config`` 파일을 수정하여 해당 키를 ``localhost`` 로그인에 사용하십시오.
예를 들어:

.. code-block:: text

   # 다음 줄 추가
   Host localhost
      IdentityFile ~/.ssh/id_rsa_local

``guestmount`` 프로그램을 설치하고 제대로 실행되는지 확인하십시오.
이는 시뮬레이션 결과를 이미지에서 복사해 오기/내보내기에 필요한 다양한 FireSim 단계에 필요합니다.
``guestmount`` 가 오류를 일으키지 않도록 하려면 대부분의 경우 ` 여기 <https://askubuntu.com/questions/1046828/how-to-run-libguestfs-tools-tools-such-as-virt-make-fs-without-sudo>`_ 의 지침을 따라야 할 것입니다.

.. warning:: ``guestmount`` 를 사용하는 경우 명령이 제대로 작동하는지 확인하십시오.
   내부적으로 ``guestmount`` 와 관련된 이전 문제로 인해 FireSim 저장소(및 모든 임시 디렉터리)가 NFS 마운트에 있지 않도록 하십시오.

다음으로, 새로운 ``firesim`` Linux 그룹에 FireSim 스크립트를 설치/활성화하십시오.

.. note::
    이러한 스크립트는 sudo 권한 없이 FireSim 관리자 및 기타 FireSim 도구(FireMarshal)에서 사용됩니다.

먼저, 스크립트가 포함된 FireSim의 임시 버전을 클론합니다:

.. code-block:: bash
   :substitutions:

   cd ~/     # 또는 임시 디렉토리
   mkdir firesim-script-installs
   cd firesim-script-installs
   git clone https://github.com/firesim/firesim
   cd firesim
   # 최신 공식 firesim 릴리스 체크아웃
   # 참고: 문서 버전이 "stable"이 아니면 최신 릴리스가 아닐 수 있음
   git checkout |overall_version|

다음으로 필수 스크립트를 ``/usr/local/bin`` 에 복사합니다:

.. code-block:: bash
   :substitutions:

   sudo cp deploy/sudo-scripts/* /usr/local/bin
   sudo cp platforms/xilinx_alveo_u250/scripts/* /usr/local/bin

이제 임시 클론을 삭제할 수 있습니다:

.. code-block:: bash
   :substitutions:

   rm -rf ~/firesim-script-installs    # 또는 이전에 만든 임시 디렉토리

다음으로, 스크립트의 권한을 변경하고 새로운 ``firesim`` Linux 그룹으로 변경합니다.

.. code-block:: bash
   :substitutions:

   sudo addgroup firesim
   sudo chmod 755 /usr/local/bin/firesim*
   sudo chgrp firesim /usr/local/bin/firesim*

다음으로, 설치된 명령을 실행할 수 있도록 ``firesim`` Linux 그룹을 허용합니다.
``sudo`` 를 사용하여 다음 파일을 입력/생성하십시오:

.. code-block:: bash
   :substitutions:

   sudo visudo /etc/sudoers.d/firesim

그런 다음 다음 줄을 추가합니다:

.. code-block:: bash
   :substitutions:

   %firesim ALL=(ALL) NOPASSWD: /usr/local/bin/firesim-*

이제 파일의 권한을 변경합니다:

.. code-block:: bash
   :substitutions:

   sudo chmod 400 /etc/sudoers.d/firesim

이렇게 하면 ``firesim`` 그룹에 속한 사용자만 스크립트를 실행할 수 있습니다.

다음으로, 사용자를 `firesim` 그룹에 추가합니다.

다음으로, FireSim을 사용하려는 모든 사용자를 만든 ``firesim`` 그룹에 추가합니다.
``YOUR_USER_NAME`` 을 시뮬레이션을 실행할 사용자로 교체하십시오:

.. code-block:: bash
   :substitutions:

   sudo usermod -a -G firesim YOUR_USER_NAME

마지막으로, 사용자가 FireSim 설치 스크립트에 액세스할 수 있는지 확인해 보십시오. 실행:

.. code-block:: bash
   :substitutions:

   sudo -l

출력은 다음과 유사해야 합니다:

.. code-block:: bash
   :substitutions:

   User YOUR_USER_NAME may run the following commands on MACHINE_NAME:
       (ALL) NOPASSWD: /usr/local/bin/firesim-*


Setting up the FireSim Repo
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

마지막으로 FireSim의 소스를 가져올 준비가 되었습니다. 실행:

.. code-block:: bash
   :substitutions:

    git clone https://github.com/firesim/firesim
    cd firesim
    # 최신 공식 firesim 릴리스 체크아웃
    # 참고: 문서 버전이 "stable"이 아니면 최신 릴리스가 아닐 수 있음
    git checkout |overall_version|

다음으로 Miniforge Conda, 소프트웨어 패키지 매니저를 설치하고 Conda를 사용해 기본 소프트웨어 환경을 설정합니다.
먼저 다음을 실행하여 bootstrap 스크립트의 옵션을 확인하십시오:

.. code-block:: bash

   ./scripts/machine-launch-script.sh --help

옵션을 이해하고 적절한 명령을 실행하십시오.
예를 들어, Conda를 이미 설치한 경우 ``--prefix`` 플래그를 사용하여 기존 설치를 가리킬 수 있습니다.
또한 동일한 플래그를 사용하여 sudo가 필요 없는 위치에 Conda를 설치할 수 있습니다.
다음으로, 필요한 옵션을 사용하여 ``machine-launch-script.sh`` 를 실행하십시오.
아래 몇 가지 명령 실행 예제를 제시합니다 (명령을 선택하거나 적절히 수정하십시오):

.. Warning:: Miniforge Conda(Conda의 최소 설치)를 다시 설치하는 것이 좋습니다.

.. tabs::

   .. tab:: With ``sudo`` access (newly install Conda)

      .. code-block:: bash

         sudo ./scripts/machine-launch-script.sh

   .. tab:: Without ``sudo`` access (install Conda to user-specified location)

      .. code-block:: bash

         ./scripts/machine-launch-script.sh --prefix REPLACE_USER_SPECIFIED_LOCATION

   .. tab:: Without ``sudo`` access (use existing Conda)

      .. code-block:: bash

         ./scripts/machine-launch-script.sh --prefix REPLACE_PATH_TO_CONDA

옵션이 선택되면, 스크립트는 Miniforge Conda(https://github.com/conda-forge/miniforge)를 설치하고 ``firesim`` 이라는 기본 환경을 생성합니다.
**이 단계 후에는** ``.bashrc`` **수정이 적용될 수 있도록 머신에서 로그아웃/터미널을 종료하십시오.**

머신에 다시 로그인한 후, ``firesim`` Conda 환경(또는 ``machine-launch-script.sh`` 에서 이름을 설정한 환경)에 존재해야 합니다.
다음 명령을 실행하여 이를 확인하십시오:

.. code-block:: bash

   conda env list

``firesim`` 환경에 있지 않고 환경이 존재하는 경우, 다음을 실행하여 환경을 "활성화"하거나 진입할 수 있습니다:

.. code-block:: bash

   conda activate firesim # 또는 환경 이름

다음 명령을 실행하십시오:

.. code-block:: bash

    ./build-setup.sh

``build-setup.sh`` 스크립트는 태그된 분기에 있는지 확인하고, 그렇지 않으면 확인을 요청합니다.
이는 서브모듈을 초기화하고 RISC-V 도구 및 기타 종속성을 설치합니다.

다음 명령을 실행하십시오:

.. code-block:: bash

    source sourceme-manager.sh --skip-ssh-setup

이는 RISC-V 도구를 경로에 추가하는 등의 다양한 환경 설정 단계를 수행합니다.
처음으로 이를 소싱하면 시간이 걸리지만 이후에는 즉시 완료됩니다.

**FireSim을 사용하려면** ``cd`` **FireSim 디렉토리로 이동하여 이 파일을 주어진 인수로 다시 소싱하십시오.**

Final Environment Check
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

마지막으로, 나머지 가이드의 환경 변수가 올바르게 설정되었는지 확인해 보겠습니다. 실행:

.. code-block:: bash

   echo $PATH

``PATH`` 에 |tool_type| 도구가 있으며, Conda 환경 경로 **이후**에 있는지 확인하십시오. 다음 명령을 실행하십시오:

.. code-block:: bash

   echo $LD_LIBRARY_PATH

``LD_LIBRARY_PATH`` 에 |tool_type| 도구가 있으며 끝에 ``:`` 이 없는지 확인하십시오 (그렇지 않으면 나중에 컴파일 오류가 발생합니다).

마지막으로 ``ssh`` 를 통해 로컬에서 실행할 때 |tool_type| 도구가 검색되는지 확인하십시오. 실행:

.. code-block:: bash

   ssh localhost printenv

로컬에서 실행할 때(``ssh localhost`` 없이)와 유사하게 ``PATH`` 및 ``LD_LIBRARY_PATH`` 가 설정되었는지 확인하십시오.

Completing Setup Using the Manager
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

FireSim 관리자는 나머지 FireSim 설정 과정을 완료하는 명령을 포함하고 있습니다.
실행하려면 다음을 따르십시오:

.. code-block:: bash
   :substitutions:

    firesim managerinit --platform |platform_name|

이는 초기 구성 파일을 생성하며, 이후 섹션에서 이를 수정할 것입니다.

다음을 클릭하여 가이드를 계속 진행하십시오.