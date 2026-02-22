{ config
, pkgs
, util
, ...
}:
let
  col = config.lib.stylix.colors;
  h2d = util.style.hexColorToDecimalTriplet;
in
{
  home.packages = [
    pkgs.wofi
  ];

  xdg.configFile."wofi/style.css".text = ''
    * * {
      background: transparent;
      margin: 0;
      padding: 0;
    }

    * {
      font-family: 'Cantarell', monospace;
      font-size: 14px;
      outline: none;
    }

    /* Window */
    window {
      background-color: transparent;
      animation: fadeIn 0.2s ease-in-out;
    }

    #outer-box {
      margin: 2pt;
      box-shadow: 0 0 0 1pt alpha(rgb(${h2d col.base00}), 0.5);
      background-color: #${col.base00};

      border: 1.5pt solid #${col.base03};
      border-radius: 1em;

      padding: 0.25em;
      animation: colorIn 3s ease-in;
    }


    /* Scroll */
    #scroll {
      margin: 0.5em 1em;
      padding: 0;
      border: none;
      background-color: #${col.base01};
      box-shadow: 0 0 0 0.75pt #${col.base02};
      border-radius: 0.75em;
    }

    #input {
      margin: 0.5em 1em;
      margin-bottom: 0.125em;
      padding: 0;
      border: 0;
      border-radius: 0.75em;
      background-color: #${col.base00};

      box-shadow: 0 0 0 0.75pt #${col.base02};
    }
    :placeholder-text {
      color: #${col.base08};
    }

    #input image {
      border: none;
      color: #${col.base07};
      margin: 0 0.8125em;
    }

    * {
      text-decoration-color: #${col.base06};
      caret-color: mix(#${col.base06}, #${col.base0B}, 0.4);
    }
    /* Outer Box */
    #inner-box {
      background-color: transparent;
      margin: 0.25em;
    }
    /* Color In */
    keyframes colorIn {
      0% {
         border-color: #${col.base01};
      }

      100% {
        border-color: #${col.base03};
      }
    }
    /* Slide In */
    keyframes slideIn {
      0% {
         opacity: 0;
      }

      100% {
         opacity: 1;
      }
    }

    /* Fade In */
    keyframes fadeIn {
      0% {
         opacity: 0;
      }

      100% {
         opacity: 1;
      }
    }

    image {
      padding: 0.25em;
    }

    #entry {
      margin: 0;
      padding: 0;
      border: 0.0625em solid;
      border-radius: 0.5em;
      border-color: transparent;
      background-color: transparent;
      color: #${col.base05});

    }

    #entry arrow {
      margin: 0.25em;
      border: none;
    }

    #entry *:backdrop  {
      border-color: #${col.base0D};
    }

    arrow {
      margin: 0.25em;
      border: none;
    }

    #entry:selected, #entry:selected arrow {
      border-color: #${col.base0B};
      background-color: #${col.base03};
    }

    #entry:selected #text {
      color: #${col.base07};
    }

    #entry #text {
      margin: 0.5em;
      color: #${col.base07};
    }

    #entry #entry {
      padding-left: 1.625em;

      border: none;
      border-radius: 0;
      background-color: #${col.base01};
    }

    #entry #entry:nth-last-child(1) {
      border-bottom-left-radius: 0.75em;
      border-bottom-right-radius: 0.75em;
    }

    #entry #entry:hover {
      border: none;
      background-color: mix(rgb(${h2d col.base01}), rgb(${h2d col.base02}), 0.5);
    }

    #entry #entry:selected {
      border: none;
      background-color: #${col.base02};
    }

    #entry #entry #text {
      color: #${col.base05};
    }
    #entry #entry image {
      opacity: 0.33;
    }
    #entry #entry:hover image {
      opacity: 0.66;
    }
    #entry #entry:selected image {
      opacity: 1;
    }
    #entry #entry:hover #text {
      color: mix(rgb(${h2d col.base06}), rgb(${h2d col.base05}), 0.5);;
    }
    #entry #entry:selected #text {
      color: #${col.base05});
    }
  '';

}
