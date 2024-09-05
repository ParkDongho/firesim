.. _FAME-5:

Optimizing FPGA Resource Utilization
====================================

호스트와 분리된 시뮬레이터의 장점 중 하나는 여러 FPGA 사이클에 걸쳐 비싼 연산을 분산시키면서도 완벽한 사이클 정확성을 유지할 수 있다는 점입니다. 이 전략을 사용할 때 시뮬레이터는 다음 상태를 결정하기 위해 기본 계산을 완료하는 데 여러 사이클이 걸리는 리소스 효율적인 구현을 사용할 수 있습니다. 추상적으로 볼 때, 이는 시뮬레이터의 호스트 구현이 대상 설계보다 병렬성이 *적다*는 것을 의미합니다. 이 전략은 RTL 회로를 순차적, 범용 하드웨어에서 실행되는 소프트웨어 시뮬레이터로 매핑하는 컴파일러 설계에 본질적이지만, FPGA 시뮬레이션에서는 덜 일반적입니다. 이러한 *공간-시간* 절충은 주로 수작업으로 작성된 아키텍처 특정 학술 시뮬레이터 또는 분할된 다중 FPGA 환경에서 I/O 컷과 같은 매우 특정한 호스트 기능 구현에 제한됩니다.

Golden Gate 컴파일러로, 우리는 이러한 최적화를 자동화하는 프레임워크를 제공합니다. 이는 Golden Gate 설계에 관한 `2019 ICCAD 논문 <https://people.eecs.berkeley.edu/~magyar/documents/goldengate-iccad19.pdf>`_ 에서 논의되었습니다. 또한, FireSim의 최신 버전에는 리소스 활용을 급격히 줄일 수 있는 두 가지 선택적 최적화가 포함되어 있습니다(따라서 훨씬 더 큰 SoCs를 시뮬레이션할 수 있습니다). 첫 번째 최적화는 FPGA 호스트에서 직접 RTL 번역을 통해 구현하기에 극단적인 메모리의 오버헤드를 줄이고, 두 번째는 큰 블록을 반복적으로 사용하는 대상 설계의 인스턴스를 단일 기본 호스트 구현에서 여러 인스턴스를 시뮬레이션하는 *스레딩* 작업에 적용됩니다.

Multi-Ported Memory Optimization
--------------------------------

ASIC 다중 포트 RAM은 FPGA 프로토타입에서 자원 활용이 낮은 대표적인 원인이며, 이는 BLAM(Block RAM)으로 간단히 구현할 수 없고 대신 조회 테이블(LUT), 멀티플렉서 및 레지스터로 분해됩니다. 이중 펌핑, BRAM 중복 또는 FPGA 최적화된 마이크로아키텍처를 사용하면 도움이 될 수 있지만, Golden Gate는 이러한 메모리를 자동으로 추출하고 블록 RAM(BRAM)으로 매핑하기 쉬운 기본 구현에 직렬화된 접근을 통해 RAM을 시뮬레이션하는 분리된 모델로 교체할 수 있습니다. 이러한 직렬화는 에뮬레이션 속도 감소의 대가를 치르지만, 결과 시뮬레이터는 기존 FPGA에 더 큰 SoCs를 장착할 수 있게 합니다. 또한 Golden Gate의 분리 프레임워크는 시뮬레이터가 여전히 비트 일치, 사이클 정확한 결과를 생성하도록 보장합니다.

이 최적화의 세부사항은 ICCAD 논문에서 길게 논의되었지만, 배포는 비교적 간단합니다. 먼저, 원하는 메모리는 최적화가 필요함을 나타내는 Chisel 애노테이션을 통해 주석을 달아야 합니다. Rocket 및 BOOM 기반 시스템의 경우 이러한 애노테이션은 이미 코어의 레지스터 파일에 제공되어 있으며, 이는 설계에서 FPGA에게 가장 적대적인 메모리입니다. 다음으로, 이러한 주석이 있는 경우 최적화를 활성화하려면 ``MCRams`` 클래스를 플랫폼 구성에 혼합해야 합니다. 다음 예제 빌드 레시피에서 이를 확인할 수 있습니다:

.. code-block:: yaml

    firesim-boom-mem-opt:
        DESIGN: FireSim
        TARGET_CONFIG: WithNIC_DDR3FRFCFSLLC4MB_FireSimLargeBoomConfig
        PLATFORM_CONFIG: MCRams_BaseF1Config
        deploy_quintuplet: null


Multi-Threading of Repeated Instances
-------------------------------------

FPGA 적대적인 메모리를 최적화하면 AWS에서 호스팅되는 VU9P FPGAs에서 최대 50% 더 높은 코어 수를 허용할 수 있지만, 대상 시스템에서 반복 인스턴스를 스레딩하여 훨씬 더 큰 이득을 얻을 수 있습니다. *모델 멀티스레딩* 최적화는 이러한 반복 인스턴스를 추출하고 공유되는 기본 물리적 구현에서의 별도의 실행 스레드로 각 인스턴스를 시뮬레이션합니다.

메모리 최적화와 마찬가지로, 이는 대상 설계에서 원하는 인스턴스 집합을 주석으로 표시해야 합니다. 그러나 일반적인 Rocket 칩 목표에 대한 가장 큰 효과적 FPGA 용량 증가는 코어 복합체를 포함하는 타일을 스레딩함으로써 실현되므로, 이러한 인스턴스는 Rocket 및 BOOM 기반 시스템 모두에 대해 사전 주석이 달려 있습니다. 이 타일 멀티스레딩을 활성화하려면 ``MTModels`` 클래스를 플랫폼 구성에 혼합해야 합니다. 다음 예제 빌드 레시피에서 이를 확인할 수 있습니다:

.. code-block:: yaml

    firesim-threaded-cores-opt:
        DESIGN: FireSim
        TARGET_CONFIG: WithNIC_DDR3FRFCFSLLC4MB_FireSimQuadRocketConfig
        PLATFORM_CONFIG: MTModels_BaseF1Config
        deploy_quintuplet: null

이 시뮬레이터 구성은 단일 스레드 모델을 사용하여 네 개의 Rocket 타일을 시뮬레이트합니다. 그러나 여전히 동일한 대상 시스템을 시뮬레이트하는 다른 플랫폼 구성과 같은 비트 및 사이클 일치 결과를 생성합니다.

실제로, 가장 큰 이득은 큰 다중 코어 BOOM 기반 시스템에 ``MCRams`` 및 ``MCModels`` 최적화를 적용함으로써 실현될 것입니다. 이러한 시뮬레이터 플랫폼은 최적화되지 않은 FireSim 시뮬레이터보다 처리량이 감소하겠지만, 단일 FPGA에 맞지 않는 매우 큰 SoC를 분할의 비용과 성능 단점을 없이 시뮬레이션할 수 있습니다.

.. code-block:: yaml

    firesim-optimized-big-soc:
        DESIGN: FireSim
        TARGET_CONFIG: MyMultiCoreBoomConfig
        PLATFORM_CONFIG: MTModels_MCRams_BaseF1Config
        deploy_quintuplet: null
