//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./OpenZeppelin/ERC20/ERC20.sol";

contract CrowdFund {
    ERC20 private token;

    uint public donations = 0;
    uint public funds_approved = 0;
    uint public total_requests = 0;
    uint public funded_pools = 0;

    address private immutable owner;
    mapping(address => bool) public users;
    struct Pools {
        uint id;
        string name;
        address admin;
        address[] investors;
        uint funds_asked;
        uint funds_received;
        bool is_approved;
        bool is_filled;
        bool is_valid;
    }
    Pools[] public pools;
    uint public pools_count = 0;
    mapping(string => bool) public unique_names;
    address[] private temp_investors;
    mapping(address => bool) public has_user_created_pool;
    mapping(uint => mapping(address => uint)) private user_specific_pool_investment;
    mapping(uint => mapping(address => bool)) private is_user_in_pool;
    mapping(uint => mapping(address => uint)) private user_in_pool_at_index;

    constructor() {
        require(msg.sender != address(0), "Cannot deploy contract from address 0");

        token = new ERC20("Crowd Fund Token", "CPT", address(this));
        owner = msg.sender;
    }

    receive() external payable {
        donations += msg.value;
        (bool success, ) = payable(owner).call{value: msg.value}("");
        require(success, "Cannot donate");
    }

    function get_token_address() external view returns(address) {
        return address(token);
    }

    function contract_call() external {
        require(!users[msg.sender], "Already a user");
        users[msg.sender] = true;
    }

    function create_fund_request(string memory _name, uint _amount) external {
        require(users[msg.sender], "Not a user");
        require(!has_user_created_pool[msg.sender], "You have already created a pool");
        require(!unique_names[_name], "Try different name");
        
        Pools memory pool = Pools({
            id: pools_count,
            name: _name,
            admin: msg.sender,
            investors: temp_investors,
            funds_asked: _amount,
            funds_received: 0,
            is_approved: false,
            is_filled: false,
            is_valid: true
        });

        pools.push(pool);
        unique_names[_name] = true;
        has_user_created_pool[msg.sender] = true;
        pools_count += 1;
        total_requests += 1;
    }

    function approve_fund_request(uint _id) external {
        require(msg.sender == owner, "Only callable by the owner");
        require(pools[_id].is_valid, "Pools not valid");
        require(!pools[_id].is_approved, "Already approved");

        pools[_id].is_approved = true;
        funds_approved += 1;
    }

    function invest_in_pool(uint _id) external payable {
        require(users[msg.sender], "Not a user");
        require(_id < pools_count, "Enter a valid pools id");
        require(msg.sender != pools[_id].admin, "Admins cannot fund");
        require(msg.value <= pools[_id].funds_asked - pools[_id].funds_received, "Overflow");
        require(pools[_id].is_approved, "This pool is not yet approved");
        require(!pools[_id].is_filled, "This pools is filled");
        require(pools[_id].is_valid, "Pool not valid");
        require(payable(msg.sender).balance > 0, "You don't have enough balance");

        if(!is_user_in_pool[_id][msg.sender]) {
            pools[_id].investors.push(msg.sender);
            uint index = pools[_id].investors.length - 1;
            is_user_in_pool[_id][msg.sender] = true;
            user_in_pool_at_index[_id][msg.sender] = index;
        }

        pools[_id].funds_received += msg.value;
        user_specific_pool_investment[_id][msg.sender] += msg.value;

        token._mint(msg.sender, msg.value);

        if(pools[_id].funds_asked == pools[_id].funds_received) {
            pool_filled(_id);
        }
    }

    function pool_filled(uint _id) internal {
        pools[_id].is_filled = true;

        for(uint i = 0; i < pools[_id].investors.length; i++) {
            token._burn(pools[_id].investors[i], user_specific_pool_investment[_id][pools[_id].investors[i]]);
            user_specific_pool_investment[_id][pools[_id].investors[i]] = 0;
        }

        (bool success, ) = payable(pools[_id].admin).call{value: pools[_id].funds_asked}("");
        require(success, "Cannot transfer funds");

        has_user_created_pool[pools[_id].admin] = false;
        funded_pools += 1;
    }

    function withdraw_pool(uint _id) external payable {
        require(users[msg.sender], "Not a user");
        require(_id < pools_count, "Enter a valid pool ID");
        require(pools[_id].admin == msg.sender, "You don't own this pool");
        require(pools[_id].is_valid, "You have already abandonded this pool");
        require(payable(msg.sender).balance > 1, "You don't have enough balance");
        require(msg.value == 1 ether, "You need to pay 1 ether as penalty");

        uint length = pools[_id].investors.length;
        uint i = length - 1;
        do {
            uint amount = user_specific_pool_investment[_id][pools[_id].investors[i]];
            delete user_in_pool_at_index[_id][pools[_id].investors[i]];
            delete is_user_in_pool[_id][pools[_id].investors[i]];
            delete user_specific_pool_investment[_id][pools[_id].investors[i]];

            token._burn(pools[_id].investors[i], amount);
            (bool success, ) = payable(pools[_id].investors[i]).call{value: amount}("");
            require(success, "Cannot send funds back");
            pools[_id].investors.pop();
            if(i != 0){
                i--;
            }
        } while (i != 0);

        unique_names[pools[_id].name] = false;
        has_user_created_pool[msg.sender] = false;
        pools[_id].is_valid = false;

        (bool sent, ) = payable(owner).call{value: msg.value}("");
        require(sent, "Something went wrong");
    }

    function withdraw_funds(uint _id) external {
        require(users[msg.sender], "Not a user");
        require(token.balanceOf(msg.sender) > 0, "You don't have enough tokens");
        require(_id < pools_count, "Enter a valid pool id");
        require(pools[_id].admin != msg.sender, "You are the admin of the pool");
        require(is_user_in_pool[_id][msg.sender], "You don't have invested in this pool");
        require(pools[_id].is_approved, "Not yet approved");
        require(!pools[_id].is_filled, "Pool is full cannot withdraw");
        require(pools[_id].is_valid, "Pool disabled by admin, you might have receiced your funds");

        pools[_id].is_valid = false;

        uint amount = user_specific_pool_investment[_id][msg.sender];
        uint index = user_in_pool_at_index[_id][msg.sender];

        address temp = pools[_id].investors[pools[_id].investors.length - 1];
        pools[_id].investors[pools[_id].investors.length - 1] = pools[_id].investors[index];
        pools[_id].investors[index] = temp;
        pools[_id].investors.pop();

        delete user_in_pool_at_index[_id][msg.sender];
        user_in_pool_at_index[_id][pools[_id].investors[index]] = index;
        is_user_in_pool[_id][msg.sender] = false;
        user_specific_pool_investment[_id][msg.sender] = 0;

        pools[_id].funds_received -= amount;
        token._burn(msg.sender, amount);
    }
}