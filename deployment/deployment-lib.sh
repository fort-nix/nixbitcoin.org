copyKexec() {(
    set -euxo pipefail
    if [[ ! $XDG_RUNTIME_DIR ]]; then
        echo 'Error: Missing env var XDG_RUNTIME_DIR'
        return 1
    fi

    echo "install kexec"
    ssh nborg-installer "
      if ! type -P kexec >/dev/null; then
        DEBIAN_FRONTEND=noninteractive apt-get -y install kexec-tools
      fi
    "

    echo "build installer system"
    nix build .#packages.x86_64-linux.installerSystemKexec --out-link /tmp/deploy-nixbitcoinorg/kexec

    echo "copy kexec image for installer system"
    rsync -a --copy-links --progress --inplace /tmp/deploy-nixbitcoinorg/kexec/ nborg-installer:/tmp/

    echo "append ssh-host-key to initrd"
    # Extract host key to tmpfs in RAM (XDG_RUNTIME_DIR)
    initrdDir=$XDG_RUNTIME_DIR/nixos-deploy-tmp
    trap "rm -rf $initrdDir" EXIT
    mkdir -p $initrdDir/.initrd-secrets/run/keys
    install -m 600 <(gpg --decrypt ../secrets/client-side/ssh-host-key.gpg 2>/dev/null) \
        $initrdDir/.initrd-secrets/run/keys/ssh-host-key
    # Append to initrd. The host key will be available at /run/keys/ssh-host-key in the booted system
    (cd $initrdDir && find | cpio -o -H newc -R +0:+0) | gzip -9 | ssh nborg-installer 'cat >> /tmp/initrd.gz'
    rm -rf $initrdDir
)}
