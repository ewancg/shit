{ pkgs, secrets, ... }:
{
  ## Create a hashed password file in the store from its text
  password = user: builtins.toString (pkgs.writeText "_${user}" secrets.u.${user}.hashedPassword);
}
