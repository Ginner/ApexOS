# STUB — replace with the output of:
#   nixos-generate-config --show-hardware-config
# on first boot, or copy from /etc/nixos/hardware-configuration.nix after
# running nixos-install.
#
# The stub below is the absolute minimum needed for the flake to evaluate.
# It will NOT produce a bootable system as-is.

{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # TODO: set the correct filesystem UUIDs and mount points.
  # Example (replace with actual values from blkid):
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
  #   fsType = "ext4";
  # };
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/XXXX-XXXX";
  #   fsType = "vfat";
  # };
  # swapDevices = [ { device = "/dev/disk/by-uuid/..."; } ];

  # TODO: uncomment the appropriate CPU microcode loader.
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.cpu.amd.updateMicrocode   = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
