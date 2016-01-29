module Test.Main where

newtype Lang = Lang
  { key :: String
  , name :: String
  , description :: String
  , homepage :: String
  , rating :: Number
  , tags :: Array String
  }

runLang (Lang lang) = lang

purescript = Lang { key: "purescript"
                      , name: "PureScript"
                      , description: "A small strongly typed programming language that compiles to JavaScript"
                      , homepage: "http://purescript.org/"
                      , rating: toNumber 463
                      , tags: [ "Pure", "Functional", "Static", "AltJS" ]
                      }



--getTags m 