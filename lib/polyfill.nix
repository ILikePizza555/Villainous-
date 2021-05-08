# This module holds polyfills from nixpkgs master.

{lib}:

rec {
  cartesianProductOfSets = attrsOfLists:
    lib.foldl' (listOfAttrs: attrName:
      lib.concatMap (attrs:
        map (listValue: attrs // { ${attrName} = listValue; }) attrsOfLists.${attrName}
      ) listOfAttrs
    ) [{}] (lib.attrNames attrsOfLists);
}
