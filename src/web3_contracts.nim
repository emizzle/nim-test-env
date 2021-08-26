import # std libs
  std/[json, strformat, strutils]

import # vendor modules
  chronos, stint, web3

contract(Erc20Contract):
  proc name(): string {.view.}
  proc symbol(): string {.view.}
  proc decimals(): Address {.view.}
  proc totalSupply(): UInt256 {.view.}
  proc balanceOf(
    account: Address
  ): UInt256 {.view.}
  proc transfer(
    recipient: Address,
    amount: UInt256
  ): Bool
  proc allowance(
    owner: Address,
    spender: Address,
  ): UInt256 {.view.}
  proc approve(
    spender: Address,
    amount: UInt256
  ): Bool
  proc transferFrom(
    sendr: Address, # intentional misspelling is to prevent compilation error "attempt to redefine 'sender'"
    recipient: Address,
    amount: UInt256
  ): Bool
  proc increaseAllowance(
    spender: Address,
    addedValue: UInt256
  ): Bool
  proc decreaseAllowance(
    spender: Address,
    subtractedValue: UInt256
  ): Bool

contract(MiniMeContract):
  # uncomment all commented methods once
  # https://github.com/status-im/nim-web3/pull/39 is merged
  # proc MiniMeToken(
  #   tokenFactory: Address,
  #   parentToken: Address,
  #   parentSnapShotBlock: Uint,
  #   tokenName: string,
  #   decimalUnits: Uint8,
  #   tokenSymbol: string,
  #   transfersEnalbed: Bool
  # ) {.constructor.}
  # proc transferFrom(
  #   `from`: Address,
  #   to: Address,
  #   ammount: UInt256
  # ): Bool
  # proc doTransfer(
  #   `from`: Address,
  #   to: Address,
  #   ammount: UInt256
  # ): Bool
  proc balanceOf(
    owner: Address
  ): UInt256 {.view.}
  # proc approve(
  #   spender: Address,
  #   amount: UInt256
  # ): Bool
  proc allowance(
    owner: Address,
    spender: Address
  ): UInt256 {.view.}
  proc approveAndCall(
    spender: Address,
    amount: UInt256,
    extraData: Bytes100
  )
  proc totalSupply(): UInt256 {.view.}
  proc balanceOfAt(
    owner: Address,
    blockNumber: Uint
  ): Uint {.view.}
  proc balanceOfAt(
    blockNumber: Uint
  ): Uint {.view.}
  # proc createCloneToken(
  #   cloneTokenName: Bytes256, # string
  #   cloneDecimalUnits: Uint8,
  #   cloneTokenSymbol: Bytes256, # string
  #   snapshotBlock: Uint,
  #   transfersEnabled: Bool
  # ): Address
  # proc generateTokens(
  #   owner: Address,
  #   amount: Uint
  # ): Bool
  # proc destroyTokens(
  #   owner: Address,
  #   amount: Uint
  # ): Bool
  # proc enableTransfers(
  #   transfersEnabled: Bool
  # )

contract(Erc721Contract):
  proc Erc721Contract(
    name: string,
    symbol: string
  ) {.constructor.}
  proc balanceOf(
    tokenHolder: Address
  ): UInt256 {.view.}
  proc ownerOf(
    tokenId: UInt256
  ): Address {.view.}
  proc name(): string {.view.}
  proc symbol(): string {.view.}
  proc tokenURI(
    tokenId: UInt256
  ): string {.view.}
  proc approve(
    to: Address,
    tokenId: UInt256
  )
  proc getApproved(
    tokenId: UInt256
  ): Address {.view.}
  # proc setApprovalForAll(
  #   owner: Address,
  #   operator: Address
  # ): Bool {.view.}
  # proc isApprovedForAll(
  #   owner: Address,
  #   operator: Address
  # ): Bool {.view.}
  proc transferFrom(
    `from`: Address,
    to: Address,
    tokenId: UInt256
  )
  proc safeTransferFrom(
    `from`: Address,
    to: Address,
    tokenId: UInt256
  )

type
  SntContract = MiniMeContract

proc wei2Eth*(input: Stuint[256], decimals: int = 18): string =
  var one_eth = u256(10).pow(decimals) # fromHex(Stuint[256], "DE0B6B3A7640000")

  var (eth, remainder) = divmod(input, one_eth)
  let leading_zeros = "0".repeat(($one_eth).len - ($remainder).len - 1)

  fmt"{eth}.{leading_zeros}{remainder}"


debugEcho ">> START"
debugEcho Erc20Contract.type
debugEcho MiniMeContract.type
debugEcho Erc721Contract.type
debugEcho SntContract.type

proc go() {.async.} =
  let web3 = await newWeb3("wss://mainnet.infura.io/ws/v3/220a1abb4b6943a093c35d0ce4fb0732")
  let sntAddress = Address.fromHex("0x744d70fdbe2ba4cf95131626614a1763df805b9e")
  var snt = web3.contractSender(SntContract, sntAddress)
  echo "default account: ",web3.defaultAccount
  echo "type of default account: ", type web3.defaultAccount
  # let accounts = await web3.provider.eth_accounts()
  # web3.defaultAccount = accounts[0]
  # snt.sender("0x744d70fdbe2ba4cf95131626614a1763df805b9e").balanceOf(

  # )
  let randomRealAddress = Address.fromHex("0x1062a747393198f70f71ec65a582423dba7e5ab3")
  let balance = await snt.balanceOf(randomRealAddress).call()
  echo "balance: ", wei2Eth balance

waitFor go()