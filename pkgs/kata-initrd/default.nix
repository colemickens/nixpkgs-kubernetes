{ makeInitrd
, writeScriptBin
, kata-agent
}:

let
  init = writeScriptBin "kata-agent" ''
    exec ${kata-agent}/bin/kata-agent
  '';
in 
makeInitrd {
  name = "initrd-kata";
  contents = [
    { object = init;
      symlink = "/init"; }
  ];
}
