//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Variables.sol";

contract Modifiers is Variables {
    modifier isUser
    {
        require(users[msg.sender] == true, "Not a user");
        _;
    }

    modifier onlyAdmin
    {
        require(msg.sender == admin, "Not an admin");
        _;
    }

    modifier isNotApproved
    (
        uint _id
    )
    {
        require(funds[_id].is_approved == false, "Already approved");
        _;
    }

    modifier isApproved
    (
        uint _id
    )
    {
        require(funds[_id].is_approved == true, "Funds not approved yet");
        _;
    }

    modifier isPoolFilled
    (
        uint _id
    )
    {
        require(!funds[_id].is_filled, "Pool already full");
        _;
    }

    modifier hasUserAppliedForFunding
    (
        address user
    )
    {
        require(has_user_applied[user] == false, "You have already applied for funding");
        _;
    }

    modifier checkNameAlreadyExists
    (
        string memory name
    )
    {
        require(unique_names[name] == false, "Name already exists");
        _;
    }
}