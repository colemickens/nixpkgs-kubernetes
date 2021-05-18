{ makeInitrd
, writeScript
, dash
, kata-agent
}:

let
  init = writeScript "kata-agent" ''
    $!${dash}/bin/dash
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
