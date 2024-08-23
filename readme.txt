SDLHelper is a wrapper library around SDL that I'm using to abstract some stuff for myself

----- (Stack) Dependencies -----
- base >= 4.7 && < 5
- sdl2
- aeson
- containers
- directory
- bytestring
- extra
- text
- sdl2-ttf
- sdl2-mixer
- sdl2-image


----- General Setup -----
Plop the SDLHelper folder in src/

The main function in app/Main.hs should look like this:

main :: IO ()
main = SDLHelper.SDLHelper.doMain "nameofapp" (screenWidth, screenHeight) "kbPath" initFunc loopFunc terminateFunc

doMain :: Text                        -- name of the application
       -> (Int, Int)                  -- the width and height of the screen
                                          -- Fullscreen isn't currently supported
       -> FilePath                    -- path to where the serialised keyboard layout is stored
                                          -- for more on this, see SDLHelper.KeyboardReader
       -> (WorldRaw -> IO World)      -- the initialisation function, used for initialising the game
                                          -- takes in a couple of essential data values grouped together as a record
                                          -- World and WorldRaw will be discussed later in the general setup
                                          -- Both World and WorldRaw are defined in SDLHelper.Data.WorldExposed
       -> (World -> IO World)         -- the main function, computes all calculations needed in one tick
                                          -- some key operations are abstracted out of your hands
                                          -- this will also be discussed later
       -> (World -> IO ())            -- the termination function of the game
                                          -- use it for freeing memory allocated to sprites/sounds/etc
       -> IO ()

I recommend reading through SDLHelper.Data.WorldExposed.
A short summary of what you need to know is written at the top of the file.

SDLHelper.SDLHelper abstracts some information from you. It initialises and shuts down many things, like the renderer. These functions have corresponding comments in SDLHelper.SDLHelper than you can read if you want to. A descriptive list of what SDLHelper loads for you can be found in the WorldRaw record in SDLHelper.Data.WorldExposed.
During each frame, SDLHelper.SDLHelper also performs some useful operations. These are detailed at the withEventHandling in SDLHelper.SDLHelper

----- RENDERING -----
loadTexture :: (MonadIO m)
           => SDL.Renderer                     -- the renderer used (you'll probably get this from WorldRaw)
           -> FilePath                         -- the path where the texture to be loaded is stored
           -> m (SDL.Texture, SDL.TextureInfo) -- texture and texture info
-- used to simplify loading textures
-- textures are stored as a tuple containing the texture and information about the texture (eg: width)
-- there's a newtype wrapper for this called Sprite in SDLHelper.Data.MiscData

-- given a surface, it creates a texture and frees space used up by the surface
-- why do you want to do this? Bc SDLHelper only accepts textures for rendering, and not surfaces
surfaceToTexture :: (MonadIO m)
                 => SDL.Renderer                     -- the renderer used (you'll probably get this from WorldRaw)
                 -> SDL.Surface                      -- the surface to be changed into a texture
                 -> m (SDL.Texture, SDL.TextureInfo) -- texture and texture info

-- render stuff onto the screen
renderSimple :: W.World    -- the world containing the renderer to be used
             -> MD.Sprite  -- defined as (SDL.Texture, SDL.TextureInfo) in SDLHelper.Data.MiscData
             -> SDL.V2 Int -- the position where to blit the sprite
             -> IO ()

-- abstracts renderSimple for instances of Drawable
renderEntity :: (MD.Drawable e)
             => W.World -- the world containing the renderer to be used
             -> e       -- the drawable to be blitted
             -> IO ()

----- KEYBOARD -----
-- For an explanation, check the text at the top of SDLHelper.KeyboardReader

-- All of the following functions follow the same type signature
   (MonadIO m)
=> World    -- the World containing the Keyboard to be referred to (defined in SDLHelper.Data.WorldExposed)
-> Keybind  -- the Keybind to check for (defined in SDLHelper.Data.KeyboardReaderExposed)
-> m Bool   -- whether the Keybind has been pressed

-- checks if a key has been pressed on this frame and not the last frame
isKeyPressed :: (MonadIO m) => World -> Keybind -> m Bool

-- checks if a key has been pressed on this and last frame
isKeyHeld :: (MonadIO m) => W.World -> Keybind -> m Bool

-- checks if a key has been pressed on this frame
isKeyDown :: (MonadIO m) => World -> Keybind -> m Bool

-- takes a world, a keybind and a key to update the keybind with,
-- updates the keybind in the keyboard in the world,
-- and returns the updated world
modifyKeyBind :: World        -- the world containing the keyboard to change
              -> Keybind      -- the keybind to change
              -> SDL.Scancode -- the key to change the keybind to
              -> World        -- the updated world record

----- MISCDATA -----
-- instances of the drawable class can take advantage of some functions to make rendering and working with rects easier
-- instances of the drawable class must define the setRect, getRect and getSprite functions
-- every drawable has a corresponding sprite and a rect
       -- The rect defines the x and y-co-ordinates of the top-left of the drawable
       -- and the drawable's width and height
       -- The sprite determines what the drawable looks like

-- rects are defined in SDLHelper.Data.Rect

class Drawable a where
    -- gets a rectangle corresponding to a drawable
    getRect :: a -> Rect

    -- takes a drawable and a rectangle. This rectangle becomes the rectangle that corresponds to the drawable
    setRect :: a -> Rect -> a

    -- returns the position of the drawable as an SDL.V2 Int, which is helpful for rendering
    getPos :: a -> SDL.V2 Int
    
    -- modifies the x-position of the drawable
    changeX :: a -> Float -> a

    -- modifies the y-position of the drawable
    changeY :: a -> Float -> a

    -- gets the sprite of the drawable, used to make rendering easier
    getSprite :: a -> (SDL.Texture, SDL.TextureInfo)

-- want a drawable but don't want to create a whole new instantiation of the class?
-- there's a datatype with an instantiation of drawable already, it's called drawthing
-- I use it for blitting text to the screen
-- there's also a poopy instance of show defined for it
data Drawthing = Drawthing {
    rect :: Rect,
    sprite :: Sprite
}

-- converts floats to integers by slicing of the decimal points
toInt :: Int -> Float

-- given a condition, if the condition is true, the first non-boolean parameter is returned as a lifted value
-- if the condition is false, the second non-boolean parameter is returned as a lifted value
ifM :: (Monad m) => m Bool -> a -> a -> m a

----- RECT ----
-- Rects are useful when dealing with anything that has a position and width and height
data Rect = Rect { rectX :: Float, rectY :: Float, rectW :: Float, rectH :: Float } deriving Show

-- centers a rect on another rect
centerRect :: Rect -- rect to be centered
           -> Rect -- rect to center on
           -> Rect -- centered rect

-- centers a rect on another rect vertically
-- this and centerRectHorizontal follows the parameter structure of centerRect
centerRectVertical :: Rect -> Rect -> Rect

-- centers a rect on another rect horizontally
centerRectHorizontal :: Rect -> Rect -> Rect

-- constructor for a convoluted SDL-friendly format that can be used for rendering
toSDLRect :: a -- x
          -> a -- y
          -> a -- width
          -> a -- height
          -> SDL.Rectangle a

-- checks if the second rect is fully contained within the first
fullyContains :: Rect -> Rect -> Bool

-- checks if a and b overlap in any capacity
overlaps :: Rect -> Rect -> Bool
overlaps a b = overlapsVertically a b && overlapsHorizontally a b

-- checks if a and b overlap vertically
overlapsVertically :: Rect -> Rect -> Bool

-- checks if a and b overlap horizontally
overlapsHorizontally :: Rect -> Rect -> Bool

----- TEXTRENDERER -----
-- helpful font operations

-- performs some operation with a font
-- frees data afterwards
withFont :: (MonadIO m)
         => FilePath           -- path to font
         -> Int                -- font size
         -> (SDLF.Font -> m a) -- operation to be performed with the font
         -> m a

-- loads a font at some font size
-- creates several textures using that font
-- frees up space used by the font
-- returns the textures in the form of a map
loadSolidText :: (MonadIO m)
              => SDL.Renderer                 -- renderer to use
              -> FilePath                     -- path to font
              -> Int                          -- font size
              -> SDLF.Color                   -- colour of font
              -> [(String, Text)]             -- a list of (the key used to access the text, the rendered text)
              -> m (Map.Map String MD.Sprite) -- a map. Access rendered font textures using the keys you provided

-- frees up space used by the loaded textures in the map created in loadSolidText
destroyTextMap :: (MonadIO m) => Map.Map String MD.Sprite -> m ()
