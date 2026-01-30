// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// @title IDecentralMart
// @author Batch 3
// @notice Interface for the DecentralMart eCommerce DApp
// @dev Defines all external functions for the marketplace

interface IDecentralMart {

    //Seller Functions

    function registerSeller(
        string calldata shopName, 
        string calldata shopDescription
        ) external;

    function listProduct (
        string calldata name, 
        string calldata description, 
        uint256 price, 
        uint256 quantity, 
        string calldata category) external returns (uint256 productId);

    function updateProduct(
        uint256 productId,
        uint256 price,
        uint256 quantity,
        bool isActive
    ) external; 

    function withdrawEarnings() external; 

    //Buyer Functions

    function purchaseProduct(uint256 productId, uint256 quantity) external payable;
    
    function confirmDelivery(uint256 orderId) external;

    function requestRefund(uint256 orderId, string calldata reason) external;


    function raiseDispute(uint256 orderId, string calldata description) external;

    //View Functions

    function getProduct(uint256 productId) external view returns (
        string memory name, 
        string memory description,
        uint256 price,
        uint256 quantity,
        address seller,
        bool isActive
    );

    function getOrder(uint256 orderId) external view returns(
        uint256 productId,
        address buyer,
        address seller,
        uint256 quantity,
        uint256 totalPrice,
        uint8 status,
        uint256 createdAt
    );

    function getSellerInfo(address seller) external view returns(
        string memory shopName,
        string memory shopDescription,
        uint256 totalSales,
        uint256 earnings,
        bool isActive,
        uint256 registeredAt
    );
}