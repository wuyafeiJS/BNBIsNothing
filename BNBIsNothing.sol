// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BNBIsNothing is ERC20, Ownable {
    // 固定供应量：1亿枚代币
    uint256 public constant TOTAL_SUPPLY = 100_000_000 * 10**18; // 100,000,000 * 10^18
    // 税收：1%
    uint256 public constant TAX_FEE = 1; // 1% 每次交易
    // 营销钱包地址（税收接收地址）
    address public marketingWallet = 0xcD86585251351923cFCA52Cd3143947469CeAed0; // 替换为你的实际地址

    constructor() ERC20("BNBIsNothing", "BNBN") Ownable(msg.sender) {
        // 给自己分配10%（1000万枚）
        _mint(msg.sender, TOTAL_SUPPLY * 10 / 100); // 10,000,000 * 10^18
        // 剩余90%留在合约中，供后续分配
       
    }

    // 重写transfer函数，加入1%税收
    function transfer(address to, uint256 amount) public override returns (bool) {
        uint256 taxAmount = amount * TAX_FEE / 100; // 计算1%税收
        uint256 netAmount = amount - taxAmount;     // 实际转账金额

        _transfer(msg.sender, marketingWallet, taxAmount); // 税收给营销钱包
        _transfer(msg.sender, to, netAmount);              // 剩余给接收者
        return true;
    }

    // 重写transferFrom函数，确保税收逻辑一致
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        uint256 taxAmount = amount * TAX_FEE / 100;
        uint256 netAmount = amount - taxAmount;

        _transfer(from, marketingWallet, taxAmount);
        _transfer(from, to, netAmount);
        
        // 更新授权额度
        uint256 currentAllowance = allowance(from, msg.sender);
        require(currentAllowance >= amount, "Insufficient allowance");
        _approve(from, msg.sender, currentAllowance - amount);
        return true;
    }

    // 手动分配代币（仅限拥有者，例如社区空投或流动性）
    function distribute(address to, uint256 amount) public onlyOwner {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, to, amount);
    }

    // 销毁代币（可选，用于减少供应）
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // 更新营销钱包地址（可选）
    function setMarketingWallet(address newWallet) public onlyOwner {
        require(newWallet != address(0), "Invalid address");
        marketingWallet = newWallet;
    }
}