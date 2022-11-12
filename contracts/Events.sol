//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Events {
    event withdraw_donations_event(string);
    event register_user_event(address, string);
    event request_fund_approval_event(uint, string);
    event funds_approved(uint, string);
    event pool_filled(uint, string);
    event pool_destroyed(uint, string);
}