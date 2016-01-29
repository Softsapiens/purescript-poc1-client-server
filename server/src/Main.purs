module Main where

import Prelude hiding (apply)

import Control.Monad.Eff.Console (log)

import Data.Maybe
import Data.Tuple
import Data.Either
import qualified Data.List as L
import Data.Array (nub, sort, (:))
import Data.Foldable (elem)

import qualified Data.Map as M

import Control.Monad.Eff
import Control.Monad.Eff.Ref
import Control.Monad.Eff.Exception
import Control.Monad.Eff.Class

import Node.HTTP (Server())

import Node.Express.Types
import Node.Express.App
import Node.Express.Handler
import Node.Express.Request
import Node.Express.Response

import DB

import JSMiddleware (jsonBodyParser, staticFiles)

indexHandler :: forall e. Handler e
indexHandler = send
  { name: "langdb server"
  , lang: "http://localhost:9000/api/lang"
  , tag: "http://localhost:9000/api/tag"
  }

shortLang :: Tuple Key Lang -> { key :: Key, name :: String, uri :: String, like :: String }
shortLang (Tuple key (Lang o)) =
  { key: key
  , name: o.name
  , uri: "http://localhost:9000/api/lang/" <> runInsensitive key
  , like: "http://localhost:9000/api/lang/" <> runInsensitive key <> "/like"
  }

listHandler :: forall e. Ref DB -> Handler (ref::REF | e)
listHandler db = do
  m <- liftEff $ readRef db
  send <<< toArray <<< map shortLang <<< M.toList $ m -- $ [ Tuple (getKey purescript) purescript, Tuple (getKey haskell) haskell ]
  where
  getKey (Lang l) = l.key
  toArray (L.Cons x xs) = x : toArray xs
  toArray L.Nil = []

getHandler :: forall e. Ref DB -> Handler (ref::REF | e)
getHandler db = do
  idParam <- getRouteParam "id"
  case idParam of
    Nothing -> nextThrow (error "id parameter is required")
    Just _id -> do
      m <- liftEff $ readRef db
      case M.lookup (insensitive _id) m of
        Nothing -> do
          setStatus 404
          send "Not found"
        Just val -> send val

rateHandler :: forall e. Ref DB -> Handler (ref::REF | e)
rateHandler db = do
  idParam <- getRouteParam "id"
  case idParam of
    Nothing -> nextThrow (error "id parameter is required")
    Just _id -> do
      m <- liftEff $ readRef db
      case M.lookup (insensitive _id) m of
        Nothing -> do
          setStatus 404
          sendJson "Not found"
        Just _ -> do
          liftEff $ modifyRef db $ M.update (\(Lang lang) -> Just $ Lang (lang { rating = one + lang.rating })) (insensitive _id)
          sendJson "ok"

putHandler :: forall e. Ref DB -> Handler (ref::REF | e)
putHandler db = do
  idParam <- getRouteParam "id"
  case idParam of
    Nothing -> nextThrow (error "id parameter is required")
    Just _id -> do
      name <- getBodyParam "name"
      description <- getBodyParam "description"
      homepage <- getBodyParam "homepage"
      tags <- getBodyParam "tags"
      let lang = { key: insensitive _id
                 , name: _
                 , description: _
                 , homepage: _
                 , rating: zero :: Number
                 , tags: _
                 } <$> (name         `orDie` "Name is required")
                   <*> (description  `orDie` "Description is required")
                   <*> (homepage     `orDie` "Homepage is required")
                   <*> (map insensitive <$> (tags `orDie` "Tags are required"))
      case lang of
        Left err -> do
          setStatus 406
          send err
        Right lang -> do
          liftEff $ modifyRef db $ M.insert (insensitive _id) $ Lang lang
          sendJson "ok"
  where
  orDie :: forall a. Maybe a -> String -> Either String a
  orDie Nothing s = Left s
  orDie (Just a) _ = Right a

tagsHandler :: forall e. Ref DB -> Handler (ref::REF | e)
tagsHandler db = do
  m <- liftEff $ readRef db
  send <<< map makeEntry <<< sort <<< -- nub $ do
    --langs <- M.values m
    --L.concatMap getTags $ langs -- Array Tag
    nub $ map insensitive [ "Pure", "Functional", "Static", "AltJS" ]
  where
    getTags (Lang l) = l.tags -- Array Tag
    makeEntry tag = { tag: tag, uri: "http://localhost:9000/api/tag/" <> runInsensitive tag }

tagHandler :: forall e. Ref DB -> Handler (ref::REF | e)
tagHandler db = do
  tagParam <- getRouteParam "tag"
  case tagParam of
    Nothing -> nextThrow (error "tag parameter is required")
    Just _tag -> do
      m <- liftEff $ readRef db
      send <<< toArray <<< map shortLang <<< L.filter (hasTag (insensitive _tag)) <<< M.toList $ m
  where
  hasTag t (Tuple _ (Lang o)) = t `elem` o.tags
  toArray (L.Cons x xs) = x : toArray xs
  toArray L.Nil = []

app :: Ref DB -> App (ref::REF)
app db = do
  setProp "json spaces" 2

  useExternal jsonBodyParser
  useExternal staticFiles -- the client web

  get "/api" indexHandler
  get "/api/lang" (listHandler db)

  get "/api/lang/:id" (getHandler db)
  put "/api/lang/:id" (putHandler db)

  post "/api/lang/:id/like" (rateHandler db)

  get "/api/tag" (tagsHandler db)
  get "/api/tag/:tag" (tagHandler db)

main:: Eff (express::EXPRESS, ref:: REF) Server
main = do
  ref <- newRef db
  listenHttp (app ref) 9000 \_ -> log "Listening on port 9000"
