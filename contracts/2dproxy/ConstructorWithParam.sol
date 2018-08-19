/***
* 
* Smart Contract with a valid constructor accepting a parameter
* 
***/

pragma solidity ^0.4.24;


contract ConstructorWithParam {
    uint public myNum = 12;
    bytes32 public myBytes32 = hex"aabbcc";
    
    constructor(uint256 myUint) public {
        myNum = myUint;
    }
    
    function getNum() public view returns (uint256) {
        return myNum;
    }
    
    function setNum(uint256 myUint) public returns (uint256) {
        myNum = myUint;
    }
}
