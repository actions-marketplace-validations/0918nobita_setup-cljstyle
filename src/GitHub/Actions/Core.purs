module GitHub.Actions.Core where

import Prelude

import Effect (Effect)

foreign import addPath :: String -> Effect Unit

data InputOption = InputOption
  { required :: Boolean
  , trimWhitespace :: Boolean
  }

foreign import getInput :: String -> InputOption -> Effect String