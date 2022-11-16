//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Modifiers.sol";
import "./Events.sol";

contract CrowdFund is Modifiers, Events {
    using SafeMath for uint256;

    receive() external payable {
        uint amount = msg.value;
        donations += amount;
    }

    function withdraw_donations() external onlyAdmin {
        require(donations > 0, "Not enough donations");
        require(address(this).balance >= donations, "Not enough balance in contract");

        donations = 0;

        (bool success, ) = payable(admin).call{value: donations}("");
        require(success, "Failed to withdraw");

        emit withdraw_donations_event("Donations has been withdrawn");
    }

    function contract_call() 
        external
    {
        require(users[msg.sender] == false, "Already a user");
        users[msg.sender] = true;

        emit register_user_event(msg.sender, "User has been successfully registered");
    }

    function request_fund_approval
    (
        string memory _fundName, 
        uint _amount
    ) 
        external 
        isUser 
        hasUserAppliedForFunding(msg.sender)
        checkNameAlreadyExists(_fundName)
        returns(uint) 
    {
        Funds memory p = Funds({
            name: _fundName,
            owner: msg.sender,
            amount_asked: SafeMath.mul(_amount, SafeMath.mul(token_diversity, token_impound)),
            investors: temp_investors,
            funds_raised: 0,
            is_approved: false,
            is_filled: false
        });
        funds.push(p);
        unique_names[_fundName] = true;

        has_user_applied[msg.sender] = true;
        emit request_fund_approval_event(
            funds.length - 1, 
            "Your funds has been sent for approval with the given id"
        );

        return funds.length;
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
        approved_pools = SafeMath.add(approved_pools, 1);
        emit funds_approved_event(_id, funds[_id].name);
    }

    function fund_a_pool
    (
        uint _id
    ) 
        external 
        isUser 
        isApproved(_id)
        payable 
    {
        require(address(msg.sender).balance > 0, "Not enough balance");
        require(msg.value > 0, "Not enough funding");
        require(msg.value < address(msg.sender).balance, "Not enough balance");
        require(funds[_id].owner != msg.sender, "Owner's cannot fund");

        uint amount = SafeMath.mul(msg.value, 1000);
        uint totalAmount = SafeMath.add(funds[_id].funds_raised, amount);
        require(totalAmount <= funds[_id].amount_asked, "Overflow");
        funds[_id].funds_raised = SafeMath.add(
            funds[_id].funds_raised,
            amount
        );

        total_funds_raised = SafeMath.add(total_funds_raised, amount);

        if(unique_investors_in_pool[_id][msg.sender] == false){
            unique_investors_in_pool[_id][msg.sender] = true;
            funds[_id].investors.push(msg.sender);
        }

        user_pool_liquidity[_id][msg.sender] = SafeMath.add(
            user_pool_liquidity[_id][msg.sender],
            amount
        );
        t.mint(msg.sender, amount);

        if(is_pool_filled(_id)){
            funds[_id].is_filled = true;
            emit pool_filled_event(_id, "Specified pool has been filled");
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

        uint amount = SafeMath.div(funds[_id].amount_asked, 1000);
        (bool success, ) = payable(funds[_id].owner).call{value: amount}("");
        completed_pools = SafeMath.add(completed_pools, 1);
        require(success, "Failed to withdraw");
        burn_liquidity(_id);

        has_user_applied[funds[_id].owner] = false;

        delete funds[_id];

        emit pool_destroyed_event(_id, "Pools has been successfully destroyed");
    }

    function view_fund_details
    (
        uint _id
    ) 
    external 
    view 
    returns
    (
        string memory Name,
        address Owner,
        uint Amount_asked,
        uint Funds_raised,
        bool Is_approved,
        bool Is_filled,
        address[] memory Investors
    ) 
    {
        return (
            Name = funds[_id].name,
            Owner = funds[_id].owner,
            Amount_asked = funds[_id].amount_asked,
            Funds_raised = funds[_id].funds_raised,
            Is_approved = funds[_id].is_approved,
            Is_filled = funds[_id].is_filled,
            Investors = funds[_id].investors
        );
    }

    function get_refund(uint _id) external isUser {
        require(funds[_id].is_approved, "This pool is not valid");
        require(funds[_id].is_filled == false, "This pool is full, cannot get refund");
        uint amount = SafeMath.div(user_pool_liquidity[_id][msg.sender], token_impound);

        bool flag = false;
        for(uint i = 0; i < funds[_id].investors.length; i++) {
            if(funds[_id].investors[i] == msg.sender) {
                flag = true;
                uint length = SafeMath.sub(funds[_id].investors.length, 1);
                address temp = funds[_id].investors[length];
                funds[_id].investors[length] = funds[_id].investors[i];
                funds[_id].investors[i] = temp;
                funds[_id].investors.pop();

                break;
            }
        }
        require(flag, "You have not invested in this pool");
        delete unique_investors_in_pool[_id][msg.sender];
        funds[_id].funds_raised = SafeMath.sub(funds[_id].funds_raised, user_pool_liquidity[_id][msg.sender]);
        t.burn(msg.sender, user_pool_liquidity[_id][msg.sender]);

        total_funds_raised = SafeMath.sub(total_funds_raised, user_pool_liquidity[_id][msg.sender]);

        delete user_pool_liquidity[_id][msg.sender];

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Not able to withdraw");
    }

    function transer_ownership(address _to) external onlyAdmin {
        require(accept_ownership == false, "You have already sent the ownership to someone");

        new_owner = _to;
        accept_ownership = true;
    }

    function _accept_ownership() external {
        require(msg.sender == new_owner, "You cannot claim the ownership role");
        require(accept_ownership == true, "You have already accepted the ownership");

        admin = new_owner;
    }

    function transfer_funds(uint _from, uint _to) external isUser {
        require(funds[_to].owner != msg.sender, "Owner's cannot fund their own pool");
        require(unique_investors_in_pool[_from][msg.sender] == true, "You have not invested inside this pool");
        require(user_pool_liquidity[_from][msg.sender] > 0, "Not enough liquidity");

        require(funds[_to].is_approved, "Not yet approved");
        require(funds[_to].is_filled == false, "Pool is full");

        uint amount = user_pool_liquidity[_from][msg.sender];
        amount = SafeMath.add(amount, funds[_from].funds_raised);

        require(amount <= funds[_to].amount_asked, "Overflow");

        unique_investors_in_pool[_from][msg.sender] = false;
        amount = user_pool_liquidity[_from][msg.sender];
        user_pool_liquidity[_from][msg.sender] = 0;

        funds[_from].funds_raised = SafeMath.sub(funds[_from].funds_raised, amount);
        funds[_to].funds_raised = SafeMath.add(funds[_to].funds_raised, amount);
        user_pool_liquidity[_to][msg.sender] = amount;

        if(unique_investors_in_pool[_to][msg.sender] == false){
            unique_investors_in_pool[_to][msg.sender] = true;
            funds[_to].investors.push(msg.sender);
        }

         for(uint i = 0; i < funds[_from].investors.length; i++) {
            if(funds[_from].investors[i] == msg.sender) {
                uint length = SafeMath.sub(funds[_from].investors.length, 1);
                address temp = funds[_from].investors[length];
                funds[_from].investors[length] = funds[_from].investors[i];
                funds[_from].investors[i] = temp;
                funds[_from].investors.pop();

                break;
            }
        }
    }

    function check_liquidity() external isUser view returns(uint) {
        return t.balance_Of(msg.sender);
    }

    // function get_price() external view returns(int) {
    //     (
    //         /* uint80 roundId */,
    //         int price,
    //         /* uint startedAt */,
    //         /* uint timeStamp */,
    //         /* uint80 answeredInRound */
    //     ) = priceFeed.latestRoundData();

    //     return price;
    // }
}