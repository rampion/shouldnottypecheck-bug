I've found an issue with `shouldNotTypeCheck` where it's not capturing some
of the deferred type errors at runtime.

    $ cabal sandbox init
    $ cabal install e-dependencies-only --enable-tests
    $ cabal test --show-details=always
    ...
    Resolving dependencies...
    Configuring shouldnottypecheck-bug-0.1.0.0...
    Preprocessing test suite 'spec' for shouldnottypecheck-bug-0.1.0.0...
    [1 of 2] Compiling Data.BugSpec     ( test/Data/BugSpec.hs, dist/build/spec/spec-tmp/Data/BugSpec.o )
    [2 of 2] Compiling Main             ( test/Spec.hs, dist/build/spec/spec-tmp/Main.o )
    Linking dist/build/spec/spec ...
    Running 1 test suites...
    Test suite spec: RUNNING...

    Data.Bug
      shoultNotTypecheck
        captures errors from fromNatSingToZ
        captures errors from fromZToF . fromNatSingToZ FAILED [1]
        captures errors from fromZToF . (lte :=>)
        captures errors from fromNatSingToF FAILED [2]

    Failures:

      src/Test/ShouldNotTypecheck.hs:40:
      1) Data.Bug.shoultNotTypecheck captures errors from fromZToF . fromNatSingToZ
           Make sure the expression has an NFData instance! See docs at https://github.com/CRogers/should-not-typecheck#nfdata-a-constraint. Full error:
           test/Data/BugSpec.hs:28:35: error:
               • Could not deduce (IsLessThanOrEqualTo ('Succ 'Zero) 'Zero)
                   arising from a use of ‘fromNatSingToZ’
                 from the context: () ~ ()
                   bound by a type expected by the context:
                              () ~ () => F
                   at test/Data/BugSpec.hs:28:5-70
               • In the first argument of ‘fromZToF’, namely
                   ‘(fromNatSingToZ (SuccSing ZeroSing))’
                 In the first argument of ‘shouldNotTypecheck’, namely
                   ‘(fromZToF (fromNatSingToZ (SuccSing ZeroSing)))’
                 In a stmt of a 'do' block:
                   shouldNotTypecheck (fromZToF (fromNatSingToZ (SuccSing ZeroSing)))
           (deferred type error)

      src/Test/ShouldNotTypecheck.hs:40:
      2) Data.Bug.shoultNotTypecheck captures errors from fromNatSingToF
           Make sure the expression has an NFData instance! See docs at https://github.com/CRogers/should-not-typecheck#nfdata-a-constraint. Full error:
           test/Data/BugSpec.hs:36:25: error:
               • Could not deduce (IsLessThanOrEqualTo ('Succ 'Zero) 'Zero)
                   arising from a use of ‘fromNatSingToF’
                 from the context: () ~ ()
                   bound by a type expected by the context:
                              () ~ () => F
                   at test/Data/BugSpec.hs:36:5-59
               • In the first argument of ‘shouldNotTypecheck’, namely
                   ‘(fromNatSingToF (SuccSing ZeroSing))’
                 In a stmt of a 'do' block:
                   shouldNotTypecheck (fromNatSingToF (SuccSing ZeroSing))
                 In the second argument of ‘($)’, namely
                   ‘do { shouldNotTypecheck (fromNatSingToF (SuccSing ZeroSing)) }’
           (deferred type error)

    Randomized with seed 1234172950

    Finished in 0.0058 seconds
    4 examples, 2 failures

    Test suite spec: FAIL
    Test suite logged to: dist/test/shouldnottypecheck-bug-0.1.0.0-spec.log
    0 of 1 test suites (0 of 1 test cases) passed.


Environment details

    $ ghc --version
    The Glorious Glasgow Haskell Compilation System, version 8.0.2
    $ cabal --version
    cabal-install version 1.24.0.2
    compiled using version 1.24.2.0 of the Cabal library 
    $ cabal sandbox hc-pkg list
    /usr/local/Cellar/ghc/8.0.2/lib/ghc-8.0.2/package.conf.d
        Cabal-1.24.2.0
        array-0.5.1.1
        base-4.9.1.0
        binary-0.8.3.0
        bytestring-0.10.8.1
        containers-0.5.7.1
        deepseq-1.4.2.0
        directory-1.3.0.0
        filepath-1.4.1.1
        ghc-8.0.2
        ghc-boot-8.0.2
        ghc-boot-th-8.0.2
        ghc-prim-0.5.0.0
        ghci-8.0.2
        haskeline-0.7.3.0
        hoopl-3.10.2.1
        hpc-0.6.0.3
        integer-gmp-1.0.0.1
        pretty-1.1.3.3
        process-1.4.3.0
        rts-1.0
        template-haskell-2.11.1.0
        terminfo-0.4.0.2
        time-1.6.0.1
        transformers-0.5.2.0
        unix-2.7.2.1
        xhtml-3000.2.1
    /Users/rampion/Projects/shouldnottypecheck-bug/.cabal-sandbox/x86_64-osx-ghc-8.0.2-packages.conf.d
        HUnit-1.6.0.0
        QuickCheck-2.9.2
        ansi-terminal-0.6.2.3
        async-2.1.1.1
        call-stack-0.1.0
        hspec-2.4.3
        hspec-core-2.4.3
        hspec-discover-2.4.3
        hspec-expectations-0.8.2
        primitive-0.6.2.0
        quickcheck-io-0.1.4
        random-1.1
        setenv-0.1.1.3
        should-not-typecheck-2.1.0
        stm-2.4.4.1
        tf-random-0.5
