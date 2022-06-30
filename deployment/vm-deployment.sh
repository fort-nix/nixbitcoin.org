source ./vm-deployment-lib.sh

# Interactive helper commands
helper() {
    # Delete VM deployment dir
    rm -rf $tmpDir
    echo $tmpDir

    # Create deployment dir (run automatically by vmRun)
    vmCreateTmpDir

    # Enter VM
    vmssh

    # Abort the VM
    kill $(cat $tmpDir/qemuPID)
}

deployVM() {(
    set -euxo pipefail
    # Start VM
    vmRun

    # Format storage
    <2-format-storage.sh vmssh 'bash -s'
    # Run this to remount already formatted storage
    # <2-format-storage.sh vmssh 'bash -s remount'

    # Install system
    vmssh -n 'nixos-install --system /etc/base-system --root /mnt --no-root-passwd'
    vmssh -n poweroff
)}
deployVM

# Run installed machine
qemu-kvm -m 2048 -smp 2 -hda $tmpDir/hd1 -hdb $tmpDir/hd2

# Run with only one HDD connected.
# Stage 1 is delayed because it waits for the missing device,
# but the system starts successfully
qemu-kvm -m 2048 -smp 2 -hda $tmpDir/hd1
qemu-kvm -m 2048 -smp 2 -hda $tmpDir/hd2

# Remove system
rm -rf $tmpDir
