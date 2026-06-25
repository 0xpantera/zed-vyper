# @version ^0.4.0

from vyper.interfaces import ERC20

implements: ERC20

NAME: constant(String[32]) = "Example Token"
SYMBOL: constant(String[8]) = "EXT"
DECIMALS: constant(uint8) = 18
INITIAL_SUPPLY: constant(uint256) = 1_000_000 * 10**18

owner: public(address)
total_supply: public(uint256)
balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])

flag: transient(bool)

@deploy
def __init__():
    self.owner = msg.sender
    self.total_supply = INITIAL_SUPPLY
    self.balanceOf[msg.sender] = INITIAL_SUPPLY

@external
@view
def name() -> String[32]:
    return NAME

@external
@view
def symbol() -> String[8]:
    return SYMBOL

@external
@view
def decimals() -> uint8:
    return DECIMALS

@external
def approve(spender: address, amount: uint256) -> bool:
    self.allowance[msg.sender][spender] = amount
    return True

@external
def transfer(receiver: address, amount: uint256) -> bool:
    assert receiver != empty(address), "empty receiver"
    assert self.balanceOf[msg.sender] >= amount, "insufficient balance"
    self.balanceOf[msg.sender] -= amount
    self.balanceOf[receiver] += amount
    return True
