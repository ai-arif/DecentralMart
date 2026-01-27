// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// @title DecentralMart
// @author Batch 3
// @notice A decentralized ecommerce marketplace on the blockchain
// @dev Implements secure buying/selling with escrow and dispute resolution

// Security Features:
// -ReentrancyGuard: Prevents reentrancy attacks on Withdrawls
// -CEI Patter: Checks-Effects-Interactions for safe external calls
// -Custom Errors: Gas-efficient error handling
// -Access control: Ownable for admin functions

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IDecentralMart} from "./interfaces/IDecentralMart.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {Errors} from "./libraries/Errors.sol";
import {Events} from "./libraries/Events.sol";


contract DecentralMart is IDecentralMart, ReentrancyGuard, Ownable{
    //State Variables

    uint256 private _productIdCounter;

    uint256 private _orderIdCounter;

    uint256 public platformFeePercent;

    uint256 public platformEarnings;



    //Mapping

    mapping(address => DataTypes.Seller) public sellers;

    mapping(uint256 => DataTypes.Product) public products;

    mapping(uint256 => DataTypes.Order) public orders;

    mapping(uint256 => DataTypes.Dispute) public disputes;

    mapping(address => uint256[]) public buyerOrders;

    mapping(address => uint256[]) public sellerProducts;

    mapping (address => uint256[]) public sellerOrders;

    //Modifiers

    modifier onlySeller(){
        if(!sellers[msg.sender].isActive){
            revert Errors.NotASeller();
        }
        _;
    }

    modifier validProduct(uint256 productId){
        if(productId == 0 || productId > _productIdCounter){
            revert Errors.ProductNotFound();
        }

        if(!products[productId].isActive){
            revert Errors.ProductNotActive();
        }
        _;
    }

    modifier validOrder(uint256 orderId){
        if(orderId == 0 || orderId > _orderIdCounter){
            revert Errors.OrderNotFound();
        }
        _;
    }

    //Constructor

    constructor (uint256 _platformFeePercent) Ownable(msg.sender) {
        platformFeePercent == _platformFeePercent;
    }

    // Seller Functions

    function registerSeller(
        string calldata shopName,
        string calldata shopDescription
    ) external override {
        if(sellers[msg.sender].isActive){
            revert Errors.AlreadySeller();
        }

        if(bytes(shopName).length == 0 ){
            revert Errors.InvalidShopName();
        }

        if(bytes(shopDescription).length == 0){
            revert Errors.InvalidShopDescription();
        }

        sellers[msg.sender] = DataTypes.Seller({
            shopName: shopName,
            shopDescription: shopDescription,
            sellerAddress: msg.sender,
            totalSales: 0,
            earnings: 0,
            isActive: true,
            registeredAt: block.timestamp
        });

        emit Events.SellerRegistered(msg.sender, shopName, block.timestamp);
    }


    function listProduct(
        string calldata name, 
        string calldata description, 
        uint256 price,
        uint256 quantity,
        string calldata category
    ) external override onlySeller returns(uint256 productId){
        if(bytes(name).length == 0){
            revert Errors.InvalidProductName();
        }

        if(price == 0){
            revert Errors.InvalidPrice();
        }

        if(quantity == 0){
            revert Errors.InvalidQuantity();
        }

        _productIdCounter++;
        productId = _productIdCounter;

        products[productId] = DataTypes.Product({
            id: productId,
            name: name,
            description: description,
            price: price,
            quantity: quantity,
            category: category,
            seller: msg.sender,
            isActive: true,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        sellerProducts[msg.sender].push(productId);

        emit Events.ProductListed(productId, msg.sender, name, price, quantity);

        return productId;
    }

    function updateProduct(
        uint256 productId,
        uint256 price,
        uint256 quantity,
        bool isActive
    ) external override {
        if(productId == 0 || productId > _productIdCounter){
            revert Errors.ProductNotFound();
        }

        if(products[productId].seller != msg.sender){
            revert Errors.NotProductOwner();
        }

        if(price == 0){
            revert Errors.InvalidPrice();
        }

        DataTypes.Product storage product = products[productId];

        product.price = price;
        product.quantity = quantity;
        product.isActive = isActive;
        product.updatedAt = block.timestamp;

        emit Events.ProductUpdated(productId, price, quantity, isActive);
    }

    function withdrawEarnings() external override onlySeller nonReentrant { 
        uint256 amount = sellers[msg.sender].earnings;

        if(amount == 0) {
            revert Errors.NothingToWithdraw();
        }

        sellers[msg.sender].earnings = 0;

        (bool success,) = payable (msg.sender).call{value: amount}("");

        if(!success) {
            revert Errors.TransferFailed();
        }

        emit Events.EarningsWithdrawn(msg.sender, amount, block.timestamp);
    }


    function purchaseProduct(uint256 productId, uint256 quantity) external payable override validProduct(productId) nonReentrant{
        DataTypes.Product storage product = products[productId];

        if(product.seller == msg.sender){
            revert Errors.CannotBuyOwnProduct();
        }

        if(quantity == 0){
            revert Errors.InvalidQuantity();
        }

        if(product.quantity < quantity){
            revert Errors.InsufficientStock();
        }

        uint256 totalPrice = product.price * quantity;
        if(msg.value != totalPrice){
            revert Errors.IncorrectPayment();
        }

        _orderIdCounter++;
        uint256 orderId = _orderIdCounter;

        product.quantity -= quantity;

        uint256 platformFee = (totalPrice * platformFeePercent) / 10000;
        uint256 sellerAmount = totalPrice - platformFee;

        platformEarnings += platformFee;

        orders[orderId] = DataTypes.Order({
            id: orderId,
            productId: productId,
            buyer: msg.sender,
            seller: product.seller,
            quantity: quantity,
            totalPrice: totalPrice,
            status: DataTypes.OrderStatus.Pending,
            disputeStatus: DataTypes.DisputeStatus.None,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        buyerOrders[msg.sender].push(orderId);
        sellerOrders[product.seller].push(orderId);

        emit Events.OrderPlaced(
            orderId, productId, msg.sender, product.seller, quantity, totalPrice
        );
    }

    function confirmDelivery(uint256 orderId) external override validOrder(orderId) nonReentrant{
        DataTypes.Order storage order = orders[orderId];

        if(order.buyer != msg.sender){
            revert Errors.NotTheBuyer();
        }

        if(order.status != DataTypes.OrderStatus.Shipped)
        {

            revert Errors.InvalidOrderStatus();
        }    

    DataTypes.OrderStatus oldStatus = order.status;
    order.status = DataTypes.OrderStatus.Delivered;
    order.updatedAt = block.timestamp;

    uint256 platformFee = (order.totalPrice * platformFeePercent)/10000;
    uint256 sellerAmount = order.totalPrice - platformFee;
    platformEarnings += platformFee;
    sellers[order.seller].earnings += sellerAmount;
    sellers[order.seller].totalSales++;

    emit Events.OrderStatusChanged(orderId, oldStatus, DataTypes.OrderStatus.Delivered, block.timestamp);

    emit Events.DeliveryConfirmed(orderId, msg.sender, block.timestamp);

    }

    function requestRefund(uint256 orderId, string calldata reason) external override validOrder(orderId){{
        DataTypes.Order storage order = orders[orderId];

        if(order.buyer != msg.sender){
            revert Errors.NotTheBuyer();
        }

        if(order.status != DataTypes.OrderStatus.Pending){
            revert Errors.InvalidOrderStatus();
        }

        if(bytes(reason).length == 0){
            revert Errors.EmptyString();
        }

        emit Events.RefundRequest(orderId, msg.sender, reason, block.timestamp);
    }}


    function raiseDispute(uint256 orderId, string calldata description) external override validOrder(orderId) {
        DataTypes.Order storage order = orders[orderId];
        
        if(order.buyer != msg.sender && order.seller != msg.sender){
            revert Errors.Unauthorized();
        }

        if(

            order.status == DataTypes.OrderStatus.Delivered ||
            order.status == DataTypes.OrderStatus.Cancelled ||
            order.status == DataTypes.OrderStatus.Refunded

        )
        {
            revert Errors.OrderNotDisputable();
        }

        if(order.disputeStatus != DataTypes.DisputeStatus.None){
            revert Errors.DisputeAlreadyExists();
        }

        if(bytes(description).length == 0){
            revert Errors.EmptyString();
        }

        order.status = DataTypes.OrderStatus.Disputed;
        order.disputeStatus = DataTypes.DisputeStatus.Open;
        order.updatedAt = block.timestamp;

        disputes[orderId] = DataTypes.Dispute({
            orderId: orderId,
            complainant: msg.sender,
            description: description,
            status: DataTypes.DisputeStatus.Open,
            createdAt: block.timestamp,
            resolvedAt: 0
        });

        emit Events.DisputeRaised(orderId, msg.sender, description, block.timestamp);
    }

    function getProduct(uint256 productId) external view override returns(
        string memory name, 
        string memory description,
        uint256 price, 
        uint256 quantity,
        address seller, 
        bool isActive
    ) {
        DataTypes.Product storage product = products[productId];

        return (
            product.name, 
            product.description,
            product.price,
            product.quantity,
            product.seller,
            product.isActive
        );
    }

    // function confirmDelivery(uint256 orderId) external override validOrder(orderId) nonReentrant{
    //     DataTypes.Order storage order = orders[orderId];

    //     if(order.buyer != msg.sender){
    //         revert Errors.NotTheBuyer();
    //     }

    //     if(order.status != DataTypes.OrderStatus.Shipped){
    //         revert Errors.InvalidOrderStatus();
    //     }

    //     DataTypes.OrderStatus oldStatus = order.status;
    //     order.status = DataTypes.OrderStatus.Delivered;
    //     order.updatedAt = block.timestamp;
    // }

    function getOrder(uint256 orderId) external view override returns(
        uint256 productId,
        address buyer,
        address seller,
        uint256 quantity,
        uint256 totalPrice,
        uint8 status,
        uint256 createdAt
    ){
        DataTypes.Order storage order = orders[orderId];
        return (
            order.productId,
            order.buyer,
            order.seller,
            order.quantity,
            order.totalPrice,
            uint8(order.status),
            order.createdAt
        );
    }

    function getSellerInfo(address sellerAddress) external view override returns(

        string memory shopName,
        string memory shopDescription,
        uint256 totalSales,
        uint256 earnings,
        bool isActive,
        uint256 registeredAt

    ){
        DataTypes.Seller storage seller = sellers[sellerAddress];

        return (
            seller.shopName,
            seller.shopDescription,
            seller.totalSales,
            seller.earnings,
            seller.isActive,
            seller.registeredAt
            
        );
    }
    //Admin Functions

    function updatePlatformFee(uint256 newFeePercent) external onlyOwner{
        platformFeePercent = newFeePercent;
    }

    function withdrawPlatformFees() external onlyOwner nonReentrant {
        uint256 amount = platformEarnings;

        if(amount == 0){
            revert Errors.NothingToWithdraw();

            platformEarnings = 0;

            (bool success, ) = payable(owner()).call{value: amount}("");

            if(!success) {
                revert Errors.TransferFailed();
            }
        }
    }

    function markAsShipped(uint256 orderId) external validOrder(orderId){
        DataTypes.Order storage order = orders[orderId];

        if(order.seller != msg.sender){
            revert Errors.NotTheOrderSeller();

        }

        if(order.status != DataTypes.OrderStatus.Pending){
            revert Errors.InvalidOrderStatus();
        }

        DataTypes.OrderStatus oldStatus = order.status;
        order.status = DataTypes.OrderStatus.Shipped;
        order.updatedAt = block.timestamp;

        order.status = DataTypes.OrderStatus.Shipped;
        emit Events.OrderStatusChanged(orderId, oldStatus, DataTypes.OrderStatus.Shipped, block.timestamp);
    }

    //Helper Functions

    function getTotalProducts() external view returns(uint256) {
        return _productIdCounter;
    }

    function getTotalOrders() external view returns(uint256){
        return _orderIdCounter;
    }

    function getSellerProductIds(address seller) external view returns(uint256[] memory){
        return sellerProducts[seller];
    }

    function getBuyerOrderIds(address buyer) external view returns(uint256[] memory){
        return buyerOrders[buyer];
    }
}