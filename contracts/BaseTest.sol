// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract BaseTest{
    // this is solidity test 

    using Math for uint256;

    event Transfer(address indexed from,address indexed to,uint amount);

    error NullExcption(string name);

    modifier onlyOwner{
        require(owner==msg.sender,"only own can use the function");
        _;
    }

    enum State{
        HasOwner,
        NoOwner
    }

    struct Person{
        address account;
        string name;
    }

    Person[] persons;

    address private owner;
    string public symbol;
    mapping(address=>uint256) accounts;

    constructor() payable{
        owner = msg.sender;
    }    

    function withDraw(uint256 _amount) external onlyOwner returns(bool result){
        uint256 amount = accounts[msg.sender];
        
        require(amount>=_amount);
        (bool action,uint256 result) = amount.trySub(_amount);
        
        require(action);

        accounts[msg.sender] = result;

        return true;
    }

    receive() external payable{
        emit Transfer(msg.sender, owner, msg.value);
    }
}