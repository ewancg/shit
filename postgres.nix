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
    }];

    # only minecraft itself and SSH tunnels
    authentication = pkgs.lib.mkOverride 10 ''
      local     ${database}       all           trust
      host      ${database}       ${user}       127.0.0.1/32        trust
      host      ${database}       ${user}       ::1/128             trust
    '';

    initialScript = pkgs.writeText "script" ''
      alter user postgres with password '${password}';
      alter user ${user} with password '${password}';
    '';
  };
}
