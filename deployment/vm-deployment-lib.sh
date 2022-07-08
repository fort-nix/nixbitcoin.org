tmpDir=/tmp/nix-bitcoin-deployment

vmCreateTmpDir() {(
    set -euo pipefail
    mkdir -p $tmpDir
    qemu-img create -f qcow2 $tmpDir/hd1 50G
    qemu-img create -f qcow2 $tmpDir/hd2 50G
    mkfifo $tmpDir/pipe.{in,out}
)}

vmRun() {(
    set -euxo pipefail
    if [[ ! -e $tmpDir ]]; then vmCreateTmpDir || return; fi

    nix build .#installerSystemVM --out-link $tmpDir/vm || return
    export NIX_DISK_IMAGE=$tmpDir/vmimg; rm -f $NIX_DISK_IMAGE
    export QEMU_OPTS="-m 1500 -smp 2 -hda $tmpDir/hd1 -hdb $tmpDir/hd2 -serial pipe:$tmpDir/pipe"
    export QEMU_NET_OPTS="hostfwd=tcp::2222-:22"
    </dev/null $tmpDir/vm/bin/run-*-vm &>/dev/null & qemuPID=$!
    echo $qemuPID > $tmpDir/qemuPID

    # Wait until VM has booted
    set +x
    while read line; do
        echo "$line"
        if [[ ${line} == *"nixos login"* ]]; then
            break;
        fi
    done <$tmpDir/pipe.out
)}

vmssh() {
    ssh -p 2222 -o ConnectTimeout=1 \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
        -o ControlMaster=auto -o ControlPath=$tmpDir/ssh-connection -o ControlPersist=60 \
        root@127.0.0.1 "$@"
}

qemuUefi() {
    nix build --out-link $tmpDir/ovmf --inputs-from . nixpkgs#OVMF.fd || return
    qemu-kvm -bios $tmpDir/ovmf-fd/FV/OVMF.fd "$@"
}
