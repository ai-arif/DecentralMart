import Image from "next/image";
import Link from "next/link";
import Navbar from "@/components/Navbar";

import ConnectWallet from "@/components/ConnectWallet";

export default function Home() {
  return (
    <main>
      <nav>
        <h1>DecentralMart</h1>
        <ConnectWallet />
      </nav>

      <div>
        <Navbar />
      </div>

      <section>
        <h2>
          <span>Decentralized</span>
          <span>eCommerce Platform</span>
        </h2>
      </section>

      <p>
        Buy and Sell products with crypto. No middleman, no fees, just peer to
        peer ecommerce. Powered by NonAcademy.
      </p>

      <div>
        <button>Start Shopping</button>
        <button>Become a Seller</button>
      </div>

      <section>
        <h3>Why DecentralMart</h3>

        <div>
          <div>
            <div>
              <h4>Full Decentralized</h4>
              <p>
                No central authority. All transactions are handled by smart
                contracts on the Ethereum
              </p>
            </div>
            <div>
              <h4>Full Decentralized</h4>
              <p>
                No central authority. All transactions are handled by smart
                contracts on the Ethereum
              </p>
            </div>
            <div>
              <h4>Full Decentralized</h4>
              <p>
                No central authority. All transactions are handled by smart
                contracts on the Ethereum
              </p>
            </div>
          </div>
        </div>
      </section>

      <footer>
        <p>Built with Love by NonAcademy Batch 3 | Powered by Ethereum</p>
      </footer>
    </main>
  );
}
