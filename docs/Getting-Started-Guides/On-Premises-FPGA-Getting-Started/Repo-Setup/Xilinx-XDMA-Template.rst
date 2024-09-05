FireSim Repo Setup
==============================

.. |manager_machine| replace:: **Manager Machine**
.. |build_farm_machine| replace:: **Build Farm Machines**
.. |run_farm_machine| replace:: **Run Farm Machines**

.. |mach_or_inst| replace:: Machine
.. |mach_or_inst_l| replace:: machines
.. |mach_details| replace:: your local desktop or server
.. |mach_or_inst2| replace:: local machines
.. |simple_setup| replace:: In the simplest setup, a single host machine (e.g. your desktop) can serve the function of all three of these: as the manager machine, the build farm machine (assuming Vivado is installed), and the run farm machine (assuming an FPGA is attached).

Next, we'll clone FireSim on your Manager Machine and run a few final setup steps using scripts in the repo.

Setting up the FireSim Repo
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Machine:** From this point forward, run everything on your Manager Machine, unless otherwise instructed.

우리는 마침내 FireSim의 소스를 가져올 준비가 되었습니다. 이는 Manager Machine에서 수행해야 합니다. 다음 명령을 실행하세요:

.. code-block:: bash
   :substitutions:

    git clone https://github.com/firesim/firesim
    cd firesim
    # checkout latest official firesim release
    # note: this may not be the latest release if the documentation version != "stable"
    git checkout |overall_version|

이제 우리는 Miniforge Conda, 우리의 소프트웨어 패키지 관리자를 설치하고 Conda를 사용하여 기본 소프트웨어 환경을 설정하여 머신을 부트스트랩할 것입니다.

Conda가 설치될 위치를 선택해야 합니다. 이는 기존 Miniforge Conda 설치일 수도 있고 Conda가 설치될 디렉터리일 수도 있습니다 (존재하지 않는 디렉터리).

아래 명령에서 ``REPLACE_ME_USER_CONDA_LOCATION`` 를 선택한 경로로 대체하고 실행하세요:

.. code-block:: bash

   ./scripts/machine-launch-script.sh --prefix REPLACE_ME_USER_CONDA_LOCATION

다른 설정 단계 중에서 이 스크립트는 Miniforge Conda(https://github.com/conda-forge/miniforge)를 설치하고 ``firesim`` 이라는 기본 환경을 생성할 것입니다.

프롬프트가 표시되면 Conda 설치 프로그램이 새 셸을 열 때 자동으로 Conda 환경에 들어가도록 ``~/.bashrc`` 를 수정하도록 허용해야 합니다.

.. warning::
    **``machine-launch-script.sh`` 가 완료되면, 터미널에서 로그아웃하여``.bashrc`` 수정 사항이 적용될 수 있도록 하세요.**

머신에 다시 로그인하면 ``firesim`` Conda 환경에 있어야 합니다.

다음 명령을 실행하여 이를 확인하세요:

.. code-block:: bash

   conda env list

``firesim`` 환경에 있지 않지만 환경이 존재하는 경우, 다음 명령어를 실행하여 환경을 "활성화"하거나 들어갈 수 있습니다:

.. code-block:: bash

   conda activate firesim

다음으로, FireSim repo의 클론으로 돌아가서 다음을 실행하세요:

.. code-block:: bash

    ./build-setup.sh

``build-setup.sh`` 스크립트는 태깅된 브랜치에 있는지를 확인하고, 그렇지 않으면 확인을 요청합니다. 그런 다음 서브모듈을 자동으로 초기화하고 RISC-V 도구 및 기타 종속성을 설치합니다.

``build-setup.sh`` 가 완료되면 다음을 실행하세요:

.. code-block:: bash

    source sourceme-manager.sh --skip-ssh-setup

이 작업은 RISC-V 도구를 경로에 추가하는 등의 다양한 환경 설정 단계를 수행합니다. 처음으로 이 작업을 수행할 때는 시간이 걸릴 수 있지만, 이후에는 즉시 완료될 것입니다.

.. warning::
    **FireSim을 사용할 때마다 FireSim 디렉터리로 이동하여 위와 동일한 인수로 ``sourceme-manager.sh`` 를 다시 소싱해야 합니다.**

Initializing FireSim Config Files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

FireSim 매니저에는 특정 플랫폼에 대한 새로운 구성 파일을 자동으로 제공하는 명령어가 있습니다.

이를 실행하려면 다음을 수행하세요:

.. code-block:: bash
   :substitutions:

    firesim managerinit --platform |platform_name|

이는 초기 구성 파일을 여러 개 생성하며, 다음 섹션에서 이를 편집할 것입니다.

Configuring the FireSim manager to understand your Run Farm Machine setup
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

마지막 설정 단계로, Manager가 우리의 Run Farm machine 설정과 각 Run Farm Machine에 연결된 FPGA 세트를 이해할 수 있도록 FireSim의 구성 파일을 편집할 것입니다.

클론된 FireSim repo 내에서 ``deploy/config_runtime.yaml`` 파일을 열어 다음 키를 표시된 값으로 설정하세요:

* ``default_simulation_dir`` 은 Run Farm Machines에서 선택한 임시 시뮬레이션 디렉토리를 가리켜야 합니다. 이 디렉토리는 시뮬레이션이 실행되는 디렉토리입니다.

* ``run_farm_hosts_to_use`` 은 각 Run Farm Machine에 대해 ``- IP-address: machine_spec`` 쌍 목록이어야 합니다. ``IP-address`` 는 시스템의 IP 주소 또는 호스트 이름이어야 하며 (Manager Machine이 Run Farm Machine에 ssh 접속할 때 사용할 수 있는), ``machine_spec`` 값은 :gh-file-ref:`deploy/run-farm-recipes/externally_provisioned.yaml` 에 있는 ``run_farm_host_specs`` 의 값이어야 합니다. 각 사양은 시스템에 연결된 FPGA 수 및 시스템에 대한 기타 속성을 설명합니다.

다음은 두 가지 구성 예입니다:

**Example 1**: Run Farm에 하나의 FPGA가 연결된 단일 머신이 있고 이 머신이 또한 Manager Machine 인 경우:

.. code-block:: yaml

   ...
       run_farm_hosts_to_use:
           - localhost: one_fpgas_spec
   ...

**Example 2**: Manager Machine과 별개로 두 개의 Run Farm Machines가 있으며, 이들은 ``firesim-runner1.berkeley.edu`` 및 ``firesim-runner2.berkeley.edu`` 의 호스트 이름으로 Manager Machine에서 접근할 수 있으며, 각각 8개의 FPGA가 연결되어 있습니다:

.. code-block:: yaml

   ...
       run_farm_hosts_to_use:
           - firesim-runner1.berkeley.edu: eight_fpgas_spec
           - firesim-runner2.berkeley.edu: eight_fpgas_spec
   ...

* ``default_hw_config`` 은 |hwdb_entry_name| 여야 합니다.

그런 다음 다음 명령을 실행하여 FireSim이 JTAG 프로그래밍에 사용되는 FPGA ID와 시뮬레이션 실행에 사용되는 PCIe ID 간의 매핑을 생성할 수 있도록 합니다. 물리적 레이아웃(예: FPGA가 연결된 PCIe 슬롯)을 변경하는 경우 이 명령을 다시 실행해야 합니다.

.. code-block:: bash
   :substitutions:

   firesim enumeratefpgas

이는 각 Run Farm Machine의 ``/opt/firesim-db.json`` 에 이 매핑을 포함한 데이터베이스 파일을 생성할 것입니다.

이제 첫 번째 FireSim 시뮬레이션을 실행할 준비가 되었습니다! 다음 단계를 진행하세요.