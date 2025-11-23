// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

/// @dev Interface imports
import { IReserveProof } from "./interfaces/IReserveProof.sol";

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

contract WrappedGGC is ERC20, ERC20Burnable, ERC20Permit, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice The reserve proof contract address
    IReserveProof public reserveProof;
    /// @notice The total deposited amount.
    uint256 public totalDeposited;
    /// @notice The total pending mint amount.
    uint256 public totalPendingMint;

    /// @notice The deposit token check if is accepted.
    mapping(address => bool) public depositERC20;
    /// @notice The deposit balance of a address.
    mapping(address => uint256) public depositBalance;
    /// @notice The mint balance of a address.
    mapping(address => uint256) public mintBalance;


    /// @notice The deposit event.
    event Deposit(address indexed to, uint256 indexed amount, uint256 indexed mintable, uint256 timestamp);
    /// @notice The mint event.
    event Mint(address indexed to, uint256 indexed minted, uint256 timestamp);


    /// @notice Error messages
    error InvalidAddress();
    error TokenAlreadyAdded();
    error TokenNotAdded();
    error InvalidAmount();
    error InsufficientDepositBalance();
    error InsufficientReserveProof();
    error NotEnoughTokens();


    constructor(address initialOwner, address reserveProofAddress)
        ERC20("WrappedGGC", "WGGC")
        Ownable(initialOwner)
        ERC20Permit("WrappedGGC")
    {
        reserveProof = IReserveProof(reserveProofAddress);
    }
    
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

    /// @notice Deposit an amount of an ERC20 token into the contract.
    /// @param token The address of the ERC20 token contract.
    function depositQuaterOZ(address token) public nonReentrant {
        if (!depositERC20[token]) revert TokenNotAdded();
        uint256 rate = reserveProof.pricePerOzUSD();
        uint256 amountUSD = rate * 1e2 / 25;
        IERC20(token).transferFrom(msg.sender, address(this), amountUSD);
        totalDeposited += amountUSD;
        depositBalance[msg.sender] += amountUSD;
        uint256 mintable = (amountUSD * 1e18) / rate;
        totalPendingMint += mintable;
        mintBalance[msg.sender] += mintable;
        emit Deposit(msg.sender, amountUSD, mintable, block.timestamp);
    }


    /// @notice Deposit an amount of an ERC20 token into the contract.
    /// @param token The address of the ERC20 token contract.
    function depositHalfOZ(address token) public nonReentrant {
        if (!depositERC20[token]) revert TokenNotAdded();
        uint256 rate = reserveProof.pricePerOzUSD();
        uint256 amountUSD = rate * 1e2 / 50;
        IERC20(token).transferFrom(msg.sender, address(this), amountUSD);
        totalDeposited += amountUSD;
        depositBalance[msg.sender] += amountUSD;
        uint256 mintable = (amountUSD * 1e18) / rate;
        totalPendingMint += mintable;
        mintBalance[msg.sender] += mintable;
        emit Deposit(msg.sender, amountUSD, mintable, block.timestamp);
    }


    /// @notice Deposit an amount of an ERC20 token into the contract.
    /// @param token The address of the ERC20 token contract.
    function depositOZ(address token) public nonReentrant {
        if (!depositERC20[token]) revert TokenNotAdded();
        uint256 rate = reserveProof.pricePerOzUSD();
        uint256 amountUSD = rate * 1e2 / 100;
        IERC20(token).transferFrom(msg.sender, address(this), amountUSD);
        totalDeposited += amountUSD;
        depositBalance[msg.sender] += amountUSD;
        uint256 mintable = (amountUSD * 1e18) / rate;
        totalPendingMint += mintable;
        mintBalance[msg.sender] += mintable;
        emit Deposit(msg.sender, amountUSD, mintable, block.timestamp);
    }


    /// @notice Mint a amount of WrappedGGC tokens to a address.
    /// @param to The address to mint the WrappedGGC tokens to.
    /// @param amount The amount of the WrappedGGC tokens to mint.
    /// @param mintable The amount of the WrappedGGC tokens to mint.
    function mint(address to, uint256 amount, uint256 mintable) public onlyOwner nonReentrant {
        if (totalSupply() + totalPendingMint != reserveProof.totalSupply()) revert InsufficientReserveProof();
        _mint(to, mintable);
        depositBalance[to] -= amount;
        totalDeposited -= amount;
        mintBalance[to] -= mintable;
        totalPendingMint -= mintable;
        emit Mint(to, mintable, block.timestamp);
    }


    /// @notice Withdraw BOG Ghana Gold Coin sales from wrapped ggc.
    /// @param token The address of the ERC20 contract.
    /// @param to The address to send the sales to.
    function withdraw(address token, address to) external onlyOwner nonReentrant {
        if (token == address(0)) revert InvalidAddress();
        IERC20 tokenContract = IERC20(token);
        uint256 amount = tokenContract.balanceOf(address(this));
        if (amount == 0) revert NotEnoughTokens();
        tokenContract.safeTransfer(to, amount);
    }

}