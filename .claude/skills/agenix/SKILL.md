---
name: agenix
description: Store secrets in agenix
---

# Agenix secrets management

## Overview

Make a new agenix entry to store secrets.

The base working directory is this mynixos project.

## Step 1: Create age file

In ./secrets/agenix the secrets.nix. If a new secrets file is to be created
create a new entry.

## Step 2: Edit the file

E.g. the following command opens the file in the editor:

`agenix -i ~/.ssh/id_ed25519_home -e whatlastgenre.age`

add the file to git so it can be used: `git add ...`. Staging is sufficient.

## Step 3:

add the file in nixconfig/server/agenix.nix

## Step 4:

Use the file in the nix config. For example:

users.users.user1 = {
    isNormalUser = true;
    passwordFile = config.age.secrets.secret1.path;
  };

Agenix cannot work yet if the file hast to be in a specific location.


