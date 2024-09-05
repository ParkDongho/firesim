.. include:: Running-Sims-Top-Template.rst

Setting up the manager configuration
-------------------------------------

manager의 모든 런타임 구성 옵션은 ``YOUR_FIRESIM_REPO/deploy/config_runtime.yaml`` 에 있습니다. 이 가이드에서는 이 파일에서 목적에 필요한 부분만 설명합니다. 모든 매개변수에 대한 전체 설명은 :ref:`manager-configuration-files` 섹션에서 찾을 수 있습니다.

이전에 한 변경 사항을 기준으로, 이 파일은 이미 시뮬레이션을 실행하도록 모든 것이 올바르게 설정되어 있을 것입니다.

아래에서 이 라인들 중 몇 가지를 강조하여 어떤 일이 일어나고 있는지 설명할 것입니다:

* 상단에는 시뮬레이션을 실행할 머신을 설명하고 지정하는 ``run_farm`` 매핑이 있습니다.

  * 기본적으로 ``run-farm-recipes/externally_provisioned.yaml`` 의 ``base_recipe`` 를 사용할 것이며, 이는 우리의 Run Farm 머신이 사전에 구성되어 있고, 매니저가 동적으로 이를 시작/종료할 필요가 없음을 의미합니다 (예: 클라우드 인스턴스에서 하는 것처럼).

  * ``default_platform`` 은 우리 FPGA 보드에 대해 자동으로 |deploy_manager_code|로 설정되었습니다.

  * ``default_simulation_dir`` 는 Run Farm Machines에서 시뮬레이션이 실행될 디렉토리입니다. 기본값은 문제 없지만, Run Farm 머신에서 접근할 수 있는 임의의 디렉토리로 변경할 수 있습니다.

  * ``run_farm_hosts_to_use`` 는 각 Run Farm Machine에 대해 ``- IP-address: machine_spec`` 쌍의 목록이어야 합니다. ``IP-address`` 는 시스템의 IP 주소 또는 호스트 이름이어야 하며 (매니저 머신이 Run Farm Machine에 ssh로 접속할 수 있는) ``machine_spec`` 는 :gh-file-ref:`deploy/run-farm-recipes/externally_provisioned.yaml` 에 있는 ``run_farm_host_specs`` 의 값이어야 합니다. 각 사양은 시스템에 연결된 FPGA 수 및 시스템에 대한 기타 속성을 설명합니다. 우리는 이전 단계에서 이미 이것을 구성했습니다.

* ``target_config`` 섹션은 우리가 시뮬레이션하려는 시스템을 설명합니다.

  * ``topology: no_net_config`` 는 시뮬레이션 간에 네트워크가 없음을 나타냅니다.

  * ``no_net_num_nodes: 1`` 는 단일 SoC의 시뮬레이션임을 나타냅니다.

  * ``default_hw_config`` 는 단일 RISC-V Rocket 코어가 있는 사전 제작된 디자인 (우리 FPGA, |hwdb_entry_name|에 대해)으로 설정됩니다. 이것은 일반적으로 기본 설정되지 않지만, 우리는 이전 단계에서 이미 설정했습니다.

* ``workload`` 섹션은 시뮬레이션되는 시스템에서 실행할 워크로드를 설명합니다. 이 경우, 모든 SoC에서 Linux를 부팅할 기본값으로 남겨둘 것입니다.

.. include:: Running-Sims-Bottom-Template.rst