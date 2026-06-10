


### Git-Crypt (Secret Management)

```bash
# Unlock encrypted secrets
git-crypt unlock ~/.ssh/gitcrypt_mynixos_key

# Check encryption status
git-crypt status -e
```

Secrets are stored in:
- `secrets/gitcrypt/` - Git-crypt encrypted files (e.g., `params.json` with hostnames/emails)
- `secrets/agenix/` - Age-encrypted secrets for runtime use
