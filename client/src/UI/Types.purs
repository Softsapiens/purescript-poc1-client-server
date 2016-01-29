-- | Types used by the Programming Languages Database client application.
-- |
-- | Instances of the `IsForeign` class are provided so that various types
-- | can be safely read from AJAX responses.

module UI.Types where

import Prelude

import Data.Foreign.Class

-- | A primary key for a language.
type Key = String

-- | A tag name.
type Tag = String

-- | An AJAX response with no content.
data Ok = Ok

-- | A tag summary record.
newtype TagSummary = TagSummary
  { tag :: Tag
  , uri :: String
  }

runTagSummary (TagSummary o) = o

-- | A language summary record.
newtype LangSummary = LangSummary
  { key :: Key
  , name :: String
  , uri :: String
  , like :: String
  }

runLangSummary (LangSummary o) = o

-- | A full language record.
newtype Lang = Lang
  { key :: Key
  , name :: String
  , description :: String
  , homepage :: String
  , rating :: Number
  , tags :: Array Tag
  }

runLang (Lang o) = o

-- | The empty language record.
emptyLang :: Lang
emptyLang = Lang
  { key: ""
  , name: ""
  , description: ""
  , homepage: ""
  , rating: zero :: Number
  , tags: []
  }

instance isForeignOk :: IsForeign Ok where
  read _ = return Ok

instance tagSummaryIsForeign :: IsForeign TagSummary where
  read value = TagSummary <$> ( { tag: _, uri: _ } <$> readProp "tag" value <*> readProp "uri" value )

instance langSummaryIsForeign :: IsForeign LangSummary where
  read value = LangSummary <$>
    ({ key: _, name: _, uri: _, like: _ }
      <$> readProp "key" value
      <*> readProp "name" value
      <*> readProp "uri" value
      <*> readProp "like" value)

instance langIsForeign :: IsForeign Lang where
  read value = Lang <$>
    ({ key: _, name: _, description: _, homepage: _, rating: _, tags: _ }
      <$> readProp "key" value
      <*> readProp "name" value
      <*> readProp "description" value
      <*> readProp "homepage" value
      <*> readProp "rating" value
      <*> readProp "tags" value)
