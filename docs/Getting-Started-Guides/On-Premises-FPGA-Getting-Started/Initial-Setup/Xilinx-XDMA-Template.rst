Initial Setup/Installation
==============================

Background/Terminology
--------------------------

.. |manager_machine| replace:: **Manager Machine**
.. |build_farm_machine| replace:: **Build Farm Machines**
.. |run_farm_machine| replace:: **Run Farm Machines**

.. |mach_or_inst| replace:: Machine
.. |mach_or_inst_l| replace:: machines
.. |mach_details| replace:: your local desktop or server
.. |mach_or_inst2| replace:: local machines
.. |simple_setup| replace:: In the simplest setup, a single host machine (e.g. your desktop) can serve the function of all three of these: as the manager machine, the build farm machine (assuming Vivado is installed), and the run farm machine (assuming an FPGA is attached).

.. include:: ../../Terminology-Template.rst


System Setup
----------------------------------

다음 섹션에서는 FireSim 클러스터의 각 기계 유형에서 FireSim을 실행하기 위해 설치해야 할 항목을 설명합니다. 아래의 세 가지 기계 유형은 모두 설정에서 단일 기계에 매핑될 수 있습니다. 이 경우 여러 기계 유형에 필요한 단계라 해도 중복 없이 단일 기계에서 모든 설치 지침을 따라야 합니다 (즉, 동일한 기계에서 여러 기계 유형에 필요한 단계를 반복 실행하지 않음).

.. warning::
    **Xilinx에서 권장하는 OS인 Ubuntu 20.04 LTS를 온프레미스 설정의 모든 기계 유형의 호스트 운영 체제로 사용하는 것을 강력히 권장합니다.**

다음 단계는 ``sudo`` 가 필요한 단계와 필요하지 않은 단계로 나뉩니다.
``sudo`` 로 초기 설정 후에는 FireSim에서 ``sudo`` 접근 권한이 필요하지 않습니다.
공유 기계를 사용하는 경우 대부분의 경우 기본적인 ``sudo`` 기반 설정이 이미 완료되어 있으므로 사용자는 비-``sudo`` 기반 설정을 계속 진행해야 합니다.

``sudo`` Setup
^^^^^^^^^^^^^^

**1. Install/enable FireSim scripts to new** ``firesim`` **Linux group**

.. note::
    이러한 스크립트는 ``sudo`` 접근 권한이 필요 없는 FireSim 관리자 및 기타 FireSim 도구 (예: FireMarshal)에서 사용됩니다.

**Machines:** Manager Machine, Run Farm Machines, Build Farm Machines.

먼저, 스크립트가 포함된 임시 FireSim 버전을 클론합시다:

.. code-block:: bash
   :substitutions:

   cd ~/     # 또는 임시 디렉토리
   mkdir firesim-script-installs
   cd firesim-script-installs
   git clone https://github.com/firesim/firesim
   cd firesim
   # 최신 공식 firesim 릴리스를 체크아웃합니다.
   # 참고: 문서 버전이 "stable"이 아닌 경우 최신 릴리스가 아닐 수 있습니다.
   git checkout |overall_version|

다음으로, 필요한 스크립트를 ``/usr/local/bin`` 으로 복사합니다:

.. code-block:: bash
   :substitutions:

   sudo cp deploy/sudo-scripts/* /usr/local/bin
   sudo cp platforms/xilinx_alveo_u250/scripts/* /usr/local/bin

이제 임시 클론을 삭제할 수 있습니다:

.. code-block:: bash
   :substitutions:

   rm -rf ~/firesim-script-installs    # 또는 이전에 생성한 임시 디렉토리

다음으로, 스크립트의 권한을 변경하고 새로운 ``firesim`` Linux 그룹에 추가합시다.

.. code-block:: bash
   :substitutions:

   sudo addgroup firesim
   sudo chmod 755 /usr/local/bin/firesim*
   sudo chgrp firesim /usr/local/bin/firesim*

그 다음, ``firesim`` Linux 그룹이 사전 설치된 명령을 실행할 수 있도록 허용합니다.
`sudo` 로 다음 파일에 들어가거나 생성합니다:

.. code-block:: bash
   :substitutions:

   sudo visudo /etc/sudoers.d/firesim

그 다음, 다음 줄을 추가합니다:

.. code-block:: bash
   :substitutions:

   %firesim ALL=(ALL) NOPASSWD: /usr/local/bin/firesim-*

그 다음, 파일의 권한을 변경합니다:

.. code-block:: bash
   :substitutions:

   sudo chmod 400 /etc/sudoers.d/firesim

이는 ``firesim`` 그룹의 사용자만 스크립트를 실행할 수 있도록 합니다.

**2. Add your user to the** ``firesim`` **group**

**Machines:** Manager Machine, Run Farm Machines, Build Farm Machines.

다음으로, FireSim을 사용하려는 모든 사용자를 만든 ``firesim`` 그룹에 추가합니다.
``YOUR_USER_NAME`` 을 시뮬레이션을 실행할 사용자로 대체해야 합니다:

.. code-block:: bash
   :substitutions:

   sudo usermod -a -G firesim YOUR_USER_NAME

마지막으로, FireSim 설치된 스크립트에 접근할 수 있는지 확인하려면 다음을 실행합니다:

.. code-block:: bash
   :substitutions:

   sudo -l

출력은 이와 유사해야 합니다:

.. code-block:: bash
   :substitutions:

   User YOUR_USER_NAME may run the following commands on MACHINE_NAME:
       (ALL) NOPASSWD: /usr/local/bin/firesim-*

**3. Install Vivado Lab and Cable Drivers**

**Machines:** Run Farm Machines.

`Xilinx 다운로드 웹사이트 <https://www.xilinx.com/support/download.html>`_ 로 가서 ``Vivado 2023.1: Lab Edition - Linux`` 을 다운로드하십시오.

다운로드한 ``.tar.gz`` 파일을 추출한 후에:

.. code-block:: bash

   cd [EXTRACTED VIVADO LAB DIRECTORY]
   sudo ./installLibs.sh
   sudo ./xsetup --batch Install --agree XilinxEULA,3rdPartyEULA --edition "Vivado Lab Edition (Standalone)"

이로써 Vivado Lab이 ``/tools/Xilinx/Vivado_Lab/2023.1/`` 에 설치되었습니다.

사용 편의를 위해 다음을 ``~/.bashrc`` 의 끝에 추가합니다:

.. code-block:: bash

   source /tools/Xilinx/Vivado_Lab/2023.1/settings64.sh


그런 다음 새로운 터미널을 열거나 ``~/.bashrc`` 를 소싱하십시오.

다음으로, 케이블 드라이버를 다음과 같이 설치합니다:

.. code-block:: bash

   cd /tools/Xilinx/Vivado_Lab/2023.1/data/xicom/cable_drivers/lin64/install_script/install_drivers/
   sudo ./install_drivers


**4. Install the Xilinx XDMA and XVSEC drivers**

**Machines:** Run Farm Machines.

.. warning::
    이 명령은 커널이 업데이트될 때마다 (보통 기계가 재부팅될 때마다) 다시 실행해야 합니다.

먼저, 다음을 실행하여 XDMA 커널 모듈 소스를 클론합니다:

.. code-block:: bash

   cd ~/   # 또는 작업하길 원하는 디렉토리
   git clone https://github.com/Xilinx/dma_ip_drivers
   cd dma_ip_drivers
   git checkout 0e8d321
   cd XDMA/linux-kernel/xdma

|nitefury_patch_xdma|

.. code-block:: bash

   sudo make install


이제 모듈이 삽입될 수 있는지 테스트합니다:

.. code-block:: bash

   sudo insmod $(find /lib/modules/$(uname -r) -name "xdma.ko") poll_mode=1
   lsmod | grep -i xdma


위 두 번째 명령은 XDMA 드라이버가 로드되었음을 나타내는 출력을 생성해야 합니다.

다음, 커널 버전 호환성 문제로 인해 별도의 저장소에서 가져온 XVSEC 드라이버에 대해 동일한 작업을 수행합니다:

.. code-block:: bash

   cd ~/   # 또는 작업하길 원하는 디렉토리
   git clone https://github.com/paulmnt/dma_ip_drivers dma_ip_drivers_xvsec
   cd dma_ip_drivers_xvsec
   git checkout 302856a
   cd XVSEC/linux-kernel/

   make clean all
   sudo make install

이제 모듈이 삽입될 수 있는지 테스트합니다:

.. code-block:: bash

   sudo modprobe xvsec
   lsmod | grep -i xvsec


위 두 번째 명령은 XVSEC 드라이버가 로드되었음을 나타내는 출력을 생성해야 합니다.

또한 다음 명령에 대해 출력을 얻었는지 확인하십시오 (일반적으로 ``/usr/local/sbin/xvsecctl``):

.. code-block:: bash

   which xvsecctl


**5. Install your FPGA(s)**

**Machines:** Run Farm Machines.

이제 |fpga_name|_ FPGA를 Run Farm Machines에 연결합시다:

1. 기계를 끄십시오.

2. |fpga_name|_ FPGA를 삽입하십시오 |fpga_attach_prereq|

3. FPGA와 호스트 기계 사이의 추가 전원 케이블을 연결하십시오. |fpga_power_info|

4. JTAG 용으로 FPGA와 호스트 기계 사이의 USB 케이블을 연결하십시오 |jtag_help|

5. 기계를 부팅하십시오.

6. ``bitstream_tar`` 에 나열된 URL 아래에 있는 |hwdb_entry_name| 항목에서 FPGA용 기존 비트스트림 tar 파일을 얻으십시오: :gh-file-ref:`deploy/sample-backup-configs/sample_config_hwdb.yaml`.

7. ``.tar.gz`` 파일을 알려진 위치에 다운로드하고 추출하십시오. |mcs_info|

8. Vivado Lab을 열고 "Open Hardware Manager"를 클릭하십시오. 그런 다음 "Open Target"을 클릭하고 "Auto connect"를 누르십시오.

9. FPGA를 우클릭하고 "Add Configuration Memory Device"를 클릭하십시오. |fpga_name|_, |fpga_spi_part_number|을 Configuration Memory Part로 선택하십시오. Configuration Memory Device를 프로그래밍하라는 메시지가 나타나면 "OK"를 클릭하십시오.

10. Configuration file로 ``firesim.mcs`` 를 선택하십시오 |extra_mcs|

11. "Verify"를 선택 해제하고 OK를 클릭하십시오.

12. FPGA를 우클릭하고 "Boot from Configuration Memory Device"를 클릭하십시오.

13. Configuration memory device 프로그래밍이 완료되면 기계를 완전히 종료하십시오 (즉, FPGA는 완전히 전원이 꺼져야 합니다 |dip_switch_extra|).

14. 기계를 콜드 부팅하십시오. 콜드 부팅은 FPGA가 플래시에서 성공적으로 다시 프로그래밍되도록 합니다.

15. 기계가 부팅되면 다음을 실행하여 FPGA가 제대로 설정되었는지 확인하십시오:

.. code-block:: bash

   lspci -vvv -d 10ee:903f

성공하면 Xilinx가 제조사로 표시되고 두 개의 메모리 영역이 있는 항목이 표시됩니다.
Run Farm Machine에 추가한 각 FPGA에 대해 하나의 항목이 표시되어야 합니다.

.. note:: |jtag_cable_reminder|


**6. Install sshd**

**Machines:** Manager Machine, Run Farm Machines, and Build Farm Machines

Ubuntu에서 ``openssh-server`` 를 다음과 같이 설치하십시오:

.. code-block:: bash

   sudo apt install openssh-server

**7. Check Hard File Limit**

**Machine:** Manager Machine

다음 명령의 출력을 확인하십시오:

.. code-block:: bash

   ulimit -Hn

결과가 16384 이상이면 "Setting up the FireSim Repo"로 계속 진행할 수 있습니다. 그렇지 않으면 다음을 실행하십시오:

.. code-block:: bash

   echo "* hard nofile 16384" | sudo tee --append /etc/security/limits.conf

그런 다음 기계를 재부팅하십시오.

Non-``sudo`` Setup
^^^^^^^^^^^^^^^^^^

**1. Fix default** ``.bashrc``

**Machines:** Manager Machine, Run Farm Machines, Build Farm Machines.

비상호작용 모드에서도 ``~/.bashrc`` 파일의 다양한 부분이 실행되도록 해야 합니다.
이를 위해 ``~/.bashrc`` 파일에서 다음 섹션을 제거합니다:

.. code-block:: bash

   # 비상호작용 모드로 실행되지 않으면 아무 것도 하지 않음
   case $- in
        *i*) ;;
          *) return;;
   esac

**2. Set up SSH Keys**

**Machines:** Manager Machine.

관리자 기계에서 관리자 기계 (ssh localhost), Run Farm Machines, 그리고 Build Farm Machines로 ssh하기 위해 사용할 키페어를 생성합니다:

.. code-block:: bash

   cd ~/.ssh
   ssh-keygen -t ed25519 -C "firesim.pem" -f firesim.pem
   [비밀번호 생성]

그 다음, 관리자 기계에서 이 키를 ``authorized_keys`` 파일에 추가합니다:

.. code-block:: bash

   cd ~/.ssh
   cat firesim.pem.pub >> authorized_keys
   chmod 0600 authorized_keys

또한 이 공개 키를 모든 Run Farm 및 Build Farm Machines의 ``~/.ssh/authorized_keys`` 파일에 복사해야 합니다.

다시 관리자 기계로, ``ssh-agent`` 를 설정합시다:

.. code-block:: bash

   cd ~/.ssh
   ssh-agent -s > AGENT_VARS
   source AGENT_VARS
   ssh-add firesim.pem


기계를 재부팅하거나 (또는 ``ssh-agent`` 를 종료하는 경우), FireSim을 사용하기 전에 위의 네 명령어를 다시 실행해야 합니다.
``ssh-agent`` 가 이미 실행 중인 경우 신규 터미널을 열면 단순히 ``source ~/.ssh/AGENT_VARS`` 를 실행하기만 하면 됩니다.

마지막으로, 이제 비밀번호 입력 없이 ``ssh localhost`` 및 Run Farm과 Build Farm Machines에 ssh할 수 있는지 확인하십시오.

**3. Verify Run Farm Machine environment**

**Machines:** Manager Machine and Run Farm Machines

마지막으로, |tool_type_lab| 도구가 쉘 설정 (예: ``.bashrc``)에서 올바르게 소싱되었는지 확인합시다.
즉, Run Farm Machines의 모든 쉘이 해당 프로그램을 사용할 수 있어야 합니다. 환경 변수는 생성된 비상호작용 쉘에도 표시되어야 합니다.

Run Farm 기계와 Manager 기계가 동일한 경우 ``RUN_FARM_IP`` 를 ``localhost`` 로, 다른 기계인 경우 해당 기계의 IP 주소로 교체하여 관리자 기계에서 다음 명령을 실행하여 이를 확인할 수 있습니다.

.. code-block:: bash

    ssh RUN_FARM_IP printenv


명령의 출력에 |tool_type_lab| 도구가 환경 변수 (즉, ``PATH``)에 포함되어 있는지 확인하십시오.

여러 Run Farm 기계가 있는 경우 각 Run Farm 기계에 대해 이 과정을 반복하여 ``RUN_FARM_IP`` 를 다른 Run Farm 기계의 IP 주소로 교체해야 합니다.

축하합니다! 이제 시뮬레이션을 실행할 기계/클러스터 설정을 완료했습니다. 가이드를 계속 진행하려면 Next를 클릭하십시오.