 # TokenVault: Unlocking Asset Potential

## Vision

The vision behind TokenVault is to transform the way we manage and trade assets by leveraging the power of blockchain technology. Traditional asset management systems often lack transparency, liquidity, and accessibility. By tokenizing a wide variety of real-world assets, TokenVault aims to democratize access to investments, enhance transparency, and unlock liquidity. Our goal is to create a more inclusive and efficient financial ecosystem where anyone can easily and securely invest in tokenized assets.

### Inspiration

The inspiration for TokenVault came from observing the limitations and inefficiencies in traditional asset management. Many valuable assets are illiquid and difficult to trade, which restricts their potential value. Blockchain technology offers a solution by enabling the tokenization of these assets, making them easily tradable and accessible to a broader audience. This concept inspired us to develop a platform that bridges the gap between traditional finance and the emerging blockchain ecosystem.

## What It Does

TokenVault enables users to:
- Tokenize a wide variety of real-world assets.
- Manage and trade tokens representing these assets.
- Redeem tokens to obtain the equivalent value of the underlying assets.

## How We Built It

### Smart Contracts

The core of TokenVault is built on a series of smart contracts designed to manage the tokenization process efficiently and securely. Here's a detailed look at each contract and its purpose:

1. **Mint Requests Contract**: 
   - Handles minting requests for new tokens.
   - Ensures that only authorized entities can initiate minting, maintaining the integrity and trustworthiness of the tokenization process.

2. **Redeem Requests Contract**: 
   - Manages requests to redeem tokens back into their underlying assets.
   - Verifies the authenticity of the tokens being redeemed and ensures that users receive the correct equivalent value of the underlying assets.

3. **Collateral Tokens Contract**: 
   - Issues tokens based on the collateralization of an asset.
   - Ensures that the value of the issued tokens is backed by the corresponding real-world asset, providing stability and trust.

4. **Asset Manager Contract**: 
   - Manages the other smart contracts and handles different assets.
   - Acts as the central authority that oversees the tokenization process, ensuring smooth operation and integration between the various components.

5. **Redemption Contract**: 
   - Manages the process of redeeming tokens for their equivalent asset value.
   - Ensures that the redemption process is secure, efficient, and accurate, maintaining user trust and satisfaction.

### Technologies Used in Smart Contracts

To ensure the accuracy and reliability of our smart contracts, we incorporated several key technologies:
- **Solidity**: The primary programming language used for writing our smart contracts. Solidity's robust features and widespread adoption make it ideal for developing secure and efficient smart contracts.
- **Chainlink Data Feeds**: Used to provide real-time price information for tokens like USDT, ensuring that our smart contracts always have access to accurate and up-to-date data.
- **Chainlink Functions**: Facilitate seamless interaction between smart contracts and our backend API, enabling efficient data retrieval and communication.

### Backend Development

For the backend, we utilized **NestJS** to develop a RESTful API. This API is deployed on an **EC2 instance** using **Docker** and **GitHub Actions** for continuous integration and deployment. The backend serves as the central hub where web2 data is stored, including user information, available assets, and different stocks.

### Caching

To make requests faster and less resource-intensive, we implemented caching with NestJS. This optimization was crucial for ensuring that the requests executed by Chainlink Functions were efficient and cost-effective, minimizing gas usage and improving overall performance.

## Challenges We Ran Into

1. **Integrating Angular with NestJS**: Ensuring seamless communication between frontend and backend required meticulous API design and thorough testing.
2. **Smart Contract Development**: Writing and deploying smart contracts required a deep understanding of Solidity and careful consideration of security and efficiency.
3. **Chainlink Functions Integration**: Managing the callbacks with minimal gas usage was complex and posed significant challenges.
4. **Caching with NestJS**: Implementing caching to make requests faster and less resource-intensive was crucial for efficient execution by Chainlink Functions.
5. **Continuous Deployment**: Setting up an automated CI/CD pipeline using GitHub Actions and Docker presented several challenges, especially in managing dependencies and ensuring reliable deployments.

## Accomplishments That We're Proud Of

- Successfully developing and deploying a robust system integrating various technologies.
- Overcoming challenges in smart contract development and efficient gas management.
- Setting up a reliable CI/CD pipeline to streamline our development process.

## What We Learned

Throughout this project, we gained extensive knowledge in:
- Smart contract development and blockchain integration.
- Implementing Chainlink data feeds and functions.
- Optimizing backend performance with NestJS caching.
- Setting up and managing continuous integration and deployment pipelines.

## What's Next for TokenVault: Unlocking Asset Potential

Moving forward, we plan to:
- Complete the development of the React application for a seamless user interface.
- Enhance TokenVault by adding more asset types and improving the user experience.
- Refine our smart contracts and backend systems for better security, efficiency, and scalability.
- Integrate **Cross-Chain Interoperability Protocol (CCIP)** to eliminate blockchain boundaries and make the platform more accessible to users across different blockchain networks.

## Requirements

- **Git**
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`.

- **Foundry**
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`.

- **Node**
  - You'll know you did it right if you can run `node --version` and you see a response like `v16.13.0`.

- **npm**
  - You'll know you did it right if you can run `npm --version` and you see a response like `8.1.0`.

- **Deno**
  - You'll know you did it right if you can run `deno --version` and you see a response like `deno 1.40.5 (release, x86_64-apple-darwin) v8 12.1.285.27 typescript 5.3.3`.
