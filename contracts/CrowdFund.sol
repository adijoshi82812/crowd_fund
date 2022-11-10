//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface Token{
    function mint(address _to, uint _amount) external;
    function burn(address _of) external;
}

contract CrowdFund{
    //Token that we will interact with in order to provide liquidity to our investors
    Token t = Token(0x047b37Ef4d76C2366F795Fb557e3c15E0607b7d8); //Token contract address

    //Users List
    mapping(address => bool) private users;

    address public immutable admin;

    //List of users that have already raised a fund
    mapping(address => bool) private has_user_applied;

    mapping(uint => mapping(address => uint)) private user_pool_liquidity;

    address[] private temp_investors;

    struct Funds {
        string name;
        address owner;
        uint amount_asked;
        address[] investors;
        uint funds_raised;
        bool is_approved;
        bool is_filled;
    }
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

    modifier isNotApproved(uint _id)
    {
        require(funds[_id].is_approved == false, "Already approved");
        _;
    }

    modifier isApproved(uint _id)
    {
        require(funds[_id].is_approved == true, "Funds not approved yet");
        _;
    }

    modifier isPoolFilled(uint _id)
    {
        require(!funds[_id].is_filled, "Pool already full");
        _;
    }

    event funds_approved(uint id, string name);
    event pool_filled(uint, string);

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

        if(is_pool_filled(_id)){
            funds[_id].is_filled = true;
            emit pool_filled(_id, "Specified pool has been filled");
        }

        user_pool_liquidity[_id][msg.sender] += amount;
        t.mint(msg.sender, amount);
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
}