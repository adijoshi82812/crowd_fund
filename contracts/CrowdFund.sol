// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CrowdFund {
    /* @dev, This are all the variables that will be used inside
    ** our contract.
    */

    /* @dev, this the owner variable, this variable is used to
    ** get the owner of this contract, meaning who owns this
    ** contract
    */
    address private immutable owner;

    /* @dev, this is a mapping for users that will join our contract
    ** via the contract call method. Consider this variable that tells
    ** if the user is signed in our not
    */
    mapping(address => bool) private users;

    /* @dev, this vaiable keeps the count of the users that have joined
    ** the contract using the contract call method
    */
    uint private userCount = 0;
    
    /* @dev, this variable is the string that tells how much has the contract
    ** received ETH in terms of donations
    */
    uint private donations = 0;

    /* @dev, this variable is the string that tells how many pools have been created
    ** till now
    */
    uint private requests = 0;

    /* @dev, this variable is the string that tells how many pools have been approved
    ** till now
    */
    uint private approved = 0;

    /* @dev, this is the structure for votes, Votes are useful when a specific pool
    ** has reached the deadline, or maybe it is filled. It keeps track of the users
    ** that have invested in a particular pool and keeps the track of false and true
    ** votes when the voting period of the pool starts.
    */
    struct Votes {
        uint totalInvestors;
        uint totalVotes;
        uint falseVotes;
        uint trueVotes;
    }

    /* @dev, this is the structure for Pools, Pools are the main backbone of our contract
    ** which keeps track of each and every details of the pools like the id, name, admin, amountAsked,
    ** amountReceived, mintToInvest, dealine, array of Investors, if the pool is valid, if the pool
    ** is approved, Votes for the particular pool and ERC20 token that is minted and supplied as
    ** security to the user investing in a specific pool
    */
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
        Votes vote;
        ERC20 token;
    }

    /* @dev, this is the main array for all the pools. This is where are the details of our
    ** structure of pool will be stored in the form of array.
    */
    Pools[] private pools;

    /* @dev, this variable keeps the count of the pools that have been added into our
    ** contract
    */
    uint private poolsCount = 0;

    /* @dev, this mapping keeps track of unique names this can be used in order to create a new
    ** pool. Consider this as a validation that can prevent duplication of pool names in our
    ** contract.
    */
    mapping(string => bool) private uniqueNames;

    /* @dev, this mapping keeps track of the users that have created the pool. As we want to limit
    ** one user to create one pool only we can use this mapping as a validation against the user
    ** creating multiple pools at a time.
    */
    mapping(address => bool) private hasUserCreatedPool;

    /* @dev, this is just a temporary array that will be used to create a dynamic array inside
    ** a new pool.
    */
    address[] private tempInvestors;

    /* @dev, this mapping is used to track if a user is already already inside a specific pool
    ** or not.
    */
    mapping(uint => mapping(address => bool)) private isUserInPool;

    /* @dev, this mapping is used to track the investment a user has done inside a specific
    ** pool. This mapping is also responsible to withdraw ERC20 tokens if a pool is not approved
    ** or is dismentled by the admin.
    */
    mapping(uint => mapping(address => uint)) private userSpecificPoolInvestment;

    /* @dev, we are setting the owner of the contract inside our constructor, the person that deploys
    ** the contract is the actual owner of the contract.
    */
    constructor() {
        owner = msg.sender;
    }

    /* @dev, this is a receive function which is responsible to send the donations received in the contract
    ** and send it to the owner of the contract. Responsible for updating the donations strings as well.
    */
    receive() external payable  {
        // Upadate the donation string with the value that is received in a single transaction
        donations += msg.value;

        // Send the received value to the owner of the contract
        (bool success,) = payable(owner).call{value: msg.value}("");

        // Verifying if the transaction was successfull or not.
        require(success, "Could not donate");
    }

    ///////////////////////////
    ////   View Funtions   ////
    ///////////////////////////

    /* @dev, this view function returns who is the owner of this contract
    */
    function Owner() external view returns(address) {
        return owner;
    }

    /* @dev, this view function returns if the user is registered inside this
    ** contract or not. Users can call the contract_call function in order to
    ** register themselves inside this contract.
    */
    function isUser() external view returns(bool) {
        return users[msg.sender];
    }

    /* @dev, this view function returns the number of users that has been registered
    ** in this contract.
    */
    function getUserCount() external view returns(uint) {
        return userCount;
    }

    /* @dev, this view function returns the donations that the contract has received in
    ** wei. 1 eth = 10 ** 18 eth.
    */
    function getDonationReceived() external view returns(uint) {
        return donations;
    }

    /* @dev, this view function returns the pool requests that the contract
    ** has received.
    */
    function getRequestsReceived() external view returns(uint) {
        return requests;
    }

    /* @dev, this view function returns the pool requests that has been
    ** approved in the contract
    */
    function getApprovedCount() external view returns(uint) {
        return approved;
    }

    /* @dev, this view function returns the pool details using the ID of that
    ** pool. There is a validation to check is the ID is not out bound of the total
    ** pools that has been created.
    */
    function getPoolDetails(uint _id) external view returns(Pools memory) {
        require(_id < poolsCount, "Enter a valid pool id");
        return pools[_id];
    }

    /* @dev, this view function returns the pools count that has been created in
    ** the contract untill now
    */
    function getPoolsCount() external view returns(uint) {
        return poolsCount;
    }

    /* @dev, this view function returns if a string passed in as parameter is unique or not.
    */
    function checkName(string memory _name) external view returns(bool) {
        return uniqueNames[_name];
    }

    /* @dev, this view function returns if the user that is calling the function has
    ** created a pool or not
    */
    function getHasUserCreatedPool() external view returns(bool) {
        return hasUserCreatedPool[msg.sender];
    }

    /* @dev, this view function returns if the user that is calling the function passing
    ** the ID of a pool is inside that pool or not.
    */
    function getIsUserInPool(uint _id) external view returns(bool) {
        require(_id < poolsCount, "Enter a valid pool id");
        return isUserInPool[_id][msg.sender];
    }

    /* @dev, this view function returns the investment of the user that is calling
    ** this function along with user id. There is a validation to check the id against pools
    ** count to handle outbound errors.
    */
    function getUserSpecificInvestment(uint _id) external view returns(uint) {
        require(_id < poolsCount, "Enter a valid pool id");
        return userSpecificPoolInvestment[_id][msg.sender];
    }

    /////////////////////////////////
    ////   External Functions   ////
    ///////////////////////////////

    /* @dev, this function is used to register the user inside the contract, there is a
    ** validation that the user cannot register themselves if they have already registered
    ** before.
    */
    function contractCall() external {
        // Check if the user has already registered inside the contract
        require(!users[msg.sender], "Already a user");

        // Set the mapping for the user calling the function to true
        users[msg.sender] = true;

        // Increments the users count varible by 1.
        userCount += 1;
    }

    /* @dev, this function is used to create a pool in our contract. This function requires various
    ** parameters such as name for the pool, amount that the pool admin wants as fund, a minimum amount
    ** in ether a user should invest for this specific pool, deadline for the pool in epoch, and the symbol
    ** for the ERC20 token that will be generated for a particular pool
    */
    function createPool
    (
        string memory _name,
        uint _amount,
        uint _minToInvest,
        uint _deadline,
        string memory _symbol
    ) external payable {
        // Check if the user is registered inside the contract
        require(users[msg.sender], "Not a user");

        // Check if the name that is passed is unique to other names or not
        require(!uniqueNames[_name], "Try a different name");

        // Check if the user that is creating the pool has already created a pool or not
        require(!hasUserCreatedPool[msg.sender], "You have already created a pool");

        // Minimum amount to invest should always be always less then amount
        require(_minToInvest <= _amount, "Minimum cannot be greater then amount");

        // Admin of the pool must send the amount they are asking for funds as a form of
        // collateral
        require(msg.value == _amount * 1 ether, "You must send the same amount of ether as your amount");

        // Incrementing the requests variable by 1.
        requests += 1;

        // Creating a Vote variable inside the memory of the blockchain.
        Votes memory _vote = Votes({
            totalInvestors: 0,
            totalVotes: 0,
            falseVotes: 0,
            trueVotes: 0
        });

        // Deploying a new ERC20 token based on the name and symbol provided by the admin
        // of the pool
        ERC20 _token = new ERC20(_name, _symbol, address(this));

        // Creating a Pools variable inside the memory of the blockchain. This variable will be pushed
        // inside our array of pools
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
            // Using the vote varible that was created in the memory.
            vote: _vote,
            token: _token
        });

        // Pushing the pool variable that was created inside the memory to the state of
        // the contract on the blockchain
        pools.push(pool);

        // Incrementing the pools count by 1
        poolsCount += 1;

        // Assigning the map of unique names with the parameter passed. So no one can use
        // the same name again to create a pool.
        uniqueNames[_name] = true;

        // Assigning the map of has user created pool with the user that initiated this function, so that
        // they cannot create a new pool.
        hasUserCreatedPool[msg.sender] = true;
    }

    /* @dev, this function is used to let users invest in a pool using the id parameter. Id should not be
    ** greater then the pools count.
    */
    // function invest(uint _id) external payable {
    //     require(users[msg.sender], "Not a user");
    // }

    /* @dev, this function is used to let users vote for a pool. Votes are crucial part of a pool to get
    ** approved. If majority votes are false, the pool will not be approved whereas, if majority
    ** of the votes are true then admin of that pool can withdraw whatever investment the pool has got.
    */
    function vote(uint _id) external {}

    /* @dev, this function is for admins of the pool. Admins of the pool if they have any hesitation for
    ** the pool they have created, then they can cancle their pool. In return a small amount of ether that were
    ** given as collateral will be transffered to the owner of the contract.
    */
    function dismantlePool(uint _id) external {}

    /* @dev, this function is for users. If the pool is dismentled by the admin then a user can withdraw their
    ** invested ether if they have already invested inside that pool.
    */
    function withdraw(uint _id) external {}

    /* @dev, this function is for admins of the pool. If the pool is approved by the investors of the pool.
    ** Then admins can claim whatever investment they have raised for their pool.
    */
    function claimInvestment(uint _id) external {}
}