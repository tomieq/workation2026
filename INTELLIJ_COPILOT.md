# IntelliJ + GitHub Copilot

GitHub Copilot is expected to be already installed and authenticated in IntelliJ IDEA.

1. Open the repository in IntelliJ.
2. Open Copilot Chat and verify that it can see repository files.
3. Run `./bootstrap-spec-kit.sh` once in the IntelliJ terminal. This initializes Spec Kit files; it does **not** install Copilot.
4. Return to Copilot Chat and continue the Spec Kit workflow.
5. If newly generated repository prompts/agents do not appear immediately, start a new Copilot Chat session or reopen the project.

Spec Kit uses repository customizations under `.github/`. The `.vscode/settings.json` file that may be generated in commands mode is irrelevant for IntelliJ.
