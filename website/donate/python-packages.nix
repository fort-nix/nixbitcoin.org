{
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
