.. _manager-environment-variables:

Manager Environment Variables
===============================

This page contains a centralized reference for the environment variables used
by the manager.

.. _runfarm-prefix:

``FIRESIM_RUNFARM_PREFIX``
--------------------------

이 환경 변수는 AWS EC2의 경우 모든 Run Farm 태그에 일부 접두사를 추가하는 데 사용됩니다.
이는 여러 FireSim 복사본 간의 Run Farm을 분리하는 데 유용합니다.

.. _buildfarm-prefix:

``FIRESIM_BUILDFARM_PREFIX``
----------------------------

이 환경 변수는 AWS EC2의 경우 모든 Build Farm 태그에 일부 접두사를 추가하는 데 사용됩니다.
이는 주로 CI 용도로만 사용됩니다.
