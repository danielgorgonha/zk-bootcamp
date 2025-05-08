from web3 import Web3
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

token_abi = [
    {"name": "name", "outputs": [{"type": "string"}], "inputs": [], "stateMutability": "view", "type": "function"},
    {"name": "symbol", "outputs": [{"type": "string"}], "inputs": [], "stateMutability": "view", "type": "function"},
    {"name": "decimals", "outputs": [{"type": "uint8"}], "inputs": [], "stateMutability": "view", "type": "function"},
    {"name": "totalSupply", "outputs": [{"type": "uint256"}], "inputs": [], "stateMutability": "view", "type": "function"},
    {"name": "balanceOf", "outputs": [{"type": "uint256"}], "inputs": [{"type": "address"}], "stateMutability": "view", "type": "function"},
    {"name": "transfer", "outputs": [{"type": "bool"}], "inputs": [{"type": "address"}, {"type": "uint256"}], "stateMutability": "nonpayable", "type": "function"},
    {"name": "mint", "outputs": [], "inputs": [{"type": "address"}, {"type": "uint256"}], "stateMutability": "nonpayable", "type": "function"},
    {"name": "approve", "outputs": [{"type": "bool"}], "inputs": [{"type": "address"}, {"type": "uint256"}], "stateMutability": "nonpayable", "type": "function"},
    {"name": "transferFrom", "outputs": [{"type": "bool"}], "inputs": [{"type": "address"}, {"type": "address"}, {"type": "uint256"}], "stateMutability": "nonpayable", "type": "function"},
    {"name": "allowance", "outputs": [{"type": "uint256"}], "inputs": [{"type": "address"}, {"type": "address"}], "stateMutability": "view", "type": "function"},
    {"name": "increaseAllowance", "outputs": [{"type": "bool"}], "inputs": [{"type": "address"}, {"type": "uint256"}], "stateMutability": "nonpayable", "type": "function"},
    {"name": "decreaseAllowance", "outputs": [{"type": "bool"}], "inputs": [{"type": "address"}, {"type": "uint256"}], "stateMutability": "nonpayable", "type": "function"},
]

# Connect to Sepolia testnet
w3 = Web3(Web3.HTTPProvider(os.getenv('SEPOLIA_RPC_URL')))

# Verify connection
if not w3.is_connected():
    raise Exception("Could not connect to Sepolia network")

# Contract address deployed on Sepolia
contract_address = os.getenv('CONTRACT_ADDRESS')
contract = w3.eth.contract(address=w3.to_checksum_address(contract_address), abi=token_abi)

# Account that will interact (your account)
wallet_address = w3.to_checksum_address(os.getenv('WALLET_ADDRESS'))

# Load private key from .env
private_key = os.getenv('PRIVATE_KEY')

def get_token_info():
    """Get basic token information"""
    print("\n=== Token Information ===")
    print("Name:", contract.functions.name().call())
    print("Symbol:", contract.functions.symbol().call())
    print("Decimals:", contract.functions.decimals().call())
    print("Total Supply:", contract.functions.totalSupply().call() / 10**18)
    print("Account Balance:", contract.functions.balanceOf(wallet_address).call() / 10**18)

def transfer_tokens(to_address, amount):
    """Transfer tokens to another address"""
    try:
        # Prepare transaction
        nonce = w3.eth.get_transaction_count(wallet_address)
        amount_wei = int(amount * 10**18)  # Convert to wei
        
        # Build transaction
        transaction = contract.functions.transfer(
            w3.to_checksum_address(to_address),
            amount_wei
        ).build_transaction({
            'from': wallet_address,
            'nonce': nonce,
            'gas': 200000,
            'gasPrice': w3.eth.gas_price
        })
        
        # Sign and send transaction
        signed_txn = w3.eth.account.sign_transaction(transaction, private_key)
        tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        
        # Wait for confirmation
        receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        print(f"\nTransfer successful!")
        print(f"Transaction hash: {receipt['transactionHash'].hex()}")
        
    except Exception as e:
        print(f"\nTransfer error: {str(e)}")

def main():
    # Display token information
    get_token_info()
    
    # Example transfer (uncomment and adjust values)
    # transfer_tokens("DESTINATION_ADDRESS", 1.0)  # Transfer 1 token

if __name__ == "__main__":
    main()

