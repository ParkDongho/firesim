.. _single-node-sim:

Running a Single Node Simulation
===================================

이제 관리자 인스턴스의 설정을 완료했으므로, 시뮬레이션을 실행할 차례입니다! 이 섹션에서는 **1개의 타겟 노드** 를 시뮬레이션할 것이며, 이를 위해 ``f1.2xlarge`` (1 FPGA) 인스턴스가 필요합니다.

이 명령을 실행하기 전에 관리자 인스턴스에 ``ssh`` 또는 ``mosh`` 로 접속하여 ``sourceme-manager.sh`` 를 소스해야 합니다.

Building target software
------------------------

이 설명에서는 시뮬레이션된 노드에서 Linux를 부팅하고자 한다고 가정합니다. 이를 위해 FireSim과 호환되는 RISC-V Linux 배포판을 빌드해야 합니다. 이 가이드에서는 간단한 buildroot 기반 배포판을 사용할 것입니다. 다음과 같이 수행할 수 있습니다:

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

이 단일 노드 시뮬레이션 가이드에서는 기본값을 수정할 필요가 없지만, 파일의 여러 주요 부분을 살펴보겠습니다.

먼저, 관리자에게 올바른 수량과 유형의 인스턴스를 지정하는 방법을 살펴보겠습니다:

* ``run_farm`` 매핑에서 관리자가 ``mainrunfarm`` 이라는 이름의 Run Farm을 시작하도록 구성되어 있습니다(``run_farm_tag`` 에 의해 지정됨). 여기서 지정된 태그는 관리자가 여러 병렬 Run Farm(각각 일부 타겟 디자인에서 작업 부하를 실행 중)을 구별할 수 있도록 합니다. 이 경우 단일 Run Farm만 실행하므로 기본값으로 충분합니다.
* ``run_farm_hosts_to_use`` 아래에 ``f1.2xlarge`` 에 대한 유일한 비제로 값이 ``1`` 로 설정되어 있습니다. 이 가이드에서는 이 설정이 필요합니다.
* ``run_farm`` 매핑에서 ``run_instance_market``, ``spot_interruption_behavior``, ``spot_max_price`` 와 같은 다른 매개변수들도 볼 수 있습니다. AWS에 익숙한 사용자라면 :ref:`manager-configuration-files` 섹션을 참고하여 이들이 무엇을 하는지 확인할 수 있습니다. 그렇지 않으면 변경하지 마십시오.

다음으로, 타겟 디자인이 관리자에게 지정되는 방식을 살펴보겠습니다. 이는 ``firesim/deploy/config_runtime.yaml``의 ``target_config`` 섹션에 위치하며, 주석이 제거된 상태로 아래에 표시되어 있습니다:

.. code-block:: yaml

    target_config:
        topology: no_net_config
        no_net_num_nodes: 1
        link_latency: 6405
        switching_latency: 10
        net_bandwidth: 200
        profile_interval: -1

        default_hw_config: firesim_rocket_quadcore_no_nic_l2_llc4mb_ddr3

        plusarg_passthrough: ""

이 섹션의 주요 내용은 다음과 같습니다:

* ``topology`` 는 ``no_net_config`` 로 설정되어 있으며, 네트워크를 원하지 않음을 나타냅니다.
* ``no_net_num_nodes`` 는 ``1`` 로 설정되어 있으며, 한 개의 노드만 시뮬레이션하려고 합니다.
* ``default_hw_config`` 는 ``firesim_rocket_quadcore_no_nic_l2_llc4mb_ddr3`` 로 설정되어 있습니다. 이는 ``firesim/deploy/config_hwdb.yaml`` 에 지정된 사전 빌드된 공개 AWS FPGA 이미지를 참조합니다. 이 사전 빌드된 이미지는 네트워크 인터페이스 카드가 없는 4MB L2 캐시와 16GB DDR3를 갖춘 쿼드 코어 Rocket Chip을 모델링합니다.

.. attention::

    **[고급 사용자] Rocket Chip 대신 BOOM 시뮬레이션**: 단일 코어 `BOOM <https://github.com/ucb-bar/riscv-boom>`__ 을 대상으로 시뮬레이션하려면 ``default_hw_config`` 를 ``firesim_boom_singlecore_no_nic_l2_llc4mb_ddr3`` 로 설정하십시오.

마지막으로, 시뮬레이션된 타겟 디자인에서 실행할 타겟 소프트웨어를 정의하는 ``workload`` 섹션을 살펴보겠습니다. 기본값은 다음과 같습니다:

.. code-block:: yaml

    workload:
        workload_name: br-base-uniform.json
        terminate_on_completion: no
        suffix_tag: null

여기서도 ``workload`` 매핑은 변경하지 않을 것입니다. 왜냐하면 시뮬레이션된 시스템에서 지정된 buildroot 기반 Linux(``br-base-uniform.json``)를 실행하려고 하기 때문입니다. ``terminate_on_completion`` 기능은 고급 기능으로, :ref:`manager-configuration-files` 섹션에서 자세히 알아볼 수 있습니다.

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
	Waiting for instance boots: f1.4xlarges
	Waiting for instance boots: m4.16xlarges
	Waiting for instance boots: f1.2xlarges
	i-0d6c29ac507139163 booted!
	The full log of this run is:
	/home/centos/firesim-new/deploy/logs/2018-05-19--00-19-43-launchrunfarm-B4Q2ROAK0JN9EDE4.log

출력이 ``Waiting for instance boots: f1.2xlarges`` 까지 빠르게 진행된 후, ``f1.2xlarge`` 인스턴스가 시작될 때까지 1~2분 정도 소요됩니다. 시작이 완료되면 인스턴스 ID가 출력되고, AWS EC2 관리 콘솔에서도 인스턴스를 볼 수 있습니다. 관리자는 ``config_runtime.yaml`` 파일에서 위에서 설정한 ``run_farm_tag`` 값을 사용하여 시작된 인스턴스에 태그를 지정합니다. 이 값은 관리자가 여러 Run Farm을 구별할 수 있도록 하며, 여러 독립적인 Run Farm이 서로 다른 작업 부하/하드웨어 구성으로 병렬로 실행될 수 있습니다. 이는 :ref:`manager-configuration-files` 및 :ref:`firesim-launchrunfarm` 섹션에서 자세히 설명되며, 여기서는 익숙하지 않아도 됩니다.

Setting up the simulation infrastructure
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

관리자는 또한 시뮬레이션을 실행하는 데 필요한 모든 소프트웨어 구성 요소를 빌드하고 배포합니다. 관리자는 또한 FPGA 프로그래밍을 처리합니다. 시뮬레이션 인프라를 설정하려면 다음 명령을 실행하십시오:

.. code-block:: bash

    firesim infrasetup

완전한 실행을 위해서는 다음과 같은 출력을 예상할 수 있습니다:

.. code-block:: bash

	centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy$ firesim infrasetup
	FireSim Manager. Docs: http://docs.fires.im
	Running

: infrasetup

	Building FPGA software driver for FireSim-FireSimQuadRocketConfig-BaseF1Config
	[172.30.2.174] Executing task 'instance_liveness'
	[172.30.2.174] Checking if host instance is up...
	[172.30.2.174] Executing task 'infrasetup_node_wrapper'
	[172.30.2.174] Copying FPGA simulation infrastructure for slot: 0.
	[172.30.2.174] Installing AWS FPGA SDK on remote nodes.
	[172.30.2.174] Unloading XDMA/EDMA/XOCL Driver Kernel Module.
	[172.30.2.174] Copying AWS FPGA XDMA driver to remote node.
	[172.30.2.174] Loading XDMA Driver Kernel Module.
	[172.30.2.174] Clearing FPGA Slot 0.
	[172.30.2.174] Flashing FPGA Slot: 0 with agfi: agfi-0eaa90f6bb893c0f7.
	[172.30.2.174] Unloading XDMA/EDMA/XOCL Driver Kernel Module.
	[172.30.2.174] Loading XDMA Driver Kernel Module.
	The full log of this run is:
	/home/centos/firesim-new/deploy/logs/2018-05-19--00-32-02-infrasetup-9DJJCX29PF4GAIVL.log

이 작업들 중 많은 부분이 몇 분 정도 소요될 것입니다. 특히 리포지토리의 클린 복사본의 경우. 여기의 콘솔 출력은 "사용자 친화적"인 버전의 출력입니다. 진행 상황을 자세히 보고 싶다면 ``firesim/deploy/logs/`` 에서 최신 로그 파일을 ``tail -f`` 로 확인하십시오.

이 시점에서 Run Farm의 ``f1.2xlarge`` 인스턴스는 시뮬레이션을 실행하는 데 필요한 모든 인프라를 갖추게 됩니다.

이제 시뮬레이션을 시작해 봅시다!

Running the simulation
^^^^^^^^^^^^^^^^^^^^^^^^^

마지막으로, 시뮬레이션을 실행해 봅시다! 이를 위해 다음 명령을 실행합니다:

.. code-block:: bash

	firesim runworkload

이 명령은 시뮬레이션을 부팅하고 시뮬레이션된 노드의 상태를 10초마다 출력합니다. 이 명령을 실행하면 처음에는 다음과 같은 출력이 나타납니다:

.. code-block:: bash

	centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy$ firesim runworkload
	FireSim Manager. Docs: http://docs.fires.im
	Running: runworkload

	Creating the directory: /home/centos/firesim-new/deploy/results-workload/2018-05-19--00-38-52-br-base/
	[172.30.2.174] Executing task 'instance_liveness'
	[172.30.2.174] Checking if host instance is up...
	[172.30.2.174] Executing task 'boot_simulation_wrapper'
	[172.30.2.174] Starting FPGA simulation for slot: 0.
	[172.30.2.174] Executing task 'monitor_jobs_wrapper'

빠르게 보지 않으면 놓칠 수 있습니다. 왜냐하면 실시간 상태 페이지로 대체되기 때문입니다:

.. code-block:: text

	FireSim Simulation Status @ 2018-05-19 00:38:56.062737
	--------------------------------------------------------------------------------
	This workload's output is located in:
	/home/centos/firesim-new/deploy/results-workload/2018-05-19--00-38-52-br-base/
	This run's log is located in:
	/home/centos/firesim-new/deploy/logs/2018-05-19--00-38-52-runworkload-JS5IGTV166X169DZ.log
	This status will update every 10s.
	--------------------------------------------------------------------------------
	Instances
	--------------------------------------------------------------------------------
	Hostname/IP:   172.30.2.174 | Terminated: False
	--------------------------------------------------------------------------------
	Simulated Switches
	--------------------------------------------------------------------------------
	--------------------------------------------------------------------------------
	Simulated Nodes/Jobs
	--------------------------------------------------------------------------------
	Hostname/IP:   172.30.2.174 | Job: br-base0 | Sim running: True
	--------------------------------------------------------------------------------
	Summary
	--------------------------------------------------------------------------------
	1/1 instances are still running.
	1/1 simulations are still running.
	--------------------------------------------------------------------------------

이 명령은 시뮬레이션된 모든 노드가 종료될 때까지 종료되지 않습니다. 시뮬레이션을 실행하고 관리자 인스턴스에 새로운 ssh 연결을 열어 봅시다. 그런 다음, 다시 firesim 디렉토리로 이동하고 ``sourceme-manager.sh``를 다시 소스하여 ssh 키를 설정합니다. 시뮬레이션된 시스템에 액세스하려면, **관리자 인스턴스에서** 상태 페이지에 출력된 IP 주소로 ssh를 실행합니다. 위의 출력에서 시뮬레이션된 시스템이 ``172.30.2.174`` IP를 가진 인스턴스에서 실행 중임을 알 수 있습니다. 따라서 다음 명령을 실행합니다:

.. code-block:: bash

	[관리자 인스턴스에서 실행하세요!]
	ssh 172.30.2.174

이 명령은 시뮬레이션을 실행하는 인스턴스에 로그인합니다. 그런 다음, 시뮬레이션된 시스템의 콘솔에 연결하려면 다음 명령을 실행합니다:

.. code-block:: bash

	screen -r fsim0

짜잔! 이제 시뮬레이션된 시스템에서 Linux가 부팅되고, Linux 로그인 프롬프트가 나타나는 것을 볼 수 있습니다:

.. code-block:: bash

	[truncated Linux boot output]
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
	Starting network: ip: SIOCGIFFLAGS: No such device
	ip: can't find device 'eth0'
	FAIL
	Starting dropbear sshd: OK

	Welcome to Buildroot
	buildroot login:

네트워크에 대한 메시지는 무시해도 됩니다. NIC이 없는 디자인을 시뮬레이션하고 있기 때문입니다.

이제 시스템에 로그인할 수 있습니다! 사용자 이름은 ``root`` 이고 비밀번호는 없습니다. 이 시점에서 시뮬레이션에서 명령을 입력하고 프로그램을 실행할 수 있는 일반 콘솔이 표시됩니다. 예를 들어:

.. code-block:: bash

	Welcome to Buildroot
	buildroot login: root
	Password:
	# uname -a
	Linux buildroot 4.15.0-rc6-31580-g9c3074b5c2cd #1 SMP Thu May 17 22:28:35 UTC 2018 riscv64 GNU/Linux
	#

이제 작업 부하를 원하는 대로 실행할 수 있습니다. 이 가이드를 마무리하기 위해, 시뮬레이션된 시스템을 종료하고 관리자가 어떻게 동작하는지 확인해 봅시다. 이를 위해, 시뮬레이션된 시스템의 콘솔에서 ``poweroff -f`` 명령을 실행하십시오:

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
	[   12.456000] reboot: Power down
	Power off
	time elapsed: 468.8 s, simulation speed = 88.50 MHz
	*** PASSED *** after 41492621244 cycles
	Runs 41492621244 cycles
	[PASS] FireSim Test
	SEED: 1526690334
	Script done, file is uartlog

	[screen is terminating]

관리자 폴링 루프도 종료되었음을 알 수 있습니다! 관리자에서 다음과 같은 출력이 나타날 것입니다:

.. code-block:: bash

	FireSim Simulation Status @ 2018-05-19 00:46:50.075885
	--------------------------------------------------------------------------------
	This workload's output is located in:
	/home/centos/firesim-new/deploy/results-workload/2018-05-19--00-38-52-br-base/
	This run's log is located in

:
	/home/centos/firesim-new/deploy/logs/2018-05-19--00-38-52-runworkload-JS5IGTV166X169DZ.log
	This status will update every 10s.
	--------------------------------------------------------------------------------
	Instances
	--------------------------------------------------------------------------------
	Hostname/IP:   172.30.2.174 | Terminated: False
	--------------------------------------------------------------------------------
	Simulated Switches
	--------------------------------------------------------------------------------
	--------------------------------------------------------------------------------
	Simulated Nodes/Jobs
	--------------------------------------------------------------------------------
	Hostname/IP:   172.30.2.174 | Job: br-base0 | Sim running: False
	--------------------------------------------------------------------------------
	Summary
	--------------------------------------------------------------------------------
	1/1 instances are still running.
	0/1 simulations are still running.
	--------------------------------------------------------------------------------
	FireSim Simulation Exited Successfully. See results in:
	/home/centos/firesim-new/deploy/results-workload/2018-05-19--00-38-52-br-base/
	The full log of this run is:
	/home/centos/firesim-new/deploy/logs/2018-05-19--00-38-52-runworkload-JS5IGTV166X169DZ.log

관리자 출력에서 지정된 작업 부하 출력 디렉토리(이 경우 ``/home/centos/firesim-new/deploy/results-workload/2018-05-19--00-38-52-br-base/``)를 확인하면 다음 파일들이 있습니다:

.. code-block:: bash

	centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy/results-workload/2018-05-19--00-38-52-br-base$ ls -la */*
	-rw-rw-r-- 1 centos centos  797 May 19 00:46 br-base0/memory_stats.csv
	-rw-rw-r-- 1 centos centos  125 May 19 00:46 br-base0/os-release
	-rw-rw-r-- 1 centos centos 7316 May 19 00:46 br-base0/uartlog

이 파일들은 관리자가 시뮬레이션 실행 후 자동으로 관리자에게 복사하도록 지정한 파일들입니다(벤치마크를 자동으로 실행하는 데 유용합니다). :ref:`deprecated-defining-custom-workloads` 섹션에서 이 과정을 자세히 설명합니다.

이제 ``f1.2xlarge`` 인스턴스를 종료하는 것으로 이 가이드를 마무리하겠습니다. 이를 위해 다음 명령을 실행하십시오:

.. code-block:: bash

	firesim terminaterunfarm

다음과 같은 출력을 확인할 수 있습니다:

.. code-block:: bash

	centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy$ firesim terminaterunfarm
	FireSim Manager. Docs: http://docs.fires.im
	Running: terminaterunfarm

	IMPORTANT!: This will terminate the following instances:
	f1.16xlarges
	[]
	f1.4xlarges
	[]
	m4.16xlarges
	[]
	f1.2xlarges
	['i-0d6c29ac507139163']
	Type yes, then press enter, to continue. Otherwise, the operation will be cancelled.

인스턴스를 종료하려면 여기서 ``yes`` 를 입력하고 엔터를 눌러야 합니다. 그러면 다음과 같은 출력을 볼 수 있습니다:

.. code-block:: text

	[ truncated output from above ]
	Type yes, then press enter, to continue. Otherwise, the operation will be cancelled.
	yes
	Instances terminated. Please confirm in your AWS Management Console.
	The full log of this run is:
	/home/centos/firesim-new/deploy/logs/2018-05-19--00-51-54-terminaterunfarm-T9ZAED3LJUQQ3K0N.log

**이 시점에서 인스턴스가 종료 상태 또는 종료 중 상태에 있는지 AWS 관리 콘솔에서 항상 확인해야 합니다. 인스턴스가 적절하게 종료되었는지 확인하는 것은 궁극적으로 사용자의 책임입니다.**

첫 번째 FireSim 시뮬레이션 실행을 축하드립니다! 이 시점에서 왼쪽 사이드바에서 FireSim의 고급 기능 중 일부를 확인할 수 있습니다. 또는 클러스터 시뮬레이션 가이드를 계속 진행할 수 있습니다.

