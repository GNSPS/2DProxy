/***
* Made with ❤️ by @GNSPS
* 
* Multi-proxy factory design borrowed from
* https://gist.github.com/GNSPS/ba7b88565c947cfd781d44cf469c2ddb/edit
* 
***/

pragma solidity 0.4.24;


contract TwoDeeProxyFactory {
    event ProxyDeployed(address proxyAddress, address _constructorAddress, address _runtimeAddress);
    event ProxiesDeployed(address[] proxyAddresses, address _constructorAddress, address _runtimeAddress);

    function createManyProxies(uint256 _count, address _constructorAddress, address _runtimeAddress)
        external
    {
        address[] memory proxyAddresses = new address[](_count);

        for (uint256 i = 0; i < _count; ++i) {
            proxyAddresses[i] = _createProxy(_constructorAddress, _runtimeAddress);
        }

        emit ProxiesDeployed(proxyAddresses, _constructorAddress, _runtimeAddress);
    }

    function createProxy(address _constructorAddress, address _runtimeAddress)
        external
        returns (address proxyContract)
    {
        proxyContract = _createProxy(_constructorAddress, _runtimeAddress);

        emit ProxyDeployed(proxyContract, _constructorAddress, _runtimeAddress);
    }
    
    function _createProxy(address _constructorAddress, address _runtimeAddress)
        internal
        returns (address proxyContract)
    {
        bytes memory proxyCode = abi.encodePacked(hex"60008080808073", _constructorAddress, hex"5af481141560255780fd5b60316000818160319039f3600080808080368092803773", _runtimeAddress, hex"5af43d828181803e808314603057f35bfd");
        
        assembly {
            proxyContract := create(0, add(proxyCode, 0x20), 103) // total length 103 bytes
            if iszero(extcodesize(proxyContract)) {
                revert(0, 0)
            }
        }
    }
}


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