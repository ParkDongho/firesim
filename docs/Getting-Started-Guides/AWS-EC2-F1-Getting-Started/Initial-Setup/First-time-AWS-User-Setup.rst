.. _first-time-aws:

First-time AWS User Setup
==============================

만약 AWS를 처음 사용하고 계정이 없다면, 아래의 지침을 따라 시작하십시오.

Creating an AWS Account
-----------------------

먼저, AWS 계정이 필요합니다. `aws.amazon.com <https://aws.amazon.com>`__ 에 접속하여 "Sign Up"을 클릭하여 계정을 생성하십시오. 개인 계정을 생성해야 하며, 신용카드 번호를 입력해야 합니다.

.. _limitincrease:

Requesting Limit Increases
--------------------------

AWS는 인프라를 보호하기 위해 신규/이용 빈도가 낮은 계정에서 특정 인스턴스 유형의 사용을 제한합니다. 이러한 제한/쿼터가 어떻게 작동하는지에 대해서는 `여기 <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html#ec2-on-demand-instances-limits>`__ 에서 자세히 알아볼 수 있습니다.

이 가이드를 따르기 위해 계정이 충분한 인스턴스를 시작할 수 있는지 확인하려면, AWS 콘솔의 "Service Quotas" 페이지를 참조해야 합니다. 해당 페이지는 `여기 <https://console.aws.amazon.com/servicequotas/home/services/ec2/quotas/>`__ 에서 접근할 수 있습니다. 페이지를 열면 올바른 리전이 선택되어 있는지 다시 확인하십시오.

이 페이지에 표시된 값은 동시에 실행할 수 있는 최대 vCPUs 수를 나타내며, 이는 실행할 수 있는 시뮬레이션의 규모(예: 병렬 FPGAs의 수)를 제한합니다. 제한을 늘려야 하는 경우, 아래 지침을 따르십시오.

이 가이드를 완료하려면 다음과 같은 제한이 필요합니다:

* ``Running On-Demand F instances``: 64 vCPUs.

    * 이는 8개의 병렬 FPGA에 충분합니다. 각 8 vCPUs = 1 FPGA입니다.

* ``Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances``: 24 vCPUs.

    * 이는 하나의 ``c5.4xlarge`` 매니저 인스턴스와 하나의 ``z1d.2xlarge`` 빌드 팜 인스턴스에 충분합니다.

제한이 부족한 경우, 다음 단계를 따라 제한 증가를 요청하십시오: `request-increase <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-resource-limits.html#request-increase>`__

요청 시, 위에서 언급된 두 가지 인스턴스 클래스에 대한 vCPU 제한을 입력하십시오. 이 과정에는 가끔 사람이 개입되므로 가능한 한 빨리 요청을 제출해야 합니다. 이 시점에서 요청에 대한 응답을 기다려야 합니다.

아래의 Next를 클릭하여 계속 진행하십시오.
