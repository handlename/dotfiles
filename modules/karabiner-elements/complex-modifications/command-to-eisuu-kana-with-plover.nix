{ homeDirectory ? "/Users/handlename" }:

let
  pythonBin = "/Applications/Plover.app/Contents/Frameworks/Python.framework/Versions/3.13/bin/python3";
  scriptPath = "${homeDirectory}/src/github.com/handlename/dotfiles/modules/karabiner-elements/scripts/plover-control.py";
in
{
  description = "コマンドキーを単体で押したときに、英数・かなキーを送信し、Ploverの出力を連動させる（左コマンド: 英数/Plover停止、右コマンド: かな/Plover再開）";
  manipulators = [
    {
      from = {
        key_code = "left_command";
        modifiers = {
          optional = [ "any" ];
        };
      };
      to = [ { key_code = "left_command"; } ];
      to_if_alone = [
        { key_code = "japanese_eisuu"; }
        { shell_command = "${pythonBin} ${scriptPath} suspend"; }
      ];
      type = "basic";
    }
    {
      from = {
        key_code = "right_command";
        modifiers = {
          optional = [ "any" ];
        };
      };
      to = [ { key_code = "right_command"; } ];
      to_if_alone = [
        { key_code = "japanese_kana"; }
        { shell_command = "${pythonBin} ${scriptPath} resume"; }
      ];
      type = "basic";
    }
  ];
}
