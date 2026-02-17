import os
from web3 import Web3
from decimal import Decimal

class PaymentModule:
    def __init__(self, provider_url: str):
        self.w3 = Web3(Web3.HTTPProvider(provider_url))
        self.token_address = os.getenv('TOKEN_ADDRESS')

    def process_payment(self, amount: Decimal, sender_address: str) -> bool:
        try:
            # Convert amount to Wei
            amount_wei = int(amount * 10**18)
            tx = {
                'from': sender_address,
                'to': self.token_address,
                'value': amount_wei,
                'gas': 200000,
                'gasPrice': Web3.toWei(50, 'gwei'),
                'nonce': self.w3.eth.get_transaction_count(sender_address)
            }
            signed_tx = self.w3.eth.sign_transaction(tx)
            tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)
            return True
        except Exception as e:
            print(f"Payment failed: {str(e)}")
            return False

    def get_balance(self, address: str