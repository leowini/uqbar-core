::  fungible.hoon tests
/-  zink
/+  *test, smart=zig-sys-smart, *sequencer, merk, ethereum
/+  fun=zig-contracts-lib-fungible
/*  smart-lib-noun  %noun  /lib/zig/compiled/smart-lib/noun
/*  zink-cax-noun   %noun  /lib/zig/compiled/hash-cache/noun
/*  zigs-contract   %noun  /lib/zig/compiled/zigs/noun
/*  fung-contract   %noun  /lib/zig/compiled/fungible/noun
|%
::
::  constants / dummy info for mill
::
++  big  (bi:merk id:smart grain:smart)  ::  merkle engine for granary
++  pig  (bi:merk id:smart @ud)          ::                for populace
++  batch-num  1
++  town-id    0x2
++  rate    1
++  budget  100.000
++  fake-sig   [0 0 0]
++  mil
  %~  mill  mill
  :+    ;;(vase (cue q.q.smart-lib-noun))
    ;;((map * @) (cue q.q.zink-cax-noun))
  %.y
::
+$  granary   (merk:merk id:smart grain:smart)
+$  mill-result
  [fee=@ud =land burned=granary =errorcode:smart hits=(list hints:zink) =crow:smart]
++  gilt
  ::  grains list to granary
  |=  grz=(list grain:smart)
  (gas:big *granary (turn grz |=(g=grain:smart [id.p.g g])))
::
::  fake data
::
++  miller    ^-  caller:smart  [0x1512.3341 1 0x1.1512.3341]
++  caller-1  ^-  caller:smart  [0xbeef 1 0x1.beef]
++  caller-2  ^-  caller:smart  [0xdead 1 0x1.dead]
++  caller-3  ^-  caller:smart  [0xcafe 1 0x1.cafe]
::
++  zigs
  |%
  ++  zig-account
    |=  [holder=id:smart amt=@ud]
    ^-  grain:smart
    =/  sal  `@`'zigsalt'
    =/  id  (fry-rice:smart zigs-wheat-id:smart holder town-id sal)
    :*  %&  sal  %account
        [amt ~ `@ux`'zigs']
        id
        zigs-wheat-id:smart
        holder
        town-id
    ==
  ++  miller-account
    ^-  grain:smart
    :*  %&
        `@`'zigs'
        %account
        [1.000.000 ~ `@ux`'zigs-metadata']
        0x1.1512.3341
        zigs-wheat-id:smart
        0x1512.3341
        town-id
    ==
  ++  wheat
    :: todo does mill:mill depend on this existing
    ^-  grain:smart
    =/  cont  ;;([bat=* pay=*] (cue q.q.zigs-contract))
    =/  interface=lumps:smart  ~
    =/  types=lumps:smart  ~
    :*  %|
        `cont
        interface
        types
        zigs-wheat-id:smart  ::  id
        zigs-wheat-id:smart  ::  lord
        zigs-wheat-id:smart  ::  holder
        town-id
    ==
  --
::
::
::
::  N.B. owner zigs ids must match the ones generated in `+zig-account`
++  fun-account
  |=  [holder=id:smart amt=@ud meta=(unit @ux) allowances=(map address:smart @ud)]
  ::  meta - metadata of the fungible account. defaults to `@ux`'simple' unless provided
  ^-  grain:smart
  =/  meta-id  ?~(meta `@ux`'simple-metadata-1' u.meta)
  =*  sal      meta-id
  =/  id  (fry-rice:smart id.p:fungible-wheat holder town-id sal)
  :*  %&  sal  %account
      `account:sur:fun`[amt allowances meta-id 0]
      id
      id.p:fungible-wheat
      holder
      town-id
  ==
++  priv-1  0xbeef.beef.beef.beef.beef.beef.beef.beef.beef.beef
++  pub-1   (address-from-prv:key:ethereum priv-1)
++  owner-1  ::  previously 0x1.beef
  ^-  caller:smart
  [pub-1 0 (fry-rice:smart zigs-wheat-id:smart pub-1 town-id `@`'zigsalt')]
++  account-1
  (fun-account pub-1 50 ~ ~)
::
++  priv-2  0xdead.dead.dead.dead.dead.dead.dead.dead.dead.dead
++  pub-2   (address-from-prv:key:ethereum priv-2)
++  owner-2
  ^-  caller:smart
  [pub-2 0 (fry-rice:smart zigs-wheat-id:smart pub-2 town-id `@`'zigsalt')]
++  account-2  ::  previously 0x1.dead
  (fun-account pub-2 30 ~ ~)
::
++  priv-3  0xcafe.cafe.cafe.cafe.cafe.cafe.cafe.cafe.cafe.cafe
++  pub-3   (address-from-prv:key:ethereum priv-3)
++  owner-3
  ^-  caller:smart
  [pub-3 0 (fry-rice:smart zigs-wheat-id:smart pub-3 town-id `@`'zigsalt')]
++  account-3  :: previously 0x1.cafe
  (fun-account pub-3 20 ~ (malt ~[[0xffff 100]]))
++  account-4
  (fun-account 0xface 20 ``@ux`'different meta' ~)
++  account-1-mintable
  (fun-account pub-1 50 ``@ux`'simple-mintable' ~)
++  account-2-mintable
  (fun-account pub-2 50 ``@ux`'simple-mintable' ~)
::
++  fungible-wheat
  ^-  grain:smart
  =/  cont  ;;([bat=* pay=*] (cue q.q.fung-contract))
  =/  interface=lumps:smart  ~
  =/  types=lumps:smart      ~
  :*  %|
      `cont
      interface
      types
      id=`@ux`'fungible'
      lord=`@ux`'fungible'
      holder=`@ux`'fungible'
      town-id
  ==
++  metadata-1
  ^-  grain:smart
  :*  %&  `@`'salt'  %metadata
      ^-  token-metadata:sur:fun
      :*  name='Simple Token'
          symbol='ST'
          decimals=0
          supply=100
          cap=~
          mintable=%.n
          minters=~
          deployer=0x0
          salt=`@`'salt'
      ==
      `@ux`'simple-metadata-1'
      id.p:fungible-wheat
      id.p:fungible-wheat
      town-id
  ==
++  metadata-mintable
  ^-  grain:smart
  :*  %&  `@`'salt'  %metadata
      ^-  token-metadata:sur:fun
      :*  name='Simple Token Mintable'
          symbol='STM'
          decimals=0
          supply=100
          cap=`1.000
          mintable=%.y
          minters=(silt ~[pub-1])
          deployer=0x0
          salt=`@`'salt'
      ==
      `@ux`'simple-mintable'
      id.p:fungible-wheat
      id.p:fungible-wheat
      town-id
  ==
::
::
::
++  fake-granary
  ^-  granary
  %-  gilt
  :~  fungible-wheat
      metadata-1
      metadata-mintable
      account-1
      account-2
      account-3
      account-4
      account-1-mintable
      account-2-mintable
      (zig-account:zigs holder.p:account-1 999.999)
      (zig-account:zigs holder.p:account-2 999.999)
      (zig-account:zigs holder.p:account-3 999.999)
      (zig-account:zigs 0xffff 999.999)
      ::miller-account:zigs
      ::wheat:zigs
  ==
++  fake-populace
  ^-  populace
  %+  gas:pig  *(merk:merk id:smart @ud)
  :~  [pub-1 0]
      [pub-2 0]
      [pub-3 0]
  ==
++  fake-land
  ^-  land
  [fake-granary fake-populace]
::
++  test-set-allowance
  ^-  tang
  =/  =action:sur:fun  [%set-allowance id.p:account-1 id:owner-3 10]
  =/  shel=shell:smart
    [[id +(nonce) zigs]:owner-1 ~ id.p:fungible-wheat rate budget town-id 0]
  =/  updated-1=grain:smart
    (fun-account pub-1 50 ~ (malt ~[[id:owner-3 10]]))
  =/  milled=mill-result
    %+  ~(mill mil miller town-id 1)
    fake-land  `egg:smart`[fake-sig shel action]
  =/  res=grain:smart  (got:big p.land.milled id.p:account-1)
  =*  correct  updated-1
  (expect-eq !>(correct) !>(res))
::
::  %give
::
++  test-give-known-receiver
  ^-  tang
  =/  =action:sur:fun
    [%give id.p:account-1 pub-2 `id.p:account-2 30]
  =/  shel=shell:smart
    [[id +(nonce) zigs]:owner-1 ~ id.p:fungible-wheat rate budget town-id 0]
  =/  updated-1=grain:smart  (fun-account pub-1 20 ~ ~)
  =/  updated-2=grain:smart  (fun-account pub-2 60 ~ ~)
  =/  milled=mill-result
    %+  ~(mill mil miller town-id 1)
    fake-land  `egg:smart`[fake-sig shel action]
  =/  expected=granary  (gas:big *granary ~[[id.p:updated-1 updated-1] [id.p:updated-2 updated-2]])
  ::  filter out any grains whose keys are not in expected
  =/  res=granary       (int:big expected p.land.milled)
  (expect-eq !>(expected) !>(res))
++  test-give-unknown-receiver
  ^-  tang
  =/  =action:sur:fun  [%give id.p:account-1 0xffff ~ 30]
  =/  shel=shell:smart
    [[id +(nonce) zigs]:owner-1 ~ id.p:fungible-wheat rate budget town-id 0]
  =/  new-id  (fry-rice:smart id.p:fungible-wheat 0xffff town-id `@`'simple-metadata-1')
  =/  new=grain:smart  (fun-account 0xffff 30 ~ ~)
  =/  milled=mill-result
    %+  ~(mill mil miller town-id 1)
    fake-land  `egg:smart`[fake-sig shel action]
  =/  res=grain:smart  (got:big p.land.milled new-id)
  =*  correct  new
  (expect-eq !>(correct) !>(res))
++  test-give-not-enough
  ^-  tang
  =/  =action:sur:fun  [%give id.p:account-1 pub-2 `id.p:account-2 51]
  =/  shel=shell:smart
    [[id +(nonce) zigs]:owner-1 ~ id.p:fungible-wheat rate budget town-id 0]
  =/  milled=mill-result
    %+  ~(mill mil miller town-id 1)
    fake-land  `egg:smart`[fake-sig shel action]
  (expect-eq !>(%6) !>(errorcode.milled))
++  test-give-metadata-mismatch
  ^-  tang
  =/  =action:sur:fun  [%give id.p:account-1 0xface `id.p:account-4 10]
  =/  shel=shell:smart
    [[id +(nonce) zigs]:owner-1 ~ id.p:fungible-wheat rate budget town-id 0]
  =/  milled=mill-result
    %+  ~(mill mil miller town-id 1)
    fake-land  `egg:smart`[fake-sig shel action]
  (expect-eq !>(%6) !>(errorcode.milled))
::
:: %take
::
++  test-take-send-new-account
  ::  TODO doesn't crash anymore but still fails
  ^-  tang
  =/  =action:sur:fun  [%take 0xffff ~ id.p:account-3 10]
  =/  shel=shell:smart
    =+  zigs=(fry-rice:smart zigs-wheat-id:smart 0xffff town-id `@`'zigsalt')
    [[0xffff 1 zigs] ~ id.p:fungible-wheat rate budget town-id 0]
  =/  new-id=id:smart  (fry-rice:smart id.p:fungible-wheat 0xffff town-id `@ux`'simple-metadata-1')
  =/  new=grain:smart  (fun-account 0xffff 10 ~ ~)
  =/  milled=mill-result
    %+  ~(mill mil miller town-id 1)
    fake-land  `egg:smart`[fake-sig shel action]
  =/  res=grain:smart  (got:big p.land.milled new-id)
  =*  correct  new
  (expect-eq !>(correct) !>(res))
++  test-mint-known-receivers
  ^-  tang

  =/  =action:sur:fun
    [%mint pub-1 `@ux`'simple-mintable' (silt ~[[pub-1 `id.p:account-1-mintable 50] [pub-2 `id.p:account-2-mintable 10]])]
  =/  shel=shell:smart
    [[id +(nonce) zigs]:owner-1 ~ id.p:fungible-wheat rate budget town-id 0]
  =/  new-simp-meta=grain:smart
    :*  %&  `@`'salt'  %metadata
        ^-  token-metadata:sur:fun
        :*  name='Simple Token Mintable'
            symbol='STM'
            decimals=0
            supply=160
            cap=`1.000
            mintable=%.n
            minters=(silt ~[pub-1])
            deployer=0x0
            salt=`@`'salt'
        ==
        `@ux`'simple-mintable'
        id.p:fungible-wheat
        id.p:fungible-wheat
        town-id
    ==
  =/  updated-1=grain:smart
    (fun-account pub-1 100 ``@ux`'simple-mintable' ~)

  =/  updated-2=grain:smart
    (fun-account pub-2 60 ``@ux`'simple-mintable' ~)
  =/  milled=mill-result
    %+  ~(mill mil miller town-id 1)
    fake-land  `egg:smart`[fake-sig shel action]
  =/  expected=granary  (gilt ~[new-simp-meta updated-1 updated-2])
  =/  res=granary       (int:big expected p.land.milled)
  (expect-eq !>(expected) !>(res))
::::
::::
::::  %deploy
::::
::++  test-deploy
::  ::  XX this test will never run to completion until tap:in is jetted
::  ^-  tang
::  =/  token-salt  (sham (cat 3 pub-1 'TC'))
::  =/  new-token-metadata=grain:smart
::    :*  %&  token-salt  %metadata
::        ^-  token-metadata:sur:fun
::        :*  'Test Coin'
::            'TC'
::            0
::            900
::            `1.000
::            %.y
::            (silt ~[pub-1])
::            pub-1
::            token-salt
::        ==
::        (fry-rice:smart id.p:fungible-wheat id.p:fungible-wheat town-id token-salt)
::        id.p:fungible-wheat
::        id.p:fungible-wheat
::        town-id
::    ==
::  =/  new-account=grain:smart
::    :*  %&  token-salt  %account
::        ^-  account:sur:fun
::        :*  900
::            ~
::            id.p.new-token-metadata
::            0
::        ==
::        (fry-rice:smart id.p:fungible-wheat pub-1 town-id token-salt)
::        id.p:fungible-wheat
::        pub-1
::        town-id
::    ==
::  =/  =action:sur:fun
::    [%deploy (silt ~[[pub-1 900]]) (silt ~[pub-1]) 'Test Coin' 'TC' 0 1.000 %.y]
::  =/  shel=shell:smart
::    [[id +(nonce) zigs]:owner-1 ~ id.p:fungible-wheat rate budget town-id 0]
::  =/  milled=mill-result
::    %+  ~(mill mil miller town-id 1)
::    fake-land  `egg:smart`[fake-sig shel action]
::  =/  expected=granary  (gilt ~[new-account new-token-metadata])
::  =/  res=granary       (int:big expected p.land.milled)
::  (expect-eq !>(expected) !>(res))
--