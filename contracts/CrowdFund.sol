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
        require(address(this).balance > donations, "Not enough balance in contract");

        (bool success, ) = payable(admin).call{value: donations}("");
        require(success, "Failed to withdraw");

        emit withdraw_donations_event("Donations has been withdrawn");
    }

    function contractCall() 
        external 
    {
        require(users[msg.sender] == false, "Already a user");
        users[msg.sender] = true;

        emit register_user_event(msg.sender, "User has been successfully registered");
    }

    function requestFundApproval
    (
        string memory _fundName, 
        uint _amount
    ) 
        external 
        isUser 
        has_user_applied_for_funding(msg.sender)
        check_name_already_exists(_fundName)
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
        emit funds_approved(_id, funds[_id].name);
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

        uint amount = SafeMath.mul(msg.value, 1000);
        uint totalAmount = SafeMath.add(funds[_id].funds_raised, amount);
        require(totalAmount <= funds[_id].amount_asked, "Overflow");
        funds[_id].funds_raised = SafeMath.add(
            funds[_id].funds_raised,
            amount
        );

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

        require(success, "Failed to withdraw");
        burn_liquidity(_id);

        has_user_applied[funds[_id].owner] = false;

        delete funds[_id];

        emit pool_destroyed(_id, "Pools has been successfully destroyed");
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
            Is_filled = funds[_id].is_approved,
            Investors = funds[_id].investors
        );
    }
}