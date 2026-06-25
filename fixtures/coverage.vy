# @version ^0.4.0

from vyper.interfaces import ERC20

implements: ERC20

interface Oracle:
    def price(asset: address) -> uint256: view
    def update(asset: address): nonpayable

event PriceUpdated:
    asset: indexed(address)
    old_price: uint256
    new_price: uint256

struct Observation:
    price: uint256
    timestamp: uint256

enum Role:
    ADMIN
    REPORTER

MAX_OBSERVATIONS: constant(uint256) = 16
OWNER: immutable(address)

last_observation: public(Observation)
observations: public(HashMap[address, Observation])
roles: public(HashMap[address, Role])

@deploy
def __init__(owner: address):
    OWNER = owner
    self.roles[owner] = Role.ADMIN

@internal
@view
def _is_admin(user: address) -> bool:
    return self.roles[user] == Role.ADMIN

@external
@view
def price(asset: address) -> uint256:
    return self.observations[asset].price

@external
def update(asset: address, new_price: uint256):
    assert self._is_admin(msg.sender), "not admin"
    old: uint256 = self.observations[asset].price
    self.observations[asset] = Observation(price=new_price, timestamp=block.timestamp)
    self.last_observation = self.observations[asset]
    log PriceUpdated(asset=asset, old_price=old, new_price=new_price)

@external
def bounded_sum(values: DynArray[uint256, MAX_OBSERVATIONS]) -> uint256:
    total: uint256 = 0
    # NOTE: tree-sitter-vyper currently errors on modern typed loop variables
    # (`for value: uint256 in values:`), so this fixture keeps the grammar smoke
    # test on the parser-supported form.
    for value in values:
        if value == 0:
            continue
        total += value
    return total
