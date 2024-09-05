.. _cluster-sim:

Running a Cluster Simulation
===============================

이제 8개의 노드로 구성된 클러스터를 시뮬레이션해 보겠습니다. 이 클러스터는 하나의 8포트 Top-of-Rack(ToR) 스위치와 200 Gbps, 2μs 링크로 연결된 네트워크로 구성됩니다. 이를 위해 ``f1.16xlarge`` (8 FPGA) 인스턴스가 필요합니다.

이 명령을 실행하기 전에 관리자 인스턴스에 ``ssh`` 또는 ``mosh`` 로 접속하여 ``sourceme-manager.sh`` 를 소스해야 합니다.

Building target software
------------------------

단일 노드 시작 가이드에서 타겟 소프트웨어를 이미 빌드한 경우, 다음 섹션(Setting up the manager configuration)으로 넘어가면 됩니다. 단일 노드 시작 가이드를 따르지 않았다면 이 섹션을 계속 진행하십시오.

이 설명에서는 시뮬레이션된 클러스터의 각 노드에서 buildroot 기반의 Linux 배포판을 부팅하고자 한다고 가정합니다. 이를 위해 FireSim과 호환되는 RISC-V Linux 배포판을 빌드해야 합니다. 다음과 같이 수행할 수 있습니다:

.. code-block:: bash

    cd firesim/target-design/chipyard/software/firemarshal
    ./init-submodules.sh
    ./marshal -v build br-base.json
    ./marshal -v install br-base.json

이 과정은 ``c5.4xlarge`` 인스턴스에서 약 10~15분 정도 소요됩니다. 완료되면 다음 파일들이 생성됩니다:

-  ``firesim/target-design/chipyard/software/firemarshal/images/firechip/br-base/br-base-bin`` - 시뮬레이션할 노드용 부트로더 + Linux 커널 이미지.
-  ``firesim/target-design/chipyard/software/firemarshal/images/firechip/br-base/br-base.img`` - 시뮬레이션할 각 노드용 디스크 이미지.

이 파일들은 더 복잡한 작업 부하를 빌드하거나(:ref:`deprecated-defining-custom-workloads` 섹션 참조) 배포할 때 사용될 기본 이미지로 사용됩니다.

Setting up the manager configuration
-------------------------------------

관리자의 모든 런타임 구성 옵션은 ``firesim/deploy/config_runtime.yaml`` 파일에서 설정됩니다. 이 가이드에서는 필요한 부분만 설명하겠습니다. 모든 매개변수에 대한 전체 설명은 :ref:`manager-configuration-files` 섹션에서 확인할 수 있습니다.

이 파일을 열면 기본 설정(수정하지 않았다고 가정)이 다음과 같다는 것을 알 수 있습니다:

.. include:: DOCS_EXAMPLE_config_runtime.yaml
   :code: yaml

8-노드 클러스터 시뮬레이션을 위해 이 파일의 기본값은 거의 적합하지만 약간의 수정이 필요합니다. 변경해야 하는 중요한 매개변수를 정리해 보겠습니다:

* ``f1.16xlarges:``: 이 매개변수를 ``1``로 변경합니다. 이는 ``launchrunfarm`` 명령을 호출할 때 ``f1.16xlarge`` 인스턴스 하나를 시작하도록 관리자에게 지시합니다.
* ``f1.2xlarges:``: 이 매개변수를 ``0``으로 변경합니다. 이는 ``launchrunfarm`` 명령을 호출할 때 ``f1.2xlarge`` 인스턴스를 시작하지 않도록 관리자에게 지시합니다.
* ``topology:``: 이 매개변수를 ``example_8config`` 으로 변경합니다. 이는 ``deploy/runtools/user_topology.py`` 에 정의된 ``example_8config`` 이라는 이름의 토폴로지를 사용하도록 관리자에게 지시합니다. 이 토폴로지는 하나의 ToR 스위치와 8개의 노드로 구성된 클러스터를 시뮬레이션합니다.
* ``default_hw_config:`` 이 매개변수를 ``firesim_rocket_quadcore_nic_l2_llc4mb_ddr3`` 로 변경합니다. 이는 관리자에게 우리가 시뮬레이션하는 토폴로지의 각 노드에 대해 512 KB의 L2, 4 MB의 L3(LLC), 16 GB의 DDR3 및 NIC을 가진 쿼드코어 Rocket Chip 구성을 시뮬레이션하도록 지시합니다.

.. attention::

    **[고급 사용자] Rocket Chip 대신 BOOM 시뮬레이션**: 단일 코어 `BOOM <https://github.com/ucb-bar/riscv-boom>`__을 대상으로 시뮬레이션하려면 ``default_hw_config`` 를 ``firesim_boom_singlecore_nic_l2_llc4mb_ddr3`` 로 설정하십시오.

변경할 필요는 없지만 주목할 만한 매개변수도 있습니다:

* ``link_latency: 6405``: 이는 링크 지연이 6405 사이클인 네트워크를 모델링합니다. 우리는 3.2 Ghz에서 실행되는 프로세서를 모델링하고 있으므로, 1 사이클 = 1/3.2 ns이고, 따라서 6405 사이클은 대략 2마이크로초입니다.
* ``switching_latency: 10``: 이는 포트 간 지연이 최소 10사이클인 스위치를 모델링합니다.
* ``net_bandwidth: 200``: 이는 NIC의 대역폭을 200 Gbit/s로 설정합니다. 현재 하드웨어 수정을 하지 않고 이보다 낮은 정수 값으로 설정할 수 있습니다.

여기서 ``run_instance_market``, ``spot_interruption_behavior``, ``spot_max_price`` 와 같은 다른 매개변수들도 볼 수 있습니다. AWS에 익숙한 사용자라면 :ref:`manager-configuration-files` 섹션을 참고하여 이들이 무엇을 하는지 확인할 수 있습니다. 그렇지 않으면 변경하지 마십시오.

단일 노드 시작 가이드와 마찬가지로 여기서도 시뮬레이션된 시스템에서 기본 buildroot 기반 Linux를 실행하고자 하므로 ``workload:`` 매핑은 변경하지 않습니다. ``terminate_on_completion`` 기능은 고급 기능으로, :ref:`manager-configuration-files` 섹션에서 자세히 알아볼 수 있습니다.

Launching a Simulation!
-----------------------------

이제 관리자에게 단일 노드 시뮬레이션을 실행하기 위해 필요한 모든 정보를 제공했으니, 실제로 인스턴스를 시작하고 실행해 보겠습니다!

Starting the Run Farm
^^^^^^^^^^^^^^^^^^^^^^^^^

먼저, 관리자가 앞서 지정한 대로 Run Farm을 시작하도록 합니다. 이렇게 하면 실행 중인 EC2 인스턴스(관리자를 포함하여)에 대해 요금이 부과되기 시작합니다.

Run Farm을 시작하려면 다음 명령을 실행합니다:

.. code-block:: bash

    firesim launchrunfarm

다음과 같은 출력을 예상할 수 있습니다:

.. code-block:: bash

    centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy$ firesim launchrunfarm
    FireSim Manager. Docs: http://docs.fires.im
    Running: launchrunfarm

    Waiting for instance boots: f1.16xlarges
    i-09e5491cce4d5f92d booted!
    Waiting for instance boots: f1.4xlarges
    Waiting for instance boots: m4.16xlarges
    Waiting for instance boots: f1.2xlarges
    The full log of this run is:
    /home/centos/firesim-new/deploy/logs/2018-05-19--06-05-53-launchrunfarm-ZGVP753DSU1Y9Q6R.log

출력이 ``Waiting for instance boots: f1.16xlarges`` 까지 빠르게 진행된 후, ``f1.16xlarge`` 인스턴스가 시작될 때까지 1~2분 정도 소요됩니다. 시작이 완료되면 인스턴스 ID가 출력되고, AWS EC2 관리 콘솔에서도 인스턴스를 볼 수 있습니다. 관리자는 ``config_runtime.yaml`` 파일에서 위에서 설정한 ``run_farm_tag`` 값을 사용하여 시작된 인스턴스에 태그를 지정합니다. 이 값은 관리자가 여러 Run Farm을 구별할 수 있도록 하며, 여러 독립적인 Run Farm이 서로 다른 작업 부하/하드웨어 구성으로 병렬로 실행될 수 있습니다. 이는 :ref:`manager-configuration-files` 및 :ref:`firesim-launchrunfarm` 섹션에서 자세히 설명되며, 여기서는 익숙하지 않아도 됩니다.

Setting up the simulation infrastructure
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

관리자는 또한 시뮬레이션을 실행하는 데 필요한 모든 소프트웨어 구성 요소(네트워크의 경우 스위치 포함)를 빌드하고 배포합니다. 관리자는 또한 FPGA 프로그래밍을 처리합니다. 시뮬레이션 인프라를 설정하려면 다음 명령을 실행하십시오:

.. code-block:: bash

    firesim infrasetup

완전한 실행을 위해서는 다음과 같은 출력을 예상할 수 있습니다:

.. code-block:: bash

    centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy$ firesim infrasetup
    FireSim Manager. Docs: http://docs.fires.im


    Running: infrasetup

    Building FPGA software driver for FireSim-FireSimQuadRocketConfig-BaseF1Config
    Building switch model binary for switch switch0
    [172.30.2.178] Executing task 'instance_liveness'
    [172.30.2.178] Checking if host instance is up...
    [172.30.2.178] Executing task 'infrasetup_node_wrapper'
    [172.30.2.178] Copying FPGA simulation infrastructure for slot: 0.
    [172.30.2.178] Copying FPGA simulation infrastructure for slot: 1.
    [172.30.2.178] Copying FPGA simulation infrastructure for slot: 2.
    [172.30.2.178] Copying FPGA simulation infrastructure for slot: 3.
    [172.30.2.178] Copying FPGA simulation infrastructure for slot: 4.
    [172.30.2.178] Copying FPGA simulation infrastructure for slot: 5.
    [172.30.2.178] Copying FPGA simulation infrastructure for slot: 6.
    [172.30.2.178] Copying FPGA simulation infrastructure for slot: 7.
    [172.30.2.178] Installing AWS FPGA SDK on remote nodes.
    [172.30.2.178] Unloading XDMA/EDMA/XOCL Driver Kernel Module.
    [172.30.2.178] Copying AWS FPGA XDMA driver to remote node.
    [172.30.2.178] Loading XDMA Driver Kernel Module.
    [172.30.2.178] Clearing FPGA Slot 0.
    [172.30.2.178] Clearing FPGA Slot 1.
    [172.30.2.178] Clearing FPGA Slot 2.
    [172.30.2.178] Clearing FPGA Slot 3.
    [172.30.2.178] Clearing FPGA Slot 4.
    [172.30.2.178] Clearing FPGA Slot 5.
    [172.30.2.178] Clearing FPGA Slot 6.
    [172.30.2.178] Clearing FPGA Slot 7.
    [172.30.2.178] Flashing FPGA Slot: 0 with agfi: agfi-09e85ffabe3543903.
    [172.30.2.178] Flashing FPGA Slot: 1 with agfi: agfi-09e85ffabe3543903.
    [172.30.2.178] Flashing FPGA Slot: 2 with agfi: agfi-09e85ffabe3543903.
    [172.30.2.178] Flashing FPGA Slot: 3 with agfi: agfi-09e85ffabe3543903.
    [172.30.2.178] Flashing FPGA Slot: 4 with agfi: agfi-09e85ffabe3543903.
    [172.30.2.178] Flashing FPGA Slot: 5 with agfi: agfi-09e85ffabe3543903.
    [172.30.2.178] Flashing FPGA Slot: 6 with agfi: agfi-09e85ffabe3543903.
    [172.30.2.178] Flashing FPGA Slot: 7 with agfi: agfi-09e85ffabe3543903.
    [172.30.2.178] Unloading XDMA/EDMA/XOCL Driver Kernel Module.
    [172.30.2.178] Loading XDMA Driver Kernel Module.
    [172.30.2.178] Copying switch simulation infrastructure for switch slot: 0.
    The full log of this run is:
    /home/centos/firesim-new/deploy/logs/2018-05-19--06-07-33-infrasetup-2Z7EBCBIF2TSI66Q.log

이 작업들 중 많은 부분이 몇 분 정도 소요될 것입니다. 특히 리포지토리의 클린 복사본의 경우(``f1.16xlarges`` 의 경우 부팅하는 데 몇 분 정도 소요되므로 ``Checking if host instance is up...`` 단계에서 멈춰 있는 것처럼 보일 수 있습니다). 여기의 콘솔 출력은 "사용자 친화적"인 버전의 출력입니다. 진행 상황을 자세히 보고 싶다면 ``firesim/deploy/logs/`` 에서 최신 로그 파일을 ``tail -f`` 로 확인하십시오.

이 시점에서 Run Farm의 ``f1.16xlarge`` 인스턴스는 시뮬레이션을 실행하는 데 필요한 모든 인프라를 갖추게 됩니다.

이제 시뮬레이션을 시작해 봅시다!

Running the simulation
^^^^^^^^^^^^^^^^^^^^^^^^^

마지막으로, 시뮬레이션을 실행해 봅시다! 이를 위해 다음 명령을 실행합니다:

.. code-block:: bash

	firesim runworkload

이 명령은 8포트 스위치 시뮬레이션을 부팅한 후 8개의 Rocket Chip FPGA 시뮬레이션을 시작하고, 시뮬레이션된 노드와 스위치의 상태를 10초마다 출력합니다. 이 명령을 실행하면 처음에는 다음과 같은 출력이 나타납니다:

.. code-block:: bash

	centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy$ firesim runworkload
	FireSim Manager. Docs: http://docs.fires.im
	Running: runworkload

	Creating the directory: /home/centos/firesim-new/deploy/results-workload/2018-05-19--06-28-43-br-base/
	[172.30.2.178] Executing task 'instance_liveness'
	[172.30.2.178] Checking if host instance is up...
	[172.30.2.178] Executing task 'boot_switch_wrapper'
	[172.30.2.178] Starting switch simulation for switch slot: 0.
	[172.30.2.178] Executing task 'boot_simulation_wrapper'
	[172.30.2.178] Starting FPGA simulation for slot: 0.
	[172.30.2.178] Starting FPGA simulation for slot: 1.
	[172.30.2.178] Starting FPGA simulation for slot: 2.
	[172.30.2.178] Starting FPGA simulation for slot: 3.
	[172.30.2.178] Starting FPGA simulation for slot: 4.
	[172.30.2.178] Starting FPGA simulation for slot: 5.
	[172.30.2.178] Starting FPGA simulation for slot: 6.
	[172.30.2.178] Starting FPGA simulation for slot: 7.
	[172.30.2.178] Executing task 'monitor_jobs_wrapper'

빠르게 보지 않으면 놓칠 수 있습니다. 왜냐하면 시뮬레이션이 시작되면 실시간 상태 페이지로 대체되기 때문입니다:

.. code-block:: text

    FireSim Simulation Status @ 2018-05-19 06:28:56.087472
    --------------------------------------------------------------------------------
    This workload's output is located in:
    /home/centos/firesim-new/deploy/results-workload/2018-05-19--06-28-43-br-base/
    This run's log is located in:
    /home/centos/firesim-new/deploy/logs/2018-05-19--06-28-43-runworkload-ZHZEJED9MDWNSCV7.log
    This status will update every 10s.
    --------------------------------------------------------------------------------
    Instances
    --------------------------------------------------------------------------------
    Hostname/IP:   172.30.2.178 | Terminated: False
    --------------------------------------------------------------------------------
    Simulated Switches
    --------------------------------------------------------------------------------
    Hostname/IP:   172.30.2.178 | Switch name: switch0 | Switch running: True
    --------------------------------------------------------------------------------
    Simulated Nodes/Jobs
    --------------------------------------------------------------------------------
    Hostname/IP:   172.30.2.178 | Job: br-base1 | Sim running: True
    Hostname/IP:   172.30.2.178 | Job: br-base0 | Sim running: True
    Hostname/IP:   172.30.2.178 | Job: br-base3 | Sim running: True
    Hostname/IP:   172.30.2.178 | Job: br-base2 | Sim running: True
    Hostname/IP:   172.30.2.178 | Job: br-base5 | Sim running: True
    Hostname/IP:   172.30.2.178 | Job: br-base4 | Sim running: True
    Hostname/IP:   172.30.2.178 | Job: br-base7 | Sim running: True
    Hostname/IP:   172.30.2.178 | Job: br-base6 | Sim running: True
    --------------------------------------------------------------------------------
    Summary
    --------------------------------------------------------------------------------
    1/1 instances are still running.
    8/8 simulations are still running.
    --------------------------------------------------------------------------------

정확한 사이클로 네트워크를 시뮬레이션하는 모드에서는 시뮬레이션된 노드 중 하나라도 종료되면 시뮬레이션

이 종료됩니다. 시뮬레이션을 실행하고 관리자 인스턴스에 새로운 ssh 연결을 열어 봅시다. 그런 다음, 다시 firesim 디렉토리로 이동하고 ``sourceme-manager.sh`` 를 다시 소스하여 ssh 키를 설정합니다. 시뮬레이션된 시스템에 액세스하려면, **관리자 인스턴스에서** 상태 페이지에 출력된 IP 주소로 ssh를 실행합니다. 위의 출력에서 시뮬레이션된 시스템이 ``172.30.2.178`` IP를 가진 인스턴스에서 실행 중임을 알 수 있습니다. 따라서 다음 명령을 실행합니다:

.. code-block:: bash

	[관리자 인스턴스에서 실행하세요!]
	ssh 172.30.2.178

이 명령은 시뮬레이션을 실행하는 인스턴스에 로그인합니다. 이 머신에서 ``screen -ls`` 명령을 실행하여 실행 중인 모든 시뮬레이션 구성 요소의 목록을 확인할 수 있습니다. ``fsim0`` 에서 ``fsim7`` 까지의 스크린에 연결하면 시뮬레이션된 8개 노드 중 어느 노드의 콘솔에도 연결할 수 있습니다. 스위치에 대한 추가 스크린도 있지만, 성능상의 이유로 기본적으로는 이곳에 흥미로운 출력이 없습니다.

예를 들어, 0번 노드의 콘솔로 들어가고 싶다면 다음과 같이 콘솔에 연결할 수 있습니다:

.. code-block:: bash

	screen -r fsim0

짜잔! 이제 시뮬레이션된 노드에서 Linux가 부팅되고, Linux 로그인 프롬프트가 나타나는 것을 볼 수 있습니다:

.. code-block:: text

    [truncated Linux boot output]
    [    0.020000] Registered IceNet NIC 00:12:6d:00:00:02
    [    0.020000] VFS: Mounted root (ext2 filesystem) on device 254:0.
    [    0.020000] devtmpfs: mounted
    [    0.020000] Freeing unused kernel memory: 140K
    [    0.020000] This architecture does not have kernel memory protection.
    mount: mounting sysfs on /sys failed: No such device
    Starting logging: OK
    Starting mdev...
    mdev: /sys/dev: No such file or directory
    modprobe: can't change directory to '/lib/modules': No such file or directory
    Initializing random number generator... done.
    Starting network: OK
    Starting dropbear sshd: OK

    Welcome to Buildroot
    buildroot login:

단일 노드 no-nic 시뮬레이션도 실행했다면, 이 부팅 출력에서 차이점을 확인할 수 있습니다. 여기서는 Linux가 NIC와 할당된 MAC 주소를 인식하고 부팅 시 자동으로 ``eth0`` 인터페이스를 활성화합니다.

이제 시스템에 로그인할 수 있습니다! 사용자 이름은 ``root`` 이고 비밀번호는 없습니다. 이 시점에서 시뮬레이션에서 명령을 입력하고 프로그램을 실행할 수 있는 일반 콘솔이 표시됩니다. 예를 들어:

.. code-block:: bash

	Welcome to Buildroot
	buildroot login: root
	Password:
	# uname -a
	Linux buildroot 4.15.0-rc6-31580-g9c3074b5c2cd #1 SMP Thu May 17 22:28:35 UTC 2018 riscv64 GNU/Linux
	#

이제 작업 부하를 원하는 대로 실행할 수 있습니다. 이 시작 가이드를 마무리하기 위해, 시뮬레이션된 시스템을 종료하고 관리자가 어떻게 동작하는지 확인해 봅시다. 이를 위해, 시뮬레이션된 시스템의 콘솔에서 ``poweroff -f`` 명령을 실행하십시오:

.. code-block:: bash

	Welcome to Buildroot
	buildroot login: root
	Password:
	# uname -a
	Linux buildroot 4.15.0-rc6-31580-g9c3074b5c2cd #1 SMP Thu May 17 22:28:35 UTC 2018 riscv64 GNU/Linux
	# poweroff -f

시뮬레이션 콘솔에서 다음과 같은 출력이 나타날 것입니다:

.. code-block:: bash

	# poweroff -f
	[    3.748000] reboot: Power down
	Power off
	time elapsed: 360.5 s, simulation speed = 37.82 MHz
	*** PASSED *** after 13634406804 cycles
	Runs 13634406804 cycles
	[PASS] FireSim Test
	SEED: 1526711978
	Script done, file is uartlog

	[screen is terminating]

관리자 폴링 루프도 종료되었음을 알 수 있습니다! 관리자에서 다음과 같은 출력이 나타날 것입니다:

.. code-block:: text

	--------------------------------------------------------------------------------
	Instances
	--------------------------------------------------------------------------------
	Instance IP:   172.30.2.178 | Terminated: False
	--------------------------------------------------------------------------------
	Simulated Switches
	--------------------------------------------------------------------------------
	Instance IP:   172.30.2.178 | Switch name: switch0 | Switch running: True
	--------------------------------------------------------------------------------
	Simulated Nodes/Jobs
	--------------------------------------------------------------------------------
	Instance IP:   172.30.2.178 | Job: br-base1 | Sim running: True
	Instance IP:   172.30.2.178 | Job: br-base0 | Sim running: False
	Instance IP:   172.30.2.178 | Job: br-base3 | Sim running: True
	Instance IP:   172.30.2.178 | Job: br-base2 | Sim running: True
	Instance IP:   172.30.2.178 | Job: br-base5 | Sim running: True
	Instance IP:   172.30.2.178 | Job: br-base4 | Sim running: True
	Instance IP:   172.30.2.178 | Job: br-base7 | Sim running: True
	Instance IP:   172.30.2.178 | Job: br-base6 | Sim running: True
	--------------------------------------------------------------------------------
	Summary
	--------------------------------------------------------------------------------
	1/1 instances are still running.
	7/8 simulations are still running.
	--------------------------------------------------------------------------------
	Teardown required, manually tearing down...
	[172.30.2.178] Executing task 'kill_switch_wrapper'
	[172.30.2.178] Killing switch simulation for switchslot: 0.
	[172.30.2.178] Executing task 'kill_simulation_wrapper'
	[172.30.2.178] Killing FPGA simulation for slot: 0.
	[172.30.2.178] Killing FPGA simulation for slot: 1.
	[172.30.2.178] Killing FPGA simulation for slot: 2.
	[172.30.2.178] Killing FPGA simulation for slot: 3.
	[172.30.2.178] Killing FPGA simulation for slot: 4.
	[172.30.2.178] Killing FPGA simulation for slot: 5.
	[172.30.2.178] Killing FPGA simulation for slot: 6.
	[172.30.2.178] Killing FPGA simulation for slot: 7.
	[172.30.2.178] Executing task 'screens'
	Confirming exit...
	[172.30.2.178] Executing task 'monitor_jobs_wrapper'
	[172.30.2.178] Slot 0 completed! copying results.
	[172.30.2.178] Slot 1 completed! copying results.
	[172.30.2.178] Slot 2 completed! copying results.
	[172.30.2.178] Slot 3 completed! copying results.
	[172.30.2.178] Slot 4 completed! copying results.
	[172.30.2.178] Slot 5 completed! copying results.
	[172.30.2.178] Slot 6 completed! copying results.
	[172.30.2.178] Slot 7 completed! copying results.
	[172.30.2.178] Killing switch simulation for switchslot: 0.
	FireSim Simulation Exited Successfully. See results in:
	/home/centos/firesim-new/deploy/results-workload/2018-05-19--06-39-35-br-base/
	The full log of this run is:
	/home/centos/firesim-new/deploy/logs/2018-05-19--06-39-35-runworkload-4CDB78E3A4IA9IYQ.log

클러스터의 경우, 하나의 시뮬레이터를 종료하면 전체 시뮬레이션이 종료됩니다. 이는 우리가 현재 전역 사이클 정확 시뮬레이션에서 하나의 노드를 제거하기 위한 "연결 끊기" 메커니즘을 구현하지 않았기 때문입니다.

관리자 출력에서 지정된 작업 부하 출력 디렉토리(이 경우 ``/home/centos/firesim-new/deploy/results-workload/2018-05-19--06-39-35-br-base/``)를 확인하면

 다음 파일들이 있습니다:

.. code-block:: bash

	centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy/results-workload/2018-05-19--06-39-35-br-base$ ls -la */*
	-rw-rw-r-- 1 centos centos  797 May 19 06:45 br-base0/memory_stats.csv
	-rw-rw-r-- 1 centos centos  125 May 19 06:45 br-base0/os-release
	-rw-rw-r-- 1 centos centos 7476 May 19 06:45 br-base0/uartlog
	-rw-rw-r-- 1 centos centos  797 May 19 06:45 br-base1/memory_stats.csv
	-rw-rw-r-- 1 centos centos  125 May 19 06:45 br-base1/os-release
	-rw-rw-r-- 1 centos centos 8157 May 19 06:45 br-base1/uartlog
	-rw-rw-r-- 1 centos centos  797 May 19 06:45 br-base2/memory_stats.csv
	-rw-rw-r-- 1 centos centos  125 May 19 06:45 br-base2/os-release
	-rw-rw-r-- 1 centos centos 8157 May 19 06:45 br-base2/uartlog
	-rw-rw-r-- 1 centos centos  797 May 19 06:45 br-base3/memory_stats.csv
	-rw-rw-r-- 1 centos centos  125 May 19 06:45 br-base3/os-release
	-rw-rw-r-- 1 centos centos 8157 May 19 06:45 br-base3/uartlog
	-rw-rw-r-- 1 centos centos  797 May 19 06:45 br-base4/memory_stats.csv
	-rw-rw-r-- 1 centos centos  125 May 19 06:45 br-base4/os-release
	-rw-rw-r-- 1 centos centos 8157 May 19 06:45 br-base4/uartlog
	-rw-rw-r-- 1 centos centos  797 May 19 06:45 br-base5/memory_stats.csv
	-rw-rw-r-- 1 centos centos  125 May 19 06:45 br-base5/os-release
	-rw-rw-r-- 1 centos centos 8157 May 19 06:45 br-base5/uartlog
	-rw-rw-r-- 1 centos centos  797 May 19 06:45 br-base6/memory_stats.csv
	-rw-rw-r-- 1 centos centos  125 May 19 06:45 br-base6/os-release
	-rw-rw-r-- 1 centos centos 8157 May 19 06:45 br-base6/uartlog
	-rw-rw-r-- 1 centos centos  797 May 19 06:45 br-base7/memory_stats.csv
	-rw-rw-r-- 1 centos centos  125 May 19 06:45 br-base7/os-release
	-rw-rw-r-- 1 centos centos 8157 May 19 06:45 br-base7/uartlog
	-rw-rw-r-- 1 centos centos  153 May 19 06:45 switch0/switchlog

이 파일들은 관리자가 시뮬레이션 실행 후 자동으로 관리자에게 복사하도록 지정한 파일들입니다(벤치마크를 자동으로 실행하는 데 유용합니다). 각 시뮬레이션된 노드와 클러스터의 각 시뮬레이션된 스위치에 대해 디렉토리가 있습니다. :ref:`deprecated-defining-custom-workloads` 섹션에서 이 과정을 자세히 설명합니다.

이제 ``f1.16xlarge`` 인스턴스를 종료하는 것으로 이 가이드를 마무리하겠습니다. 이를 위해 다음 명령을 실행하십시오:

.. code-block:: bash

	firesim terminaterunfarm

다음과 같은 출력을 확인할 수 있습니다:

.. code-block:: bash

	centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy$ firesim terminaterunfarm
	FireSim Manager. Docs: http://docs.fires.im
	Running: terminaterunfarm

	IMPORTANT!: This will terminate the following instances:
	f1.16xlarges
	['i-09e5491cce4d5f92d']
	f1.4xlarges
	[]
	m4.16xlarges
	[]
	f1.2xlarges
	[]
	Type yes, then press enter, to continue. Otherwise, the operation will be cancelled.

인스턴스를 종료하려면 여기서 ``yes`` 를 입력하고 엔터를 눌러야 합니다. 그러면 다음과 같은 출력을 볼 수 있습니다:

.. code-block:: text

	[ truncated output from above ]
	Type yes, then press enter, to continue. Otherwise, the operation will be cancelled.
	yes
	Instances terminated. Please confirm in your AWS Management Console.
	The full log of this run is:
	/home/centos/firesim-new/deploy/logs/2018-05-19--06-50-37-terminaterunfarm-3VF0Z2KCAKKDY0ZU.log

**이 시점에서 인스턴스가 종료 상태 또는 종료 중 상태에 있는지 AWS 관리 콘솔에서 항상 확인해야 합니다. 인스턴스가 적절하게 종료되었는지 확인하는 것은 궁극적으로 사용자의 책임입니다.**

클러스터 FireSim 시뮬레이션을 실행한 것을 축하드립니다! 이제 왼쪽 사이드바에서 FireSim의 고급 기능 중 일부를 확인할 수 있습니다. 또는, 다음을 클릭하여 맞춤형 FPGA 이미지를 만드는 방법을 보여주는 가이드로 이동하십시오.
