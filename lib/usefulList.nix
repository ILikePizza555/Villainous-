/*
This module contains useful helper functions for working with lists.
*/
{lib, polyfill}:

rec {
  /*
  Takes the cartesian product of an attribute set of lists of strings, and maps the provided function
  over the result.
  */
  crossMap = mapFn: attrsOfLists:
    map mapFn (polyfill.cartesianProductOfSets attrsOfLists);

  productOfStrings = separator: attrsOfLists:
    crossMap (attr: lib.concatStringsSep separator (lib.attrValues attr)) attrsOfLists;

  /*
  Creates a new list with the specified amount of entries by generating the missing entries using genFn and appending to the original list.

  Example:
    fillList toString 5 ["a" "b" "c"] =>
      ["a" "b" "c" "4" "5"]
  */
  fillList = genFn: amount: l:
    let 
      rangeBegin = (lib.length l) + 1;
    in
    l ++ map genFn (lib.range rangeBegin amount);
}
