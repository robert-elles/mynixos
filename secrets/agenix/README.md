Create a secret file:
`
$ agenix -e secret1.age
`

It will open a temporary file in the app configured in your $EDITOR environment variable. When you save that file its content will be encrypted with all the public keys mentioned in the secrets.nix file.

Add secret to a NixOS module config:
`
{
  age.secrets.secret1.file = ../secrets/secret1.age;
}
`

When the age.secrets attribute set contains a secret, the agenix NixOS module will later automatically decrypt and mount that secret under the default path /run/agenix/secret1. Here the secret1.age file becomes part of your NixOS deployment, i.e. moves into the Nix store.

Reference the secrets' mount path in your config:

`
{
  users.users.user1 = {
    isNormalUser = true;
    passwordFile = config.age.secrets.secret1.path;
  };
}
`

You can reference the mount path to the (later) unencrypted secret already in your other configuration. So config.age.secrets.secret1.path will contain the path /run/agenix/secret1 by default.