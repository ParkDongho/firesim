.. _uri-path-support:

Manager URI Paths
===============================

``config_hwdb.yaml`` 에 지정된 일부 키는 ``URI`` 로 지정될 수 있습니다.

``URI Support``
--------------------------
Uniform Resource Identifier (URI) 는 `fsspec 라이브러리 <https://filesystem-spec.readthedocs.io/en/latest/api.html#built-in-implementations>`_ 에서 직접 지원하거나, `fsspec 위에 구축된 많은 서드 파티 확장 라이브러리 중 하나 <https://filesystem-spec.readthedocs.io/en/latest/api.html#other-known-implementations>`_ 에서 지원하는 프로토콜을 명시하는 것입니다.

많은 다른 URI 프로토콜을 처리하기 위해 ``fsspec`` 라이브러리를 사용할 때, 그 중 많은 것들이 FireSim 자체에서 설치를 요구하지 않는 추가 종속성을 필요로 한다는 점을 유의하십시오. ``fsspec`` 은 우리가 테스트하지 않는 많은 URI 프로토콜 중 하나를 사용할 경우, 필요한 패키지를 설치하라는 예외를 던질 것입니다.

마찬가지로, 개별 URI 프로토콜은 자격 증명을 명시하기 위한 고유한 요구 사항을 가집니다. 자격 증명을 제공하는 문서는 개별 프로토콜 구현에서 제공합니다. 예를 들어:

* `Azure Data-Lake Gen1 및 Gen2를 위한 adlfs <https://github.com/fsspec/adlfs#details>`_
* `Google Cloud Services를 위한 gcfs <https://gcsfs.readthedocs.io/en/latest/#credentials>`_
* `AWS S3를 위한 s3fs <https://s3fs.readthedocs.io/en/latest/#credentials>`_

SSH의 경우, 필요한 키를 ssh-agent에 추가하십시오.

일부 프로토콜 백엔드가 자체 구성 파일이나 환경 변수(예: ``~/.aws`` 에 저장된 AWS 자격 증명, ``aws configure`` 로 생성)를 통해 인증을 제공하는 반면, 하나는 추가 기본 키워드 인수로 ``fsspec`` 을 각 백엔드 프로토콜에 따라 구성할 수 있는 `fsspec 구성 <https://filesystem-spec.readthedocs.io/en/latest/features.html#configuration>`_ 방법 중 하나를 사용할 수 있음을 유의하십시오.