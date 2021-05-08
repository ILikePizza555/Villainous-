/* The default module for the projects lib package.

All these modules are designed as a function which returns an attrset that can be used with `lib.extend`.These functions will always take the nixpkgs standard library as the `lib` parameter. Some may take additional dependencies as additional parameters.
*/
{lib}:

rec {
  polyfill = import ./polyfill.nix { inherit lib; };
  usefulList = import ./usefulList.nix { inherit lib; inherit polyfill; };  
}
