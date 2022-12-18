// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CrowdFund {
    address private immutable owner;
    mapping(address => bool) private users;
    uint private userCount = 0;

    uint donations = 0;
    uint requests = 0;
    uint approved = 0;

    struct Votes {
        uint totalInvestors;
        uint totalVotes;
        uint falseVotes;
        uint trueVotes;
    }

    struct Pools {
        uint id;
        string name;
        address admin;
        uint amountAsked;
        uint amountReceived;
        uint minToInvest;
        uint deadline;
        address[] investors;
        bool isValid;
        bool isApproved;
        bool dismantledByAdmin;
        Votes vote;
        ERC20 token;
    }
    Pools[] private pools;
    uint private poolsCount = 0;
    mapping(string => bool) private uniqueNames;
    mapping(address => bool) private hasUserCreatedPool;
    address[] private tempInvestors;
    mapping(uint => mapping(address => bool)) private isUserInPool;
    mapping(uint => mapping(address => uint)) private userSpecificPoolInvestment;
    mapping(uint => mapping(address => bool)) private votersForPool;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        donations += msg.value;
        (bool success, ) = payable(owner).call{value: msg.value}("");
        require(success, "Cannot donate");
    }

    function getOwner() external view returns(address) {
        return owner;
    }

    function getIsUser() external view returns(bool) {
        return users[msg.sender];
    }

    function getUserCount() external view returns(uint) {
        return userCount;
    }

    function getDonationsReceived() external view returns(uint) {
        return donations;
    }

    function getRequestsReceived() external view returns(uint) {
        return requests;
    }

    function getApprovedFunds() external view returns(uint) {
        return approved;
    }

    function getPoolDetails(uint _id) external view returns(Pools memory) {
        require(_id < poolsCount, "Enter a valid pool id");
        return pools[_id];
    }

    function getPoolsCount() external view returns(uint) {
        return poolsCount;
    }

    function checkName(string memory _name) external view returns(bool) {
        return uniqueNames[_name];
    }

    function checkHasUserCreatedPool() external view returns(bool) {
        return hasUserCreatedPool[msg.sender];
    }

    function checkIsUserInPool(uint _id) external view returns(bool) {
        require(_id < poolsCount, "Enter a valid pool id");
        return isUserInPool[_id][msg.sender];
    }

    function checkUserSpecificPoolInvestment(uint _id) external view returns(uint) {
        require(_id < poolsCount, "Enter a valid pool id");
        return userSpecificPoolInvestment[_id][msg.sender];
    }

    function contractCall() external {
        require(!users[msg.sender], "Already a user");
        users[msg.sender] = true;
        userCount += 1;
    }

    function createPool
    (
        string memory _name,
        uint _amount,
        uint _minToInvest,
        uint _deadline,
        string memory _symbol
    ) external payable {
        require(users[msg.sender], "Not a user");
        require(!uniqueNames[_name], "Try a different name");
        require(!hasUserCreatedPool[msg.sender], "You have already created a pool");
        require(_minToInvest <= _amount, "Min to invest should be less then amount");
        require(msg.value == _amount * 1 ether, "You must send value equal to amount");

        requests += 1;

        Votes memory _vote = Votes({
            totalInvestors: 0,
            totalVotes: 0,
            falseVotes: 0,
            trueVotes: 0
        });

        ERC20 _token = new ERC20(_name, _symbol, address(this));

        Pools memory pool = Pools({
            id: poolsCount,
            name: _name,
            admin: msg.sender,
            amountAsked: _amount * 1 ether,
            amountReceived: 0,
            minToInvest: _minToInvest * 1 ether,
            deadline: block.timestamp + _deadline,
            investors: tempInvestors,
            isValid: true,
            isApproved: false,
            dismantledByAdmin: false,
            vote: _vote,
            token: _token
        });

        pools.push(pool);
        poolsCount += 1;
        uniqueNames[_name] = true;
        hasUserCreatedPool[msg.sender] = true;
    }

    function invest(uint _id) external payable {
        require(users[msg.sender], "Not a user");
        require(_id < poolsCount, "Enter a valid pool id");
        require(msg.sender != pools[_id].admin, "Admins cannot invest");
        require(msg.value > 0 ether, "You need invest ethers");
        require(msg.value >= pools[_id].minToInvest, "Check the minimum investment label");
        require(msg.value <= pools[_id].amountAsked - pools[_id].amountReceived, "Overflow");
        require(block.timestamp <= pools[_id].deadline, "Deadline reached");
        require(pools[_id].isValid, "Pool is not valid");

        pools[_id].amountReceived += msg.value;

        if(!isUserInPool[_id][msg.sender]) {
            pools[_id].investors.push(msg.sender);
            isUserInPool[_id][msg.sender] = true;
            pools[_id].vote.totalInvestors += 1;
        }

        userSpecificPoolInvestment[_id][msg.sender] += msg.value;
        pools[_id].token._mint(msg.sender, msg.value);
    }

    function vote(uint _id, bool _opinion) external {
        require(users[msg.sender], "Not a user");
        require(_id < poolsCount, "Enter a valid pool id");
        require(msg.sender != pools[_id].admin, "Admins cannot vote");
        require(block.timestamp > pools[_id].deadline, "Cannot vote early");
        require(isUserInPool[_id][msg.sender], "You have not invested in this pool");
        require(pools[_id].isValid, "Pool is not valid");
        require(!votersForPool[_id][msg.sender], "You have already voted");

        if(_opinion) {
            pools[_id].vote.trueVotes += 1;
        } else {
            pools[_id].vote.falseVotes += 1;
        }
        pools[_id].vote.totalVotes += 1;
        votersForPool[_id][msg.sender] = true;

        pools[_id].token._burn(msg.sender, userSpecificPoolInvestment[_id][msg.sender]);
    }

    function checkAndApprove(uint _id) external returns(bool) {
        require(users[msg.sender], "Not a user");
        require(_id < poolsCount, "Enter a valid pool id");
        require(msg.sender == pools[_id].admin, "Only for pool admins");
        require(block.timestamp > pools[_id].deadline, "Still in progress");
        
        uint roundInvestors;
        if(pools[_id].vote.totalInvestors % 2 != 0) {
            roundInvestors = pools[_id].vote.totalInvestors - 1;
        } else {
            roundInvestors = pools[_id].vote.totalInvestors;
        }

        require(pools[_id].vote.totalVotes > roundInvestors / 2, "Not enough votes");

        uint roundVotes;
        if(pools[_id].vote.totalVotes % 2 != 0) {
            roundVotes = pools[_id].vote.totalVotes - 1;
        } else {
            roundVotes = pools[_id].vote.totalVotes;
        }

        bool favour;
        if(pools[_id].vote.trueVotes > roundVotes / 2) {
            favour = true;
        } else {
            favour = false;
        }

        if(favour) {
            pools[_id].isApproved = true;
            pools[_id].isValid = false;
        } else {
            pools[_id].isValid = false;
        }

        return favour;
    }

    function dismantlePool() external {}

    function withdraw() external {}

    function claimInvestment() external {}
}