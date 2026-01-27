// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


// @title Errors
// @author Batch 3
// @notice Library containing all custom errors for DecentralMart
// @dev Custom errors are more gas efficient than require strings

library Errors {
    //SELLER ERRORS

    error NotASeller();

    error AlreadySeller();

    error SellerNotActive();

    error InvalidShopName();

    error InvalidShopDescription();

    //PRODUCTS ERROR

    error ProductNotFound();

    error ProductNotActive();

    error InvalidProductName();

    error InvalidPrice();

    error InvalidQuantity();

    error InsufficientStock();

    error NotProductOwner();


    //ORDER ERRORS

    error OrderNotFound();

    error IncorrectPayment();

    error CannotBuyOwnProduct();

    error InvalidOrderStatus();

    error NotTheBuyer();

    error NotTheOrderSeller();


    //DISPUTE ERRORS

    error DisputeAlreadyExists();

    error DisputeNotFound();

    error OrderNotDisputable();

     
    // PAYMENT ERRORS

    error NothingToWithdraw();

    error TransferFailed();

    // General Errors

    error ZeroAddress();

    error Unauthorized();

    error EmptyString();
}