{ stdenv, fetchgit, cmake }:

stdenv.mkDerivation rec {
 
  name = "DataFrame-${version}";
  version = "1.5.0";
  src = fetchgit {
    url = "https://github.com/hosseinmoein/DataFrame";
    rev = "9d4e594af389d643985af0f7140896f93cdbcda1";
    sha256 = "1j6165l956b9pan7vfrgjyz5m9s2wxjp6swzai5f2m6kyghnzgmc";
  };

  nativeBuildInputs = [ cmake ];
  cmakeFlags = [];
}
