.. _printf-synthesis:

Printf Synthesis: Capturing RTL printf Calls when Running on the FPGA
=============================================================================

Golden Gate는 FPGA 합성 흐름에서 손실될 수 있는 Chisel/FIRRTL에 존재하는 printf를 합성할 수 있습니다
(``printf`` 문장으로 구현됨).
Rocket과 BOOM은 그들의 커밋 로그와 다른 유용한 트랜잭션 스트림의 printf를 가지고 있습니다.

.. code-block:: text

    C0:        409 [1] pc=[008000004c] W[r10=0000000000000000][1] R[r 0=0000000000000000] R[r20=0000000000000003] inst=[f1402573] csrr    a0, mhartid
    C0:        410 [0] pc=[008000004c] W[r 0=0000000000000000][0] R[r 0=0000000000000000] R[r20=0000000000000003] inst=[f1402573] csrr    a0, mhartid
    C0:        411 [0] pc=[008000004c] W[r 0=0000000000000000][0] R[r 0=0000000000000000] R[r20=0000000000000003] inst=[f1402573] csrr    a0, mhartid
    C0:        412 [1] pc=[0080000050] W[r 0=0000000000000000][0] R[r10=0000000000000000] R[r 0=0000000000000000] inst=[00051063] bnez    a0, pc + 0
    C0:        413 [1] pc=[0080000054] W[r 5=0000000080000054][1] R[r 0=0000000000000000] R[r 0=0000000000000000] inst=[00000297] auipc   t0, 0x0
    C0:        414 [1] pc=[0080000058] W[r 5=0000000080000064][1] R[r 5=0000000080000054] R[r16=0000000000000003] inst=[01028293] addi    t0, t0, 16
    C0:        415 [1] pc=[008000005c] W[r 0=0000000000010000][1] R[r 5=0000000080000064] R[r 5=0000000080000064] inst=[30529073] csrw    mtvec, t0

이 printf들을 합성하면 실행 중인 FireSim 인스턴스에서 동일한 로그를 캡처할 수 있습니다.

Enabling Printf Synthesis
----------------------------

printf를 합성하려면 Chisel 소스 코드에서 캡처하려는 특정 printf를 다음과 같이 주석으로 달아야 합니다::

    midas.targetutils.SynthesizePrintf(printf("x%d p%d 0x%x\n", rf_waddr, rf_waddr, rf_wdata))

많은 빈번한 printf를 합성하면 시뮬레이터가 느려지므로 신중하게 선택하십시오.

printf에 주석을 달았다면, ``config_build_recipes.yaml`` 의 ``PLATFORM_CONFIG`` 에
``WithPrintfSynthesis`` 구성 믹스인을 추가하여 printf 합성을 활성화하십시오.
예를 들어, 이전 ``PLATFORM_CONFIG`` 가 ``PLATFORM_CONFIG=BaseF1Config`` 인 경우,
``PLATFORM_CONFIG=WithPrintfSynthesis_BaseF1Config`` 로 변경하십시오. 믹스인을 반드시
앞에 추가해야 합니다. 컴파일 중에 Golden Gate는 합성한 printf의 수를 출력합니다.
타겟의 생성된 헤더(``FireSim-generated.const.h``)에서 Golden Gate가 합성한 각 printf에 대한 메타데이터를 찾을 수 있습니다.
이는 ``synthesized_prints_t`` 브리지 드라이버의 생성자에 인수로 전달되며,
자동으로 FireSim 드라이버에 인스턴스화됩니다.

Runtime Arguments
---------------------------

**+print-file**
    파일 이름 접두사를 지정합니다. 생성된 파일은 `<print-file><N>` 형태로,
    각 클럭 도메인 당 하나의 출력 파일이 생성됩니다. 연결된 클럭 도메인의
    이름과 기본 클럭에 대한 주파수는 출력 파일의 헤더에 포함됩니다.

**+print-start**
    시뮬레이터에서 printf 트레이스를 캡처할 타겟 주기를 기본 클럭의 주기로 지정합니다.
    고대역폭 printf 트레이스를 캡처하면 시뮬레이션이 느려지므로,
    사용자가 관심 영역에 최대 시뮬레이션 속도로 도달할 수 있도록 합니다.

**+print-end**
    시뮬레이터에서 합성된 printf 트레이스를 중지할 타겟 주기를 기본 클럭의 주기로 지정합니다.

**+print-binary**
    기본적으로 캡처된 printf 트레이스는 소프트웨어 RTL 시뮬레이터에서
    방출되는 형식으로 파일에 기록됩니다. 이 플래그를 설정하면 FPGA에서
    나오는 원시 바이너리를 대신 덤프하여 시뮬레이션 속도를 개선합니다.

**+print-no-cycle-prefix**
    (형식화된 출력 전용) 각 printf에서 사이클 접두사를 제거하여
    printf가 이미 주기 필드를 포함하는 경우 대역폭을 절약합니다. 바이너리 출력 모드에서는
    타겟 주기가 토큰 스트림에 내포되어 있으므로 이 플래그는 효과가 없습니다.

이 옵션들 중 일부는 "synthprint" 섹션의 필드를 변경하여 config_runtime.yaml에서 설정할 수 있습니다.

.. literalinclude:: /../deploy/sample-backup-configs/sample_config_runtime.yaml
   :language: yaml
   :start-after: DOCREF START: Synthesized Prints
   :end-before: DOCREF END: Synthesized Prints

"start" 필드는 "print-start"에, "end"는 "print-end"에, "cycleprefix"는 "print-no-cycle-prefix"에 해당합니다.

Related Publications
--------------------

Printf 합성은 FPL2018 논문, `DESSERT <https://people.eecs.berkeley.edu/~biancolin/papers/dessert-fpl18.pdf>`_ 에서 처음 발표되었습니다.