// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title Reserve Proof interface V1.0
/// @notice interface for reserve proof of the backed assets BOG Ghana Gold Coin
/// @author geeloko.eth

interface IReserveProof {
    /// @notice Get the price per ounce of gold in USD with 18 decimals.
    function pricePerOzUSD() external view returns (uint256);


    /// @notice Get the total supply of the reserve proof.s
    function totalSupply() external view returns (uint256);
}