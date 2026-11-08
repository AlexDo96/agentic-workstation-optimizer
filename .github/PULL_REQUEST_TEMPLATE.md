## Summary

Briefly describe the changes introduced in this Pull Request.

## Checklist

- [ ] All PowerShell scripts (`./scripts/*.ps1`) run without syntax errors.
- [ ] Any new system setting modified in `optimize-workstation.ps1` is backed up and restored in `backup-and-rollback.ps1`.
- [ ] Safe for corporate machines when running `-Mode Work` (does not alter corporate DNS, Active Directory, or VPN profiles).
- [ ] Both `README.md` (English) and `README.vi.md` (Vietnamese) have been updated in a clear, natural developer tone.
