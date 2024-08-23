{-# LANGUAGE DeriveGeneric #-}

module SDLHelper.Data.KeyboardReaderExposed where

import SDL
import GHC.Generics (Generic)

{-
This file contains keybind names and what they're bound to. Add and remove keybinds as you wish, then add or remove the scancodes they're bound to. The way it works is that the nth keybind in the record is bound to the nth keybind in the list. So in the example below, Quit, the 5th keybind, is bound to ScancodeEscape, the 5th element in getDefaultInputsExposed
When I say "is bound to", I mean that Keyboard will map from the keybind to the scancode
-}

-- you can add and remove names for keybinds as you wish
data Keybind  = Left
              | Right
              | Up
              | Down
              | Quit
              deriving (Eq, Ord, Enum, Bounded, Generic)

-- additionally, edit these
-- these are the default keys that the Keybinds are bound to
getDefaultInputsExposed :: [SDL.Scancode]
getDefaultInputsExposed = [
        SDL.ScancodeLeft,
        SDL.ScancodeRight,
        SDL.ScancodeUp,
        SDL.ScancodeDown,
        SDL.ScancodeEscape
     ]