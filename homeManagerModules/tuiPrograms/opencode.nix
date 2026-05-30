{ config, pkgs, lib, ... }:

{
  options.myHomeModules.tuiPrograms.opencode = {
    enable = lib.mkEnableOption "AI coding assistant";
  };

  config = lib.mkIf config.myHomeModules.tuiPrograms.opencode.enable {
    programs.opencode = {
      enable = true;
      settings = {
        instructions = lib.mkDefault [
          "AGENTS.md"
        ];
        plugin = [
          "@ex-machina/opencode-anthropic-auth@1.8.1"
        ];
        permission = {
          "*" = "ask";
          read = "allow";
          grep = "allow";
          glob = "allow";
          todoread = "allow";
          todowrite = "allow";
          bash = {
            "*" = "ask";
            ls = "allow";
            "ls *" = "allow";
            cat = "allow";
            "cat *" = "allow";
            head = "allow";
            "head *" = "allow";
            tail = "allow";
            "tail *" = "allow";
            file = "allow";
            "file *" = "allow";
            wc = "allow";
            "wc *" = "allow";
            pwd = "allow";
            which = "allow";
            "which *" = "allow";
            "git status" = "allow";
            "git status *" = "allow";
            "git log" = "allow";
            "git log *" = "allow";
            "git diff" = "allow";
            "git diff *" = "allow";
            "git show" = "allow";
            "git show *" = "allow";
            "nix flake check" = "allow";
            "nix flake check *" = "allow";
            "nix eval *" = "allow";
            "nixfmt *" = "allow";
          };
        };
      };
    };

    xdg.configFile."opencode/AGENTS.md".text = ''
      # Global Agent Instructions

      You are assisting on a personal NixOS system. These instructions apply globally unless a more specific `AGENTS.md` file in the current workspace overrides them.

      ## Instruction Scope

      - Treat this file as baseline guidance.
      - Prefer more specific instructions closer to the current working directory when available.
      - Project-specific instructions override global instructions.
      - If instructions conflict, follow the more specific instruction unless it is unsafe.

      ## System Context

      - The system is NixOS.
      - Prefer declarative configuration over imperative/manual setup.
      - Do not assume packages, services, shells, fonts, desktop settings, or user programs should be installed manually.
      - Prefer editing NixOS, Home Manager, flake, or project devshell configuration when changing persistent system behavior.
      - Avoid suggesting `apt`, `dnf`, `pacman`, `brew`, or global language package installs unless explicitly working inside a non-Nix environment.
      - If a tool is missing, first consider whether it belongs in Nix configuration, `nix shell`, `nix run`, or a project flake/devshell.

      ## Work Style

      - Understand the current context before acting.
      - Prefer minimal, focused, reversible changes.
      - Preserve existing structure, naming, tone, and conventions.
      - Do not make broad unrelated changes while solving a narrow task.
      - Ask a concise clarifying question when the goal is ambiguous or when multiple reasonable interpretations exist.

      ## Personal System Safety

      - Treat this as a personal workstation and workspace.
      - Do not remove, overwrite, or reorganize files unless explicitly requested.
      - Be careful with commands that affect user data, system state, credentials, networking, or long-running services.
      - Explain risks before recommending destructive or irreversible actions.

      ## Secrets And Private Data

      - Never expose secrets, tokens, private keys, decrypted secret values, or sensitive personal data.
      - Never place secrets directly into Nix files, generated configs, shell history, logs, or the Nix store.
      - Prefer established secret-management mechanisms such as sops-nix when working on NixOS or Home Manager configuration.
      - Distinguish between secrets and personal information, and avoid committing either unless the repository explicitly allows encrypted storage.

      ## Commands

      - Prefer read-only inspection before making changes.
      - Use Nix-native commands where appropriate.
      - Avoid destructive commands unless explicitly requested and the consequence is clear.
      - If elevated privileges are needed, explain why.

      ## Communication

      - Be concise and direct.
      - Explain outcomes, important tradeoffs, and any verification performed.
      - If verification could not be run, say why.
    '';
  };
}
