{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Game.Client.ConsoleSpec where

import Game.Client.Console (readInput)
import Game.Client.IO (Command (..))
import Game.ClientSpec (KnownParties (KnownParties))
import Game.Server (HeadId (HeadId), partyId)
import Game.Server.Mock (MockChain)
import qualified Data.Text as Text
import Test.Hspec (Spec, it, shouldBe)
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Small (Small))
import Test.QuickCheck.Modifiers (Positive (Positive))
import Data.Aeson (ToJSON(..))

spec :: Spec
spec = do
  it "parses 'quit' command" $ do
    readInput "quit" `shouldBe` Right Quit
    readInput "q" `shouldBe` Right Quit

  prop "parses 'newTable' command" $ \(KnownParties parties) ->
    let names = (partyId @MockChain <$> parties)
     in readInput ("newTable " <> Text.unwords names) `shouldBe` Right (NewTable names)

  prop "parses 'fundTable' command" $ \(HeadId headId) (Positive (Small n)) ->
    readInput ("fundTable " <> headId <> " " <> Text.pack (show n)) `shouldBe` Right (FundTable headId n)

  prop "parses 'play' command" $ \(HeadId headId) (Positive (n :: Integer)) ->
    readInput ("play " <> headId <> " " <> Text.pack (show n)) `shouldBe` Right (Play headId (toJSON n))

  prop "parses 'newGame' command" $ \(HeadId headId) ->
    readInput ("newGame " <> headId) `shouldBe` Right (NewGame headId)

  prop "parses 'stop' command" $ \(HeadId headId) ->
    readInput ("stop " <> headId) `shouldBe` Right (Stop headId)
