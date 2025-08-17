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
    settings = {
      port = port;
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
      local     all     all     peer
      host      all     all     all     trust
    '';

    initialScript = pkgs.writeText "script" ''
      alter user ${user} with password ${password};
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ port ];
  };
}
