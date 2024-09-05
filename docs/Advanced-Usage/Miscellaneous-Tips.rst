Miscellaneous Tips
=============================

.. _fsimcluster-aws-panel:

Add the ``fsimcluster`` column to your AWS management console
----------------------------------------------------------------

일단 시뮬레이션을 매니저와 함께 한 번 배포하면, AWS 관리 콘솔에서 사용자 지정 열을 추가하여 각 인스턴스가 어느 FireSim 런 팜에 속하는지 한눈에 확인할 수 있습니다.

이를 위해 AWS 관리 콘솔 오른쪽 상단의 기어 아이콘을 클릭하세요. 그 다음, ``fsimcluster`` 체크박스를 선택하여 해당 열을 활성화하세요.

FPGA Dev AMI Remote Desktop Setup
-----------------------------------

매니저 인스턴스로 원격 데스크톱을 접속하려면, 다음을 수행해야 합니다:

.. code-block:: bash

    curl https://s3.amazonaws.com/aws-fpga-developer-ami/1.5.0/Scripts/setup_gui.sh -o /home/centos/src/scripts/setup_gui.sh
    sudo sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/CentOS-CR.repo
    /home/centos/src/scripts/setup_gui.sh
    # 매니저 paramiko 호환성 유지
    sudo pip2 uninstall gssapi

참조:

https://forums.aws.amazon.com/message.jspa?messageID=848073#848073

그리고

https://forums.aws.amazon.com/ann.jspa?annID=5710


Experimental Support for SSHing into simulated nodes and accessing the internet from within simulations
-------------------------------------------------------------------------------------------------------

여기서는 1개의 노드 네트워크 클러스터를 시뮬레이션한다고 가정합니다. 이 지침은 시뮬레이션된 노드로 SSH 접속을 하고, 시뮬레이션 내에서 외부 인터넷에 접속할 수 있게 해줍니다.

1. 설정 파일을 1개의 노드 네트워크 클러스터(``example_1config``)로 설정합니다.
2. ``firesim launchrunfarm && firesim infrasetup`` 을 실행하고 완료될 때까지 기다립니다.
3. ``firesim/target-design/switch/`` 디렉토리로 이동합니다.
4. ``switch0-`` 로 시작하는 최신 디렉토리로 이동합니다.
5. ``switchconfig.h`` 파일을 다음과 같이 수정합니다:

.. code-block:: c

    // THIS FILE IS MACHINE GENERATED. SEE deploy/buildtools/switchmodelconfig.py

    #ifdef NUMCLIENTSCONFIG
    #define NUMPORTS 2
    #define NUMDOWNLINKS 2
    #define NUMUPLINKS 0
    #endif
    #ifdef PORTSETUPCONFIG
    ports[0] = new ShmemPort(0, "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", false);
    ports[1] = new SSHPort(1);

    #endif

    #ifdef MACPORTSCONFIG
    uint16_t mac2port[3]  {1, 2, 0};
    #endif


6. ``make`` 를 실행한 후 ``cp switch switch0`` 을 실행합니다.
7. ``scp switch0 YOUR_RUN_FARM_INSTANCE_IP:switch_slot_0/switch0`` 을 실행합니다.
8. 런 팜 인스턴스에서 다음을 실행합니다:

.. code-block:: bash

    sudo ip tuntap add mode tap dev tap0 user $USER
    sudo ip link set tap0 up
    sudo ip addr add 172.16.0.1/16 dev tap0
    sudo ifconfig tap0 hw ether 8e:6b:35:04:00:00
    sudo sysctl -w net.ipv6.conf.tap0.disable_ipv6=1

9. ``firesim runworkload`` 를 실행합니다. fsim0 화면에서 노드가 로그인 프롬프트로 부팅되었는지 확인합니다.

10. 시뮬레이션된 머신에 SSH 접속하려면 먼저 런 팜 인스턴스로 SSH 접속한 다음, 시뮬레이션된 노드의 IP 주소(172.16.0.2)로 SSH 접속해야 합니다. 사용자 이름은 ``root`` 입니다. 백스페이스가 제대로 작동하도록 하기 위해 SSH 명령 앞에 TERM=linux를 붙여야 합니다. 예를 들어:

.. code-block:: bash

    ssh YOUR_RUN_FARM_INSTANCE_IP
    # 런 팜 인스턴스 내에서:
    TERM=linux ssh root@172.16.0.2


11. 시뮬레이션 내에서 인터넷에 접속할 수 있도록 하려면, 런 팜 인스턴스에서 다음을 실행합니다:

.. code-block:: bash

    sudo sysctl -w net.ipv4.ip_forward=1
    export EXT_IF_TO_USE=$(ifconfig -a | sed 's/[ \t].*//;/^\(lo:\|\)$/d' | sed 's/[ \t].*//;/^\(tap0:\|\)$/d' | sed 's/://g')
    sudo iptables -A FORWARD -i $EXT_IF_TO_USE -o tap0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -A FORWARD -i tap0 -o $EXT_IF_TO_USE -j ACCEPT
    sudo iptables -t nat -A POSTROUTING -o $EXT_IF_TO_USE -j MASQUERADE


12. 그런 다음 시뮬레이션 내에서 다음을 실행합니다:

.. code-block:: bash

    route add default gw 172.16.0.1 eth0
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf

이제 ``ping google.com`` 또는 ``wget google.com`` 과 같이 외부 인터넷에 접속할 수 있습니다.

Navigating the FireSim Codebase
---------------------------------

이 코드는 매우 큰 코드베이스이며 많은 종속성을 포함하고 있어 탐색이 어려울 수 있습니다. 기본적으로 ``./build-setup.sh`` 를 실행하면 코드베이스를 탐색하는 데 도움이 되는 ``tags`` 파일이 생성됩니다. 이 파일은 Exuberant Ctags에 의해 생성되며, 많은 편집기들이 이 파일을 사용하여 코드베이스를 탐색할 수 있습니다. 코드 변경을 하면 ``./gen-tags.sh`` 를 실행하여 ``tags`` 파일을 다시 생성할 수 있습니다.

예를 들어, ``vim``에서 이러한 태그를 사용하여 코드베이스를 탐색하려면, ``.vimrc`` 에 다음을 추가합니다:

.. code-block:: bash

    set tags=tags;/

그런 다음 탐색하려는 위치로 커서를 이동시키고 ``ctrl-]`` 를 눌러 정의로 이동한 후 ``ctrl-t`` 를 눌러 이전 위치로 돌아갈 수 있습니다. 예를 들어 FireSim의 최상위 구성에서 Rocket Chip 코드베이스와 Chisel까지 탐색할 수 있습니다.

Using FireSim CI
----------------

FireSim CI를 처리하는 방법과 CI에서 FPGA 시뮬레이션을 실행하는 방법에 대한 자세한 내용은 ``.github/`` 디렉토리 내의 ``CI_README.md`` 를 참조하세요.

How to view AWS build logs when AGFI build fails
------------------------------------------------

비트스트림 빌드가 실패할 때(특히 매니저가 ``pending`` 을 출력하는 동안 비트스트림 빌드가 실패한 경우) Vivado 로그를 확인하고 싶을 때가 있습니다.
AWS AGFI 생성 백엔드는 이러한 로그를 S3 버킷이라는 스토리지 서버에 저장합니다.
다음 단계는 버킷에서 매니저 인스턴스로 이러한 로그를 복사하는 방법을 안내합니다:

1. AWS 콘솔로 이동합니다.

2. "View all services"를 선택합니다.

3. "Storage"에서 "S3"를 선택합니다.

4. 왼쪽 패널에서 "Buckets"을 선택합니다.

5. 생성한 버킷을 선택합니다.

버킷 명명 스타일에 대해서는 https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-bucket-intro.html 을 참조하세요.
버킷 이름은 ``firesim/deploy/bit-builder-recipes/f1.yaml``에 정의되어 있습니다.

6. "logs/agfi-<somenumber>" 경로에 있는 "<date and time>_vivado.log" 파일을 선택하고 S3 URI를 복사합니다.

7. 매니저 인스턴스로 돌아가서 ``aws s3 cp <URI that you just copied> some_descriptive_name.log`` 명령을 실행합니다.

이제 원하는 텍스트 편집기로 Vivado 로그를 확인할 수 있습니다.
