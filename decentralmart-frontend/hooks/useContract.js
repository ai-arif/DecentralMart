"use client";

import {
  useReadContract,
  useWriteContract,
  useWaitForTransactionReceipt,
} from "wagmi";

import { parseEther } from "viem";
import { CONTRACT_ADDRESS, CONTRACT_ABI } from "@/constants/contract";

export function useGetTotalProducts() {
  return useReadContract({
    address: CONTRACT_ADDRESS,
    abi: CONTRACT_ABI,
    functionName: "getTotalProducts",
  });
}

export function useGetTotalOrders() {
  return useReadContract({
    address: CONTRACT_ADDRESS,
    abi: CONTRACT_ABI,
    functionName: "getTotalOrders",
  });
}

export function useGetProduct(productId) {
  return useReadContract({
    address: CONTRACT_ADDRESS,
    abi: CONTRACT_ABI,
    functionName: "getProduct",
    args: [productId],
  });
}

export function useGetOrder(orderId) {
  return useReadContract({
    address: CONTRACT_ADDRESS,
    abi: CONTRACT_ABI,
    functionName: "getOrder",
    args: [orderId],
  });
}

export function useGetSellerInfo(sellerAddress) {
  return useReadContract({
    address: CONTRACT_ADDRESS,
    abi: CONTRACT_ABI,
    functionName: "getSellerInfo",
    args: [sellerAddress],

    enabled: !!sellerAddress,
  });
}

export function useGetSellerProducts(sellerAddress) {
  return useReadContract({
    address: CONTRACT_ADDRESS,
    abi: CONTRACT_ABI,
    functionName: "getSellerProductsIds",
    args: [sellerAddress],

    enabled: !!sellerAddress,
  });
}

export function useGetBuyerOrders(buyerAddress) {
  return useReadContract({
    address: CONTRACT_ADDRESS,
    abi: CONTRACT_ABI,
    functionName: "getBuyerOrderIds",
    args: [buyerAddress],

    enabled: !!buyerAddress,
  });
}

export function useGetPlatformFee() {
  return useReadContract({
    address: CONTRACT_ADDRESS,
    abi: CONTRACT_ABI,
    functionName: "platformFeePercent",
  });
}
