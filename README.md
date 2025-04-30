# ArtifactLedger

## A Decentralized Historical Artifact Authentication and Provenance Platform

ArtifactLedger is a blockchain-based system built on Stacks that provides a transparent, immutable record of historical artifact authentication and provenance. The platform connects heritage institutions (museums, galleries, universities) with professional authenticators, creating a trusted ecosystem for artifact verification and historical record-keeping.

## Overview

ArtifactLedger addresses the challenges in the artifact authentication industry:

1. **Provenance Verification**: Establishing an immutable record of an artifact's history and authentication
2. **Expert Authentication**: Connecting qualified authenticators with institutions
3. **Transparency**: Creating open records of authentication processes
4. **Fraud Prevention**: Reducing forgeries and misattributions through blockchain verification

## Key Features

- **Institutional Registration**: Museums and heritage institutions can register on the platform
- **Authenticator Certification**: Professional authenticators can register and build reputation
- **Artifact Registration**: Institutions can register artifacts with detailed information
- **Authentication Requests**: Authenticators can bid on authentication jobs
- **Immutable Records**: All verifications are permanently recorded on the blockchain
- **Trust Scoring**: Both institutions and authenticators develop reputation scores
- **Fee Management**: Transparent fee structures for authentication services

## Smart Contract Structure

The platform consists of a single smart contract (`artifact-ledger.clar`) with several key components:

### Data Maps

- `heritage-institutions`: Stores information about registered museums and institutions
- `authenticators`: Maintains records of professional artifact authenticators
- `historical-items`: Contains detailed information about registered artifacts
- `authentication-records`: Tracks all authentication processes and their outcomes

### Key Functions

- `register-institution`: Allows museums to join the platform
- `register-authenticator`: Enables experts to offer authentication services
- `register-historical-item`: Lets institutions add artifacts to the registry
- `request-item-authentication`: Initiates the authentication process

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development environment
- [Stacks Wallet](https://www.hiro.so/wallet) - For transaction signing

### Installation

1. Clone the repository
```bash
git clone https://github.com/davesvill/artifactledger.git
cd artifactledger
```

2. Install dependencies
```bash
npm install
```

3. Deploy contract using Clarinet
```bash
clarinet contract deploy
```

## Usage Example

```clarity
;; Register as a heritage institution
(contract-call? .artifact-ledger register-institution)

;; Register as an authenticator
(contract-call? .artifact-ledger register-authenticator "Ancient Mesopotamian Artifacts")

;; Register a historical item
(contract-call? .artifact-ledger register-historical-item 
    "Neo-Babylonian Period" 
    u10000
    u500000
    u1
    u5
    "Clay tablet with cuneiform script describing agricultural practices"
    "Southern Iraq, Tell el-Muqayyar"
    true
)

;; Request authentication
(contract-call? .artifact-ledger request-item-authentication u0 u2 "Cuneiform analysis and clay composition")
```

## Future Enhancements

- Integration with physical authentication tools (spectroscopy, carbon dating)
- NFT creation for authenticated artifacts
- Marketplace for authenticated artifacts
- Multi-signature authentication for high-value items
- Decentralized governance for platform parameters

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- The Stacks Foundation
- The global community of archeologists and conservationists
- Museums and institutions committed to artifact provenance transparency