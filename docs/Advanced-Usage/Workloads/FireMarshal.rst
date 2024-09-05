.. _firemarshal:

FireMarshal
=======================================

FireSim에서의 워크로드 생성은 Chipyard의 **FireMarshal** 도구(Chipyard의 ``software/firemarshal``  경로에 위치함)가 처리합니다.

FireMarshal의 **워크로드** 는 타겟 시스템의 논리적 노드에 할당되는 일련의 **Jobs** 로 구성됩니다. 만약 특정 작업이 지정되지 않으면, 해당 워크로드는 ``uniform`` 으로 간주되며 시스템의 모든 노드에 대해 단일 이미지가 생성됩니다. 워크로드는 JSON 파일과 해당 워크로드 디렉토리로 설명되며, 기존 워크로드로부터 정의를 상속받을 수 있습니다. 일반적으로 워크로드 구성은 ``<firemarshal-dir>/workloads/`` 에 보관되지만, 원하는 디렉토리를 사용할 수도 있습니다. 기본적으로 buildroot 또는 Fedora 기반의 리눅스 배포판 및 bare-metal을 포함한 몇 가지 기본 워크로드를 제공합니다.

워크로드를 정의하면 ``marshal`` 명령어는 워크로드의 각 작업에 해당하는 부트 바이너리와 루트 파일 시스템(rootfs)을 생성합니다. 이 바이너리와 rootfs는 qemu 또는 spike(기능 시뮬레이션용)에서 실행하거나, 실제 RTL에서 실행하기 위해 firesim에 설치할 수 있습니다.

더 자세한 내용은 공식 `FireMarshal documentation <https://firemarshal.readthedocs.io/en/latest/>`_ 과 `quickstart tutorial <https://firemarshal.readthedocs.io/en/latest/Tutorials/quickstart.html>`_ 을 참조하십시오.
