//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

struct Funds {
    string name;
    address owner;
    uint amount_asked;
    address[] investors;
    uint funds_raised;
    bool is_approved;
    bool is_filled;
}