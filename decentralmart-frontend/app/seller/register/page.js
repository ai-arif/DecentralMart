"use client";

import { useState } from "react";
import { useAccount } from "wagmi";
import { userRegisterSeller } from "@/hooks/useContract";
import Navbar from "@/components/Navbar";
import { form } from "viem/chains";

export default function SellerRegisterPage() {
  const [shopName, setShopName] = useState("");
  const [shopDescription, setShopDescription] = useState("");

  const { isConnected } = useAccount();

  const { registerSeller, isPending, isSuccess, isError, error, hash } =
    userRegisterSeller();

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!shopName.trim() || !shopDescription.trim()) {
      alert("Please fill in all fields");
      return;
    }

    registerSeller(shopName.trim(), shopDescription.trim());

    return (
      <div>
        <Navbar />

        <main>
          <div>
            <h1>Become a Seller</h1>
            <p>Register your shop and start selling on DecentralMart</p>
          </div>

          {!isConnected ? (
            <div>
              <p>Please connect your wallet first</p>

              <p>
                You need to connect your MetaMask wallet to register as a seller
              </p>
            </div>
          ) : (
            <form onSubmit={handleSubmit}>
              <div>
                <label htmlFor="shopName">Shop Name</label>
                <input
                  type="text"
                  id="shopName"
                  value={shopName}
                  onChange={(e) => setShopName(e.target.value)}
                  placeholder="Enter your shop name"
                  disabled={isPending}
                />
              </div>
              <div>
                <label htmlFor="shopDescription">Shop Description</label>
                <textarea
                  id="shopDescription"
                  value={shopDescription}
                  onChange={(e) => setShopDescription(e.target.value)}
                  placeholder="Describe your shop and what you sell"
                  disabled={isPending}
                />
              </div>

              <button type="submit" disabled={isPending}>
                {isPending ? "Registering..." : "Register as Seller"}
              </button>

              {isSuccess && (
                <div>
                  <p>Successfully registered as a seller</p>
                  {hash && <p>Transaction Hash: {hash}</p>}
                </div>
              )}

              {isError && (
                <div>
                  <p>Registration Failed</p>

                  <p>
                    {error?.message || "Something went wrong, please try again"}
                  </p>
                </div>
              )}
            </form>
          )}
        </main>
      </div>
    );
  };
}
