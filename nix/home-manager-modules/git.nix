{ lib, pkgs, config, ... }:
let
  cfg = config.modules.jhol-dotfiles.git;
in
{
  options.modules.jhol-dotfiles.git = {
    enable = lib.mkEnableOption "Enable git configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;

      userName = "Joel Holdsworth";

      aliases = {
        graph = "log --graph --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(bold white)— %an%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit --date=relative";
        it = "!git init && git commit --allow-empty -m \"initial commit [empty]\"";
        please = "push --force-with-lease";
        commend = "commit --amend --no-edit";
        commedit = "commit --amend";
        ch = "checkout";
        cb = "checkout --branch";
        ps = "push";
        psu = "push --set-upstream";
        pl = "pull";
        pr = "pull --rebase";
        plr = "pull --rebase --autostash";
        plm = "pull --merge";
        pls = "pull --ff-only";
        stsh = "stash --keep-index";
        staash = "stash --include-untracked";
        staaash = "stash --all";
        ss = "status --short --branch";
        ls = "ls-files -m -- .";
        lsm = "ls-files -m";
        lsu = "ls-files -u";
        lsd = "ls-files -d";
        lso = "ls-files -o";
        lls = "!f() { for a in `git lsm`; do git ss | rg $a; done; for a in `git lsu`; do git ss | rg $a; done; for a in `git lsd`; do git ss | rg $a; done; }; f";
        logstr = "log -p -S";
        merc = "merge --no-ff";
        merff = "merge --ff";
        merffo = "merge --ff-only";
        mt = "mergetool";
        grog = "log --graph --abbrev-commit --decorate --all --format=format:\"%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(dim white) - %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)\"";
        rbi = "rebase --interactive --autosquash --autostash";
        rbc = "rebase --continue";
        rbabort = "rebase --abort";
        safepull = "pull --ff-only";
        hardpull = "!git fetch $1 && git reset --hard $1/$2";
        softpull = "pull --rebase --autostash";
        addi = "add --interactive";
        ap = "add --patch";
        chp = "cherry-pick";
        chpn = "cherry-pick --no-commit";
        unadd = "reset HEAD --";
        xhp = "cherry-pick -Xtheirs";
        xhpn = "cherry-pick -Xtheirs --no-commit";
        uhp = "cherry-pick -Xunion";
        uhpn = "cherry-pick -Xunion --no-commit";
        fixup = "!f() { git commit -m \"fixup! $1\"; }; f";
        squash = "!f() { git commit -m \"squash! $1\"; }; f";
        oops = "!f() { git fixup `git rev-parse --short HEAD`; }; f";
        oopsq = "!f() { git squash `git rev-parse --short HEAD`; }; f";
        look = "log --oneline";
        loo = "!f() { git log --oneline | cat; }; f";
        loq = "!f() { git log --oneline | head; }; f";
        unstage = "reset HEAD --";
        cm = "!f() { git commit -m \"$*\"; }; f";
        aac = "!f() { git add -- $* && git commit -m \"added $*\"; }; f";
        tips = "for-each-ref --sort=-committerdate  --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
        report = "!f() { pwd; git status $*; }; f";
        ignore = "!f() { for a in `echo $*`; do echo $a >> .gitignore; done;}; f";
        wip = "for-each-ref --sort='authordate:iso8601' --format=' %(color:green)%(authordate:relative)%09%(color:white)%(refname:short)' refs/heads";
      };

      lfs.enable = true;

      extraConfig = {
        color = {
          diff = true;
          status = true;
          interactive = true;
        };

        column.ui = "auto";

        init.defaultBranch = "master";

        sendemail.airwebreathe = {
          smtpserver = "smtp.aa.net.uk";
          smtpserverport = 587;
          smtpencryption = "tls";
          smtpuser = "joel@airwebreathe.org.uk";
        };
      };
    };

    systemd.user = {
      services =
        let
          serviceCommand = { name, command }: {
            Unit = {
              Wants = "${name}.timer";
            };

            Service = {
              Type = "oneshot";
              ExecStart = command;
            };

            Install = {
              WantedBy = [ "multi-user.target" ];
            };
          };

          serviceGit = { time }: serviceCommand {
            name = "git-${time}";
            command = let
              git = config.programs.git.package;
            in ("${git}/libexec/git-core/git --exec-path=${git}/libexec/git-core/ for-each-repo " +
              "--config=maintenance.repo maintenance run --schedule=${time}");
          };
        in
        {
          git-hourly = serviceGit { time = "hourly"; };
          git-daily = serviceGit { time = "daily"; };
          git-weekly = serviceGit { time = "weekly"; };
        };

      timers =
        let
          timer = { name, onCalendar }: {
            Unit = {
              Requires = "${name}.service";
            };

            Timer = {
              OnCalendar = onCalendar;
              AccuracySec = "12h";
              Persistent = true;
            };

            Install = {
              WantedBy = [ "timers.target" ];
            };
          };
        in
        {
          git-hourly = timer {
            name = "git-hourly";
            onCalendar = "hourly";
          };

          git-daily = timer {
            name = "git-daily";
            onCalendar = "hourly";
          };

          git-weekly = timer {
            name = "git-weekly";
            onCalendar = "weekly";
          };
        };
    };
  };
}
