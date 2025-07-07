{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    rust-analyzer
  ];

  programs.zed = {
        enable = true;

        ## This populates the userSettings "auto_install_extensions"
        extensions = ["nix" "toml" "fish"];

        ## everything inside of these brackets are Zed options.
        userSettings = {
            # Disable telemetry
            telemetry = {
                diagnostics = false;
                metrics = false;
            };
            
            # Disable AI assistant & predictions
            agent = {
                enabled = false;
            };
            features = {
              edit_prediction_provider = "none";
            };
            language_models = {
              anthropic = {
                version = 1;
                api_url = "";
              };
              google = {
                api_url = "";
              };
              ollama = {
                api_url = "";
              };
              openai = {
                version = 1;
                api_url = "";
              };
              open_router = {
                api_url = "";
              };
              lmstudio = {
                api_url = "";
              };
              deepseek = {
                api_url = "";
              };
              mistral = {
                api_url = "";
              };
            };

            # Zed settings
            vim_mode = false;
            base_keymap = "VSCode";
            show_whitespaces = "all" ;
            hour_format = "hour12";
            auto_update = false;
            shell = lib.getExe pkgs.fish;

            # UI settings
            theme = {
                mode = "system";
                light = "Gruvbox Light Hard";
                dark = "Gruvbox Dark Hard";
            };

            unstable = {
              ui_density = "compact";
            };

            ui_font_size = 12.95;
            ui_font_family = "Menlo";
            line_height = "standard";

            buffer_font_size = 12;
            buffer_font_family = "JetBrainsMono Nerd Font";
            buffer_line_height = "standard";

            # Rust

            # Nix
            # tell zed to use direnv and direnv can use a flake.nix enviroment ; may have to switch for fish
            load_direnv = "shell_hook";

            # Node
            node = {
                path = lib.getExe pkgs.nodejs;
                npm_path = lib.getExe' pkgs.nodejs "npm";
            };

            terminal = {
                alternate_scroll = "off";
                blinking = "off";
                copy_on_select = false;
                dock = "bottom";
                detect_venv = {
                    on = {
                        directories = [".env" "env" ".venv" "venv" ];
                        activate_script = "default";
                    };
                };
                env = {
                    TERM = "alacritty";
                };
                font_family = "JetBrainsMono Nerd Font";
                font_features = null;
                font_size = null;
                line_height = "standard";
                option_as_meta = false;
                button = false;
                shell = "system"; 
                toolbar = {
                    title = true;
                };
                working_directory = "current_project_directory";
            };

            # LSP config
            lsp = {
                rust-analyzer = {
                    binary = {
                        path = "${lib.getExe pkgs.rust-analyzer}";
                    };
                };
                nix = { 
                    initialization_options = {
                      autoArchive = true;
                    };
                    binary = { 
                        path = "${lib.getExe pkgs.nil}";
                    }; 
                };
            };
            
            # languages = {
            #   
            # };
        };
    };
}