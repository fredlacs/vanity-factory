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
  "0x68b3465833fb72a70ecdf485e0e4c7bd8665fc45",
  "0x906e1c57281f7ecdb765ba6b964f4d641aa3ec648e6775ed9006589aaad5b135", // erc20 hash
  (addr) =>  addr.startsWith("0x000000")
  
);

console.log(a.findMatch())
