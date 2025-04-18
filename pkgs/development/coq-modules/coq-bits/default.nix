{
  lib,
  mkCoqDerivation,
  coq,
  mathcomp,
  mathcomp-algebra-tactics,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  pname = "coq-bits";
  repo = "bits";
  inherit version;
  defaultVersion =
    with lib.versions;
    lib.switch
      [ coq.version mathcomp.version ]
      [
        {
          cases = [
            (range "8.10" "8.16")
            (isLt "2.0")
          ];
          out = "1.1.0";
        }
        {
          cases = [
            (range "8.7" "8.15")
            (isLt "2.0")
          ];
          out = "1.0.0";
        }
      ]
      null;

  release."1.1.0".sha256 = "sha256-TCw1kSXeW0ysIdLeNr+EGmpGumEE9i8tinEMp57UXaE=";
  release."1.0.0".sha256 = "0nv5mdgrd075dpd8bc7h0xc5i95v0pkm0bfyq5rj6ii1s54dwcjl";

  propagatedBuildInputs = [
    mathcomp.algebra
    mathcomp-algebra-tactics
    stdlib
  ];

  meta = with lib; {
    description = "Formalization of bitset operations in Coq";
    license = licenses.asl20;
    maintainers = with maintainers; [ ptival ];
  };
}
