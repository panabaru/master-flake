# PLACEHOLDER — this file did not exist in the original upload.
#
# hosts/desktop/configuration.nix imports ./hardware.nix, so this file has
# to exist for the flake to evaluate at all — but the values below are
# fake and WILL NOT boot your actual desktop. You must replace this file
# with the real one generated on the desktop machine itself:
#
#   1. Boot the NixOS installer (or boot the desktop if NixOS is already
#      installed on it).
#   2. Run: nixos-generate-config --show-hardware-config > hardware.nix
#      (or nixos-generate-config --root /mnt if partitioning fresh)
#   3. Copy the output over this file, replacing it entirely.
#
# See the laptop's hosts/laptop/hardware.nix for what a real generated
# file looks like — yours will have the same shape, with your desktop's
# actual disk UUIDs, kernel modules, and CPU microcode settings.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ ]; # FIX ME: real modules from nixos-generate-config
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # FIX ME: replace with your desktop's real filesystem UUIDs
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0000-0000";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # If your desktop has an AMD CPU instead, use:
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
