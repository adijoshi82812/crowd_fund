// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CroudFund is ERC20 {
    address allowedAddress;
    address admin;

    constructor() ERC20("CroudFundToken", "CFT") {
        admin = msg.sender;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Not an admin");
        _;
    }

    modifier allowedAddr {
        require(msg.sender == allowedAddress, "Unauthorized");
        _;
    }

    function alloweAddress(address _addr) onlyAdmin external {
        allowedAddress = _addr;
    }

    function mint(address _to, uint _amount) allowedAddr external {
        _mint(_to, _amount);
    }

    function burn(address _to) allowedAddr external {
        _burn(_to, balanceOf(_to));
    }
}
