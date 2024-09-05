Simulation Triggers
===================

디버그 및 계측 기능을 특정 타겟 이벤트를 사용하여 전역적으로 조정하는 것이 종종 유용할 수 있으며, 이는 타겟 설계 전반에 걸쳐 분산될 수 있습니다.
예를 들어, 특정 명령이 어떤 코어에서든 커밋될 때 합성된 출력 수집과 AutoCounters의 샘플링을 동시에 활성화하고 싶거나,
메모리 시스템이 특정 메모리 주소에 쓰기를 수행할 때 이러한 작업을 수행하고자 할 수 있습니다.
Golden Gate의 트리거 시스템은 중심화된 크레딧 기반 시스템을 사용하여 설계 전반에 걸쳐 분산된 주석 처리된 ``TriggerSources`` 를 집계함으로써 이를 가능하게 합니다.
그런 다음 이 시스템은 설계 전반에 걸쳐 분산된 모든 ``TriggerSinks`` 에 단일 비트 레벨 민감도 활성화를 구동합니다.
이 활성화 신호는 설계가 관심 지역(ROI)에 있는 동안 주장됩니다.
Source는 크레딧을 부여하여 ROI의 시작을 신호하고, 디빗을 주장하여 ROI의 끝을 신호합니다.
여러 Source가 있을 수 있으며, 각 Source는 크레딧을 부여할 수 있기 때문에, 트리거는 시스템이 크레딧을 받은 횟수만큼 정확하게 디빗을 받을 때만 비활성화됩니다(잔액이 0).

Quick-Start Guide
--------------------

Level-Sensitive Trigger Source
******************************

부울 ``enable`` 이 참일 때 트리거를 주장합니다.

.. literalinclude:: ../../sim/src/main/scala/midasexamples/TriggerWiringModule.scala
    :language: scala
    :start-after: DOC include start: TriggerSource Level-Sensitive Usage
    :end-before: DOC include end: TriggerSource Level-Sensitive Usage

주의사항:
 - Sink에서 보이는 트리거는 지연됩니다. See :ref:`trigger-timing`.
 - 이것이 유일한 Source라고 가정합니다; 추가적인 크레딧이 부여되지 않은 경우에만 트리거가 클리어됩니다.

Distributed, Edge-Sensitive Trigger Source
******************************************

부울 `start` 가 양의 변화를 겪을 때 트리거 활성화를 주장하고, 두 번째 신호 `stop` 이 양의 변화를 겪을 때 트리거를 클리어합니다.

.. literalinclude:: ../../sim/src/main/scala/midasexamples/TriggerWiringModule.scala
    :language: scala
    :start-after: DOC include start: TriggerSource Usage
    :end-before: DOC include end: TriggerSource Usage

주의사항:
 - Sink에서 보이는 트리거는 지연됩니다. See :ref:`trigger-timing`.
 - 이것이 유일한 Source라고 가정합니다; 추가적인 크레딧이 부여되지 않은 경우에만 트리거가 클리어됩니다.

Chisel API
-----------
Trigger sources와 sinks는 특정 클럭 도메인에 동기화된 Boolean 신호로 주석 처리되었습니다.
``midas.targetutils`` 패키지는 이러한 신호를 설계에 주석 처리하기 위한 chisel-지향 유틸리티를 제공합니다.
아래에서 이러한 유틸리티를 설명하며, 소스는 :gh-file-ref:`sim/midas/targetutils/src/main/scala/midas/annotations.scala` 에서 찾을 수 있습니다.

Trigger Sources
***************
설계 전체에 걸쳐 트리거 소스를 분산할 수 있도록 하려면 ``TriggerSource`` 객체에서 제공하는 메서드를 사용하여 개별 부울 신호를 크레딧과 디빗으로 주석 처리해야 합니다.
아래에 예시를 제공하였습니다(Quick-Start Guide의 분산 예시).

.. literalinclude:: ../../sim/src/main/scala/midasexamples/TriggerWiringModule.scala
    :language: scala
    :start-after: DOC include start: TriggerSource Usage
    :end-before: DOC include end: TriggerSource Usage

위의 메서드를 사용하면 설계가 리셋 상태일 때 발행된 크레딧과 디빗은 계산되지 않습니다(사용된 리셋은 Chisel 모듈의 암시적 리셋임).
모듈이 암시적 리셋을 제공하지 않거나, 로컬 모듈의 암시적 리셋이 주장된 동안 트리거 시스템에 크레딧이나 디빗을 부여하려는 경우, 대신 ``TriggerSource.{creditEvenUnderReset, debitEvenUnderReset}`` 을 사용하십시오.

Trigger Sinks
*************
Source와 마찬가지로 Trigger Sinks는 관련 클럭과 함께 주석 처리된 부울 신호입니다.
이 신호들은 트리거 시스템에서 생성된 부울 값에 의해 구동됩니다. 설계에 트리거 소스가 존재하면,
생성된 트리거는 **동일한 신호에 대해 chisel에서 이루어진 모든 할당을 무시**합니다.
그렇지 않으면 사용자에 의해 제공된 기본 값을 가지게 됩니다. 아래에서 ``TriggerSink`` 객체를 사용한 Sink 주석 예를 제공합니다.

.. literalinclude:: ../../sim/src/main/scala/midasexamples/TriggerWiringModule.scala
    :language: scala
    :start-after: DOC include start: TriggerSink Usage
    :end-before: DOC include end: TriggerSink Usage

또한, 트리거 Sink를 Chisel의 ``when`` 블록에 대한 술어로 사용하려면 ``TriggerSink.whenEnabled`` 를 대신 사용할 수 있습니다.

.. literalinclude:: ../../sim/src/main/scala/midasexamples/TriggerPredicatedPrintf.scala
    :language: scala
    :start-after: DOC include start: TriggerSink.whenEnabled Usage
    :end-before: DOC include end: TriggerSink.whenEnabled Usage


.. _trigger-timing:

Trigger Timing
---------------
Golden Gate는 크레딧 및 디빗을 기반 클럭 도메인을 사용하여 단일 레지스터 단계로 동기화한 후, 글로벌 회계를 수행하는 타겟 회로를 생성하여 트리거 시스템을 구현합니다.
크레딧의 총 합이 디빗보다 많으면 트리거가 주장됩니다. 그런 다음 이 트리거는 단일 레지스터 단계를 사용하여 각 Sink 도메인에서 동기화된 후 주석 처리된 Sink를 구동합니다.
이 기능을 구현하는 회로는 아래에 나와 있습니다:

.. figure:: trigger-schematic.svg
    :width: 800px
    :align: center

    트리거 생성 회로. 나와 있지 않음: 크레딧을 계산하는 회로와 유사한 부 회로가 디빗을 계산하기 위해 복제됩니다.
    마찬가지로, 합산 환원에 피드를 공급하는 부 회로는 적어도 하나의 소스 주석이 포함된 각 클럭 도메인에 대해 생성됩니다.


현재 구현에 따르면, 트리거가 활성화되면 크레딧이 주장된 후 한 기본 클럭 에지와 한 로컬 클럭 에지가 경과된 뒤 순서대로 Sink 도메인에 보이게 됩니다.
이것은 아래 파형에 나타나 있습니다.

.. figure:: trigger-waveform.svg
    :width: 800px
    :align: center

    트리거 타이밍 다이어그램.


기본 클럭 도메인에 위치한 트리거 소스와 싱크는 추가적인 동기화 레지스터가 필요하지 않더라도 여전히 추가됩니다.
따라서 기본 클럭 도메인의 소스에서 발행된 크레딧은 기본 클럭 도메인의 싱크에 정확히 2 사이클 후에 보이게 됩니다.

기본 ``HostPort`` 인터페이스를 사용하는 브릿지는 시뮬레이션 FMR을 개선하기 위해 토큰 채널이 단일 레지스터 단계를 모델링하므로 브릿지의 로컬 도메인에서 추가적인 사이클 지연을 추가합니다.
따라서 다른 ``HostPort`` 구현을 사용하지 않는 경우, 브릿지에 의해 생성된 트리거 소스와 브릿지에 피드되는 트리거 싱크는 각각 추가적인 브릿지 로컬 사이클 지연을 보게 됩니다.
반면에, 합성된 출력과 애서션, AutoCounters는 모두 와이어 채널을 사용하므로(일방향 인터페이스이므로 추가 레지스터 단계가 FMR을 개선하는 데 필요하지 않음) 추가적인 싱크 지연을 보지 않습니다.

Limitations & Pitfalls
----------------------
- 시스템은 하나의 트리거 신호로 제한됩니다. 현재로서는 고유한 트리거를 개별 싱크 세트에 생성하는 방법이 없습니다.
- 크레딧보다 디빗을 더 많이 발행하지 않도록 주의하십시오. 이는 현재 구현에서 잘못된 트리거를 활성화할 수 있습니다.