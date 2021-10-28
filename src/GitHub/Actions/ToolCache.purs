module GitHub.Actions.ToolCache
  ( cacheDir
  , extractTar
  , downloadTool
  , find
  ) where

import Prelude

import Control.Monad.Except (ExceptT(..))
import Control.Promise (Promise, toAff)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff)

foreign import _cacheDir :: String -> String -> String -> Promise String

cacheDir :: String -> String -> String -> Aff String
cacheDir sourceDir tool = toAff <<< _cacheDir sourceDir tool

foreign import _extractTar :: String -> String -> Promise String

extractTar :: String -> String -> Aff String
extractTar file = toAff <<< _extractTar file

foreign import _downloadTool :: String -> Promise String

downloadTool :: String -> Aff String
downloadTool = toAff <<< _downloadTool

foreign import _find :: String -> String -> Effect String

find :: String -> String -> ExceptT Unit Effect String
find toolName versionSpec = ExceptT do
  pathOpt <- _find toolName versionSpec
  pure case pathOpt of
    "" -> Left unit
    p  -> Right p