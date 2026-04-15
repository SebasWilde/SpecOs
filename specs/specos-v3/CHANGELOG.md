# Changelog — specos-v3

## 2026-04-15 v2.0
- Roles changed from fixed identities to configurable perspectives
- Two mandatory perspectives defined: construction (Lead) and breaking (QA)
- Multiple roles per person now supported
- session.md extended with roles and implementation_repos fields
- repo_spec established as universal entry point (any folder name)
- Separate repos support added via session.md local paths
- testcases.md introduced as QA output file with free-form fields and TC-XX IDs
- tasks.md checkboxes removed — state lives in task software
- Default SP-XX IDs added to tasks, replaceable with real IDs
- Task and test case ID prefixes made configurable in specos-outputs.yml
- status field removed entirely — repo presence = approved
- specos-outputs.yml extended with team config (qa: human|agent|both) and id prefixes
- Journey 10 added: validation of implementation repo paths before session starts

## 2026-04-10 v1.0
- Initial spec created
- Covers: install.sh, 5 skills, adapters, templates, branching strategy
