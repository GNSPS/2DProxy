/***
* 
* Smart Contract with set state variables but no constructor
* 
***/

pragma solidity ^0.4.24;


contract NoConstructor {
    uint public myNum = 12;
    bytes32 public myBytes32 = hex"aabbcc";
    
    function getNum() public view returns (uint256) {
        return myNum;
    }
    
    function setNum(uint256 myUint) public returns (uint256) {
        myNum = myUint;
    }
}
