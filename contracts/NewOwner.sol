// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "./Guardian.sol";

contract NewOwner is Guardian{

    address newOwner;

    uint maxProposedGuardianCount = 3;
    uint proposedGuardianCounter;

    function setNewOwner(address _newOwner) public{
        require(_newOwner != owner,"He is already an Owner!");
        if (newOwner!=_newOwner){
            newOwner = _newOwner;
            resetAllGuardianProposed();
            proposedGuardianCounter = 0;
        }
        setIsGuardianProposed(msg.sender);
        proposedGuardianCounter++;

        if(proposedGuardianCounter >= maxProposedGuardianCount){
            owner = _newOwner;
        }
    }
}