// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {DataTypes} from "./DataTypes.sol";


// @title Events
// @author Batch 3
// @notice Library containing all events for DecentralMart
// @dev Events are used for off-chain tracking and frontend updates

library Events { 
    // SELLER EVENTS

    event SellerRegistered(
        address indexed seller,
        string shopName,
        uint256 timestamp
    );

    event SellerUpdate(
        address indexed seller,
        string shopName,
        uint256 timestamp
    );

    event EarningsWithdrawn(
        address indexed seller,
        uint256 amount,
        uint256 timestamp
    );



    //PRODUCTS EVENT

    event ProductListed(
        uint256 indexed productId,
        address indexed seller,
        string name,
        uint256 price,
        uint256 quantity
    );

    event ProductUpdated(
        uint256 indexed productId,
        uint256 price,
        uint256 quantity,
        bool isActive
    );


    //ORDER EVENTS

    event OrderPlaced(
        uint256 indexed orderId,
        uint256 indexed productId,
        address indexed buyer,
        address seller,
        uint256 quantity,
        uint256 totalPrice
    );

    event OrderStatusChanged(
        uint256 indexed orderId,
        DataTypes.OrderStatus oldStatus,
        DataTypes.OrderStatus newStatus,
        uint256 timestamp
    );

    event DeliveryConfirmed(
        uint256 indexed orderId,
        address indexed buyer,
        uint256 timestamp
    );

    //DISPUTE EVENTS

    event DisputeRaised(
        uint256 indexed orderId,
        address indexed complaint,
        string description,
        uint256 timestamp
    );

    event DisputeResolved(
        uint256 indexed orderId,
        DataTypes.DisputeStatus status,
        uint256 timestamp
    );


    //REFUND REQUEST

    event RefundRequest(
        uint256 indexed orderId,
        address indexed buyer,
        string reason,
        uint256 timestamp
    );

    event RefundProcessed(
        uint256 indexed orderId,
        address indexed buyer,
        uint256 amount,
        uint256 timestamp
    );



}