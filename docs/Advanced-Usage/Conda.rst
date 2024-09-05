Non-Source Dependency Management
================================

AWS EC2 F1 설정에서는, :doc:`/Getting-Started-Guides/AWS-EC2-F1-Getting-Started/Initial-Setup/Setting-up-your-Manager-Instance` 에서 `scripts/machine-launch-script.sh` 의 내용을 빠르게 EC2 관리 콘솔에 복사하여 붙여넣었고, 해당 스크립트는 `Conda <https://conda.io/en/latest/index.html>`_, 플랫폼에 구애받지 않는 패키지 관리자, 특히 `conda-forge 커뮤니티 <https://conda-forge.org/#about>`_ 에서 제공하는 패키지를 사용하여 FireSim이 필요로 하는 많은 종속성을 설치했습니다 (또는 :doc:`/Getting-Started-Guides/AWS-EC2-F1-Getting-Started/Initial-Setup/Setting-up-your-Manager-Instance` 에서 `scripts/machine-launch-script.sh` 를 실행했습니다).

많은 상황에서, `conda` 에 대해 아무것도 알 필요가 없을 수 있습니다. 기본적으로, `machine-launch-script.sh` 는 `/opt/conda` 에 `conda` 를 설치하고, FireSim 종속성 전부를 `/opt/conda/envs/firesim` 의 `firesim` 이라는 '이름 있는 환경'에 설치합니다. 또한 `machine-launch-setup.sh` 는 모든 사용자의 경로에 `/opt/conda/envs/firesim/bin` 을 추가하기 위해 시스템 전역의 `conda.sh` 초기화 스크립트(`etc/profile.d/conda.sh`)에 필요한 설정을 추가합니다.

그러나, 이 스크립트는 유연하게 사용할 수도 있습니다. 예를 들어, 루트 권한이 없는 경우, `machine-launch-script.sh` 에 `--prefix` 옵션을 사용하여 다른 설치 위치를 지정할 수 있습니다. 유일한 요구 사항은 설치 위치에 쓰기 권한이 있어야 한다는 것입니다. 자세한 내용은 `machine-launch-script.sh --help` 를 참조하십시오.

.. warning::

    FireSim에서 F1 FPGA에서 시뮬레이션을 실행하려면 :ref:`root 권한 <running_simulations>` 이 필요합니다.

    하지만, 루트 권한 없이도 FireSim 시스템에서 Verilator를 사용한 `<meta-simulation>`_, 또는 새로운 기능 개발 등 다양한 작업을 수행할 수 있습니다.

Updating a Package Version
--------------------------

패키지의 최신 버전이 필요한 경우, 가장 빠른 방법은 `conda-forge`_ 에서 `conda update <package-name>` 을 실행하여 새 버전이 있는지 확인하는 것입니다. 운이 좋다면, 원하는 패키지의 종속성이 단순한 경우, 다음과 같은 출력이 나타날 것입니다:

.. code-block:: bash

    bash-4.2$ conda update moto
    Collecting package metadata (current_repodata.json): done
    Solving environment: done

    ## Package Plan ##

      environment location: /opt/conda

      added / updated specs:
        - moto


    The following NEW packages will be INSTALLED:

      graphql-core       conda-forge/noarch::graphql-core-3.2.0-pyhd8ed1ab_0

    The following packages will be UPDATED:

      moto                                  2.2.19-pyhd8ed1ab_0 --> 3.1.0-pyhd8ed1ab_0

    Proceed ([y]/n)?


``graphql-core`` 의 추가는 `moto의 setup.py의 2.2.19와 3.1.0 간의 차이 <https://github.com/spulec/moto/compare/2.2.19...3.1.0#diff-60f61ab7a8d1910d86d9fda2261620314edcae5894d5aaa236b821c7256badd7>`_ 를 보면 새로운 종속성으로 추가된 것을 명확히 알 수 있습니다.

이 출력은 ``moto`` 의 최신 버전이 3.1.0임을 알려줍니다. 이제 ``<<Enter>>`` 를 눌러 진행하고 싶을 수도 있습니다.

.. attention::

    하지만, ``machine-launch-script.sh`` 의 버전을 수정하는 것이 더 좋습니다. 이렇게 하면:
    #. 새로운 버전 요구 사항을 커밋하고 공유할 수 있습니다.
    #. ``conda`` 가 요구 사항을 해결할 수 있도록 전체 요구 사항 집합을 제공할 수 있습니다. `conda install` 을 통해 모든 것을 한 번에 설치하는 것과 하나 또는 두 개의 패키지를 점진적으로 설치하는 것 사이에는 미묘한 차이가 있습니다. 이는 버전 제약 조건이 `conda 호출 사이에 유지되지 않기 때문입니다`. (참고: Python과 같은 특정 패키지는 환경 생성 시 `암묵적으로 고정되며 <https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-pkgs.html#preventing-packages-from-updating-pinning>`_, `명시적으로 요청된 경우에만 업데이트됩니다 <https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-python.html#updating-or-upgrading-python>`_ .)

따라서, ``machine-launch-script.sh`` 를 최신 버전의 ``moto`` 로 수정하고 실행하십시오. 환경을 실제로 변경하기 전에 ``machine-launch-script.sh`` 이 무엇을 할지 보고 싶다면, ``--dry-run`` 옵션을 사용하여 출력을 확인한 후 ``--dry-run`` 없이 다시 실행할 수 있습니다.

이 경우, 완료되면 ``conda list --revisions`` 을 실행하면 다음과 같은 출력을 볼 수 있습니다 ::

    bash-4.2$ conda list --revisions
    2022-03-15 19:21:10  (rev 0)
    +_libgcc_mutex-0.1 (conda-forge/linux-64)
    +_openmp_mutex-4.5 (conda-forge/linux-64)
    +_sysroot_linux-64_curr_repodata_hack-3 (conda-forge/noarch)
    +alsa-lib-1.2.3 (conda-forge/linux-64)
    +appdirs-1.4.4 (conda-forge/noarch)
    +argcomplete-1.12.3 (conda-forge/noarch)

     ...   예제에서는 많은 패키지를 생략했습니다 ...

    +xxhash-0.8.0 (conda-forge/linux-64)
    +xz-5.2.5 (conda-forge/linux-64)
    +yaml-0.2.5 (conda-forge/linux-64)
    +zipp-3.7.0 (conda-forge/noarch)
    +zlib-1.2.11 (conda-forge/linux-64)
    +zstd-1.5.2 (conda-forge/linux-64)

    2022-03-15 19:34:06  (rev 1)
         moto  {2.2.19 (conda-forge/noarch) -> 3.1.0 (conda-forge/noarch)}

이 출력은 ``machine-launch-script.sh`` 가 처음 실행될 때, 환경의 'revision' 0을 생성하면서 많은 패키지를 설치했음을 보여줍니다. ``moto`` 의 버전을 업데이트하고 다시 실행하면, 'revision' 1이 생성되어 ``moto`` 의 버전이 업데이트되었습니다. 언제든지 ``conda install -revision <n>`` 을 사용하여 Conda 환경을 이전 'revision'으로 되돌릴 수 있습니다.

Multiple Environments
---------------------

위 예제에서, 우리는 단일 패키지를 업데이트하기를 원했고 비교적 간단했습니다. 그러나, 더 큰 변경을 수행해야 하고 두 가지 도구 세트를 동시에 유지해야 할 필요가 있다고 생각되면 어떻게 해야 할까요?

이 경우, ``machine-launch-script.sh`` 의 ``--env <name>`` 옵션을 사용하십시오. 해당 옵션으로 설명적인 이름을 지정하면, 또 다른 '환경'을 생성할 수 있습니다. ``conda env list`` 를 실행하여 사용할 수 있는 환경 목록을 다음과 같이 확인할 수 있습니다::

    bash-4.2$   conda env list
    # conda environments:
    #
    base                     /opt/conda
    firesim                  /opt/conda/envs/firesim
    doc_writing           *  /opt/conda/envs/doc_writing

위 출력에서 보시다시피, `conda` 를 설치할 때 생성되는 'base' 환경과 `machine-launch-script.sh` 가 기본적으로 생성하는 ``firesim`` 환경이 있습니다. 또한, 위에 예시로 붙여넣은 몇 가지 예제를 보여주기 위해 'doc_writing' 환경도 생성했습니다.

또한 'doc_writing' 옆에 별표(*)가 있어, 현재 '활성화된' 환경임을 나타냅니다. 다른 환경으로 전환하려면 ``conda activate <name>`` 을 실행할 수 있습니다. 예를 들어 ``conda activate firesim``.

기본적으로, ``machine-launch-script.sh`` 는 요구 사항을 'firesim' 환경에 설치하고, 로그인 시 'firesim' 환경이 활성화되도록 ``conda init`` 을 실행합니다.

.. attention

    ``machine-launch-script.sh`` 를 다시 실행하고 ``--env <name>`` 를 제공하여 추가 환경을 생성

하는 경우, 로그인 시 활성화되는 환경은 업데이트되지 않습니다. 현재 활성화된 환경은 ``conda env list`` (위와 같음) 또는 ``conda info`` 의 출력을 통해 항상 확인할 수 있습니다.

Adding a New Dependency
-----------------------

다음 순서로 필요한 패키지를 찾으십시오:

#. `기존 conda-forge 패키지 목록 <feedstock-list>`_. `conda` 는 여러 도메인을 아우르므로 패키지 이름이 PyPI 또는 시스템 패키지 관리자 중 하나의 이름과 정확히 일치하지 않을 수 있음을 염두에 두십시오.
#. `conda-forge recipe 추가 <https://conda-forge.org/#add_recipe>`_. 이를 수행하는 경우, firesim@googlegroups.com 메일링 리스트에 알려주시면 추가 작업을 도와드리겠습니다.
#. `PyPI <https://pypi.org/>`_ (Python 패키지의 경우). ``pip`` 을 사용하여 ``conda`` 환경에 패키지를 설치하는 것이 가능하지만, `주의 사항이 있습니다 <https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html?highlight=pip#using-pip-in-an-environment>`_. 간단히 말해서, 환경 내 요구 사항 및 종속성을 관리할 때 Conda만 사용하는 것이 더 나은 결과를 얻을 가능성이 큽니다.
#. 마지막 수단으로 시스템 패키지. 서로 다른 플랫폼에서 동일한 도구를 사용하는 것은 서로 다른 시스템 및 조직에서 빌드 및 배포되므로 매우 어렵습니다. 그럼에도 불구하고, 급한 경우에는 ``machine-launch-script.sh`` 의 플랫폼별 설정 섹션에서 관련 부분을 찾을 수 있습니다.
#. 최후의 수단으로, 필요한 것을 설치하는 코드를 ``machine-launch-script.sh`` 또는 ``build-setup.sh`` 에 추가하고 PR 중에 위에서 언급한 다른 옵션으로 마이그레이션하는 것을 도와드리겠습니다.

Building From Source
--------------------

패키지에서 선택적 기능이 빠져 있는 경우, `기존 conda-forge 패키지 목록 <feedstock-list>`_ 에서 'feedstock' (aka recipe) 레포지토리를 찾아 이슈 또는 PR을 제출하는 것을 고려하십시오.

대신, 디버깅을 활성화해야 하거나 패키지의 소스 코드에서 적극적으로 작업해야 하는 경우:

#. `feedstock-list`_ 에서 feedstock 레포지토리 찾기
#. feedstock 레포지토리를 복제하고 ``recipe/build.sh`` (또는 빌드 스크립트가 없는 경우 ``recipe/meta.yaml``) 수정
#. ``python build-locally.py`` 를 사용하여 `conda-forge 도커 컨테이너로 빌드 <https://conda-forge.org/docs/maintainer/updating_pkgs.html#testing-changes-locally>`_. 빌드가 성공하면, ``build_artifacts/linux-64`` 에 설치 가능한 ``conda`` 패키지가 생성되어 ``conda install -c ./build_artifacts <packagename>``로 설치할 수 있습니다. 빌드가 성공하지 않으면, ``python build-locally.py`` 에 ``--debug`` 스위치를 추가하여 대화형 셸로 이동할 수 있습니다. 빌드 디렉토리를 찾고 올바른 환경을 활성화하려면 메시지에서 다음과 같은 지침을 따르십시오::

    ################################################################################
    디버깅을 위한 빌드 및/또는 호스트 환경이 생성되었습니다. 디버깅 환경에 들어가려면:

    cd /Users/UserName/miniconda3/conda-bld/debug_1542385789430/work && source /Users/UserName/miniconda3/conda-bld/debug_1542385789430/work/build_env_setup.sh

    빌드를 실행하려면, 먼저 conda_build.sh 파일을 실행하는 것이 좋습니다.
    ################################################################################

Python 패키지를 개발하는 경우, 보통은 ``conda`` 를 사용하여 모든 종속성을 설치한 다음, '개발 모드'로 패키지를 설치하는 것이 가장 쉽습니다: ``pip install -e <path to clone>`` (단, 사용 중인 ``pip`` 이 환경에서 제공되는 것인지 확인).

Running Conda with sudo
-----------------------

``tl;dr;`` `sudo` 를 사용할 때 Conda를 다음과 같이 실행하십시오::

    sudo -E $CONDA_EXE <remaining options to conda>

``machine-launch-script.sh`` 를 자세히 살펴보면, 항상 ``$CONDA_EXE`` 의 전체 경로를 사용하는 것을 알 수 있습니다. 이는 ``/etc/sudoers`` 가 ``/opt/conda`` 의 커스텀 설치 경로를 ``secure_path`` 에 허용하지 않기 때문입니다.

또한, `sudo` 에 ``-E`` 옵션 (또는 더 구체적으로는 ``--preserve-env=CONDA_DEFAULT_ENV``)을 포함하여 sudo 환경에서 수정할 환경의 기본 선택이 유지되도록 하는 것이 좋습니다.

Running things from your Conda environment with sudo
----------------------------------------------------

다른 명령어를 `sudo`로 실행하는 경우 (예: gdb를 통해 무언가를 실행하려는 경우), 기본적으로 `secure_path` 는 Conda 환경을 포함하지 않으므로 실행하려는 항목의 전체 경로를 지정해야 하거나, 일부 경우에는 전체 로그인 셸 호출로 감싸는 것이 가장 쉽습니다::

   sudo /bin/bash -l -c "<command to run as root>"

``-l`` 옵션은 **기본** Conda 환경이 완전히 활성화되도록 보장합니다. 예외적으로 기본이 아닌 명명된 환경을 사용 중인 경우, 명령어를 실행하기 전에 해당 환경을 활성화하십시오::

    sudo /bin/bash -l -c "conda activate <myenv> && <command to run as root>"


Additional Resources
--------------------
* `conda-forge`_
* `Conda Documentation <https://conda.io/projects/conda/en/latest/index.html>`_


.. _conda-forge: https://conda-forge.org
.. _feedstock-list: https://conda-forge.org/feedstock-outputs/
