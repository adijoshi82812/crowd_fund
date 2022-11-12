//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Funds.sol";

interface Token{
    function mint(address _to, uint _amount) external;
    function burn(address _of, uint _amount) external;
}

contract CrowdFund{
    Token t = Token(0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95);

    mapping(address => bool) private users;
    address public immutable admin;

    mapping(address => bool) private has_user_applied;
    mapping(uint => mapping(address => uint)) private user_pool_liquidity;
    address[] private temp_investors;

    Funds[] public funds;

    constructor()
    {
        admin = msg.sender;
    }

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

    event funds_approved(uint, string);
    event pool_filled(uint, string);
    event pool_destroyed(uint, string);

    function contractCall() 
        external 
    {
        require(users[msg.sender] == false, "Already a user");
        users[msg.sender] = true;
    }

    function requestFundApproval
    (
        string memory _fundName, 
        uint _amount
    ) 
        external 
        isUser 
        returns(uint) 
    {
        require(has_user_applied_for_funding(msg.sender) == false, "You have already applied for funding");
        require(check_name_already_exists(_fundName) == false, "Name already exists");

        Funds memory p = Funds(
            _fundName,
            msg.sender,
            _amount * 1000000000000000000 * 1000,
            temp_investors,
            0,
            false,
            false
        );
        funds.push(p);

        has_user_applied[msg.sender] = true;

        return funds.length;
    }

    function has_user_applied_for_funding
    (
        address _user
    ) 
        internal 
        view 
        returns(bool) 
    {
        return has_user_applied[_user];
    }

    function check_name_already_exists
    (
        string memory _name
    ) 
        internal 
        view 
        returns(bool) 
    {
        bool flag = false;
        for(uint i = 0; i < funds.length; i++) {
            if(keccak256(abi.encodePacked(funds[i].name)) == keccak256(abi.encodePacked(_name))) {
                flag = true;
                return flag;
            }
        }

        return flag;
    }

    function approve_funding
    (
        uint _id
    ) 
        external 
        onlyAdmin 
        isNotApproved(_id) 
    {
        funds[_id].is_approved = true;
        emit funds_approved(_id, funds[_id].name);
    }

    function fund_a_pool
    (
        uint _id
    ) 
        external 
        isUser 
        isApproved(_id) 
        isPoolFilled(_id) 
        payable 
    {
        require(address(msg.sender).balance > 0, "Not enough balance");
        require(msg.value > 0, "Not enough funding");
        require(msg.value < address(msg.sender).balance, "Not enough balance");

        uint amount = msg.value * 1000;
        uint totalAmount = funds[_id].funds_raised + amount;
        require(totalAmount <= funds[_id].amount_asked, "Overflow");
        funds[_id].funds_raised += amount;

        if(!is_second_investment(_id, msg.sender)){
            funds[_id].investors.push(msg.sender);
        }

        user_pool_liquidity[_id][msg.sender] += amount;
        t.mint(msg.sender, amount);

        if(is_pool_filled(_id)){
            funds[_id].is_filled = true;
            emit pool_filled(_id, "Specified pool has been filled");
            send_funds_and_destory_pool(_id);
        }
    }

    function burn_liquidity
    (
        uint _id
    ) 
        internal 
    {
        for(uint i = 0; i < funds[_id].investors.length; i++) {
            t.burn(funds[_id].investors[i], user_pool_liquidity[_id][funds[_id].investors[i]]);
            user_pool_liquidity[_id][funds[_id].investors[i]] = 0;
        }
    }

    function is_second_investment
    (
        uint _id, 
        address _user
    ) 
        internal 
        view 
        returns(bool) 
    {
        bool flag = false;
        for(uint i = 0; i < funds[_id].investors.length; i++) {
            if(_user == funds[_id].investors[i]){
                flag = true;
                return flag;
            }
        }

        return flag;
    }

    function is_pool_filled
    (
        uint _id
    ) 
        internal 
        view 
        returns(bool) 
    {
        bool flag = false;
        if(funds[_id].amount_asked == funds[_id].funds_raised){
            flag = true;
            return flag;
        }

        return flag;
    }

    function send_funds_and_destory_pool
    (
        uint _id
    ) 
        internal 
    {
        require(is_pool_filled(_id), "Not yet full");
        uint amount = funds[_id].amount_asked / 1000;
        (bool success, ) = payable(funds[_id].owner).call{value: amount}("");

        require(success, "Failed to withdraw");
        burn_liquidity(_id);

        has_user_applied[funds[_id].owner] = false;

        delete funds[_id];

        emit pool_destroyed(_id, "Pools has been successfully destroyed");
    }
}