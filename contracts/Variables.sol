//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Funds.sol";

interface Token{
    function mint(address _to, uint _amount) external;
    function burn(address _of, uint _amount) external;
}

contract Variables {
    Token t = Token(0xd9145CCE52D386f254917e481eB44e9943F39138);

    uint internal token_diversity = 10 ** 18;
    uint internal token_impound = 10 ** 3;

    mapping(address => bool) public users;
    address public immutable admin;

    mapping(address => bool) internal has_user_applied;
    mapping(uint => mapping(address => uint)) internal user_pool_liquidity;
    address[] internal temp_investors;

    uint public donations = 0;

    Funds[] internal funds;

    mapping(string => bool) public unique_names;
    mapping(uint => mapping(address => bool)) internal unique_investors_in_pool;

    uint public total_funds = 0;
    uint public completed_funds = 0;
    uint public approved_funds = 0;

    constructor() {
        admin = msg.sender;
    }
}