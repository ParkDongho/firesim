.. _auto-ila:

AutoILA: Simple Integrated Logic Analyzer (ILA) Insertion
===================================================================

가끔 RTL 시뮬레이터에서 FireSim을 시뮬레이션하는 데 너무 오래 걸리는 경우가 있으며,
또한 시뮬레이션 인프라 자체를 디버그하고 싶을 때도 있습니다. 이러한 목적을 위해, FPGA에서 Xilinx Integrated Logic Analyzer
리소스를 사용할 수 있습니다.

ILAs는 FPGA 런타임 동안 사전 선택된 신호를 실시간으로 샘플링하며,
트리거 설정 및 샘플 파형을 FPGA에서 보기 위한 인터페이스를 제공합니다. ILA에 대한 자세한 정보는
주제에 대한 Xilinx 가이드를 참조하십시오.

``midas.targetutils`` 패키지는 Chisel 소스에서 신호를 직접 레이블링하기 위한 주석을 제공합니다. 이는 후속 FIRRTL 패스에 의해 소비되며, 주석이 달린 신호를 연결하고 적절한 크기의 ILA 인스턴스에 바인딩합니다.

Enabling AutoILA
----------------

AutoILA를 활성화하려면, `WithAutoILA` 믹스인을 `PLATFORM_CONFIG` 에 미리 추가해야 합니다. 버전 1.13 이전에는 기본적으로 이 작업이 수행되었습니다.

Annotating Signals
------------------------

신호에 주석을 달기 위해서는 ``midas.targetutils.FpgaDebug`` 주석기를 가져와야 합니다. FpgaDebug의 apply 메서드는 chisel3.Data의 vararg를 허용합니다. 다음과 같이 호출하십시오:

.. code-block:: scala

    import midas.targetutils.FpgaDebug

    class SomeModuleIO(implicit p: Parameters) extends SomeIO()(p){
       val out1 = Output(Bool())
       val in1 = Input(Bool())
       FpgaDebug(out1, in1)
    }

FireSim 전체에서 신호를 주석으로 달 수 있으며, Golden Gate Rocket-Chip Chisel 소스에서도 가능합니다. 단, Chisel3 소스 자체(예: Chisel3.util.Queue)에서는 예외입니다.

참고: 주석이 달린 신호가 있는 모듈이 여러 번 인스턴스화된 경우, 주석이 달린 신호의 모든 인스턴스가 ILA에 연결됩니다.

Setting a ILA Depth
-------------------

ILA 깊이 파라미터는 트리거 주변에서 주석된 신호를 캡처하는 주기를 지정합니다.
이 파라미터를 증가시키면 디버깅이 쉬워질 수 있지만, FPGA 리소스 사용량도 증가합니다. 기본 깊이는 1024 주기입니다. 원하는 깊이는 `PLATFORM_CONFIG` 에 믹스를 추가하여 구성할 수 있습니다. `PLATFORM_CONFIG` 에 대한 자세한 내용은 :ref:`Generating-Different-Targets` 를 참조하십시오.

아래는 `build_recipes` 구성 파일에서 사용할 수 있는 예시 `PLATFORM_CONFIG` 입니다.

.. code-block:: bash

   PLATFORM_CONFIG=ILADepth8192_BaseF1Config

Using the ILA at Runtime
------------------------

전제 조건: "firesim" AWS 보안 그룹에서 포트 8443, 3121 및 10201이 활성화되어 있는지 확인하십시오.

ILA를 사용하기 위해, 관리자 인스턴스에서 GUI 인터페이스를 활성화해야 합니다.
과거에는 AWS가 사용자 정의 ``setup_gui.sh`` 스크립트를 제공했으나, 호환성 문제로 최근에 폐지되었습니다.
따라서 현재 AWS는 GUI 클라이언트로 `NICE DCV <https://docs.aws.amazon.com/dcv/latest/adminguide/what-is-dcv.html>`__ 사용을 권장합니다. `DCV 클라이언트를 다운로드 <https://docs.aws.amazon.com/dcv/latest/userguide/client.html>`__ 한 다음, FireSim 관리자 인스턴스에서 다음 명령을 실행하십시오:

.. code-block:: bash

  sudo yum -y groupinstall "GNOME Desktop"
  sudo yum -y install glx-utils
  sudo rpm --import https://s3-eu-west-1.amazonaws.com/nice-dcv-publish/NICE-GPG-KEY
  wget https://d1uj6qtbmh3dt5.cloudfront.net/2019.0/Servers/nice-dcv-2019.0-7318-el7.tgz
  tar xvf nice-dcv-2019.0-7318-el7.tgz
  cd nice-dcv-2019.0-7318-el7
  sudo yum -y install nice-dcv-server-2019.0.7318-1.el7.x86_64.rpm
  sudo yum -y install nice-xdcv-2019.0.224-1.el7.x86_64.rpm
  sudo systemctl enable dcvserver
  sudo systemctl start dcvserver
  sudo passwd centos
  sudo systemctl stop firewalld
  dcv create-session --type virtual --user centos centos

이 명령은 Linux 데스크톱 전제 조건을 설치하고, NICE DCV 서버를 설치하고, ``centos`` 사용자의 비밀번호를 설정하도록 요청하며, firewalld를 비활성화하고,
마지막으로 DCV 세션을 생성합니다. 이제 DCV 클라이언트를 통해 이 세션에 연결할 수 있습니다.

GUI 인터페이스에 액세스한 후, 터미널을 열고 ``vivado`` 를 실행하십시오.
`AWS-FPGA 가이드에서 Xilinx 하드웨어 매니저를 vivado (원격 머신에서 실행 중)로 연결하는 방법 <https://github.com/aws/aws-fpga/blob/master/hdk/docs/Virtual_JTAG_XVC.md#connecting-xilinx-hardware-manager-vivado-lab-edition-running-on-a-remote-machine-to-the-debug-target-fpga-enabled-ec2-instance>`__ 의 지침을 따르십시오.

여기서 ``<hostname or IP address>`` 는 시뮬레이션 인스턴스의 내부 IP(관리자 인스턴스가 아님, 즉 192.168.X.X로 시작하는 IP)입니다.
probes 파일은 관리자 인스턴스의 경로 ``firesim/deploy/results-build/<build_identifier>/cl_firesim/build/checkpoints/<probes_file.ltx>`` 에서 찾을 수 있습니다.

설명에 `WRAPPER_INST/CL/CL_FIRESIM_DEBUG_WIRING_TRANSFORM` 이 있는 ILA를 선택하면 로컬 FPGA에서 사용하듯이 ILA를 사용할 수 있습니다.