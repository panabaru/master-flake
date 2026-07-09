# PLACEHOLDER — this file did not exist in the original upload, and
# hosts/server/configuration.nix imports ./hardware.nix, so the flake
# cannot evaluate at all without SOME file here. The values below are
# fake and WILL NOT boot your actual server.
#
# Before deploying to the real server, replace this file entirely:
#
#   1. Boot the NixOS installer on the server (or boot the server if
#      NixOS is already installed on it).
#   2. Run: nixos-generate-config --show-hardware-config > hardware.nix
#      (or nixos-generate-config --root /mnt if partitioning fresh)
#   3. Copy the output over this file, replacing it entirely.
#
# See hosts/laptop/hardware.nix for what a real generated file looks
# like — yours will have the same shape, with the server's actual disk
# UUIDs, kernel modules, and CPU microcode settings.
#
# If your media library lives on a separate drive, this is also where
# you'd add a fileSystems."/data" entry (see the comment at the top of
# hosts/server/media.nix for why /data needs to be a single mount).
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ ]; # FIX ME: real modules from nixos-generate-config
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # FIX ME: replace with the server's real filesystem UUIDs
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
  # If the server has an AMD CPU instead, use:
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
