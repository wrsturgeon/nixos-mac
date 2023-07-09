{
  inputs = {
    nix.url = "github:nixos/nix/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = inputs@{ self, nix, nixpkgs }: {
    nixosConfigurations.macbook-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ (import ./configuration.nix) ];
      specialArgs = { inherit inputs; };
    };
  };
}
