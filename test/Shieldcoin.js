import { expect } from "chai";
import { network } from "hardhat";

const { ethers, networkHelpers } = await network.create("sepoliaFork");

const TOKEN_ADDRESS = "0x530aFbE13370f66921A5ECcAE9D832Dd55eb823C";
const ADMIN = "0xf8c2c497c44C0D47269f43488D8187a744A1d2dd";
const ALICE = ethers.getAddress("0x00000000000000000000000000000000000a11ce");
const BOB = ethers.getAddress("0x0000000000000000000000000000000000000b0b");

describe("Shieldcoin Sepolia deployment", function () {
  let snapshot;
  let token;
  let admin;
  let alice;
  let bob;

  beforeEach(async function () {
    if (snapshot !== undefined) {
      await snapshot.restore();
    }
    snapshot = await networkHelpers.takeSnapshot();

    for (const account of [ADMIN, ALICE, BOB]) {
      await networkHelpers.setBalance(account, ethers.parseEther("100"));
    }

    token = await ethers.getContractAt("Shieldcoin", TOKEN_ADDRESS);
    admin = await ethers.getImpersonatedSigner(ADMIN);
    alice = await ethers.getImpersonatedSigner(ALICE);
    bob = await ethers.getImpersonatedSigner(BOB);
  });

  it("matches the deployed metadata, supply, and administration", async function () {
    expect(await token.name()).to.equal("SHIELDCOIN");
    expect(await token.symbol()).to.equal("SHD");
    expect(await token.decimals()).to.equal(18n);
    expect(await token.totalSupply()).to.equal(ethers.parseEther("1000000000"));
    expect(await token.balanceOf(ADMIN)).to.equal(await token.totalSupply());
    expect(await token.admin()).to.equal(ADMIN);
    expect(await token.paused()).to.equal(false);
  });

  it("transfers balances without changing total supply", async function () {
    const amount = ethers.parseEther("125");
    const adminBalanceBefore = await token.balanceOf(ADMIN);

    await (await token.connect(admin).transfer(ALICE, amount)).wait();

    expect(await token.balanceOf(ALICE)).to.equal(amount);
    expect(await token.balanceOf(ADMIN)).to.equal(adminBalanceBefore - amount);
  });

  it("supports delegated transfers through allowances", async function () {
    const depositedAmount = ethers.parseEther("200");
    const delegatedAmount = ethers.parseEther("75");

    await (await token.connect(admin).transfer(ALICE, depositedAmount)).wait();
    await (await token.connect(alice).approve(BOB, delegatedAmount)).wait();
    await (await token.connect(bob).transferFrom(ALICE, BOB, delegatedAmount)).wait();

    expect(await token.balanceOf(ALICE)).to.equal(depositedAmount - delegatedAmount);
    expect(await token.balanceOf(BOB)).to.equal(delegatedAmount);
    expect(await token.allowance(ALICE, BOB)).to.equal(0n);
  });

  it("reverts transfers with the stored pause reason", async function () {
    const reason = "Scheduled maintenance";
    const amount = ethers.parseEther("10");

    await (await token.connect(admin).transfer(ALICE, amount)).wait();
    await (await token.connect(alice).approve(BOB, amount)).wait();
    await (await token.connect(admin).pause(reason)).wait();

    await expect(token.connect(admin).transfer(BOB, amount)).to.be.revertedWith(reason);
    await expect(token.connect(bob).transferFrom(ALICE, BOB, amount)).to.be.revertedWith(reason);
  });

  it("lets the admin unpause transfers", async function () {
    await (await token.connect(admin).pause("Scheduled maintenance")).wait();
    await (await token.connect(admin).unpause()).wait();
    await (await token.connect(admin).transfer(ALICE, ethers.parseEther("1"))).wait();

    expect(await token.paused()).to.equal(false);
    expect(await token.pauseReason()).to.equal("");
    expect(await token.balanceOf(ALICE)).to.equal(ethers.parseEther("1"));
  });

  it("rejects pause attempts from non-admin accounts", async function () {
    await expect(token.connect(alice).pause("Unauthorized pause"))
      .to.be.revertedWithCustomError(token, "Unauthorized")
      .withArgs(ALICE);
  });

  it("has no mint entry point", async function () {
    const mintInterface = new ethers.Interface(["function mint(address,uint256)"]);
    const data = mintInterface.encodeFunctionData("mint", [ADMIN, ethers.parseEther("1")]);

    await expect(admin.sendTransaction({ to: TOKEN_ADDRESS, data })).to.revert(ethers);
  });
});
