from web3 import Web3
import os
from dotenv import load_dotenv

# Carrega as variáveis do arquivo .env
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

# Conexão com a Sepolia testnet
w3 = Web3(Web3.HTTPProvider(os.getenv('SEPOLIA_RPC_URL')))

# Verifica a conexão
if not w3.is_connected():
    raise Exception("Não foi possível conectar à rede Sepolia")

# Endereço do contrato implantado na Sepolia
contract_address = os.getenv('CONTRACT_ADDRESS')
contract = w3.eth.contract(address=w3.to_checksum_address(contract_address), abi=token_abi)

# Conta que vai interagir (sua conta)
wallet_address = w3.to_checksum_address(os.getenv('WALLET_ADDRESS'))

# Carrega a chave privada do .env
private_key = os.getenv('PRIVATE_KEY')

def get_token_info():
    """Obtém informações básicas do token"""
    print("\n=== Informações do Token ===")
    print("Nome:", contract.functions.name().call())
    print("Símbolo:", contract.functions.symbol().call())
    print("Decimais:", contract.functions.decimals().call())
    print("Total Supply:", contract.functions.totalSupply().call() / 10**18)
    print("Saldo da conta:", contract.functions.balanceOf(wallet_address).call() / 10**18)

def transfer_tokens(to_address, amount):
    """Transfere tokens para outro endereço"""
    try:
        # Prepara a transação
        nonce = w3.eth.get_transaction_count(wallet_address)
        amount_wei = int(amount * 10**18)  # Converte para wei
        
        # Constrói a transação
        transaction = contract.functions.transfer(
            w3.to_checksum_address(to_address),
            amount_wei
        ).build_transaction({
            'from': wallet_address,
            'nonce': nonce,
            'gas': 200000,
            'gasPrice': w3.eth.gas_price
        })
        
        # Assina e envia a transação
        signed_txn = w3.eth.account.sign_transaction(transaction, private_key)
        tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        
        # Aguarda a confirmação
        receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        print(f"\nTransferência realizada com sucesso!")
        print(f"Hash da transação: {receipt['transactionHash'].hex()}")
        
    except Exception as e:
        print(f"\nErro na transferência: {str(e)}")

def main():
    # Exibe informações do token
    get_token_info()
    
    # Exemplo de transferência (descomente e ajuste os valores)
    # transfer_tokens("ENDERECO_DESTINO", 1.0)  # Transfere 1 token

if __name__ == "__main__":
    main()

