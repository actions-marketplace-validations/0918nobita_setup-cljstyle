module SetupCljstyle.Installer.Win32
  ( installer
  ) where

import Prelude

import Control.Monad.Trans.Class (lift)
import Control.Monad.Except (withExceptT)
import Control.Monad.Reader (ReaderT, ask, asks)
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import GitHub.Actions.ToolCache (cacheDir, downloadTool)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Sync (writeTextFile)
import Node.Path (concat)
import SetupCljstyle.Installer (Installer(..))
import Types (AffWithExcept, SingleError(..), URL(..), Version(..))

binDir :: String
binDir = "D:\\cljstyle"

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle-"
    <> version
    <> ".jar"

downloadJar :: ReaderT Version AffWithExcept Unit
downloadJar = do
  URL url <- asks downloadUrl
  version <- ask
  lift do
    log $ "Download " <> url
    void $
      downloadTool
        { url
        , auth: Nothing
        , dest: Just $ concat [ binDir, "cljstyle-" <> show version <> ".jar" ]
        }
        # withExceptT \_ -> SingleError $ "Failed to download " <> url

installer :: Installer
installer = Installer do
  downloadJar

  version <- ask

  lift do
    let batchFilePath = concat [ binDir, "cljstyle.bat" ]
    log $ "Write " <> batchFilePath
    let batchFileContent = "java -jar %~dp0cljstyle-" <> show version <> ".jar %*"
    (liftEffect $ writeTextFile UTF8 batchFilePath batchFileContent)
      # withExceptT \_ -> SingleError $ "Failed to write " <> batchFilePath

    log $ "Cache " <> binDir
    _ <- cacheDir { sourceDir: binDir, tool: "cljstyle", version: show version, arch: Nothing }
      # withExceptT \_ -> SingleError $ "Failed to cache " <> binDir

    pure binDir
