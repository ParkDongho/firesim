Running a Single Node Simulation
===================================

Now that we've completed all the basic setup steps, it's time to run
a simulation! In this section, we will simulate a single target node, for which
we will use a single |fpga_type|.

**Make sure you have sourced** ``sourceme-manager.sh --skip-ssh-setup`` **before running any of these commands.**

Building target software
------------------------

In this guide, we'll boot Linux on our
simulated node. To do so, we'll need to build our RISC-V SoC-compatible
Linux distro. For this guide, we will use a simple buildroot-based
distribution. We can build the Linux distribution like so:

.. code-block:: bash

    # assumes you already cd'd into your firesim repo
    # and sourced sourceme-manager.sh
    #
    # then:
    cd target-design/chipyard/software/firemarshal
    ./init-submodules.sh
    ./marshal -v build br-base.json
    ./marshal -v install br-base.json

Once this is completed, you'll have the following files:

-  ``YOUR_FIRESIM_REPO/target-design/chipyard/software/firemarshal/images/firechip/br-base/br-base-bin`` - a bootloader + Linux
   kernel image for the RISC-V SoC we will simulate.
-  ``YOUR_FIRESIM_REPO/target-design/chipyard/software/firemarshal/images/firechip/br-base/br-base.img`` - a disk image for
   the RISC-V SoC we will simulate

이 파일들은 복잡한 workloads를 만들기 위한 기본 이미지 (참조: :ref:`deprecated-defining-custom-workloads` 섹션) 이거나 기본적이고, 상호작용 가능한 Linux 배포판으로 직접 사용될 수 있습니다.
