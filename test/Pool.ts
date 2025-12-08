import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("Pool", () => {
    it("should deploy the Pool contract", async () => {
        // Test implementation goes here
        const [owner] = await ethers.getSigners();
        const Pool = await ethers.getContractFactory("Pool");

        const initialSupply = ethers.parseUnits("1000", 18);
        const slope = 1;

        const pool = await Pool.deploy(initialSupply, slope);

        // Fund the pool with initial ETH
        await owner.sendTransaction({
            to: pool.target,
            value: ethers.parseEther("10.0"),
        });         


        const tokenPrice = await pool.calculateTokenPrice();
        console.log("Token Price (wei per token):", tokenPrice.toString());
        console.log("Token Price (ETH per token):", ethers.formatUnits(tokenPrice, 18));


        await pool.buy({ value: ethers.parseEther("2.0") });

        const balance = await pool.balances(owner.address);
        console.log("Owner's token balance after purchase:", ethers.formatUnits(balance, 18));
        expect(balance).to.be.gt(0);

        const contractBalance = await ethers.provider.getBalance(pool.target);
        console.log("Contract ETH balance:", ethers.formatEther(contractBalance));

        const newTokenPrice = await pool.calculateTokenPrice();
        console.log("New Token Price (wei per token):", newTokenPrice.toString());

        // Track ETH balance before selling
        const ethBefore = await ethers.provider.getBalance(owner.address);

        // Execute sell and wait for transaction
        const sellTx = await pool.sell(balance);
        const sellReceipt = await sellTx.wait();

        // Track ETH balance after selling
        const ethAfter = await ethers.provider.getBalance(owner.address);

        // Compute net ETH received (compensating for gas spent)
        if (!sellReceipt) throw new Error("Transaction receipt is null");
        const gasUsed = sellReceipt.gasUsed;
        const gasPrice = sellTx.gasPrice;
        const gasCost = gasUsed * gasPrice;

        const ethReceived = ethAfter - ethBefore + gasCost;

        console.log("ETH received from selling:", ethers.formatEther(ethReceived));
        
        const finalBalance = await pool.balances(owner.address);
        console.log("Owner's token balance after selling:", ethers.formatUnits(finalBalance, 18));
        expect(finalBalance).to.equal(0);

        const newContractBalance = await ethers.provider.getBalance(pool.target);
        console.log("Contract ETH balance after selling:", ethers.formatEther(newContractBalance));

        // Price after selling all tokens
        const finalTokenPrice = await pool.calculateTokenPrice();
        console.log("Final Token Price (wei per token):", finalTokenPrice.toString());
    });
});