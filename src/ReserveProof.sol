// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// @dev OpenZeppelin ERC20 imports
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @dev OpenZeppelin utils imports
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @dev OpenZeppelin access imports
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


/// @title Reserve Proof Contract V1.0
/// @notice Manages the reserve proof of the backed assets BOG Ghana Gold Coin.
/// @author geeloko.eth

contract ReserveProof is ERC20, ERC20Burnable, ERC20Permit, Ownable, ReentrancyGuard {

    /// @notice The reserve proof event.
    event ReserveUpdated(uint256 indexed oldReserves, uint256 indexed newReserves);

    constructor(address initialOwner) Ownable(initialOwner) {}


    /// @notice Update the reserve proof of the backed assets BOG Ghana Gold Coin.
    /// @param reserves The amount of the backed assets BOG Ghana Gold Coin.
    function updateReserveWithProof(uint256 reserves) public onlyOwner nonReentrant {
        uint256 oldReserves = balanceOf(address(this));
        if (reserves > oldReserves) {
                _mint(address(this), reserves - oldReserves);
        } else {
                _burn(address(this), oldReserves - reserves);
        }
        emit ReserveUpdated(oldReserves, reserves);
    }
}