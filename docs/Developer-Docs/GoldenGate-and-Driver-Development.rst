Compiler & Driver Development
=======================================================

.. _Scala Integration Tests:

Integration Tests
+++++++++++++++++

이 테스트들은 FireSim의 Makefile을 호출하는 ``ScalaTests`` 입니다. 이 테스트들은 Target, Compiler, 그리고 Driver 측 기능에 대한 FireSim의 대부분의 테스트를 구성합니다. 각각의 테스트는 다음과 같이 진행됩니다:

#. 단일 기능을 시험하는 작은 Chisel 타겟 디자인을 설계합니다 (예: printf 합성).
#. GoldenGate로 디자인을 컴파일합니다.
#. 타겟별 드라이버와 Golden Gate에서 생성된 부수 자료를 사용하여 메타시뮬레이터를 컴파일합니다.
#. 지정된 인수로 메타시뮬레이션을 실행합니다 (여러 번 실행될 수 있습니다).
#. Scala에서 메타시뮬레이션 출력을 후처리합니다.

개별 테스트는 :gh-file-ref:`sim/` 디렉토리에서 다음과 같이 직접 실행할 수 있습니다::

   # Chipyard 기반의 모든 테스트를 실행 (Rocket + BOOM 사용)
   make test

   # 모든 통합 테스트 실행 (매우 오래 걸리므로 권장하지 않음)
   make test TARGET_PROJECT=midasexamples

   # 특정 통합 테스트 실행 (권장)
   make testOnly TARGET_PROJECT=midasexamples SCALA_TEST=firesim.midasexamples.GCDF1Test

   # 주의: 특정 테스트 서브셋을 비활성화하려면 환경 변수
   # TEST_DISABLE_{VERILATOR,VCS,VIVADO}=1을 사용할 수 있습니다.

이 테스트들은 SBT 콘솔에서 연속적으로 실행할 수 있으며, SBT는 Scala 변경 시 테스트를 다시 실행합니다 (하지만 드라이버 변경은 아님). :gh-file-ref:`sim/` 디렉토리에서 실행::

   # SBT 콘솔을 firesim 서브프로젝트로 시작
   # 참고: TARGET_PROJECT를 생략하면 FireChip 서브프로젝트로 이동합니다.
   make TARGET_PROJECT=midasexamples sbt

   # Scala 테스트 소스를 컴파일 (선택 사항, 탭 완성을 위해)
   sbt:firesim> Test / compile

   # 특정 테스트를 한 번 실행
   sbt:firesim> testOnly firesim.midasexamples.GCDF1Test

   # Scala 변경 시 테스트를 연속적으로 다시 실행
   sbt:firesim> ~testOnly firesim.midasexamples.GCDF1Test


Key Files & Locations
---------------------
- :gh-file-ref:`sim/firesim-lib/src/test/scala/TestSuiteCommon.scala`
   FireSim의 make 빌드 시스템을 사용하는 모든 테스트의 기본 ScalaTest 클래스
- :gh-file-ref:`sim/src/test/scala/midasexamples/TutorialSuite.scala`
   대부분의 통합 테스트를 위한 TestSuiteCommon의 확장 + 구체적인 서브클래스
- :gh-file-ref:`sim/src/main/cc/midasexamples/`
   타겟별 드라이버를 위한 C++ 소스
- :gh-file-ref:`sim/src/main/cc/midasexamples/TestHarness.h`
   간단한 테스트를 위해 확장하는 공통 드라이버
- :gh-file-ref:`sim/src/main/scala/midasexamples/`
   최상위 Chisel 모듈(타겟)이 정의되는 위치

Defining a New Test
--------------------

#. ``sim/src/main/scala/midasexamples`` 디렉토리에서 새로운 타겟 모듈을 정의합니다 (해당하는 경우).
#. ``src/main/cc/midasexamples`` 디렉토리에서 ``simif_t`` 또는 다른 자식 클래스를 확장하여 드라이버를 정의합니다. Peek Poke 브리지와 함께 순차 처리되는 테스트는 ``simif_peek_poke_t`` 를 확장할 수 있습니다.
#. ``src/main/cc/midasexamples`` 에서 테스트를 생성합니다. 브리지를 등록하고 ``run`` 메소드를 덮어씁니다.
#. ``TutorialSuite`` 를 확장하여 디자인에 대한 ScalaTest 클래스를 정의합니다. 매개변수는 튜플 (``DESIGN``, ``TARGET_CONFIG``, ``PLATFORM_CONFIG``)을 정의하고 메타시뮬레이터에 전달할 추가 plusArgs를 호출합니다. 자세한 내용은 ScalaDoc을 참조하세요. 메타시뮬레이터 출력의 후처리(예: 출력 파일 내용 확인)는 테스트 클래스 본문에서 구현할 수 있습니다.


Synthesizable Unit Tests
++++++++++++++++++++++++

이 테스트들은 Rocket-Chip의 합성 가능한 유닛 테스트 라이브러리에서 파생되었으며, 더 작은 독립형 Chisel 모듈을 테스트하는 데 사용됩니다.

합성 가능한 유닛 테스트는 :gh-file-ref:`sim/` 디렉토리에서 다음과 같이 실행할 수 있습니다::

   # 웨이브 없이 기본 테스트 실행
   $ make run-midas-unittests

   # 웨이브와 함께 기본 테스트 실행
   $ make run-midas-unittests-debug

   # Verilator에서 기본 테스트 실행
   $ make run-midas-unittests  EMUL=verilator

   # 다른 테스트 스위트 실행 (TimeOutCheck 클래스명으로 등록)
   $ make run-midas-unittests  CONFIG=TimeOutCheck

make 변수 ``CONFIG`` 를 다른 scala 클래스 이름으로 설정하면 다른 유닛 테스트 세트를 선택할 수 있습니다. 모든 합성 가능한 유닛 테스트는 ``WithAllUnitTests`` 클래스에 등록되어 ScalaTest와 CI에서 실행됩니다.

Key Files & Locations
---------------------

- :gh-file-ref:`sim/midas/src/main/scala/midas/SynthUnitTests.scala`
   합성 가능한 유닛 테스트 모듈이 이곳에 등록됩니다.
- :gh-file-ref:`sim/midas/src/main/cc/unittest/Makefrag`
   테스트 빌드와 실행을 위한 Make 레시피.
- :gh-file-ref:`sim/firesim-lib/src/test/scala/TestSuiteCommon.scala`
   합성 가능한 유닛 테스트를 실행하기 위한 ScalaTest 래퍼

Defining a New Test
--------------------
#. ``freechips.rocketchip.unittest.UnitTest`` 를 확장하는 새로운 Chisel 모듈을 정의합니다.
#. ``Config`` 에서 ``UnitTests`` 키를 사용하여 모듈을 등록합니다. 예시는 ``SynthUnitTests.scala`` 를 참조하세요.

Scala Unit Testing
++++++++++++++++++

우리는 또한 개별 변환, 클래스, 타겟 측 Chisel 기능 (``targetutils`` 패키지에서)을 테스트하기 위해 ScalaTest를 사용합니다. 이 테스트들은 Scala 프로젝트의 관례에 따라 ``<subproject>/src/test/scala`` 에 위치합니다. ``targetUtils`` 의 ScalaTests는 일반적으로 타겟 측 어노테이터가 제너레이터에서 올바르게 작동하는지 확인합니다 (올바르게 elaborated 되거나 원하는 오류 메시지를 제공합니다). ``midas`` 의 ScalaTests는 주로 FIRRTL 변환을 테스트하는 데 맞춰져 있으며, FIRRTL 테스트 유틸리티를 소스 트리에 복사하여 그 과정을 쉽게 합니다.

``targetUtils`` scala 테스트는 :gh-file-ref:`sim/` 에서 다음과 같이 실행할 수 있습니다::

   # firesim 서브프로젝트에서 SBT 콘솔 열기
   $ make TARGET_PROJECT=midasexamples sbt

   # targetutils 패키지로 전환
   sbt:firesim> project targetutils

   # ``targetutils`` 서브프로젝트에서 모든 scala 테스트 실행
   sbt:midas-targetutils> test

Golden Gate (이전 명칭 midas) scala 테스트는 위의 2단계처럼 scala 프로젝트를 ``midas`` 로 설정하여 실행할 수 있습니다.

Key Files & Locations
---------------------

- :gh-file-ref:`sim/midas/src/test/scala/midas`
   GoldenGate ScalaTests의 위치
- :gh-file-ref:`sim/midas/targetutils/src/test/scala`
   targetutils ScalaTests의 위치

Defining A New Test
---------------------

적절한 ScalaTest 사양 또는 기본 클래스를 확장하고, 파일을 올바른 ``src/test/scala`` 디렉토리 아래에 배치합니다. ScalaTest에 의해 자동으로 열거되어 기본적으로 CI에서 실행됩니다.

C/C++ guidelines
++++++++++++++++

C++ 소스는 ``clang-format`` 을 사용하여 포맷팅되며, 모든 제출된 pull-request는 수락되고 병합되기 전에 포맷팅되어야 합니다. 소스는 ` 여기 <https://github.com/firesim/firesim/blob/main/.clang-format>`_ 에서 정의된 코딩 스타일을 따릅니다. 또한, ``clang-tidy`` 도 CI에서 실행되어 C++ 소스를 린트하고 검증합니다. 이 도구는 LLVM의 지침과 구성을 따릅니다.

``git clang-format`` 을 사용하여 커밋하기 전에 파일이 올바르게 포맷되었는지 확인할 수 있습니다.
``make -C sim clang-tidy`` 를 사용하여 ``clang-tidy`` 를 실행할 수 있습니다. `make -C sim clang-tidy-fix` 는 대부분의 수정을 자동으로 적용하지만, 일부 오류와 경고는 사용자 개입이 필요할 수 있습니다.

Scala guidelines
++++++++++++++++

Scala 소스는 ``Scalafmt`` 와 ``Scalafix`` 를 사용하여 포맷팅됩니다. 모든 제출된 pull-request는 수락되고 병합되기 전에 포맷팅되어야 합니다. 구성 파일은 다음에서 찾을 수 있습니다: `Scalafmt config <https://github.com/firesim/firesim/blob/main/sim/.scalafix.conf>`_, `Scalafix config <https://github.com/firesim/firesim/blob/main/sim/.scalafmt.conf>`_. `make -C sim scala-lint-check`` 를 실행하여 코드가 규정을 준수하는지 확인합니다. `make -C sim scala-lint`` 를 실행하여 자동으로 수정을 적용하십시오.