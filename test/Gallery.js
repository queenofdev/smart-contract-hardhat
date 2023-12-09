const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");
// const { web3 } = require("web3");

describe("Lock", function () {
  async function deployEnv() {
    const [owner, otherAccount] = await ethers.getSigners();
    const feeDestination = "0xd41C9BafaAac35d479C95196c5d3bf0BB007fDe7";
    const protocolFeePercent = 50;
    const artistFeePercent = 50;
    const uri = "https://degenart-dev.infura-ipfs.io/ipfs/";

    const PhotoNFT = await ethers.getContractFactory("PhotoNFT");
    const gallery = await PhotoNFT.deploy(
      feeDestination,
      protocolFeePercent,
      artistFeePercent,
      uri
    );

    return {
      gallery,
      feeDestination,
      protocolFeePercent,
      artistFeePercent,
      uri,
      owner,
      otherAccount,
    };
  }
  describe("Deployment", function () {
    it("Should set the protocolFeeDestination to 0xd41C9BafaAac35d479C95196c5d3bf0BB007fDe7", async function () {
      const { gallery, feeDestination } = await loadFixture(deployEnv);
      expect(await gallery.protocolFeeDestination()).to.equal(feeDestination);
    });

    it("Should set the protocolFeePercent to 50", async function () {
      const { gallery, protocolFeePercent } = await loadFixture(deployEnv);
      expect(await gallery.protocolFeePercent()).to.equal(protocolFeePercent);
    });

    it("Should set the artistFeePercent to 50", async function () {
      const { gallery, artistFeePercent } = await loadFixture(deployEnv);
      expect(await gallery.artistFeePercent()).to.equal(artistFeePercent);
    });
  });

  describe("SetFeeDestination", function () {
    it("Should set the fee destination correctly", async function () {
      const { gallery, otherAccount } = await loadFixture(deployEnv);
      const newFeeDestination = otherAccount.address;
      await gallery.setFeeDestination(newFeeDestination);
      expect(await gallery.protocolFeeDestination()).to.equal(
        newFeeDestination
      );
    });
  });

  describe("SetProtocolFeePercent", function () {
    it("Should set the protocal fee percent correctly", async function () {
      const { gallery } = await loadFixture(deployEnv);
      const newFeePercent = 10;
      await gallery.setProtocolFeePercent(newFeePercent);
      expect(await gallery.protocolFeePercent()).to.equal(newFeePercent);
    });
  });

  describe("setArtistFeePercent", function () {
    it("Should set the artist fee percent correctly", async function () {
      const { gallery } = await loadFixture(deployEnv);
      const newFeePercent = 10;
      await gallery.setArtistFeePercent(newFeePercent);
      expect(await gallery.artistFeePercent()).to.equal(newFeePercent);
    });
  });

  describe("Mint Art", function () {
    it("Should mint an art correctly and minted token counter will be 1", async function () {
      const { gallery, owner } = await loadFixture(deployEnv);
      const artUrl = "c";
      let feeAmount = ethers.parseUnits("0.001", 18);
      const sender = owner.address;
      //   const token = await gallery.mintArtwork(artUrl, {
      //     value: feeAmount,
      //     from: sender,
      //   });

      const tokenIdCounter = await gallery.getTokenIdCounter();
      let expectedMetadataURL = "metadata/" + tokenIdCounter + ".json";
      let metadataURL = await gallery.artworks(tokenIdCounter)["metadataURL"];
      expect(
        await gallery.mintArtwork(artUrl, { value: feeAmount, from: sender })
      )
        .to.emit(gallery, ArtworkMinted)
        .withArgs(1, metadataURL);
      expect(await gallery.getTokenIdCounter()).to.equal(1);
    });
  });

  describe("Buy token", function () {
    it("should buy token and transfer fees correctly", async () => {
      const { gallery, owner } = await loadFixture(deployEnv);
      const artUrl = "0xfbf68eb6f208b5ffc3e748ac547ceb530bca1bbe";
      let feeAmount = ethers.parseUnits("0.001", 18);
      const sender = owner.address;
      const tokenId = await gallery.mintArtwork(artUrl, {
        value: feeAmount,
        from: sender,
      });

      const tokeCount = await gallery.getTokenIdCounter();
      const buyTokenPrice = ethers.formatUnits(
        await gallery.getBuyPriceAfterFee(1, 3)
      );

      const buyToken = await gallery.buyToken(1, 3, {
        value: ethers.parseUnits(buyTokenPrice, 18),
        from: sender,
      });
      expect((await gallery.artworks(1))[1]).to.equal(4);
    });
  });

  describe("Sell token", function () {
    it("should sell token and transfer fees correctly", async () => {
      const { gallery, owner } = await loadFixture(deployEnv);
      const artUrl = "0xfbf68eb6f208b5ffc3e748ac547ceb530bca1bbe";
      let feeAmount = ethers.parseUnits("0.001", 18);
      const sender = owner.address;
      const tokenId = await gallery.mintArtwork(artUrl, {
        value: feeAmount,
        from: sender,
      });

      const buyTokenPrice = ethers.formatUnits(
        await gallery.getBuyPriceAfterFee(1, 3)
      );

      const sellTokenPrice = ethers.formatUnits(
        await gallery.getSellPriceAfterFee(1, 3)
      );

      const buyToken = await gallery.buyToken(1, 3, {
        value: ethers.parseUnits(buyTokenPrice, 18),
        from: sender,
      });

      const sellToken = await gallery.sellToken(1, 2, {
        value: ethers.parseUnits(sellTokenPrice, 18),
        from: sender,
      });
      expect((await gallery.artworks(1))[1]).to.equal(2);
    });
    //   describe("Mint Art", function () {
    //     it("Should get price correctly", async function () {
    //         const { gallery } = await loadFixture(deployEnv);
    //         const price = await gallery.getBuyPrice(1 , 3);
    //         console.log(price);
    //         // expect(await gallery.getBuyPrice(1 , 3)).to.equal(1);
    //       });
    //   });
  });
});
