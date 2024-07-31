{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "json2kdl";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "AgathaSorceress";
    repo = pname;
    rev = "285e1e8aff1248da5fdb32165af9286faa1739e2";
    hash = "sha256-tkr7jOYgLtcOV13pz4/DzbcSp2IbuOAvmMS86wkaNw4=";
  };

  cargoHash = "sha256-jDdVSCtRp6heE72+bxF6ixaYNbJpKkCDg4mQskbQoZc=";

  meta = {
    description = "Program that converts JSON files to KDL";
    homepage = "https://github.com/AgathaSorceress/json2kdl";
    platforms = lib.platforms.all;
    maintainers = (with lib.maintainers; [ feathecutie ]);
  };
}
