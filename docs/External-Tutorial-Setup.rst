External Tutorial Setup
===================================

이 문서 섹션은 대면 FireSim 및 Chipyard 튜토리얼에 참석하는 외부 참가자들을 위한 것입니다.
이미 AWS EC2 계정을 가지고 있다면, 다음 단계를 따라 설정을 진행하세요.

.. Note:: AWS EC2 계정을 이미 가지고 있다면, 이 단계들은 약 2시간 정도 소요됩니다.

1. :ref:`initial-setup` 에서 시작하여 :ref:`setting-up-firesim-repo` 에서 끝나는 FireSim 문서를 따라 진행하세요(절대 FireSim 리포지토리를 클론하지 마세요). 

2. 다음 명령을 실행하세요:

.. code-block:: bash

    #!/bin/bash

    FIRESIM_MACHINE_LAUNCH_GH_URL="https://raw.githubusercontent.com/firesim/firesim/final-tutorial-2022-isca/scripts/machine-launch-script.sh"

    curl -fsSLo machine-launch-script.sh "$FIRESIM_MACHINE_LAUNCH_GH_URL"
    chmod +x machine-launch-script.sh
    ./machine-launch-script.sh

    source ~/.bashrc

    export MAKEFLAGS=-j16

    sudo yum install -y nano

    mkdir -p ~/.vim/{ftdetect,indent,syntax} && for d in ftdetect indent syntax ; do wget -O ~/.vim/$d/scala.vim https://raw.githubusercontent.com/derekwyatt/vim-scala/master/$d/scala.vim; done

    echo "colorscheme ron" >> /home/centos/.vimrc


    cd ~/

    (
    git clone https://github.com/ucb-bar/chipyard -b final-tutorial-2022-isca-morning chipyard-morning
    cd chipyard-morning
    ./scripts/init-submodules-no-riscv-tools.sh

    ./scripts/build-toolchains.sh ec2fast
    source env.sh

    ./scripts/firesim-setup.sh --fast
    cd sims/firesim
    source sourceme-manager.sh

    cd ~/chipyard-morning/sims/verilator/
    make
    make clean

    cd ~/chipyard-morning
    chmod +x scripts/repo-clean.sh
    ./scripts/repo-clean.sh
    git checkout scripts/repo-clean.sh

    )

    cd ~/

    (
    git clone https://github.com/ucb-bar/chipyard -b final-tutorial-2022-isca chipyard-afternoon
    cd chipyard-afternoon
    ./scripts/init-submodules-no-riscv-tools.sh

    ./scripts/build-toolchains.sh ec2fast
    source env.sh

    ./scripts/firesim-setup.sh --fast
    cd sims/firesim
    source sourceme-manager.sh
    cd sim
    unset MAKEFLAGS
    make f1
    export MAKEFLAGS=-j16

    cd ../target-design/chipyard/software/firemarshal
    ./init-submodules.sh
    marshal -v build br-base.json
    marshal -v install br-base.json

    cd ~/chipyard-afternoon/generators/sha3/software/
    git submodule update --init esp-isa-sim
    git submodule update --init linux
    ./build-spike.sh
    ./build.sh

    cd ~/chipyard-afternoon/generators/sha3/software/
    marshal -v build marshal-configs/sha3-linux-jtr-test.yaml
    marshal -v build marshal-configs/sha3-linux-jtr-crack.yaml
    marshal -v install marshal-configs/sha3*.yaml

    cd ~/chipyard-afternoon/sims/firesim/sim/
    unset MAKEFLAGS
    make f1 DESIGN=FireSim TARGET_CONFIG=WithNIC_DDR3FRFCFSLLC4MB_WithDefaultFireSimBridges_WithFireSimHighPerfConfigTweaks_chipyard.QuadRocketConfig PLATFORM_CONFIG=BaseF1Config
    make f1 DESIGN=FireSim TARGET_CONFIG=WithNIC_DDR3FRFCFSLLC4MB_WithDefaultFireSimBridges_WithFireSimHighPerfConfigTweaks_chipyard.LargeBoomV3Config PLATFORM_CONFIG=BaseF1Config
    make f1 DESIGN=FireSim TARGET_CONFIG=WithDefaultFireSimBridges_WithFireSimHighPerfConfigTweaks_chipyard.RocketConfig PLATFORM_CONFIG=BaseF1Config
    make f1 DESIGN=FireSim TARGET_CONFIG=WithNIC_DDR3FRFCFSLLC4MB_WithDefaultFireSimBridges_WithFireSimHighPerfConfigTweaks_chipyard.Sha3RocketConfig PLATFORM_CONFIG=BaseF1Config
    make f1 DESIGN=FireSim TARGET_CONFIG=DDR3FRFCFSLLC4MB_WithDefaultFireSimBridges_WithFireSimHighPerfConfigTweaks_chipyard.Sha3RocketConfig PLATFORM_CONFIG=BaseF1Config
    make f1 DESIGN=FireSim TARGET_CONFIG=DDR3FRFCFSLLC4MB_WithDefaultFireSimBridges_WithFireSimHighPerfConfigTweaks_chipyard.Sha3RocketPrintfConfig PLATFORM_CONFIG=WithPrintfSynthesis_BaseF1Config
    export MAKEFLAGS=-j16

    cd ~/chipyard-afternoon
    chmod +x scripts/repo-clean.sh
    ./scripts/repo-clean.sh
    git checkout scripts/repo-clean.sh

    )

3. 다음 내용을 복사하여 ``~/.bashrc`` 파일 전체를 다음 내용으로 대체하세요:

.. code-block:: bash

    # .bashrc
    # Source global definitions
    if [ -f /etc/bashrc ]; then
            . /etc/bashrc
    fi
    # Uncomment the following line if you don't like systemctl's auto-paging feature:
    # export SYSTEMD_PAGER=
    # User specific aliases and functions
    cd /home/centos/chipyard-afternoon && source env.sh && cd sims/firesim && source sourceme-manager.sh && cd /home/centos/
    export FDIR=/home/centos/chipyard-afternoon/sims/firesim/
    export CDIR=/home/centos/chipyard-afternoon/

4. 완료되었습니다! 이제 대면 튜토리얼을 계속 진행하세요.

