Target Abstraction & Host Decoupling
====================================

Golden Gate-generated simulators are deterministic, cycle-exact representations of the source RTL fed to the compiler. To achieve this, Golden Gate consumes input RTL (as FIRRTL) and transforms it into a latency-insensitive bounded dataflow network (LI-BDN) representation of the same RTL.

The Target as a Dataflow Graph
------------------------------

Golden Gate에서의 데이터플로우 그래프는 모델, 토큰, 채널로 구성됩니다:

1) Models -- 그래프의 노드로, 토큰을 소비하고 생산함으로써 타깃 머신의 동작을 캡처합니다.

2) Tokens -- 데이터플로우 그래프의 메시지로, 주어진 사이클 동안 수렴한 후 와이어에 나타나는 하드웨어 값을 나타냅니다.

3) Channels -- 그래프의 엣지로, 한 모델의 출력 포트를 다른 모델의 입력 포트와 연결합니다.

이 시스템에서는 각 모델 내에서 시간이 국소적으로 진행됩니다. 한 모델은 각 입력 포트에서 하나의 토큰을 소비하고 각 출력 포트에 하나의 토큰을 대기열에 추가하면 시뮬레이션된 시간에서 한 사이클을 진행합니다. 모델은 *지연 무감성(latency-insensitive)* 상태로, 가변적인 입력 토큰 지연 및 출력 채널에서의 백프레셔를 견딜 수 있습니다. 각 입력 포트에 대한 입력 토큰 시퀀스를 제공하면, 올바르게 구현된 모델은 해당 입력 토큰이 언제 도착하든 상관없이 각 출력에서 동일한 시퀀스의 토큰을 생산할 것입니다.

다음은 32비트 덧셈기의 데이터플로우 그래프 표현 예시로, 두 사이클의 실행을 시뮬레이션한 것입니다.

Model Implementations
---------------------

Golden Gate에서는 모델 구현의 두 가지 차원이 있습니다:

1) CPU 또는 FPGA 호스팅: 단순히 모델이 실행될 장소입니다. 소프트웨어인 CPU 호스팅 모델은 더 유연하고 디버깅이 쉽지만 느립니다. 반대로 FPGA 호스팅 모델은 빠르지만 쓰기와 디버깅이 더 어렵습니다.

2) Cycle-Exact 또는 Abstract: 사이클-정확 모델은 SoC의 RTL 조각을 충실하게 구현합니다(나중에 정식화됨). 추상 모델은 복잡성을 줄이고 시뮬레이션 성능을 향상시키며 자원 활용도를 개선하기 위해 정확성을 일부 포기합니다.

하이브리드 CPU-FPGA 호스팅 모델은 일반적입니다. 여기서 흔한 패턴은 RTL 타이밍 모델과 소프트웨어 기능 모델을 작성하는 것입니다.

Expressing the Target Graph
---------------------------

타겟 그래프는 FIRRTL로 캡처됩니다. 시스템의 대부분 RTL은 Golden Gate에 의해 하나 이상의 사이클-정확 FPGA 호스팅 모델로 변환됩니다. Target-to-Host Bridges를 사용하여 그래프에 추상적인 FPGA 호스팅 모델과 CPU 호스팅 모델을 도입합니다. 컴파일 중에 Golden Gate는 브리지의 타겟 측을 추출하고, BridgeModule이라는 사용자 정의 RTL을 인스턴스화하여 CPU 호스팅 Bridge Driver와 함께 임의의 타겟 동작을 모델링할 수 있는 수단을 제공합니다. 이는 Bridge 섹션에서 더 자세히 설명합니다.

Latency-Insensitive Bounded Dataflow Networks
---------------------------------------------

결과 시뮬레이터가 타겟 RTL을 충실하게 표현하려면 모델이 세 가지 특성을 준수해야 합니다. 독자는 이러한 특성의 공식 정의를 위해 `LI-BDN 논문 <https://dspace.mit.edu/bitstream/handle/1721.1/58834/Vijayaraghavan-2009-Bounded%20Dataflow%20Networks%20and%20Latency-Insensitive%20Circuits.pdf?sequence=1&isAllowed=y>`_ 을 참조하십시오. 이하에는 그 영어 대응 뜻이 나옵니다.

**Partial Implementation**: 모델 출력 토큰 동작은 동일한 입력이 참조 RTL과 모델(임의로 지연된 토큰 스트림) 모두에 제공될 때 참조 RTL의 사이클별 출력을 일치시킵니다. 사이클-정확 모델은 PI를 구현해야 하지만, 추상 모델은 그러지 않습니다.

나머지 두 특성은 그래프가 교착 상태에 빠지지 않도록 보장하며, 사이클-정확 모델과 추상 모델 모두에 의해 구현되어야 합니다.

**Self-Cleaning**: 각 출력 포트에 N개의 토큰을 대기열에 추가한 모델은 결국 각 입력 포트에서 N개의 토큰을 대기열에서 제거해야 합니다.

**No Extranenous Dependencies**: LI-BDN 시뮬레이션 모델의 특정 출력 채널이 다른 채널보다 더 많은 토큰을 받지 않았으며, 모델이 해당 채널의 다음 출력 토큰을 계산하는 데 필요한 모든 입력 토큰을 받는 경우 모델은 외부 활동과 상관없이 최종적으로 해당 출력 토큰을 대기열에 추가해야 합니다. 여기서 모델이 출력 토큰을 대기열에 추가하는 것은 해당 출력 채널이 토큰을 "받는" 것과 동의어입니다.