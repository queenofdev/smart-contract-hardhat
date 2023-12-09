// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PMX_Token is Ownable,  AccessControl, ERC20Burnable, Pausable {

    uint256 internal _maxAmountMintable = 100_000_000e18;

    constructor() ERC20("PMX game", "PMX") Ownable(msg.sender) {
        mint(msg.sender, 1000000000000000000000000);
    }

    function mint(address _to, uint256 _amount)
        public
        onlyOwner
        whenNotPaused
    {
        require(
            ERC20.totalSupply() + _amount <= _maxAmountMintable,
            "Max mintable exceeded"
        );
        super._mint(_to, _amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        super.transfer(recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        super.transferFrom(sender, recipient, amount);
        return true;
    }

    function pause() external onlyOwner {
        super._pause();
    }

    function unpause() external onlyOwner {
        super._unpause();
    }
}
