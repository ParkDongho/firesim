Target-to-Host Bridges
======================

A custom model in a FireSim Simulation, either CPU-hosted or FPGA-hosted, is
deployed by using a *Target-to-Host Bridge*, or Bridge for short. Bridges provide the
means to inject hardware and software models that produce and consume token streams. 

Bridges enable:

#. **Deterministic, host-agnostic I/O models.** This is the most common use case.
   Here you instantiate bridges at the I/O boundary of your chip, to provide
   a simulation models of the environment your design is executing in.  For an
   FPGA-hosted model, see FASED memory timing models. For co-simulated models
   see the UARTBridge, BlockDeviceBridge, and TSIBridge.

#. **Verification against a software golden model.** Attach an bridge (anywhere
   in your target RTL) to an interface you'd like to monitor, (e.g., a
   processor trace port). In the host, you can pipe the token stream coming off
   this interface to a software model running on a CPU (e.g, a functional ISA
   simulator). See TracerV.

#. **Distributed simulation.** The original FireSim application. You can stitch
   together networks of simulated machines by instantiating bridges at your
   SoC boundary. Then write software models and bridge drivers that move
   tokens between each FPGA. See the SimpleNICBridge.

#. **Resource optimizations.** Resource-intensive components of the target can
   be replaced with models that use fewer FPGA resources or run entirely in
   software.


The use of Bridges in a FireSim simulation has many analogs to doing
mixed-language (Verilog-C++) simulation of the same system in software. Where
possible, we'll draw analogies. After reading this page we encourage you to read the 
:ref:`bridge-walkthrough`, which concretely explains the implementation of the UARTBridge.


Terminology
--------------------------

Bridges have a `target side`, consisting of a specially annotated Module, and `host side`,
which consists of an FPGA-hosted `bridge module` (deriving from ``BridgeModule``)
and an optional CPU-hosted `bridge driver` (deriving from ``bridge_driver_t``).

In a mixed-language software simulation, a verilog procedural interface (VPI) is analogous to the target side of a bridge, with the C++ backing
that interface being the host side.

Target Side
----------------------

In your target side, you will mix-in ``midas.widgets.Bridge`` into a Chisel
``BaseModule`` (this can be a black or white-box Chisel module) and implement
its abstract members. This trait indicates that the associated module will be
replaced with a connection to the host-side of the bridge that sources and
sinks token streams. During compilation, the target-side module will be extracted by Golden Gate and
its interface will be driven by your bridge's host-side implementation.

이 trait에는 두 개의 타입 매개변수와 두 개의 추상 멤버가 있으며 Bridge를 위해 정의해야 합니다. Chisel ``BaseModule`` 에 ``Bridge`` 를 혼합해야 하므로 해당 모듈에 대해 정의한 IO가 브리지의 target-side 인터페이스를 구성합니다.

Type Parameters:
++++++++++++++++

#. **Host Interface Type** ``HPType <: TokenizedRecord``: 브리지의
   host-land 인터페이스의 Chisel 타입입니다. 이는 target 인터페이스가 개별 토큰 채널로 어떻게 분할되어 있는지를 설명합니다. 한 예로, ``HostPortIO[T]`` 는 Chisel Bundle을 단일 양방향 토큰 스트림으로 나누며, 토큰 스트림 간의 조합 경로를 모델링하지 않는 브리지를 정의하는 데 충분합니다. IO 디바이스를 모델링하기 위해 브리지를 정의할 때는 ``HostPortIO[T]`` 을 시작하는 것이 간단하며 FMR = 1에서 실행될 수 있습니다. 다른 포트 타입에 대해서는 Bridge Host Interfaces를 참조하십시오.

#. **BridgeModule Type** ``WidgetType <: BridgeModule``: target-side 모듈을 대체하기 위해 Golden Gate가 연결하려고 하는 host-land BridgeModule의 타입입니다. Golden Gate는 클래스 이름을 사용하여 생성자를 호출합니다.

Abstract Members:
+++++++++++++++++

#. **Host Interface Mock** ``bridgeIO: HPType``: 여기에서 host-side 인터페이스의 모형 인스턴스를 생성합니다. **이것은 target-side 모듈에 IO를 추가하지 않습니다.** 대신 Golden Gate에게 target-side 모듈의 target-land IO가 어떻게 채널로 분할되고 있는지를 알려주는 주석을 내보내는 데 사용됩니다.

#. **Bridge Module Constructor Arg** ``constructorArg: Option[AnyRef]``: host-land BridgeModule의 생성자에 전달하려는 선택적 Scala 케이스 클래스입니다. 이는 주석으로 직렬화되어 나중에 Golden Gate에 의해 사용됩니다. 제공된 경우, 케이스 클래스는 모듈의 생성기에 필요한 모든 target-land 구성 정보를 캡쳐해야 합니다.


마지막으로, Bridge 클래스 정의의 맨 아래에서 **generateAnnotations()를 호출해야 합니다.** 이것은 Golden Gate가 브리지를 올바르게 감지하기 위해 필요합니다.

브리지는 Target RTL의 어디에서나 인스턴스화할 수 있습니다: 칩의 I/O 경계에 있거나 모듈 계층 구조 속 깊은 곳에 있습니다. Golden Gate와 관련된 메타데이터는 모두 FIRRTL 주석에 캡처되므로, target 디자인을 생성하고 이를 target-level RTL 시뮬레이션에서 실행하거나 ASIC CAD 도구에 전달할 수 있습니다. Golden Gate의 주석은 단순히 사용되지 않을 것입니다.

What Happens Next?
------------------------

디자인을 Golden Gate에 전달하면 이를 찾아 target-side 모듈을 제거하고, 해당 모듈의 target 인터페이스를 디자인의 최상위로 연결합니다. 호스트 디커플링 변환 동안, Golden Gate는 target-side 브리지에서 내보낸 채널 주석을 기반으로 브리지의 target 인터페이스 필드를 집계하고, 이를 호스트 인터페이스 정의에 맞는 디커플드 인터페이스로 래핑합니다. 마지막으로, Golden Gate가 컴파일러 변환을 수행하고 나면, 브리지 모듈을 생성(생성자를 찾아 직렬화된 생성자 인수를 전달함으로써)하고 이를 이제 호스트-디커플된 시뮬레이터가 제공하는 토큰화된 인터페이스에 연결합니다.

Host Side
---------

브리지의 호스트 측에는 두 가지 구성 요소가 있습니다:

#. FPGA 호스팅 브리지 모듈(``BridgeModule``).
#. 선택적인, CPU 호스팅 브리지 드라이버(``bridge_driver_t``).

일반적으로 브리지에는 둘 다 있습니다: FASED 메모리 타이밍 모델에서, BridgeModule은 타이밍 매개변수를 메모리 매핑된 레지스터로 노출하는 타이밍 모델을 포함하며 드라이버는 시뮬레이션 시작 시 이를 구성합니다. Block Device 모델에서는 드라이버가 주기적으로 브리지 모듈의 큐를 폴링하여 새로운 기능 요청이 있는지 확인합니다. NIC 모델에서는 드라이버가 소프트웨어 스위치 모델과 브리지 모듈 사이에서 대량으로 토큰을 이동시키며, 이는 토큰이 도착하면 단순히 큐에 저장합니다.

브리지 모듈과 드라이버 간의 통신은 두 가지 유형의 전송으로 구현됩니다:

#. **MMIO**: 모듈에서는 32비트 AXI4-lite 버스를 통해 구현됩니다.
   드라이버는 ``simif_t::read()`` 및 ``simif_t::write()`` 을 사용하여 이 버스에 대한 읽기 및 쓰기를 수행합니다. 브리지 모듈은 ``midas.widgets.Widget`` 에 정의된 메서드를 사용하여 메모리 매핑된 레지스터를 등록하며, 생성된 C++ 헤더에서 이 레지스터의 주소가 드라이버에 전달됩니다.

#. **DMA**: 모듈에서는 CPU가 마스터하는 넓은(e.g., 512-bit) AXI4 버스를 통해 구현됩니다. 브리지 드라이버는 ``simif_t::push()`` 및 ``simif_t::pull()`` (FPGA에서의 DMA) 함수를 통해 대량 전송을 시작합니다. DMA는 일반적으로 BridgeModule의 대형 FIFO 안팎으로 토큰을 스트리밍하는 데 사용됩니다.


Compile-Time (Parameterization) vs Runtime Configuration
--------------------------------------------------------

소프트웨어 RTL 시뮬레이터를 컴파일할 때와 마찬가지로, 시뮬레이션된 디자인은 두 단계에서 구성됩니다:

#. **Compile Time**, target RTL 및 BridgeModule 생성기에 매개변수를 설정하고, Golden Gate 최적화 및 디버그 변환을 활성화하여. 이는 시뮬레이터의 RTL을 변경하므로 FPGA 재컴파일이 필요합니다. 이는 새로운 시뮬레이터를 컴파일하는 VCS를 호출하는 것과 동일하지만 상당히 느립니다.

#. **Runtime**, plus args(e.g., +latency=1)를 BridgeDrivers에 전달하여. 이는 소프트웨어 RTL 시뮬레이터에 plus args를 전달하는 것과 동일하며, 많은 경우 RTL 시뮬레이터와 FireSim 시뮬레이터에 전달되는 plus args는 동일할 수 있습니다.

Target-Side vs Host-Side Parameterization
-----------------------------------------

소프트웨어 RTL 시뮬레이션과 달리, FireSim 시뮬레이션은 브리지 모듈이 생성되는 추가 RTL 구체화 단계를 포함합니다(이들 자체가 Chisel 생성기입니다).

브리지 모듈의 매개변수 설정은 두 곳에 캡처될 수 있습니다.

#. **Target side.** 여기서 매개변수 설정 정보는 target 생성기의 자유 매개변수로 제공되며, 브리지가 인스턴스화되는 컨텍스트에서 추출됩니다. 후자는 특정 인터페이스의 폭 또는 브리지가 노출할 수 있는 target의 동작에 대한 경계를 포함할 수 있습니다(e.g., 최대 인플라이트 요청 수). 이 모든 정보는 단일 직렬화 가능한 생성자 인수, 일반적으로 케이스 클래스에 캡처되어야 합니다(``Bridge.constructorArg`` 참조).

#. **Host side.** 이는 Golden Gate의 ``Parameters`` 객체에 캡처된 매개변수 설정 정보입니다. 이는 호스트 랜드 구현 힌트를 제공하는 데 사용해야 하며(이상적으로는 시스템의 시뮬레이션 동작을 변경하지 않음), 주석 파일에 직렬화할 수 없는 인수를 제공하는 데 사용됩니다.

일반적으로 target 측에서 매개변수 설정 정보를 캡처할 수 있다면 그렇게 해야 합니다. 이는 동일한 FIRRTL의 소프트웨어 RTL 시뮬레이션과 FireSim 시뮬레이션 간의 발산을 방지하기 쉽게 만듭니다. 또한 target 측에서 동일한 유형의 여러 브리지 인스턴스를 구성하는 것이 더 쉽습니다.