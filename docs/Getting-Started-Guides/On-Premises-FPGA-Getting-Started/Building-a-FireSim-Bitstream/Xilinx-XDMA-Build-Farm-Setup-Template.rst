System Setup
----------------------------------

Here, we'll do some final one-time setup for your Build Farm Machines so that we
can build bitstreams for FireSim simulations automatically. 

**These steps assume that you have already followed the earlier setup steps
required to run simulations.**

As noted earlier, it is highly recommended that you use Ubuntu 20.04 LTS as the
host operating system for all machine types in an on-premises setup, as this is
the OS recommended by Xilinx.

Also recall that we make a distinction between the Manager Machine, the Build
Farm Machine(s), and the Run Farm Machine(s). In a simple setup, these can
all be a single machine, in which case you should run the Build Farm Machine
setup steps below on your single machine.


1. Install Vivado for Builds
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Machines:** Build Farm Machines.

FireSim에서 |fpga_name|에 대한 빌드를 실행하려면 |vivado_with_version|가 필요합니다.
다른 버전은 기본 설정으로 동작하지 않을 가능성이 큽니다.

각 Build Farm machine에서 다음을 수행하십시오:

1. `Xilinx Downloads Website <https://www.xilinx.com/support/download.html>`_ 에서 |vivado_with_version|를 설치합니다. 기본적으로 Vivado는 |vivado_default_install_path|에 설치됩니다. 이 기본값을 유지하는 것이 좋습니다. 다른 경로로 변경하는 경우, 나머지 설정 단계에서 경로를 조정해야 합니다.

2. ``~/.bashrc`` 에 다음을 추가하여 ``ssh`` 를 통해 머신에 접속할 때 ``vivado`` 가 사용 가능하도록 합니다:

.. code-block:: bash
   :substitutions:

   source /tools/Xilinx/Vivado/|vivado_version_number_only|/settings64.sh 

3. |board_package_install|


여러 대의 Build Farm Machine이 있는 경우, 각 머신에 대해 이 과정을 반복해야 합니다.


2. Verify Build Farm Machine environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Machines:** Manager Machine and Run Farm Machines

마지막으로, |vivado_with_version|가 shell 설정 (즉, ``.bashrc``)에 제대로 소싱되어 Build Farm Machines에서 모든 shell이 해당 프로그램을 사용할 수 있는지 확인합시다. 환경 변수는 생성된 모든 비대화형 shell에서 볼 수 있어야 합니다.

다음 명령어를 Manager Machine에서 실행하여 확인할 수 있습니다. Build Farm Machine과 Manager Machine이 동일한 머신인 경우 ``BUILD_FARM_IP`` 를 ``localhost`` 로 대체하고, 다른 머신인 경우 Build Farm Machine의 IP 주소로 대체하십시오.

.. code-block:: bash

    ssh BUILD_FARM_IP printenv


명령어의 출력 결과에 |vivado_with_version| 도구가 인쇄된 환경 변수 (즉, ``PATH`` 및 ``XILINX_VIVADO``)에 존재하는지 확인하십시오.

여러 대의 Build Farm Machine이 있는 경우, 각 Build Farm Machine의 IP 주소와 함께 이 과정을 반복해야 합니다.