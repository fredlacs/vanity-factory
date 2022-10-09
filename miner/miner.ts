import "ethers";
import { BigNumber, ethers } from "ethers";
import { arrayify } from "ethers/lib/utils";

class AddressMiner {
  private MAX_SALT = 281474976710655; // max value in 12 bytes

  constructor(
    public readonly minerAddress: string,
    public readonly deployerAddress: string,
    public readonly initCodeHash: string,
    public readonly criteria: (address: string) => boolean
  ) {
    // TODO: check the arg lengths
  }

  public findMatch(): string {
    for (let index = 0; index < this.MAX_SALT; index++) {
      const saltEnd = ethers.utils.hexZeroPad(arrayify(20), 12).substring(2);
      const salt = this.minerAddress.concat(saltEnd);

      const addr = ethers.utils.getCreate2Address(
        this.deployerAddress,
        salt,
        this.initCodeHash
      );

      if(this.criteria(addr)) return salt;
    }

    throw new Error("Max index reached.");
  }
}

const a = new AddressMiner(
  "0xDAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5",
  "0x68b3465833fb72a70ecdf485e0e4c7bd8665fc45",
  "0x10c927fa851e18ba5b0e93e7249cd727bfa621da83e2ae14bb00ce88b71c6955",
  () => true
);
