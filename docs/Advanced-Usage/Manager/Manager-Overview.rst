Overview
========================

When you source ``sourceme-manager.sh`` in your copy of the FireSim repo,
you get access to a new command, ``firesim``, which is the FireSim simulation
manager. If you've used tools like Vagrant or Docker, the ``firesim`` program
is to FireSim what ``vagrant`` and ``docker`` are to Vagrant and Docker
respectively. In essence, ``firesim`` lets us manage the entire lifecycle
of FPGA simulations, just like ``vagrant`` and ``docker`` do for VMs and
containers respectively.

"Inputs" to the Manager
-------------------------

매니저는 여러 곳에서 구성 정보를 얻습니다:

- 명령줄 인수, 다음을 포함한:

  - 사용할 구성 파일의 경로

  - 실행할 작업

  - 작업에 대한 인수

- 구성 파일

- 환경 변수

- 네트워크 시뮬레이션을 위한 토폴로지 정의 (``user_topology.py``)

다음 섹션에서는 이러한 입력 내용을 자세히 설명합니다. 계속하려면 Next를 클릭하십시오.

Logging
---------------

매니저는 명령을 실행할 때 자세한 로그를 생성하며, 이는 문제가 발생할 경우 디버깅 목적으로 FireSim 개발자와 공유하는 데 유용합니다. 로그에는 평소 운영 중에 매니저가 stdout/stderr로 보내는 것보다 더 자세한 출력이 포함되어 있으므로, 빌드 및 시뮬레이션을 촉진하기 위해 매니저가 실행하는 상세한 명령을 엿보고 싶을 때도 유용합니다. 로그는 ``firesim/deploy/logs/`` 에 저장됩니다.