{
  bech32 = { buildPythonPackage, fetchurl }: buildPythonPackage rec {
    pname = "bech32";
    version = "1.2.0";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/b6/41/7022a226e5a6ac7091a95ba36bad057012ab7330b9894ad4e14e31d0b858/bech32-1.2.0-py3-none-any.whl";
      sha256 = "10frg6gdwb3mnccllady83dp76yxbwqva1sjynyspzp4lpjwh3cr";
    };
    format = "wheel";
    doCheck = false;
  };
  lnurl = { buildPythonPackage, fetchurl, bech32, pydantic, typing-extensions }: buildPythonPackage rec {
    pname = "lnurl";
    version = "0.3.6";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/a6/cf/ca4e80e16bc3aae5d84dbc28554ef5b26b0d7460775090ff3579ca185b6f/lnurl-0.3.6-py3-none-any.whl";
      sha256 = "14lw7crvlq01xdd5svs2l8gzm6brrd2yqx0wqs2bq9adikyq56ap";
    };
    format = "wheel";
    doCheck = false;
    propagatedBuildInputs = [
      bech32
      pydantic
      typing-extensions
    ];
  };
}
