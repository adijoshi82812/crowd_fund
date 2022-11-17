//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./Funds.sol";

interface Token{
    function mint(address _to, uint _amount) external;
    function burn(address _of, uint _amount) external;
    function balance_Of(address _account) external view returns(uint);
}

contract Variables {
    AggregatorV3Interface internal priceFeed;
    Token internal t;

    uint internal token_diversity = 10 ** 18;
    uint internal token_impound = 10 ** 3;

    mapping(address => bool) public users;
    address public admin;

    address internal new_owner;
    bool internal accept_ownership;

    mapping(address => bool) internal has_user_applied;
    mapping(uint => mapping(address => uint)) internal user_pool_liquidity;
    address[] internal temp_investors;

    uint public donations = 0;

    Funds[] internal funds;

    mapping(string => bool) public unique_names;
    mapping(uint => mapping(address => bool)) internal unique_investors_in_pool;

    uint public total_funds_raised = 0;
    uint public completed_pools = 0;
    uint public approved_pools = 0;

    constructor() {
        admin = msg.sender;
        new_owner = msg.sender;
        priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        t = Token(0x528070E817Ce9fccc04FA73693b8807035a93642);
    }
}