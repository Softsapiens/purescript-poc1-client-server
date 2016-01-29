-- | Main.main is the entry point into the project, called at startup.

module Main where

import Control.Monad.Eff (Eff())

import DOM (DOM())
import Network.HTTP.Affjax (AJAX())

{- Impossible to set explicit signature. Compiler Bug perhaps¿?
main :: forall t389.
        Eff
          ( dom :: DOM
          , ajax :: AJAX
          | t389
          )
          ()
-}
main = UI.main
