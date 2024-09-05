FireAxe - Partitioning onto Multiple FPGAs
=============================================

FPGA 용량이 매우 커져서 많은 대형 SoC를 시뮬레이션할 수 있게 되었지만, 여전히 단일 FPGA에 설계가 맞지 않는 경우가 있습니다.
설계에 여러 중복 모듈이 포함된 경우, 먼저 :ref:`Multithreading<FAME-5>` 섹션을 참조해야 합니다.
충분한 중복 모듈이 없는 경우, FireAxe를 사용하여 더 높은 시뮬레이션 용량을 얻을 수 있습니다.
FireAxe는 또한 :ref:`Multithreading<FAME-5>` 과 호환되어 설계의 크기를 더욱 확장할 수 있습니다.

.. toctree::
   :maxdepth: 3
   :caption: FireAxe Partitioning onto Multiple FPGAs:

   FireAxe-Overview.rst
   Running-Fast-Mode-Simulations.rst
   Running-Exact-Mode-Simulations.rst
   Running-NoC-Partition-Mode-Simulations.rst
   Miscellaneous.rst
