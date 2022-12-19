# Unit tests for lib.path functions. Use `nix-build` in this directory to
# run these
{ libpath }:
let
  lib = import libpath;
  inherit (lib.path) subpath;

  cases = lib.runTests {
    testSubpathValidExample1 = {
      expr = subpath.valid null;
      expected = false;
    };
    testSubpathValidExample2 = {
      expr = subpath.valid "";
      expected = false;
    };
    testSubpathValidExample3 = {
      expr = subpath.valid "/foo";
      expected = false;
    };
    testSubpathValidExample4 = {
      expr = subpath.valid "../foo";
      expected = false;
    };
    testSubpathValidExample5 = {
      expr = subpath.valid "foo/bar";
      expected = true;
    };
    testSubpathValidExample6 = {
      expr = subpath.valid "./foo//bar/";
      expected = true;
    };
    testSubpathValidTwoDotsEnd = {
      expr = subpath.valid "foo/..";
      expected = false;
    };
    testSubpathValidTwoDotsMiddle = {
      expr = subpath.valid "foo/../bar";
      expected = false;
    };
    testSubpathValidTwoDotsPrefix = {
      expr = subpath.valid "..foo";
      expected = true;
    };
    testSubpathValidTwoDotsSuffix = {
      expr = subpath.valid "foo..";
      expected = true;
    };
    testSubpathValidTwoDotsPrefixComponent = {
      expr = subpath.valid "foo/..bar/baz";
      expected = true;
    };
    testSubpathValidTwoDotsSuffixComponent = {
      expr = subpath.valid "foo/bar../baz";
      expected = true;
    };
    testSubpathValidThreeDots = {
      expr = subpath.valid "...";
      expected = true;
    };
    testSubpathValidFourDots = {
      expr = subpath.valid "....";
      expected = true;
    };
    testSubpathValidThreeDotsComponent = {
      expr = subpath.valid "foo/.../bar";
      expected = true;
    };
    testSubpathValidFourDotsComponent = {
      expr = subpath.valid "foo/..../bar";
      expected = true;
    };

    testSubpathNormaliseExample1 = {
      expr = subpath.normalise "foo//bar";
      expected = "./foo/bar";
    };
    testSubpathNormaliseExample2 = {
      expr = subpath.normalise "foo/./bar";
      expected = "./foo/bar";
    };
    testSubpathNormaliseExample3 = {
      expr = subpath.normalise "foo/bar";
      expected = "./foo/bar";
    };
    testSubpathNormaliseExample4 = {
      expr = subpath.normalise "foo/bar/";
      expected = "./foo/bar";
    };
    testSubpathNormaliseExample5 = {
      expr = subpath.normalise "foo/bar/.";
      expected = "./foo/bar";
    };
    testSubpathNormaliseExample6 = {
      expr = subpath.normalise ".";
      expected = "./.";
    };
    testSubpathNormaliseExample7 = {
      expr = (builtins.tryEval (subpath.normalise "foo/../bar")).success;
      expected = false;
    };
    testSubpathNormaliseExample8 = {
      expr = (builtins.tryEval (subpath.normalise "")).success;
      expected = false;
    };
    testSubpathNormaliseExample9 = {
      expr = (builtins.tryEval (subpath.normalise "/foo")).success;
      expected = false;
    };
    testSubpathNormaliseValidDots = {
      expr = subpath.normalise "./foo/.bar/.../baz...qux";
      expected = "./foo/.bar/.../baz...qux";
    };
    testSubpathNormaliseWrongType = {
      expr = (builtins.tryEval (subpath.normalise null)).success;
      expected = false;
    };
    testSubpathNormaliseTwoDots = {
      expr = (builtins.tryEval (subpath.normalise "..")).success;
      expected = false;
    };
  };
in
  if cases == [] then "Unit tests successful"
  else throw "Path unit tests failed: ${lib.generators.toPretty {} cases}"
