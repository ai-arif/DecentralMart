"use client";

import { useState } from "react";
import Link from "next/link";
import ConnectWallet from "./ConnectWallet";

export default function Navbar() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const navLinks = [
    { name: "Home", href: "/" },
    { name: "Products", href: "/products" },
    { name: "Become a Seller", href: "/seller/register" },
    { name: "Dashboard", href: "/dashboard" },
  ];

  return (
    <nav>
      <div>
        <div>
          <Link href="/">
            <span>Decentral Mart</span>
          </Link>

          <div>
            {navLinks.map((link) => (
              <Link key={link.name} href={link.href}>
                {link.name}
              </Link>
            ))}
          </div>
          <div>
            <div>
              <ConnectWallet />
            </div>

            <button onClick={() => setIsMenuOpen(!isMenuOpen)}>
              {isMenuOpen ? <h3>x</h3> : <h3>=</h3>}
            </button>
          </div>
        </div>
      </div>

      {isMenuOpen && (
        <div>
          <div>
            {navLinks.map((link) => (
              <Link
                key={link.name}
                href={link.href}
                onClick={() => setIsMenuOpen(false)}
              >
                {link.name}
              </Link>
            ))}

            <div>
              <ConnectWallet />
            </div>
          </div>
        </div>
      )}
    </nav>
  );
}
