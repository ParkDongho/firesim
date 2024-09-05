Manager Command Line Arguments
===================================

매니저는 ``firesim --help`` 명령을 실행하면 지원하는 명령줄 인수에 대한 내장된 도움말 출력을 제공합니다.

.. include:: HELP_OUTPUT
   :code: bash

이 페이지에서는 이러한 옵션 중 일부를 살펴볼 것입니다. 다른 옵션들은 더 복잡하므로 다음 페이지에서 별도의 섹션으로 다루겠습니다.

``--runtimeconfigfile`` ``FILENAME``
-----------------------------------------

사용자가 맞춤형 **runtime** 구성 파일을 지정할 수 있습니다. 기본적으로 ``config_runtime.yaml`` 이 사용됩니다. 이 구성 파일이 무엇을 하는지에 대해서는 :ref:`config-runtime` 을 참조하십시오.

``--buildconfigfile`` ``FILENAME``
------------------------------------------

사용자가 맞춤형 **build** 구성 파일을 지정할 수 있습니다. 기본적으로 ``config_build.yaml`` 이 사용됩니다. 이 구성 파일이 무엇을 하는지에 대해서는 :ref:`config-build` 을 참조하십시오.

``--buildrecipesconfigfile`` ``FILENAME``
---------------------------------------------------

사용자가 맞춤형 **build recipes** 구성 파일을 지정할 수 있습니다. 기본적으로 ``config_build_recipes.yaml`` 이 사용됩니다. 이 구성 파일이 무엇을 하는지에 대해서는 :ref:`config-build-recipes` 를 참조하십시오.

``--hwdbconfigfile`` ``FILENAME``
--------------------------------------------

사용자가 맞춤형 **하드웨어 데이터베이스** 구성 파일을 지정할 수 있습니다. 기본적으로 ``config_hwdb.yaml`` 이 사용됩니다. 이 구성 파일이 무엇을 하는지에 대해서는 :ref:`config-hwdb` 를 참조하십시오.

``--overrideconfigdata`` ``SECTION`` ``PARAMETER`` ``VALUE``
------------------------------------------------------------------

**runtime** 구성 파일의 단일 값을 재정의할 수 있습니다. 예를 들어, 특정 실행에서 링크 지연 시간을 3003 사이클로 사용하려는 경우(그리고 ``config_runtime.yaml`` 파일에 다른 값이 지정되어 있는 경우), ``--overrideconfigdata target_config link_latency 6405`` 를 매니저에 전달할 수 있습니다. 이 명령은 runtime 구성을 사용하는 모든 작업에 사용할 수 있습니다.

``--launchtime`` ``TIMESTAMP``
---------------------------------------------------

``results-build`` 디렉터리에서 접두사로 사용될 "Y-m-d--H-M-S" 타임스탬프를 지정합니다. 수동으로 수정된 ``buildbitstream`` 후 ``tar2afi`` 를 실행하려는 경우에 유용합니다.

``TASK``
-------------

이것은 매니저에 필요한 유일한 위치 명령줄 인수입니다. 매니저가 수행해야 할 작업을 지정합니다. 작업 목록과 그 작업이 무엇을 하는지에 대해서는 다음 섹션을 참조하십시오. 일부 작업은 해당 작업과 함께 다른 명령줄 인수를 받습니다.
