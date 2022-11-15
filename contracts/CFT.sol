// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CroudFund is ERC20, Ownable {
    address allowedAddress;

    constructor() ERC20("CroudFundToken", "CFT") {}

    modifier allowedAddr {
        require(msg.sender == allowedAddress, "Unauthorized");
        _;
    }

    function alloweAddress(address _addr) onlyOwner external {
        allowedAddress = _addr;
    }

    function mint(address _to, uint _amount) allowedAddr external {
        _mint(_to, _amount);
    }

    function burn(address _to, uint _amount) allowedAddr external {
        require(_amount <= balanceOf(_to), "Not enough tokens");
        _burn(_to, _amount);
    }

    function balance_Of(address _account) external allowedAddr view returns(uint) {
        return balanceOf(_account);
    }
}
