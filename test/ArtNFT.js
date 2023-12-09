const {
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");
// const { web3 } = require("web3");

describe("ArtNFT Contract Test", function () {
    async function deployEnv() {
        const [owner, otherAccount] = await ethers.getSigners();

        const art = await ethers.getContractFactory("ArtNFT");
        const artNFT = await art.deploy();
        const _name = "Ichiro-art-mint";
        const _symbol = "ArtNFT";
        return {
            artNFT,
            _name,
            _symbol
        };


        // https://i.seadn.io/s/raw/files/7c828410dcb09a5db34c089c0814f2ba.png  art url
    }
    describe("Deployment", function () {
        it("Should set the name to Ichiro-art-mint", async function () {
            const { artNFT, _name, _symbol } = await loadFixture(deployEnv);
            expect(await artNFT.name()).to.equal(_name);
            expect(await artNFT.symbol()).to.equal(_symbol);
        });

        it("Should set the symbol to ArtNFT", async function () {
            const { artNFT, _name, _symbol } = await loadFixture(deployEnv);
            expect(await artNFT.symbol()).to.equal(_symbol);
        });
    });

    describe("Art Mint", function () {
        it("Should set the currentArtId to 2 ", async function () {
            const { artNFT } = await loadFixture(deployEnv);
            let price = ethers.parseUnits("0.01", 18);
            const artUrl = 'https://i.seadn.io/s/raw/files/7c828410dcb09a5db34c089c0814f2ba.png';
            const artName = "Monkey"
            const art = await artNFT.mint(artUrl, price, artName);
            expect(await artNFT.currentArtId()).to.equal(2);
        });

        it("Should mint a new art and get its data", async function () {
            const { artNFT } = await loadFixture(deployEnv);
            let price = ethers.parseUnits("0.01", 18);
            const artUrl = 'https://i.seadn.io/s/raw/files/7c828410dcb09a5db34c089c0814f2ba.png';
            const artName = "Monkey"
            await artNFT.mint(artUrl, price, artName);
            const newArtId = 1;
         
            const mintedArt = await artNFT.getArt(newArtId);
            expect(mintedArt.artId).to.equal(newArtId);
            expect(mintedArt.ownerAddress).to.equal(await artNFT.ownerOf(newArtId));
            // expect(mintedArt.artName).to.equal(artName);
            // expect(mintedArt.artPrice.toString()).to.equal(price.toString());
            // expect(mintedArt.ipfsHashOfArt).to.equal(artUrl);
            // expect(mintedArt.status).to.equal(0);
            // const updatedArtId = await artNFT.currentArtId();
            // expect(updatedArtId).to.equal(newArtId + 1);
        });


    });

});
