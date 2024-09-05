Visual Studio Code Integration
------------------------------

`VSCode <https://code.visualstudio.com/>`_ 는 FireSim 저장소 전반에 걸쳐 코드 및 문서를 개발할 수 있는 강력한 IDE입니다. SSH를 통해 클라이언트-서버 프로토콜을 지원하여 로컬 GUI 클라이언트가 원격 매니저에서 실행되는 서버와 상호작용할 수 있습니다.

General Setup
=============

#. VSCode를 설치합니다. 설치 프로그램은 ` 여기 <https://code.visualstudio.com/download>`_ 에서 받을 수 있습니다.
#. VSCode를 열고 ``Remote Developer Plugin`` 을 설치합니다. 플러그인의 기능에 대한 완전한 설명은 `marketplace page <https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack>`_ 를 참조하세요.

이 지점에서 VSCode는 ``.ssh/config`` 파일을 읽습니다. 여기 나열된 호스트들이 좌측 사이드바의 ``Remote Explorer`` 에 표시됩니다. 이 호스트에 연결하고 여기에 만든 FireSim 클론 아래에서 작업 공간을 만들 수 있습니다. ssh 구성에서 패턴 매치 또는 glob의 일부로 캡처되는 호스트에는 명시적인 이름을 지정해야 할 수도 있습니다.

Workspace Locations
===================

특정 플러그인은 특정 위치에 특정 파일이 있는 것을 전제로 하며, 종종 VSCode가 인덱스화할 파일의 범위를 줄이는 것이 바람직합니다. 다음 위치에서 작업 공간을 여는 것을 권장합니다:

 * Scala 및 C++ 개발: ``sim/``
 * RST 문서: ``docs/``
 * Manager (python): ``deploy/``

항상 FireSim의 루트에서 작업 공간을 열 수 있지만, 특정 언어 전용 플러그인 (예: 제대로 구성되지 않을 수 있음)에 대해 인지해야 합니다.

Scala Development
=========================

.. warning:: Chipyard가 업데이트될 때까지, 이를 제대로 작동시키기 위해 Chipyard의 ``plugins.sbt`` 에 bloop을 추가해야 합니다. 참조: :gh-file-ref:`sim/project/plugins.sbt` 및 bloop 설치를 ``target-design/chipyard/project/plugins.sbt`` 에 복사합니다.
VSCode는 Scala 개발을 위한 풍부한 지원을 제공하며, `Metals <https://scalameta.org/metals/docs/editors/vscode/>`_ 플러그인이 그 마법을 실현시킵니다.

How To Use (Remote Manager)
###########################

#. 아직 하지 않았다면, FireSim을 클론하고 매니저에서 ``build-setup.sh`` 를 실행합니다.
#. 매니저 인스턴스가 ``.ssh/config`` 에 호스트로 나열되어 있는지 확인합니다. 예:
   ::

    Host ec2-manager
        User centos
        IdentityFile ~/.ssh/<your-firesim.pem>
        Hostname <IP ADDR>
    
#. VSCode에서 왼쪽 사이드바의 ``Remote Manager`` 를 사용하여 매니저 인스턴스에 연결합니다.
#. FireSim 클론의 ``sim/`` 아래에서 작업 공간을 엽니다.
#. 원격당 최초 설치: 원격 머신에 Metals 플러그인을 설치합니다.
#. Metals가 "새로운 SBT 작업 공간이 감지되었습니다. 빌드를 가져오시겠습니까?"라는 메시지를 표시합니다. *Import Build* 를 클릭합니다.

이 시점에서 metals는 ``sim/`` 을 루트로 삼는 SBT 정의 빌드를 자동으로 가져오려 시도할 것입니다. 이 과정에는 다음이 포함됩니다:

#. SBT에 ``bloopInstall`` 을 실행하도록 요청합니다.
#. bloop 빌드 서버를 실행합니다.
#. FireSim의 기본 SBT 프로젝트에 대해 모든 scala 소스를 컴파일합니다.

이 과정이 완료되면 자동 완성, 소스 코드 이동, 코드 렌즈 등 모든 좋은 기능이 제대로 작동할 것입니다.

Limitations
###########

#. **메이크를 사용하는 ScalaTests에 대한 테스트 작업 지원 없음.** FireSim의 ScalaTest가 제너레이터와 Golden Gate를 호출하기 위해 메이크를 사용하는 방식 때문에, Metals의 bloop 인스턴스는 ``env.sh`` 가 소싱된 상태로 초기화되어야 합니다. 이는 향후 PR에서 해결될 것입니다. 

Other Notes
###########

SBT 멀티 프로젝트 빌드 의존성은 기본 metals 통합을 방해합니다. 이를 숨기기 위해, FireSim과 Chipyard에서 플러그인으로 나열하여 bloop를 이미 설치했음을 metals에 지시하는 ``settings.json`` 파일을 :gh-file-ref:`sim/.vscode/settings.json` 에 넣어 metals가 ``sim/`` 에서 올바르게 실행되도록 하였습니다. 이는 다음을 지시합니다:

#. FireSim과 Chipyard에 bloop를 플러그인으로 나열하여 (bloop를) 이미 설치했습니다.
#. ``bloopInstall`` 을 실행하기 위해 다른 sbt 실행 명령어를 사용해야 합니다. 즉, ``env.sh`` 를 소싱하고 Chipyard에서 제공하는 sbt 실행기를 사용합니다.
