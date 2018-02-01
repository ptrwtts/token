pragma solidity ^0.4.18;

function delegatedTransfer(uint256 _nonce, address _from, address _to, uint256 _value, uint256 _fee, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool) {
     uint256 total = _value.add(_fee);
     require(_from != address(0));
     require(_to != address(0));
     require(total <= balances[_from]);
     require(_nonce > lastSuccessfulNonceForUser[_from]);

     address delegate = msg.sender;
     address token = address(this);
     bytes32 delegatedTxnHash = keccak256(delegate, token, _nonce, _from, _to, _value, _fee);
     address signatory = ecrecover(delegatedTxnHash, _v, _r, _s);
     require(signatory == _from);

     // SafeMath.sub will throw if there is not enough balance.
     balances[signatory] = balances[signatory].sub(total);
     balances[_to] = balances[_to].add(_value);
     balances[delegate] = balances[delegate].add(_fee);
     lastSuccessfulNonceForUser[_from] = _nonce;

     DelegatedTransfer(_from, _to, delegate, _value, _fee);
     Transfer(_from, _to, _value);
     Transfer(_from, delegate, _fee);
     return true;
 }
