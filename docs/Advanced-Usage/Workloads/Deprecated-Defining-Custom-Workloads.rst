.. _deprecated-defining-custom-workloads:

[DEPRECATED] Defining Custom Workloads
================================================

.. DANGER:: This version of the Defining Custom Workloads page is kept here to
   document some of the legacy workload configurations still present in
   ``deploy/workloads/``. New workloads should NOT be generated using these
   instructions.

이 페이지는 FireSim이 타겟 디자인에서 실행하는 소프트웨어 워크로드를 이해하기 위해 사용하는 ``JSON`` 입력 형식을 문서화합니다. 대부분의 경우, 이 파일들을 처음부터 작성할 필요는 없습니다. 대신 :ref:`firemarshal` 을 사용하여 워크로드(리눅스 커널 이미지 및 루트 파일 시스템을 포함)를 생성하고 ``firemarshal`` 의 ``install`` 명령어를 사용해 FireSim용 초기 ``.json`` 파일을 생성하십시오. FireMarshal로 기본 ``.json`` 을 생성한 후, 이 페이지에 나열된 옵션들을 추가하여 시뮬레이션의 입력/출력으로 사용되는 추가 파일들을 제어할 수 있습니다.

FireSim에서 **워크로드** 는 개별 시뮬레이션에서 실행되는 일련의 **Jobs** 로 구성됩니다. 현재, 워크로드는 다음 중 하나를 정의해야 합니다:

- 사용자가 지정한 수만큼의 시뮬레이션에서 실행되는 단일 작업 유형. 이러한 워크로드는 보통 ``-uniform`` 이라는 접미사가 붙으며, 이는 워크로드의 모든 노드가 동일한 작업을 실행함을 나타냅니다. 이러한 워크로드의 예시는 :gh-file-ref:`deploy/workloads/br-base-uniform.json` 입니다.

- 서로 다른 작업들, 이 경우 시뮬레이션되는 노드의 수와 정확히 일치하는 수의 작업이 있어야 합니다. 이러한 워크로드의 예시는 :gh-file-ref:`deploy/workloads/br-base-non-uniform.json` 입니다.

FireSim은 이러한 워크로드 정의를 사용하여 매니저를 통해 배포할 수 있습니다.

다음 하위 섹션에서는 앞서 언급한 두 가지 예시 워크로드 구성에 대해 설명하며, 이 두 기능이 JSON 파일의 각 부분을 어떻게 사용하는지 설명합니다.

**ERRATA**: 다음 JSON 파일들에서 "workloads"라는 필드를 보실 수 있는데, 이 필드는 사실 "jobs"로 명명되어야 합니다. 이는 향후 릴리스에서 수정될 예정입니다.

Uniform Workload JSON
----------------------------

:gh-file-ref:`deploy/workloads/br-base-uniform.json` 는 각 시뮬레이션 노드가 동일한 소프트웨어 구성을 실행하는 "uniform" 스타일 워크로드의 예시입니다.

이 파일을 살펴보겠습니다:

.. include:: /../deploy/workloads/br-base-uniform.json
   :code: json

또한 이 워크로드/파일과 동일한 이름을 가진 디렉토리가 있습니다: ``deploy/workloads/br-base-uniform``.
이에 대해서는 나중에 더 자세히 설명하겠습니다.

이 JSON 파일을 보면 비교적 간단한 워크로드 정의라는 것을 알 수 있습니다.

이 "uniform" 경우, 매니저는 ``benchmark_name`` 필드에 따라 시뮬레이션의 이름을 지정하며, 워크로드를 사용하는 각 시뮬레이션마다 숫자를 붙입니다(예: ``br-base-uniform0``, ``br-base-uniform1`` 등). 일반적으로 ``benchmark_name``, JSON 파일명, 위의 디렉토리 이름을 동일하게 유지하는 것이 표준입니다. 이 경우, 우리는 모두 ``br-base-uniform`` 으로 설정했습니다.

다음으로, ``common_bootbinary`` 필드는 이 워크로드의 시뮬레이션들이 부팅해야 하는 바이너리를 나타냅니다. 매니저는 시뮬레이션의 각 노드에 대해 이 바이너리를 복사합니다(각각의 노드가 자신의 복사본을 가집니다). ``common_bootbinary`` 경로는 워크로드의 디렉토리에 상대적이며, 이 경우 :gh-file-ref:`deploy/workloads/br-base-uniform` 입니다.

마찬가지로, ``common_rootfs`` 필드는 이 워크로드의 시뮬레이션들이 부팅해야 하는 디스크 이미지를 나타냅니다. 매니저는 시뮬레이션의 각 노드에 대해 이 루트 파일 시스템 이미지를 복사합니다(각 노드가 자신의 복사본을 가짐). ``common_rootfs`` 경로는 워크로드의 디렉토리에 상대적이며, 이 경우 :gh-file-ref:`deploy/workloads/br-base-uniform` 입니다.

``common_outputs`` 필드는 시뮬레이션이 완료된 후 매니저가 루트 파일 시스템 이미지에서 복사할 출력 목록입니다. 여기에는 여러 경로를 추가할 수 있습니다.

``common_simulation_outputs`` 필드는 시뮬레이션이 완료된 후 시뮬레이션 호스트 머신에서 매니저가 복사할 출력 목록입니다. 이 예시에서, 시뮬레이션 클러스터에서 ``firesim runworkload``를 실행하여 워크로드가 완료되면, ``uartlog``(시뮬레이션 시스템의 전체 콘솔 출력을 포함한 자동 생성 파일) 및 ``memory_stats.csv`` 파일이 호스트 인스턴스의 시뮬레이션 기본 디렉토리에서 복사되어 워크로드 출력 디렉토리 내 작업 출력 디렉토리에 저장됩니다(:ref:`firesim-runworkload` 섹션 참조). 여기에도 여러 경로를 추가할 수 있습니다.

**ERRATA**: "Uniform" 스타일의 워크로드는 현재 자동으로 빌드되는 것을 지원하지 않습니다. 현재는 단일 노드 비일관성 워크로드로 루트 파일 시스템을 빌드한 다음, JSON의 ``workloads`` 필드를 삭제하여 매니저가 이를 uniform 워크로드로 처리하도록 하는 방법으로 해결할 수 있습니다. 이는 향후 릴리스에서 수정될 예정입니다.

Non-uniform Workload JSON (explicit job per simulated node)
---------------------------------------------------------------

이제, 각 시뮬레이션 노드에 명시적으로 작업을 정의하는 ``br-base-non-uniform`` 워크로드를 살펴보겠습니다.

.. include:: /../deploy/workloads/br-base-non-uniform.json
   :code: json

또한, 필요한 ``br-base-non-uniform`` 디렉토리의 상태를 살펴보겠습니다:

.. code-block:: bash

	centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy/workloads/br-base-non-uniform$ ls -la
	...
	drwxrwxr-x  3 centos centos         16 May 17 21:58 overlay

``overlay`` 하위 디렉토리를 살펴보겠습니다:

.. code-block:: bash

    centos@ip-172-30-2-111.us-west-2.compute.internal:~/firesim-new/deploy/workloads/br-base-non-uniform/overlay$ ls -la */*
    -rwxrwxr-x 1 centos centos 249 May 17 21:58 bin/echome.sh

이 파일은 실제로 레포에 커밋된 파일이며, 이론적으로 우리가 시뮬레이션 시스템에서 실행하고자 하는 벤치마크를 실행하게 됩니다. 이 경우, 간단한 echo 명령어입니다.

이제, 우리가 여기까지 어떻게 왔는지 살펴보겠습니다. 먼저, 이 JSON 파일에 새로 추가된 필드를 검토하겠습니다:

- ``common_files``: 이 배열에는 모든 작업의 루트 파일 시스템에 포함될 파일들이 나열됩니다. 이 경로는 루트 파일 시스템을 생성하는 스크립트에 전달되는 경로에 상대적입니다.
- ``workloads``: 이번에는 이 배열이 개별 작업을 나타내는 객체들로 채워져 있음을 알 수 있습니다. 각 작업에는 몇 가지 추가 필드가 있습니다:

   - ``name``: 이 경우, 작업들은 수동으로 이름이 할당됩니다. 이 이름들은 특정 워크로드 내에서 반드시 고유해야 합니다.
   - ``files``: ``common_files`` 와 동일하지만, 이 작업에만 적용됩니다.
   - ``command``: 시뮬레이션이 부팅되자마자 자동으로 실행되는 명령어입니다. 이는 보통 우리가 실행하고자 하는 워크로드를 시작하는 명령어입니다.
   - ``simulation_outputs``: ``common_simulation_outputs`` 와 동일하지만, 이 작업에만 적용됩니다.
   - ``outputs``: ``common_outputs`` 와 동일하지만, 이 작업에만 적용됩니다.

이 예시에서, 한 노드는 ``echome.sh && poweroff -f`` 를 실행하고, 다른 노드는 ``poweroff -f`` 만 실행합니다.

매니저에서 이 작업을 실행하려면 ``config_runtime.yaml`` 에서 ``workload_name: br-base-non-uniform.json`` 을 설정하십시오. 매니저는 자동으로 생성된 루트 파일 시스템을 찾고(워크로드 및 작업 이름을 JSON에서 읽음) 작업을 적절히 배포합니다.

uniform 경우와 마찬가지로, 우리는 JSON 파일에 지정된 결과를 복사하게 됩니다. 최종적으로 ``firesim/deploy/results-workload/`` 디렉토리 내에 워크로드 이름으로 된 디렉토리가 생성되며, 워크로드 내 각 작업 이름으로 된 하위 디렉토리에는 우리가 원하는 출력 파일들이 포함됩니다.
