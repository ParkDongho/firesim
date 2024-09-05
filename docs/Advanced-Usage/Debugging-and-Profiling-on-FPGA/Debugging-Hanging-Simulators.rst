.. _debugging-hanging-simulators:

Debugging a Hanging Simulator
=============================

A common symptom of a failing simulation is that appears to
hang. Debugging this is especially daunting in FireSim because it's not immediately
obvious if it's a bug in the target, or somewhere in the host. To make it easier to
identify the problem, the simulation driver includes a polling watchdog that
tracks for simulation progress, and periodically updates an output file,
``heartbeat.csv``, with a target cycle count and a timestamp. When debugging
these issues, we always encourage the use of metasimulation to try
reproducing the failure if possible. We outline three common cases in the
section below.


Case 1: Target hang.
++++++++++++++++++++++++++++

**Symptoms:** There is no output from the target (i.e., the uartlog
might cease), but simulated time continues to advance (``heartbeat.csv`` will
be periodically updated). Simulator instrumentation (TracerV, printf) may
continue to produce new output.

**Causes:** Typically, a bug in the target RTL. However, bridge bugs leading to
erroneous token values will also produce this behavior.

**Next steps:** You can deploy the full suite of FireSim's debugging tools for
failures of this nature, since assertion synthesis, printf synthesis, and other
target-side features still function. Assume there is a bug in the target RTL
and trace back the failure to a bridge if applicable.


Case 2: Simulator hang due to FPGA-side token starvation.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

**Symptoms:** The driver's main loop spins freely, as no bridge gets new
work to do.  As a result, the polling interval quickly elapses and the
simulation is torn down due to a lack of forward progress.

**Causes:** Generally, a bug in a bridge implementation (ex. the BridgeModule has accidentally dequeued a
token without producing a new output token; the BridgeModule is waiting on a driver interaction that never occurs).

**Next steps:** These are the trickiest to solve. Try to identify the bridge that's
responsible by removing unnecessary ones, using an AutoILA, and adding printfs
to BridgeDriver sources.  Target-side debugging utilities may be used to
identify problematic target behavior, but tend not to be useful for identifying
the root cause.

Case 3: Simulator hang due to driver-side deadlock.
+++++++++++++++++++++++++++++++++++++++++++++++++++

**Symptoms:** The loss of all output, notably, ``heartbeat.csv`` ceases to be further updated.

**Causes:** Generally, a bridge driver bug. For example, the driver may be busy waiting on
some output from the FPGA, but the FPGA-hosted part of the simulator has
stalled waiting for tokens.

**Next Steps:** Identify the buggy driver using printfs or attaching to the
running simulator using GDB.


Simulator Heartbeat PlusArgs
++++++++++++++++++++++++++++

``+heartbeat-polling-interval=<int>``: Specifies the number of round trips through
the simulator main loop before polling the FPGA's target cycle counter. Disable
the heartbeat by setting this to -1.


시뮬레이터 멈춤 디버깅
==================================

실패한 시뮬레이션의 일반적인 증상은 시뮬레이션이 멈춘 것처럼 보이는 것입니다. FireSim에서 이를 디버깅하는 것은 target에 버그가 있는지 host에 있는지가 즉시 명확하지 않기 때문에 특히 어렵습니다. 문제를 더 쉽게 식별할 수 있도록 시뮬레이션 드라이버에는 시뮬레이션 진행 상태를 추적하고 주기적으로 target 사이클 수 및 타임스탬프와 함께 출력 파일 ``heartbeat.csv`` 을 업데이트하는 polling watchdog이 포함되어 있습니다. 이러한 문제를 디버깅할 때, 가능한 경우 metasimulation을 사용하여 실패를 재현하려고 노력하는 것이 항상 권장됩니다. 아래 섹션에서는 세 가지 일반적인 사례를 설명합니다.


Case 1: Target hang.
++++++++++++++++++++++++++++

**증상:** target에서 출력이 없습니다 (예: uartlog가 중지될 수 있음), 그러나 시뮬레이션된 시간은 계속 진행됩니다 (``heartbeat.csv`` 이 주기적으로 업데이트됨). 시뮬레이터 계측 (TracerV, printf)은 계속해서 새로운 출력을 생성할 수 있습니다.

**원인:** 일반적으로 target RTL의 버그. 그러나 잘못된 토큰 값으로 이어지는 bridge 버그도 이 동작을 발생시킵니다.

**다음 단계:** assertion synthesis, printf synthesis 및 기타 target 측 기능이 여전히 작동하므로 이러한 유형의 실패에 대해 FireSim의 전체 디버깅 도구 세트를 배포할 수 있습니다. target RTL에 버그가 있다고 가정하고, 관련이 있을 경우 실패를 bridge로 추적합니다.


Case 2: Simulator hang due to FPGA-side token starvation.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

**증상:** 드라이버의 메인 루프가 자유롭게 돌며, 어떤 bridge도 새로운 작업을 받지 않습니다. 그 결과 polling 간격이 빠르게 경과하고 시뮬레이션이 진행되지 않기 때문에 해체됩니다.

**원인:** 일반적으로 bridge 구현의 버그 (예: BridgeModule이 새로운 출력 토큰을 생성하지 않고 실수로 토큰을 dequeued함; BridgeModule이 결코 발생하지 않는 드라이버 상호작용을 기다리고 있음).

**다음 단계:** 이를 해결하는 것은 가장 까다롭습니다. 불필요한 bridge를 제거하고, AutoILA를 사용하고, BridgeDriver 소스에 printfs를 추가하여 responsible bridge를 식별하려고 시도합니다. target 측 디버깅 도구를 사용하여 문제의 target 동작을 식별할 수 있지만, 근본 원인을 식별하는 데는 유용하지 않을 수 있습니다.

Case 3: Simulator hang due to driver-side deadlock.
+++++++++++++++++++++++++++++++++++++++++++++++++++

**증상:** 모든 출력 상실, 특히 ``heartbeat.csv`` 이 더 이상 업데이트되지 않습니다.

**원인:** 일반적으로 bridge 드라이버 버그. 예를 들어, 드라이버가 FPGA의 출력을 기다리며 계속 바쁜 상태이지만, 시뮬레이터의 FPGA에 호스트된 부분은 토큰을 기다리며 멈춘 상태입니다.

**다음 단계:** printfs를 사용하거나 GDB를 사용하여 실행 중인 시뮬레이터에 연결하여 버그 있는 드라이버를 식별합니다.


Simulator Heartbeat PlusArgs
++++++++++++++++++++++++++++

``+heartbeat-polling-interval=<int>``: 시뮬레이터 메인 루프를 몇 번 왕복하는 동안 FPGA의 target 사이클 카운터를 polling할지 지정합니다. 이 값을 -1로 설정하여 heartbeat을 비활성화합니다.
