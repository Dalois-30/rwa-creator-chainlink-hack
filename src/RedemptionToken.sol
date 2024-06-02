// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";


contract MyToken is ERC20, ERC20Permit {
    constructor() ERC20("MyRWAToken", "MRWA") ERC20Permit("MyToken") {}

    function decimals() public pure override returns(uint8) {
        return 18;
    }

    function mint() public {
        _mint(msg.sender, 1e18);
    }
}   