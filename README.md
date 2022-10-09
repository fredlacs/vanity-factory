# VanityFactory

VanityFactory allow one to issue bounty for vanity address. Miner can mine the salt used for the CREATE2 deployment and the highest scored submission will receive the bounty after the deadline. To prevent frontrunning, the first 20 bytes of the salt will be the miner's address (which will receive the bounty).

## How To Request

Send ether to `VanityFactory.ask(...)` with the contract inithash, desired scorer, deadline and minimum score required

## How To Mine

- Option 1

  ```npx ts-node ./miner/miner.ts```

- Option 2

  ```FOUNDRY_FUZZ_RUNS=99999999 forge test -vvv```

## TODO
 - Use unique deployers instead of mapping with init code hash as key
 - Include option to `deployAndCall` for things such as initialize
