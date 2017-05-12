{-# OPTIONS_GHC -ddump-ds -ddump-to-file -fdefer-type-errors -Wno-deferred-type-errors #-} -- needed for shouldNotTypecheck
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
-- XXX: None error if we move this from Data.BugSpec to BugSpec
module Data.BugSpec where
import Test.Hspec
import Test.ShouldNotTypecheck (shouldNotTypecheck)

import Control.DeepSeq (NFData(..))
import GHC.Generics (Generic)

spec :: Spec
-- XXX: None error if we rename F to G
spec = describe "shoultNotTypecheck" $ do

  -- PASSES
  it "captures errors from fromNatSingToZ" $ do
    shouldNotTypecheck (fromNatSingToZ (SuccSing ZeroSing) :: Z 'Zero)

  -- ERRORS
  -- doesn't error if we rename fromNatSingToZ to toZ
  it "captures errors from fromZToF . fromNatSingToZ" $ do
    shouldNotTypecheck (fromZToF (fromNatSingToZ (SuccSing ZeroSing)))

  -- PASSES
  it "captures errors from fromZToF . (lte :=>)" $ do
    shouldNotTypecheck (fromZToF (lte :=> SuccSing ZeroSing))

  -- ERRORS
  it "captures errors from fromNatSingToF" $ do
    shouldNotTypecheck (fromNatSingToF (SuccSing ZeroSing))

fromNatSingToZ :: IsLessThanOrEqualTo m n => NatSing m -> Z n
fromNatSingToZ sm = lte :=> sm

fromZToF :: Z 'Zero -> F
fromZToF (Reflexive :=> ZeroSing) = X

fromNatSingToF :: IsLessThanOrEqualTo m 'Zero => NatSing m -> F
fromNatSingToF = fromZToF . fromNatSingToZ

data F = X deriving (Generic)
instance NFData F where

-- | unary encoded naturals
data Nat = Zero | Succ Nat

-- | singletons for naturals
data NatSing (n :: Nat) where
  ZeroSing :: NatSing 'Zero
  SuccSing :: NatSing n -> NatSing ('Succ n)

instance NFData (NatSing n) where
  rnf (SuccSing sn) = rnf sn
  rnf ZeroSing = ()

-- | natural numbers mod (n+1)
data Z (n :: Nat) where
  (:=>) :: LTE m n -> NatSing m -> Z n

instance NFData (Z n) where
  rnf (pf :=> sm) = rnf pf `seq` rnf sm

-- | proof that m <= n
data LTE (m :: Nat) (n :: Nat) where
  Reflexive :: LTE m m
  Transitive :: LTE m n -> LTE m ('Succ n)

instance NFData (LTE m n) where
  rnf (Transitive pf) = rnf pf
  rnf Reflexive = ()

class IsLessThanOrEqualTo (m :: Nat) (n :: Nat) where
  lte :: LTE m n
