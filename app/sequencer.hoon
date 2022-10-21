::  sequencer [UQ| DAO]
::
::  Agent for managing a single UQ| shard. Publishes diffs to rollup.hoon
::  Accepts transactions and batches them periodically as moves to shard.
::
/-  uqbar=zig-uqbar
/+  default-agent, dbug, verb,
    *zig-sequencer, *zig-rollup,
    zink=zink-zink, sig=zig-sig
::  Choose which library smart contracts are executed against here
::
/*  smart-lib-noun  %noun  /lib/zig/sys/smart-lib/noun
/*  zink-cax-noun   %noun  /lib/zig/sys/hash-cache/noun
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      rollup=(unit ship)  ::  replace in future with ETH/starknet contract address
      private-key=(unit @ux)
      shard=(unit shard)  ::  state
      =mempool
      peer-roots=(map shard=@ux root=@ux)  ::  track updates from rollup
      proposed-batch=(unit [num=@ud =memlist =chain diff-hash=@ux root=@ux])
      status=?(%available %off)
  ==
+$  inflated-state-0  [state-0 =eng smart-lib-vase=vase]
+$  eng  $_  ~(engine engine !>(0) *(map * @) %.y)
--
::
=|  inflated-state-0
=*  state  -
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  =/  smart-lib=vase  ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  =-  `this(state [[%0 ~ ~ ~ ~ ~ ~ %off] - smart-lib])
  %~  engine  engine
  [smart-lib ;;((map * @) (cue +.+:;;([* * @] zink-cax-noun))) %.y]
::
++  on-save  !>(-.state)
++  on-load
  |=  =old=vase
  ::  on-load: pre-cue our compiled smart contract library
  =/  smart-lib=vase  ;;(vase (cue +.+:;;([* * @] smart-lib-noun)))
  =/  eng
    %~  engine  engine
    [smart-lib ;;((map * @) (cue +.+:;;([* * @] zink-cax-noun))) %.y]
  `this(state [!<(state-0 old-vase) eng smart-lib])
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?.  =(%available status.state)
    ~|("%sequencer: error: got watch while not active" !!)
  ::  open: anyone can watch
  ::  ?>  (allowed-participant [src our now]:bowl)
  ?.  ?=([%indexer %updates ~] path)
    ~|("%sequencer: rejecting %watch on bad path" !!)
  ::  handle indexer watches here -- send latest state
  ?~  shard  `this
  :_  this
  =-  [%give %fact ~ %sequencer-indexer-update -]~
  !>(`indexer-update`[%update (rear roots.hall.u.shard) ~ u.shard])
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?.  ?=(%sequencer-shard-action mark)
    ~|("%sequencer: error: got erroneous %poke" !!)
  ?>  (allowed-participant [src our now]:bowl)
  =^  cards  state
    (handle-poke !<(shard-action vase))
  [cards this]
  ::
  ++  handle-poke
    |=  act=shard-action
    ^-  (quip card _state)
    ?-    -.act
    ::
    ::  shard administration
    ::
        %init
      ?>  =(src.bowl our.bowl)
      ?.  =(%off status.state)
        ~|("%sequencer: already active" !!)
      ::  poke rollup ship with params of new shard
      ::  (will be rejected if id is taken)
      =/  =chain  ?~(starting-state.act [~ ~] u.starting-state.act)
      =/  new-root  `@ux`(sham chain)
      =/  =^shard
        :-  chain
        :*  shard-id.act
            batch-num=0
            [address.act our.bowl]
            mode.act
            0x0
            [new-root]~
        ==
      =/  sig
        (ecdsa-raw-sign:secp256k1:secp:crypto `@uvI`new-root private-key.act)
      :_  %=  state
            rollup       `rollup-host.act
            private-key  `private-key.act
            shard         `shard
            status        %available
            proposed-batch  `[0 ~ chain.shard 0x0 new-root]
          ==
      :~  [%pass /sub-rollup %agent [rollup-host.act %rollup] %watch /peer-root-updates]
          =+  [%rollup-action !>([%launch-shard address.act sig shard])]
          [%pass /batch-submit/(scot %ux new-root) %agent [rollup-host.act %rollup] %poke -]
      ==
    ::
        %clear-state
      ?>  =(src.bowl our.bowl)
      ~&  >>  "sequencer: wiping state"
      `state(rollup ~, private-key ~, shard ~, mempool ~, peer-roots ~, status %off)
    ::
    ::  handle bridged assets from rollup
    ::
        %receive-assets
      ::  uncritically absorb assets bridged from rollup
      ?>  =(src.bowl (need rollup.state))
      ?.  =(%available status.state)
        ~|("%sequencer: error: got asset while not active" !!)
      ?~  shard.state  !!
      ~&  >>  "%sequencer: received assets from rollup: {<assets.act>}"
      `state(shard `u.shard(p.chain (uni:big:engine p.chain.u.shard.state assets.act)))
    ::
    ::  transactions
    ::
        %receive
      ?.  =(%available status.state)
        ~|("%sequencer: error: got transaction while not active" !!)
      =/  received=^mempool
        %-  ~(run in txns.act)
        |=  t=transaction:smart
        [`@ux`(sham +.t) t]
      ::  give a "receipt" to sender, with signature they can show
      ::  a counterparty for "business finality"
      :_  state(mempool (~(uni in mempool) received))
      %+  turn  ~(tap in received)
      |=  [hash=@ux =transaction:smart]
      ^-  card
      =/  usig  (ecdsa-raw-sign:secp256k1:secp:crypto `@uvI`hash (need private-key.state))
      =+  [%uqbar-write !>(`write:uqbar`[%receipt hash (sign:sig our.bowl now.bowl hash) usig])]
      [%pass /submit-transaction/(scot %ux hash) %agent [src.bowl %uqbar] %poke -]
    ::
    ::  batching
    ::
        %trigger-batch
      ?>  =(src.bowl our.bowl)
      ::  fetch latest ETH block height and perform batch
      =/  tid  `@ta`(cat 3 'thread_' (scot %uv (sham eny.bowl)))
      =/  ta-now  `@ta`(scot %da now.bowl)
      =/  start-args  [~ `tid byk.bowl(r da+now.bowl) %sequencer-get-block-height !>(~)]
      :_  state
      :~
        [%pass /thread/[ta-now] %agent [our.bowl %spider] %watch /thread-result/[tid]]
        [%pass /thread/[ta-now] %agent [our.bowl %spider] %poke %spider-start !>(start-args)]
      ==
    ::
        %perform-batch
      ?>  =(src.bowl our.bowl)
      ?.  =(%available status.state)
        ~|("%sequencer: error: got poke while not active" !!)
      ?~  shard.state
        ~|("%sequencer: error: no state" !!)
      ?~  rollup.state
        ~|("%sequencer: error: no known rollup host" !!)
      ?~  mempool.state
        ~|("%sequencer: no transactions to include in batch" !!)
      =*  shard  u.shard.state
      ?:  ?=(%committee -.mode.hall.shard)
        ::  TODO data-availability committee
        ::
        ~|("%sequencer: error: DAC not implemented" !!)
      ::  publish full diff data
      ::
      ::  1. produce diff and new state with engine
      =/  batch-num  batch-num.hall.shard
      =/  addr  p.sequencer.hall.shard
      =+  /(scot %p our.bowl)/wallet/(scot %da now.bowl)/account/(scot %ux addr)/(scot %ux shard-id.hall.shard)/noun
      =+  .^(caller:smart %gx -)
      =/  [new=state-transition rejected=memlist]
        %^    ~(run eng - shard-id.hall.shard batch-num eth-block-height.act)
            chain.shard
          mempool.state
        256  ::  number of parallel "passes"
      =/  new-root       `@ux`(sham chain.new)
      =/  diff-hash      `@ux`(sham ~[state-diff.new])
      =/  new-batch-num  +(batch-num.hall.shard)
      ::  2. generate our signature
      ::  (address sig, that is)
      ?~  private-key.state
        ~|("%sequencer: error: no signing key found" !!)
      =/  sig
        (ecdsa-raw-sign:secp256k1:secp:crypto `@uvI`new-root u.private-key.state)
      ::  3. poke rollup
      ::  return rejected (not enough passes to cover them) to our mempool
      :_  %=  state
            mempool  (silt rejected)
            proposed-batch  `[new-batch-num processed.new chain.new diff-hash new-root]
          ==
      =-  [%pass /batch-submit/(scot %ux new-root) %agent [u.rollup.state %rollup] %poke -]~
      :-  %rollup-action
      !>  :-  %receive-batch
          :-  addr
          ^-  batch
          :*  shard-id.hall.shard
              new-batch-num
              mode.hall.shard
              ~[state-diff.new]
              diff-hash
              new-root
              chain.new
              peer-roots.state
              sig
          ==
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  |^
  ?+    wire  (on-agent:def wire sign)
      [%batch-submit @ ~]
    ?:  ?=(%poke-ack -.sign)
      ?~  p.sign
        ~&  >>  "%sequencer: batch approved by rollup"
        ?~  proposed-batch
          ~|("%sequencer: error: received batch approval without proposed batch" !!)
        =/  new-shard=(unit ^shard)
          (transition-state shard u.proposed-batch)
        :_  this(shard new-shard, proposed-batch ~, mempool ~)
        =-  [%give %fact ~[/indexer/updates] %sequencer-indexer-update -]~
        !>(`indexer-update`[%update root.u.proposed-batch memlist.u.proposed-batch (need new-shard)])
      ::  TODO manage rejected moves here
      ~&  >>>  "%sequencer: our move was rejected by rollup!"
      ~&  u.p.sign
      `this(proposed-batch ~)
    `this
  ::
      [%sub-rollup ~]
    ?:  ?=(%kick -.sign)
      :_  this  ::  attempt to re-sub
      [%pass wire %agent [src.bowl %rollup] %watch (snip `path`wire)]~
    ?.  ?=(%fact -.sign)  `this
    =^  cards  state
      (update-fact !<(shard-update q.cage.sign))
    [cards this]
  ::
      [%thread @ ~]
    ?+    -.sign  (on-agent:def wire sign)
        %fact
      ?+    p.cage.sign  (on-agent:def wire sign)
          %thread-fail
        =/  err  !<  (pair term tang)  q.cage.sign
        %-  (slog leaf+"%sequencer: get-eth-block thread failed: {(trip p.err)}" q.err)
        `this
          %thread-done
        =/  height=@ud  !<(@ud q.cage.sign)
        ~&  >  "eth-block-height: {<height>}"
        :_  this
        =-  [%pass /perform %agent [our.bowl %sequencer] %poke -]~
        [%sequencer-shard-action !>(`shard-action`[%perform-batch height])]
      ==
    ==
  ::
  ==
  ::
  ++  update-fact
    |=  upd=shard-update
    ^-  (quip card _state)
    ?-    -.upd
        %new-peer-root
      ::  update our local map
      `state(peer-roots (~(put by peer-roots.state) shard.upd root.upd))
    ::
        %new-sequencer
      ::  check if we have been kicked off our shard
      ::  this is in place for later..  TODO expand this functionality
      ?~  shard.state                          `state
      ?.  =(shard.upd shard-id.hall.u.shard)  `state
      ?:  =(who.upd our.bowl)                 `state
      ~&  >>>  "%sequencer: we've been kicked out of shard!"
      `state
    ==
  --
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  ^-  (quip card _this)
  (on-arvo:def wire sign-arvo)
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%status ~]
    ``noun+!>(status)
  ::
      [%shard-id ~]
    ?~  shard  ``noun+!>(~)
    ``noun+!>(`shard-id.hall.u.shard)
  ::
      [%mempool-size ~]
    ::  returns number of transactions in mempool
    ``noun+!>(`@ud`~(wyt in mempool))
  ::
  ::  state reads fail if sequencer not active
  ::
      [%has @ ~]
    ::  see if grain exists in state
    =/  id  (slav %ux i.t.t.path)
    ?~  shard  [~ ~]
    ``noun+!>((~(has by p.chain.u.shard) id))
  ::
      [%get-action @ @ ~]
    ::  return lump interface from contract on-chain
    =/  id   (slav %ux i.t.t.path)
    =/  act  (slav %tas i.t.t.t.path)
    ?~  shard  [~ ~]
    ?~  g=(get:big p.chain.u.shard id)
      ::  contract not found in state
      ``noun+!>(~)
    ?.  ?=(%| -.u.g)
      ::  found ID isn't a contract
      ``noun+!>(~)
    ?~  action=(~(get by interface.p.u.g) act)
      ::  contract doesn't have lump for that action
      ``noun+!>(~)
    ``noun+!>(u.action)
  ::
      [%get-type @ @ ~]
    ::  return lump rice type from contract on-chain
    =/  id     (slav %ux i.t.t.path)
    =/  label  (slav %tas i.t.t.t.path)
    ?~  shard  [~ ~]
    ?~  g=(get:big p.chain.u.shard id)
      ::  contract not found in state
      ``noun+!>(~)
    ?.  ?=(%| -.u.g)
      ::  found ID isn't a contract
      ``noun+!>(~)
    ?~  typ=(~(get by types.p.u.g) label)
      ::  contract doesn't have lump for that rice label
      ``noun+!>(~)
    ``noun+!>(u.typ)
  ::
      [%grain @ ~]
    ?~  shard  [~ ~]
    (read-grain t.path p.chain.u.shard)
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
