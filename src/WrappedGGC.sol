// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
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


/// @title WrappedGGC Deposit/Mint Contract V1.0
/// @notice Manages deposit and minting of Wrapped GGC tokens backed by crptogrpahic prrof of BOG Ghana Gold Coin reserves
/// @author geeloko.eth

contract WrappedGGC is ERC20, ERC20Burnable, Ownable, ERC20Permit, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice The deposit token check if is accepted.
    mapping(address => bool) public depositERC20;
    /// @notice The deposit balance of a address.
    mapping(address => uint256) public depositBalance;
    /// @notice The mint balance of a address.
    mapping(address => uint256) public mintBalance;


    /// @notice The deposit event.
    event Deposit(address indexed to, uint256 indexed amount, uint256 indexed timestamp);


    /// @notice Error messages
    error InvalidAddress();
    error TokenAlreadyAdded();
    error TokenNotAdded();

    constructor(address initialOwner)
        ERC20("WrappedGGC", "WGGC")
        Ownable(initialOwner)
        ERC20Permit("WrappedGGC")
    {}
    
    /// @notice Add erc20contract token to depositERC20s.
    /// @param token The address of the ERC20 contract.
    function addERC20(address token) 
        external
        onlyOwner
    {
        if (token == address(0)) revert InvalidAddress();
        if (depositERC20[token]) revert TokenAlreadyAdded();

        depositERC20[token] = true;
    }

    
    /// @notice remove erc20contract  token from depositERC20s.
    /// @param token The address of the ERC20 token contract.
    function removeERC20(address token) external onlyOwner {
        if (token == address(0)) revert InvalidAddress();
        if (!depositERC20[token]) revert TokenNotAdded();
        
        depositERC20[token] = false;
    }

    function deposit(address token, uint256 amount) public nonReentrant {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        depositBalance[msg.sender] += amount;
        emit Deposit(msg.sender, amount, block.timestamp);
    }

    function mint(address to, uint256 amount) public onlyOwner nonReentrant {
        _mint(to, amount);
    }
}