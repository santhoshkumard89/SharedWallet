//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

contract ownable{
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    modifier isOwner{
        require(msg.sender == owner,"Not a Owner");
        _;
    }

}