.. _usertopologies:

Manager Network Topology Definitions (``user_topology.py``)
==================================================================

Custom network topologies are specified as Python snippets that construct a
tree. You can see examples of these in :gh-file-ref:`deploy/runtools/user_topology.py`,
shown below. Better documentation of this API will be available once it stabilizes.

기본적으로 스위치 또는 서버 노드로 구성된 루트 리스트를 작성한 후, 이러한 루트에 다운링크를 추가하여 트리를 구성합니다. 링크는 양방향이므로, 노드 A에서 노드 B로 다운링크를 추가하면 암묵적으로 B에서 A로의 업링크도 추가됩니다.

여기에 추가적인 topology 생성 방법을 추가할 수 있으며, 그런 다음 ``config_runtime.yaml`` 에서 사용할 수 있습니다.

``user_topology.py`` contents:
--------------------------------

.. include:: /../deploy/runtools/user_topology.py
   :code: python


