-- DON'T TOUCH ANY OF THIS
-- there's stuff you can touch, scroll down to the definition of the World record to find it

{-
(Sorry if I use tick and frame interchangeably. It shouldn't hinder clarity though)
World is the record that stores all the data required by the game. The function that you have to define yourself that runs every frame (loopFunc) takes world as a parameter (see the general setup section in the readme). You can use loopFunc to modify the state of the game, then return the new state of the game at the end of the function. The next frame, that new state of the game that you just defined will be passed as a parameter to loopFunc. This is how you can update the game state every frame.

Inside of the World record (whose contents are mainly up to you) is the WorldRaw record (whose contents you should not change). Take a look through the WorldRaw record. It contains a lot of data whose initialisation is abstracted from you, like the renderer. Since loopFunc only provides you access to World, accessing fields of WorldRaw is a bit cumbersome, as you have to unpack some values. To simplify access of WorldRaw fields, you can use the provided getters and setters in this file.

Take a look through WorldRaw and its corresponding functions to see what stuff is available to you
Remember that you can add your own fields to World, just don't remove World's wr field
-}

module SDLHelper.Data.WorldExposed where

import qualified SDL

import qualified SDLHelper.Data.Keyboard as KB

data WorldRaw = WorldRaw {
    -- find more info on the keyboard in SDLHelper.Keyboard
    kb   :: KB.Keyboard,

    -- given an SDL scancode (a value which correspons to a key on your keyboard/controller),
    -- kbs will return if that key is currently pressed
    -- this is abstracted by SDLHelper.Keyboard, so you probably don't have to worry about this field
    kbs  :: SDL.Scancode -> Bool,

    -- also abstracted by SDLHelper.Keyboard
    -- kbps stores the keys pressed on the previous frame
    -- by comparing kbps to kbs you can determine if someone is holding or has just released a key
    kbps :: SDL.Scancode -> Bool,

    -- the game window
    -- you also probably don't need to worry about this
    -- I think there's a way to render to the screen using the window?
    -- but that's abstracted from you and you can just use the renderer and related functions I've written
    w    :: SDL.Window,

    -- events provided by SDL
    -- these are used by SDLHelper.KeyboardReader to register keypresses
    es   :: [SDL.EventPayload],

    -- used for rendering to the screen
    -- there's a bunch of related helpful functions in SDLHelper.SDLHelper
    r    :: SDL.Renderer,

    -- the fps of the game, which is 50 by default, can be changed
    fps  :: Int,

    -- false by default, set to true to exit before the next frame
    quit :: Bool,

    -- used for printing to the terminal
    -- check the corresponding function called "log"
    logger :: [String]
}

-- log adds a log message to a list
-- log will display the messages in order that they're received at the end of the frame
-- log allows you to command data to be displayed terminal outside of monadic contexts
log :: World -> String -> World
log w s = w { wr = wr' } where
    wr1 = wr w
    wr' = wr1 { logger = s : logger wr1 }

-- you can use this if you want, but this is called in SDLHelper.SDLHelper...
-- ...at the end of each frame in order to prevent the same messages being printed out every frame
clearLog :: World -> World
clearLog w = w { wr = wr' } where
    wr1 = wr w
    wr' = wr1 { logger = [] }

-- those getters and setters I was talking abt
getKb   w = kb $ wr w
getKbs  w = kbs $ wr w
getKbps w = kbps $ wr w
getW    world = w $ wr world
getEs   w = es $ wr w
getR    w = r $ wr w
getFps  w = fps $ wr w
getQuit w = quit $ wr w

setKb w x   = w { wr = wr' } where wr' = (wr w) { kb   = x }
setKbs w x  = w { wr = wr' } where wr' = (wr w) { kbs  = x }
setKbps w x = w { wr = wr' } where wr' = (wr w) { kbps = x }
setW w x    = w { wr = wr' } where wr' = (wr w) { w    = x }
setEs w x   = w { wr = wr' } where wr' = (wr w) { es   = x }
setR w x    = w { wr = wr' } where wr' = (wr w) { r    = x }
setFps w x  = w { wr = wr' } where wr' = (wr w) { fps  = x }
setQuit w x = w { wr = wr' } where wr' = (wr w) { quit = x }

-- World, as deqscribed in the text at the top of this file
data World = World {
    -- WorldRaw is a necessary argument
    wr     :: WorldRaw

    -- feel free to add whatever else you want past this line
}

-- you can even define your own functions here!
-- hopefully I managed my import lists correctly,
-- but if you do end up getting some weird error where SDLHelper is
-- trying to incorrectly call your function you defined here,
-- rename your function, or fix my import lists
