/***
* 
* Manual test file for testing in Remix
* 
***/

pragma solidity ^0.4.24;


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

contract ValidConstructor {
    uint public myNum = 12;
    bytes32 public myBytes32 = hex"aabbcc";
    
    constructor(uint256 myUint) public {
        myNum = myUint;
    }
    
    function getNum() public view returns (uint256) {
        return myNum;
    }
    
    function setNum(uint256 myUint) public {
        myNum = myUint;
    }
}

contract DeployRawContractsFactory {
    event ContractDeployed(address contractAddress);

    // This function deploys the constructor bytecode part of the "ValidConstructor" smart contract above
    function deployCtorContract()
        public
        returns (address newContract)
    {
        bytes memory contractCode = abi.encodePacked(hex"605d60008181600b9039f36080604052600c6000557faabbcc000000000000000000000000000000000000000000000000000000000060015534801561003957600080fd5b5060405160208061016083398101604052516000556101038061005d6000396000f300");
        
        assembly {
            newContract := create(0, add(contractCode, 0x20), mload(contractCode)) // total length 103 bytes
            if iszero(extcodesize(newContract)) {
                revert(0, 0)
            }
        }
        
        emit ContractDeployed(newContract);
    }

    // This function deploys the runtime bytecode part of the "ValidConstructor" smart contract above
    function deployRuntimeContract()
        public
        returns (address newContract)
    {
        bytes memory contractCode = abi.encodePacked(hex"61010360008181600c9039f3608060405260043610605c5763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416634b3e7e0c8114606157806367e0badb146085578063cd16ecbf146097578063d4da005a1460ae575b600080fd5b348015606c57600080fd5b50607360c0565b60408051918252519081900360200190f35b348015609057600080fd5b50607360c6565b34801560a257600080fd5b5060ac60043560cc565b005b34801560b957600080fd5b50607360d1565b60015481565b60005490565b600055565b600054815600a165627a7a723058202c28dd5354074dd5ef025611754a8cd95f961da794f77b1337056d0cfc6f9dce0029");
        
        assembly {
            newContract := create(0, add(contractCode, 0x20), mload(contractCode)) // total length 103 bytes
            if iszero(extcodesize(newContract)) {
                revert(0, 0)
            }
        }
        
        emit ContractDeployed(newContract);
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