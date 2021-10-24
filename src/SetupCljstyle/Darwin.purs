module SetupCljstyle.Darwin where

import Prelude

import Actions.Core (addPath)
import Actions.ToolCache (cacheDir, downloadTool, extractTar)
import Control.Monad.Except (catchError)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error)
import Node.Process (exit)
import SetupCljstyle.Types (Version, Url)

downloadUrl :: Version -> Url
downloadUrl version =
  "http://github.com/greglook/cljstyle/releases/download/"
    <> version <> "/cljstyle_" <> version <> "_macos.tar.gz"

downloadTar :: Version -> Aff String
downloadTar version =
  let
    url = downloadUrl version
    tryDownloadTar = downloadTool url
  in
  catchError
    tryDownloadTar
    (\_ -> liftEffect do
      error $ "Failed to download " <> url
      exit 1)

extractCljstyleTar :: String -> String -> Aff String
extractCljstyleTar tarPath binDir =
  catchError
    (extractTar tarPath binDir)
    (\_ -> liftEffect do
      error $ "Failed to extract " <> tarPath
      exit 1)

installBin :: Version -> Effect Unit
installBin version =
  let binDir = "/usr/local/bin" in
  launchAff_ do
    tarPath <- downloadTar version

    extractedDir <- extractCljstyleTar tarPath binDir

    _ <- cacheDir extractedDir "cljstyle" version

    liftEffect $ addPath extractedDir
