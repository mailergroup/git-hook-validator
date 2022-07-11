# Git Hooks for Conventional Commits and branch name validation

## Requirements
To use these hooks, you need to have [jq](https://stedolan.github.io/jq/download/) installed

## Installation
### Existing project
In existing project:
```
cd .git/hooks
curl https://raw.githubusercontent.com/mailergroup/git-hook-validator/main/commit-msg?token=GHSAT0AAAAAABU5BOKB7MUOB7NIRWTCEN2KYVHHARA --output commit-msg
curl https://raw.githubusercontent.com/mailergroup/git-hook-validator/main/commit-msg-config.json?token=GHSAT0AAAAAABU5BOKAI5DS5OXURIRVAY5YYVHHA6A --output commit-msg-config.json
curl https://raw.githubusercontent.com/mailergroup/git-hook-validator/main/pre-push?token=GHSAT0AAAAAABU5BOKB7MUOB7NIRWTCEN2KYVHHARA --output pre-push
curl https://raw.githubusercontent.com/mailergroup/git-hook-validator/main/post-checkout?token=GHSAT0AAAAAABU5BOKB7MUOB7NIRWTCEN2KYVHHARA --output post-checkout
curl https://raw.githubusercontent.com/mailergroup/git-hook-validator/main/allowed-branch-names-config.json?token=GHSAT0AAAAAABU5BOKAI5DS5OXURIRVAY5YYVHHA6A --output allowed-branch-names-config.json
chmod a+x commit-msg post-checkout pre-push
```

### Globally using Git Templates
If you want, you can install this hook globally, so it's going to be available in every repository your initialize. For example:

```
git config --global init.templatedir '~/.git-templates'
mkdir ~/.git-templates/hooks
cd ~/.git-templates/hooks
curl https://raw.githubusercontent.com/mailergroup/git-hook-validator/main/commit-msg?token=GHSAT0AAAAAABU5BOKB7MUOB7NIRWTCEN2KYVHHARA --output commit-msg
curl https://raw.githubusercontent.com/mailergroup/git-hook-validator/main/commit-msg-config.json?token=GHSAT0AAAAAABU5BOKAI5DS5OXURIRVAY5YYVHHA6A --output commit-msg-config.json
curl https://raw.githubusercontent.com/mailergroup/git-hook-validator/main/pre-push?token=GHSAT0AAAAAABU5BOKB7MUOB7NIRWTCEN2KYVHHARA --output pre-push
curl https://raw.githubusercontent.com/mailergroup/git-hook-validator/main/post-checkout?token=GHSAT0AAAAAABU5BOKB7MUOB7NIRWTCEN2KYVHHARA --output post-checkout
curl https://raw.githubusercontent.com/mailergroup/git-hook-validator/main/allowed-branch-names-config.json?token=GHSAT0AAAAAABU5BOKAI5DS5OXURIRVAY5YYVHHA6A --output allowed-branch-names-config.json
chmod a+x commit-msg post-checkout pre-push
```

## Usage
Once you download files you need to reinitialize your repo with `git init`. 

### Conventional Commit Validation
A Git pre-commit hook which validates commit messages using [Conventional Commits](https://www.conventionalcommits.org/) standard

The hook will look for a configuration file in the following locations (in order):
1. The root of your Git project
2. `GIT_CONVENTIONAL_COMMIT_VALIDATION_CONFIG`: you can also set a custom location for your configuration file by setting the `GIT_CONVENTIONAL_COMMIT_VALIDATION_CONFIG` env variable.

The configuration contains the following items by default:
```
{
    "enabled": true,
    "revert": true,
    "length": {
        "min": 1,
        "max": 70
    },
    "types": [
        "build",
        "ci",
        "docs",
        "feat",
        "fix",
        "perf",
        "refactor",
        "style",
        "test",
        "chore"
    ]
}
```
If you want to disable hook temporarily just change `enabled` to `false`.

You can also add new commit types or adjust the length of messages in this configuration, which allows you to have different configurations per project and a sane "default" in global configuration.

### Branch Name Validation
A Git post-checkout and pre-push hooks are used to enforce proper branch names. 

The hook will look for a configuration file in the following locations (in order):
1. The root of your Git project
2. `GIT_BRANCH_NAMES_VALIDATION_CONFIG`: you can also set a custom location for your configuration file by setting the `GIT_BRANCH_NAMES_VALIDATION_CONFIG` env variable.

The configuration contains the following items by default:
```
{
    "enabled": true,
    "types": [
        "feature",
        "hotfix",
        "bugfix"
    ]
}
```
If you want to disable hook temporarily just change `enabled` to `false`.

You can also add new branch types in this configuration, which allows you to have different configurations per project and a sane "default" in global configuration.