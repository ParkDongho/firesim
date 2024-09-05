Building and Deploying simulation infrastructure to the Run Farm Machines
----------------------------------------------------------------------------------

The manager automates the process of building and deploying all
components necessary to run your simulation on the Run Farm, including
programming FPGAs. To tell the manager to setup all of our simulation
infrastructure, run the following:

.. code-block:: bash

        firesim infrasetup


For a complete run, you should expect output like the following:

.. code-block:: bash

        $ firesim infrasetup
        FireSim Manager. Docs: https://docs.fires.im
        Running: infrasetup

        Building FPGA software driver.
        ...
        [localhost] Checking if host instance is up...
        [localhost] Copying FPGA simulation infrastructure for slot: 0.
        [localhost] Clearing all FPGA Slots.
        The full log of this run is:
        .../firesim/deploy/logs/2023-03-06--01-22-46-infrasetup-35ZP4WUOX8KUYBF3.log

Many of these tasks will take several minutes, especially on a clean copy of
the repo.  The console output here contains the "user-friendly" version of the
output. If you want to see detailed progress as it happens, ``tail -f`` the
latest logfile in ``firesim/deploy/logs/``.

이 시점에서, 단일 Run Farm 머신에 시뮬레이션을 실행하기 위한 모든 인프라가 갖춰졌으므로, 시뮬레이션을 시작해보겠습니다!

Running the simulation
-----------------------------------------

마지막으로, 시뮬레이션을 실행해보겠습니다! 다음 명령을 실행하세요:

.. code-block:: bash

        firesim runworkload


이 명령은 시뮬레이션을 부팅하고 10초마다 시뮬레이션된 노드의 실시간 상태를 출력합니다. 이 명령을 실행하면 처음에 다음과 같은 출력을 보게 될 것입니다:

.. code-block:: bash

        $ firesim runworkload
        FireSim Manager. Docs: https://docs.fires.im
        Running: runworkload

        Creating the directory: .../firesim/deploy/results-workload/2023-03-06--01-25-34-br-base/
        [localhost] Checking if host instance is up...
        [localhost] Starting FPGA simulation for slot: 0.

빠르게 보지 않으면, 이는 실시간 상태 페이지로 대체되므로 놓칠 수 있습니다:

.. code-block:: text

        FireSim Simulation Status @ 2018-05-19 00:38:56.062737
        --------------------------------------------------------------------------------
        This workload's output is located in:
        .../firesim/deploy/results-workload/2018-05-19--00-38-52-br-base/
        This run's log is located in:
        .../firesim/deploy/logs/2018-05-19--00-38-52-runworkload-JS5IGTV166X169DZ.log
        This status will update every 10s.
        --------------------------------------------------------------------------------
        Instances
        --------------------------------------------------------------------------------
        Hostname/IP:   localhost | Terminated: False
        --------------------------------------------------------------------------------
        Simulated Switches
        --------------------------------------------------------------------------------
        --------------------------------------------------------------------------------
        Simulated Nodes/Jobs
        --------------------------------------------------------------------------------
        Hostname/IP:   localhost | Job: br-base0 | Sim running: True
        --------------------------------------------------------------------------------
        Summary
        --------------------------------------------------------------------------------
        1/1 instances are still running.
        1/1 simulations are still running.
        --------------------------------------------------------------------------------


이 시뮬레이션은 모든 시뮬레이션된 노드가 종료될 때까지 종료되지 않습니다. 이제 시뮬레이션을 실행하고 manager 머신의 다른 터미널을 열어보겠습니다. 그 다음, 다시 FireSim 디렉토리로 이동하여 ``source sourceme-manager.sh --skip-ssh-setup`` 을 실행합니다.

다음으로, Run Farm 머신에 ``ssh`` 로 접속합니다. 만약 Run Farm과 Manager 머신이 동일하다면 ``RUN_FARM_IP_OR_HOSTNAME`` 을 ``localhost`` 로 대체하고, 그렇지 않다면 Run Farm 머신의 IP나 호스트네임으로 대체합니다.

.. code-block:: bash

        source ~/.ssh/AGENT_VARS
        ssh RUN_FARM_IP_OR_HOSTNAME

다음으로 ``screen`` 을 사용하여 시뮬레이션된 시스템의 콘솔에 직접 접속할 수 있습니다:

.. code-block:: bash

        screen -r fsim0

Voila! 이제 시뮬레이션된 시스템에서 Linux 부팅을 볼 수 있고, Linux 로그인 프롬프트가 나타납니다:

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


네트워크 관련 메시지는 무시해도 됩니다 -- 이는 NIC가 없는 디자인을 시뮬레이션하고 있기 때문에 예상되는 상황입니다.

이제 시스템에 로그인할 수 있습니다! 사용자 이름은 ``root`` 이며 암호는 없습니다. 이 시점에서 일반 콘솔이 표시되며, 여기에서 시뮬레이션에 명령을 입력하고 프로그램을 실행할 수 있습니다. 예를 들어:

.. code-block:: bash

        Welcome to Buildroot
        buildroot login: root
        Password:
        # uname -a
        Linux buildroot 4.15.0-rc6-31580-g9c3074b5c2cd #1 SMP Thu May 17 22:28:35 UTC 2018 riscv64 GNU/Linux
        #


이 시점에서 자유롭게 워크로드를 실행할 수 있습니다. 이 가이드를 마무리하기 위해, 시뮬레이션 시스템을 종료하고 manager가 어떻게 작동하는지 확인해보겠습니다. 이를 위해 시뮬레이션 시스템 콘솔에서 ``poweroff -f`` 명령을 실행합니다:

.. code-block:: bash

        Welcome to Buildroot
        buildroot login: root
        Password:
        # uname -a
        Linux buildroot 4.15.0-rc6-31580-g9c3074b5c2cd #1 SMP Thu May 17 22:28:35 UTC 2018 riscv64 GNU/Linux
        # poweroff -f

시뮬레이션 콘솔에서 다음과 같은 출력을 볼 수 있습니다:

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


manager의 폴링 루프가 종료된 것도 확인할 수 있습니다! 다음과 같은 출력이 manager에서 나타납니다:

.. code-block:: text

        FireSim Simulation Status @ 2018-05-19 00:46:50.075885
        --------------------------------------------------------------------------------
        This workload's output is located in:
        .../firesim/deploy/results-workload/2018-05-19--00-38-52-br-base/
        This run's log is located in:
        .../firesim/deploy/logs/2018-05-19--00-38-52-runworkload-JS5IGTV166X169DZ.log
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
        .../firesim/deploy/results-workload/2018-05-19--00-38-52-br-base/
        The full log of this run is:
        .../firesim/deploy/logs/2018-05-19--00-38-52-runworkload-JS5IGTV166X169DZ.log


manager 출력에서 주어진 워크로드 출력 디렉토리를 확인하면 (이번 경우에는 ``.../firesim/deploy/results-workload/2018-05-19--00-38-52-br-base/``), 다음과 같은 내용을 볼 수 있습니다:

.. code-block:: bash

        $ ls -la firesim/deploy/results-workload/2018-05-19--00-38-52-br-base/*/*
        -rw-rw-r-- 1 centos centos  797 May 19 00:46 br-base0/memory_stats.csv
        -rw-rw-r-- 1 centos centos  125 May 19 00:46 br-base0/os-release
        -rw-rw-r-- 1 centos centos 7316 May 19 00:46 br-base0/uartlog

이 파일들은 무엇일까요? 이 파일들은 manager의 설정 파일 (``deploy/workloads/br-base-uniform.json``)에 Run Farm 머신에서 manager 머신의 ``results-workload`` 디렉토리로 자동 복사될 파일로 지정된 파일들입니다. 이는 벤치마크를 자동으로 실행하는 데 유용합니다. :ref:`deprecated-defining-custom-workloads` 섹션은 이 과정을 자세히 설명합니다.

첫 번째 FireSim 시뮬레이션을 실행한 것을 축하합니다! 이제 왼쪽 사이드바에서 FireSim의 고급 기능을 확인해볼 수 있습니다.

다음 단계로 넘어가 직접 비트스트림을 빌드해보기 원하면 Next를 클릭하세요.