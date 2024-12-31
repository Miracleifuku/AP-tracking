# Artisanal Provenance Tracking System

## Overview
The Artisanal Provenance Tracking System is a smart contract written in Clarity that enables the tracking of artisanal goods from their creators to collectors. This system ensures verified authenticity and maintains a transparent record of transactions and ownership changes.

## Features
- **Artisan Registration:** Allows artisans to register themselves and be authenticated by the contract owner.
- **Item Crafting:** Enables artisans to create and register items they produce.
- **Provenance Tracking:** Records the history of an item as it changes hands, including ownership and venue details.
- **Authenticity Verification:** Ensures items are authenticated by the artisan and tracks their authenticity status.
- **Secure Transactions:** Facilitates the transfer of ownership and payment processing for items.

## Data Structures

### Constants
- **`contract-owner`:** The address of the contract owner.
- **Error Codes:** Predefined error codes for managing exceptions.
  - `err-owner-only` (u100): Only the contract owner can perform this action.
  - `err-not-artisan` (u101): Action restricted to registered artisans.
  - `err-invalid-item` (u102): Item does not exist.
  - `err-invalid-status` (u103): Invalid status update.
  - `err-unauthorized` (u104): Unauthorized access or action.
  - `err-already-exists` (u105): Entity already exists.

### Variables
- **`last-item-id` (uint):** Tracks the ID of the last created item.

### Maps
- **`artisans`:** Stores artisan details with their address as the key.
- **`items`:** Stores item details, including artisan, status, and current keeper.
- **`provenance-records`:** Stores provenance records for items.

## Functions

### Read-Only Functions
- **`get-item-details (item-id uint):** Retrieves details of a specific item.
- **`get-artisan (address principal):** Retrieves details of a specific artisan.
- **`get-provenance-record (item-id uint, record-number uint):** Retrieves a specific provenance record.

### Artisan Management
- **`register-artisan (name (string-ascii 50)):** Allows a user to register as an artisan.
- **`authenticate-artisan (artisan principal):** Enables the contract owner to authenticate an artisan.

### Item Management
- **`craft-item (name (string-ascii 50), authenticated bool, value uint):** Allows an artisan to craft and register a new item.

### Provenance Tracking
- **`record-provenance (item-id uint, record-number uint, venue (string-ascii 50)):** Records a provenance event for an item.

### Transfer and Payment
- **`transfer-item (item-id uint, recipient principal):** Transfers ownership of an item to a new keeper.
- **`process-transaction (item-id uint):** Processes a purchase transaction for an item.

### Authentication Verification
- **`verify-authenticity (item-id uint):** Verifies the authenticity of an item.

## Usage Workflow

### 1. Artisan Registration
1. An artisan calls `register-artisan` with their name.
2. The contract owner authenticates the artisan using `authenticate-artisan`.

### 2. Crafting Items
1. The authenticated artisan crafts an item using `craft-item`.
2. The item details, including its authentication status, are stored in the contract.

### 3. Tracking Provenance
1. The current keeper of an item records provenance using `record-provenance`.
2. Provenance details such as the venue and timestamp are added to the records.

### 4. Ownership Transfer
1. The current keeper transfers the item to a new keeper using `transfer-item`.
2. Optionally, a transaction can be processed using `process-transaction` to complete a sale.

### 5. Verifying Authenticity
1. Any user can call `verify-authenticity` to check if an item is authenticated.

## Error Handling
The contract uses `asserts!` to validate inputs and enforce permissions. Error codes help identify issues, such as unauthorized access or invalid data.

## Development
This smart contract is written in Clarity, the smart contract language for the Stacks blockchain. Clarity offers predictable execution and transparency.

### Prerequisites
- [Stacks Blockchain](https://stacks.co/)
- A Clarity-compatible development environment

### Deployment
1. Clone the repository.
2. Deploy the contract to a Stacks testnet or mainnet.
3. Interact with the contract using Clarity tools or a front-end interface.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

---
For questions or contributions, please open an issue or submit a pull request on the repository.

