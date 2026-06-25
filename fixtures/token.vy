# @version ^0.4.0

interface ERC20:
    def balanceOf(owner: address) -> uint256: view

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

struct Bid:
    bidder: address
    amount: uint256

owner: public(address)
total_supply: public(uint256)

@deploy
def __init__():
    self.owner = msg.sender

@external
@view
def balanceOf(owner: address) -> uint256:
    return self.total_supply

@external
def transfer(receiver: address, value: uint256) -> bool:
    assert receiver != empty(address)
    log Transfer(sender=msg.sender, receiver=receiver, value=value)
    return True
