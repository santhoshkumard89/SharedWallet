//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "./Ownable.sol";

contract Guardian is ownable{

    // ------------------------------------------------------------

    uint maxGuardian = 5;
    uint public guardianCounter;

    struct guardianData{
        address guardian;
        bool isGuardianProposed;
    }
    mapping (uint => guardianData) public guardians;

    modifier isGuardian(address _address){
        require(msg.sender == owner,"Not a Owner");
        (,bool flag) = getIndexGuardian(_address);
        require(flag,"Guardian already Exists!");
        _;
    }

    function getIndexGuardian(address _address) view internal returns(int, bool){
        int index = -1;
        bool flag = true;
        for(uint i=0;i<guardianCounter;i++){
            if(guardians[i].guardian == _address){
                index = int(i);
                flag = false;
            }
        }
        return (index,flag);
    }

    // ------------------------------------------------------------

    function setGuardians(address _address) public isGuardian(_address){
        require(guardianCounter < maxGuardian,"Guardian count cann't more than 5");
        guardians[guardianCounter].guardian = _address;
        guardianCounter++;
    }

    // ------------------------------------------------------------

    function updateGuardians(address _address, uint _index) public isGuardian(_address){
        require(_index < guardianCounter,"Index count cann't more than or equal to guardianCounter");
        guardians[_index].guardian = _address;
    }

    // ------------------------------------------------------------

    function setIsGuardianProposed(address _address) public{
        (int index,) = getIndexGuardian(_address);
        require(index >= 0,"Proposed is not Guardian");
        require(!guardians[uint(index)].isGuardianProposed,"Guardian already Proposed!");
        guardians[uint(index)].isGuardianProposed = true;
    }

    // ------------------------------------------------------------

    function resetAllGuardianProposed() public{
        for(uint i=0;i<guardianCounter;i++){
            if(guardians[uint(i)].isGuardianProposed){
                guardians[uint(i)].isGuardianProposed = false;
            }
        }
    }

    // ------------------------------------------------------------

}