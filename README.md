# Angel's Flood

## A 3D platformer made in PICO-8 for [PICO-32: The Lost Pages](https://store.steampowered.com/app/5275380/Pico32_The_Lost_Pages/).

Powered by [parens-8](https://codeberg.org/wellspring-labs/parens-8/) v5 by Miss Mouse.

Original pico32 launcher code by Werxyz.

#### File Structure
`dialogue.p8` is used to generate spritesheet data that contains the dialogue for the game, and the code in that file in not included in the build.
`merged_code.p8` contains the code from `angels_flood.p8` and `parens8_code.p8`, but is not executable without being run through [shrink08](https://github.com/thisismypassport/shrinko8)
because it exceeds PICO-8's token limit. To run `angels_flood.p8`, run `parens8_code.p8` in the same directory first, making sure the parens8 library folder is in the same director and named `ps8`.
