{ pkgs, secrets, ... }: let
  port = secrets.postgres.port;
  user = secrets.postgres.user;
  database = secrets.postgres.database;
  password = secrets.postgres.password;
in {
  services.postgresql = {
    enable = true;

    # Provides LLVM-based JIT, speeds things up
    enableJIT = true;

    # Remote management
    enableTCPIP = true;
    port = port;
    settings = {
      listen_addresses = "*";
    };

    ensureDatabases = [ database ];
    identMap = ''
      minecraft-user minecraft ${ user }
    '';

    ensureUsers = [{
      name = user;
      ensureClauses.superuser = true;
    }];

    authentication = pkgs.lib.mkOverride 10 ''
      #type database DBuser origin-address auth-method
      local all       all     trust
      # ipv4
      host  all      all     127.0.0.1/32   trust
      # ipv6
      host all       all     ::1/128        trust
    '';

    initialScript = pkgs.writeText "script" ''
      alter user ${user} with password ${password};
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ port ];
  };
}
