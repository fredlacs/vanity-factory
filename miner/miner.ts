import "ethers";
import { ethers } from "ethers";
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

  public findMatch(): { salt: string, addr: string} {
    for (let index = 0; index < this.MAX_SALT; index++) {
      const saltEnd = ethers.utils.hexZeroPad(arrayify(index), 12);
      const salt = saltEnd.concat(this.minerAddress.substring(2));

      const addr = ethers.utils.getCreate2Address(
        this.deployerAddress,
        salt,
        this.initCodeHash
      );

      if (this.criteria(addr)) {
        return {
          salt, addr
        }
      };
    }

    throw new Error("Max index reached.");
  }
}

const a = new AddressMiner(
  "0xDAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5",
  "0xCe71065D4017F316EC606Fe4422e11eB2c47c246",
  "0xa91ac850d836e851294d59cc0d97395c7a652b0f908e65f950532322ab0f7723", // erc20 hash
  (addr) =>  addr.startsWith("0x00000")
  
);

console.log(a.findMatch())
