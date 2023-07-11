//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "./NewOwner.sol";

contract SharedWallet is NewOwner{

    // ------------------------------------------------------------

    uint public contractBalance;

    struct walletBalance{
        uint value;
        uint balance;
    }

    mapping (address=>walletBalance) public wallet;

    event allowanceDetails(
        address indexed _address, 
        uint _amount, 
        uint _balance, 
        string _description
    );

    modifier addressNotOwner(address _address){
        require(_address != owner,"Address should Not be a Owner");
        _;
    }

    // ------------------------------------------------------------

    function setAllowance(address _address, uint _amount) public isOwner addressNotOwner(_address){
        wallet[_address].balance = _amount;
        wallet[_address].value = _amount;

        emit allowanceDetails(
            _address, 
            _amount, 
            wallet[_address].balance, 
            "Set new Allowance"
        );
    }

    // ------------------------------------------------------------

    function increaseAllowance(address _address, uint _amount) public isOwner addressNotOwner(_address){
        wallet[_address].balance += _amount;
        wallet[_address].value = _amount;

        emit allowanceDetails(
            _address, 
            _amount, 
            wallet[_address].balance, 
            "Increased Allowance"
        );
    }

    // ------------------------------------------------------------

    function decreaseAllowance(address _address, uint _amount) public isOwner addressNotOwner(_address){
        require(wallet[_address].balance >= _amount,"Balance is less than amount");
        wallet[_address].balance -= _amount;
        wallet[_address].value = _amount;

        emit allowanceDetails(
            _address, 
            _amount, 
            wallet[_address].balance, 
            "Decreased Allowance"
        );
    }

    // ------------------------------------------------------------

    function transferAllowance(address payable _to, uint _amount) public{
        require(contractBalance >= _amount,"Not sufficient balance in contract!");
        if(msg.sender == owner){
            contractBalance -= _amount;
            _to.transfer(_amount);
        }
        if(wallet[msg.sender].balance >= _amount){
            wallet[msg.sender].balance -= _amount;
            wallet[msg.sender].value = _amount;
            contractBalance -= _amount;
            _to.transfer(_amount);
        }
    }

    // ------------------------------------------------------------

    receive() external payable{
        contractBalance += msg.value;
    }

    // ------------------------------------------------------------

}