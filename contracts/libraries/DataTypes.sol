// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// @title DataTypes
// @author Batch 3
// @notice Library containing all custom data types for DecentralMart
// @dev All structs and enums used across the platform/project

library DataTypes {
    //Enums

    enum OrderStatus {
        Pending, //Order placed, awaiting for shipment
        Shipped, //Seller has shipped the product
        Delivered, //buyer confirmed delivery
        Cancelled, //Order cancelled before shipment
        Refunded, //Refunded processed
        Disputed //Order is under dispute
    }

    enum DisputeStatus {
        None, 
        Open, 
        UnderReview,
        ResolvedBuyer,
        ResolvedSeller
    }


    // All structs

    struct Seller {
        string shopName;
        string shopDescription;
        address sellerAddress;
        uint256 totalSales;
        uint256 earnings;
        bool isActive;
        uint256 registeredAt;
    }

    struct Product {
        uint256 id;
        string name;
        string description;
        uint256 price;
        uint256 quantity;
        string category;
        address seller;
        bool isActive;
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct Order {
        uint256 id;
        uint256 productId;
        address buyer;
        address seller;
        uint256 quantity;
        uint256 totalPrice;
        OrderStatus status;
        DisputeStatus disputeStatus; 
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct Dispute {
        uint256 orderId;
        address complainant;
        string description;
        DisputeStatus status;
        uint256 createdAt;
        uint256 resolvedAt;
    }
}