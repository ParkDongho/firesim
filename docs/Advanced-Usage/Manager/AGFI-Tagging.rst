AGFI Metadata/Tagging
================================================

AWS EC2의 경우, FireSim에서 AGFI를 빌드하면 AWS에 저장된 AGFI 설명에 시뮬레이션 배포 방법을 결정하는 데 도움이 되는 메타데이터가 채워집니다. 각 필드가 설정되고 사용되는 방법과 함께 중요한 메타데이터는 아래에 나열되어 있습니다:

- ``firesim-buildquintuplet``: AGFI를 빌드하는 데 사용된 quintuplet 조합을 항상 반영합니다.
- ``firesim-deployquintuplet``: AGFI를 배포하는 데 사용되는 quintuplet 조합을 반영합니다. 기본적으로, 이는 ``firesim-buildquintuplet`` 와 동일합니다. 그러나 특정 경우에는 사용자가 특정 구성에 대한 액세스 권한이 없을 수 있으며, 호환 가능한 소프트웨어 드라이버를 빌드하는 데 더 간단한 구성이 충분할 수 있습니다(예: FPGA 이미지에 외부 시스템과 인터페이스하지 않는 독점 RTL이 포함된 경우). 이 경우, 빌드 시 사용자 지정 deployquintuplet을 지정할 수 있습니다. 그렇지 않으면 매니저가 자동으로 이를 ``firesim-buildquintuplet`` 와 동일하게 설정합니다.
- ``firesim-commit``: 이 AGFI를 빌드하는 데 사용된 FireSim 버전의 커밋 해시입니다. AGFI가 수정된 FireSim 저장소 사본에서 생성된 경우, 커밋 해시 뒤에 "-dirty"가 추가됩니다.
