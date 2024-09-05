Managing the Conda Lock File
------------------------------

``build-setup.sh`` 에서 설정한 기본 Conda 환경은 ``conda-reqs/*`` 에 있는 `lock file ("*.conda-lock.yml") <https://github.com/conda-incubator/conda-lock>`_ 을 사용합니다.
이 파일은 ``conda-reqs/*`` 에 위치한 Conda requirements files (``*.yaml``)에서 파생됩니다.

Updating Conda Requirements
===========================

개발자가 requirements files를 업데이트하고자 한다면, lock file도 이에 맞게 업데이트해야 합니다.
다음 두 가지 방법이 있습니다:

#. ``build-setup.sh --unpinned-deps`` 를 실행합니다. 이는 lock file을 제자리에서 업데이트하여 커밋할 수 있게 하고 FireSim repository를 다시 설정합니다.
#. :gh-file-ref:`scripts/generate-conda-lockfile.sh` 를 실행합니다. 이는 디렉토리를 설정하지 않고 제자리에서 lock file을 업데이트합니다.

Caveats of the Conda Lock File and CI
=====================================

불행히도, 우리가 아는 한 Conda lock file에서 Conda requirements files를 파생하는 방법은 없습니다.
따라서, lock file이 requirements file(s)로 주어진 요구 사항을 충족하는지 확인할 방법이 없습니다.
requirements file을 업데이트할 때마다 같은 PR에서 lock file도 업데이트하는 것이 좋습니다.
이 확인은 ``check-conda-lock-modified`` CI 작업이 수행하는 것입니다.
이는 lock file과 requirements files가 동일한 패키지와 버전을 가지는지 확인하지 않으며, PR에서 모든 파일이 수정되었는지만 확인합니다.
