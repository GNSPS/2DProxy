# 2DProxy [WIP]
A Solidity delegate call proxy that also `delegatecall`'s its constructor

## What is this?

This is a successor of the very well known delegate call proxy pattern in the EVM (for which I have created a version in the past: https://gist.github.com/GNSPS/ba7b88565c947cfd781d44cf469c2ddb ).

2DProxy (coming from doing 2 delegate calls, one at deploy time another at runtime 😄) was created with the idea to eliminate the pattern of having to ditch the constructor (and its associated EVM security assurances) and building your own initializing functions with user-set conditions to only run once (v. https://github.com/gnosis/safe-contracts/blob/master/contracts/OwnerManager.sol#L23 ).

This work is all still very rough. Including the horrible bash script I wrote to separate the constructor and runtime parts of a bytecode file resulting from compiling a Solidity file.

## How does it work?

The proxy `delegatecall`'s a previously deployed "constructor master copy" at deploy time and, after setting all the correspondent storage slots, deploys the usual delegate call proxy bytecode with a hardcoded address of the runtime part (like you would normally do with a proxy factory minus the following "setup tx").

Might be easier with an image. 😄

<img src="https://user-images.githubusercontent.com/4008213/44305243-ae3e9d00-a36a-11e8-9871-87e303d83fb6.png">

*Legend*: LC there means "Large Contract"


The way I am dividing a compiled Solidity contract is, very simply, by finding the first occurrence of these two bytes `f300` (`0xf3` being **RETURN** and `0x00` being **STOP**) and then considering the part before (including these bytes) the constructor bytecode and the part after the runtime bytecode. I then prepend a small constructor to each one of these to make them independently deployable to the chain.

*Note*: If you're wondering if `delegatecall`ing the constructor at deploy time and then hitting a `RETURN` on that sub-call messes anything up, it doesn't! 😄🎉

## Why it doesn't work 😂

After starting to work on this I realized that what I wanted to do was not as easy as I had previously thought! 😅

The reason why, in its current form, the 2DProxy can't handle constructors with parameters is that these are not placed in a different data location in the EVM.

To paint a clearer picture:

In a create transaction, the code that is passed through the call data is run (this is deploy time) and whatever is returned from the execution of that bytecode is what gets deployed to the blockchain (the runtime bytecode).
The way parameters are passed onto a constructor is by appending them to the bytecode, at the very end, ABI-encoded and then `codecopy`ed into memory.

Since we have to deploy the constructor bytecode to the blockchain beforehand it is impossible for us, with the method described, to call it with parameters. **When the code tries to `codecopy`** the parameters from the relevant code positions **only zeros are returned since there is nothing over there**! 😂

## How it can work 🙌

The process right now is fairly straightforward and we hardly break any assumptions and assurances being made by the compiler. This is good.

The way to make this compatible with using parameters in the compiler (at least what I was capable of thinking of so far 😄) would be to replace every `codecopy` instruction with a `calldatacopy` one and, obviously, adjust the parameters to this opcode.

Even though this wouldn't be too hard, it would be messier and possibly mess some compiler assurances.

## Asks

* What do you think of the proposed solution? (the `s/codecopy/calldatacopy/` one)
* Can you think of something else? (Hopefully a better solution 😄)

## Usage Tips

**This is so rough that it probably only runs on MacOS** but maybe also in \*NIX machines. 😂 Sorry for that.

To deploy these with Truffle there's the need to use a non-stable version (`truffle@next`) that by the hand of @gnidan now supports external compilers and, basically, our hand-crafted bytecode files.

So do this:

```
npm uninstall -g truffle && npm install -g truffle@next 
```

If you just want to test the 2DProxy on a contract of your own without hacking that much and getting these artifacts deployed automagically just duplicate the file you want proxied into `contracts/2dproxy/`.

And then run:

```
truffle compile
truffle migrate 
```

Two artifacts will then be created for you: `<contract_name>_ctor.json` and `<contract_name>_runtime.json` which can then be imported normally into Truffle deployments/tests like `const <contract_name>_ctor = artifacts.require("<contract_name>_ctor");`. 😄

-----

There are also two relevant scripts in `package.json`: `prepare` & `prepare:optimized`. These are not necessary to test this in a local environment, though, use them just when hacking away!

These can be ran with the path of a Solidity file like `npm run prepare:optimized contracts/NoConstructor.sol NoConstructor` and generate two build files in the folder `2dproxy_build/` called `_ctor.sol.bin` and `_runtime.sol.bin` whose names are pretty self-explanatory.

Behind the curtains these command are running the `2dproxy_extractor.sh` script that you can try and run in the terminal and check the usage help banner for other uses.

-----

```
/***
* 
* PROXY contract (bytecode) [length of 103 bytes]

60008080808073f00df00df00df00df00df00df00df00df00df00d5af481141560255780fd5b60316000818160319039f3600080808080368092803773feedfeedfeedfeedfeedfeedfeedfeedfeedfeed5af43d828181803e808314603057f35bfd

* 
* 2DProxy disassembled (opcodes)

000000: PUSH1 0x00
000002: DUP1
000003: DUP1
000004: DUP1
000005: DUP1
000006: PUSH20 0xf00df00df00df00df00df00df00df00df00df00d  // Placeholder for the deployed constructor bytecode to be called
000027: GAS
000028: DELEGATECALL
000029: DUP2
000030: EQ
000031: ISZERO
000032: PUSH1 0x25
000034: JUMPI
000035: DUP1
000036: REVERT
000037: JUMPDEST
000038: PUSH1 0x31  // 0x31 == 49, which is the length of the runtime bytecode part of this proxy
000040: PUSH1 0x00
000042: DUP2
000043: DUP2
000044: PUSH1 0x31  // 0x31 == 49, which is the length of the constructor part of the bytecode and, therefore, the offset of the runtime part
000046: SWAP1
000047: CODECOPY
000048: RETURN
// ^ Above is the new constructor part of the 2DProxy
// v Below is the old part from a regular delegate call proxy
000049: PUSH1 0x00
000051: DUP1
000052: DUP1
000053: DUP1
000054: DUP1
000055: CALLDATASIZE
000056: DUP1
000057: SWAP3
000058: DUP1
000059: CALLDATACOPY
000060: PUSH20 0xfeedfeedfeedfeedfeedfeedfeedfeedfeedfeed  // Placeholder for the deployed runtime bytecode to be called
000081: GAS
000082: DELEGATECALL
000083: RETURNDATASIZE
000084: DUP3
000085: DUP2
000086: DUP2
000087: DUP1
000088: RETURNDATACOPY
000089: DUP1
000090: DUP4
000091: EQ
000092: PUSH1 0x30
000094: JUMPI
000095: RETURN
000096: JUMPDEST
000097: REVERT

* 
***/
```