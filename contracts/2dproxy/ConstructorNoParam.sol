/***
* 
* Smart Contract with a valid constructor setting a state variable
* 
***/

pragma solidity ^0.4.24;


contract ConstructorNoParam {
    uint public myNum = 12;
    bytes32 public myBytes32 = hex"aabbcc";
    
    constructor() public {
        myNum = 73;
    }
    
    function getNum() public view returns (uint256) {
        return myNum;
    }
    
    function setNum(uint256 myUint) public returns (uint256) {
        myNum = myUint;
    }
}
