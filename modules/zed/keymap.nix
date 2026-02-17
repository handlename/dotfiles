[
  {
    bindings = {
      "ctrl->" = "window::ShowNextWindowTab";
      "ctrl-<" = "window::ShowPreviousWindowTab";
    };
  }
  {
    context = "!Terminal";
    bindings = {
      "cmd-shift-t" = "terminal_panel::ToggleFocus";
    };
  }
  {
    context = "!Editor";
    bindings = {
      "cmd-shift-n" = "editor::ToggleFocus";
    };
  }
  {
    context = "Editor";
    bindings = {
      "ctrl-i" = "editor::Tab";
      "ctrl-m" = "editor::Newline";
      "ctrl-t" = "workspace::ActivateNextPane";

      # tasks
      "cmd-; c" = "editor::SpawnNearestTask";
      "cmd-; l" = "task::Rerun";
      "cmd-k cmd-shift-l" = "editor::CopyPermalinkToLine";
      "cmd-k cmd-shift-o" = "editor::OpenPermalinkToLine";
      "cmd-k cmd-shift-r" = "workspace::CopyRelativePath";

      # git
      "cmd-k g c" = "git::Commit";
      "cmd-k g d" = "git::Diff";

      # edit prediction
      "alt-left" = "editor::PreviousEditPrediction";
      "alt-right" = "editor::NextEditPrediction";
    };
  }

  # vim

  {
    context = "Editor && (vim_mode == normal)";
    bindings = {
      "s" = "vim::PushSneak";
      "S" = "vim::PushSneakBackward";
      "g D" = "editor::OpenDocs";
      "g o" = "editor::OpenExcerpts";
      "ctrl-w g o" = "editor::OpenExcerptsSplit";
    };
  }
  {
    context = "Editor && (vim_mode == visual)";
    bindings = {
      "S" = "vim::PushAddSurrounds";
    };
  }
  {
    context = "Editor && (vim_mode == insert)";
    bindings = {
      "cmd-a S" = "copilot::PreviousSuggestion";
      "cmd-a s" = "copilot::NextSuggestion";
    };
  }

  # languages

  {
    context = "Editor && (extension == go)";
    bindings = {
      "cmd-; c" = [
        "task::Spawn"
        {
          task_name = "Run Go Test: \${ZED_SYMBOL}";
        }
      ];
      "cmd-; f" = [
        "task::Spawn"
        {
          task_name = "Run Go Tests in file: \${ZED_RELATIVE_FILENAME}";
        }
      ];
    };
  }
]
