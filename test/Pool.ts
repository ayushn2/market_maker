import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("Pool", () => {
    it("should deploy the Pool contract", async () => {
        // Test implementation goes here
        const [owner] = await ethers.getSigners();
        const Pool = await ethers.getContractFactory("Pool");

        const totalSupply = 1000000;
        const slope = 1;

        const pool = await Pool.deploy(totalSupply, slope);
    });
});