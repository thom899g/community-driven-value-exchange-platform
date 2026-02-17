from web3 import Web3, contract
import json

class CommunityVotingModule:
    def __init__(self, provider_url: str, abi_path: str):
        self.w3 = Web3(Web3.HTTPProvider(provider_url))
        with open(abi_path) as f:
            self.abi = json.load(f)
        self.contract = self.w3.eth.contract(address='CONTRACT_ADDRESS', abi=self.abi)

    def cast_vote(self, project_id: int, voter_address: str) -> bool:
        try:
            tx = self.contract.functions.vote(project_id).transact({'from': voter_address})
            return True
        except Exception as e:
            print(f"Voting failed: {str(e)}")
            return False

    def get_project_info(self, project_id: int) -> Dict[str, Any]:
        try:
            name, description, target = self.contract.functions.getProject(project_id).call()
            return {'name': name, 'description': description, 'target': target}
        except Exception as e:
            print(f"Failed to retrieve project info: {str(e)}")
            return {}