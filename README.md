# ERC404

ERC404 is an experimental, mixed ERC20 / ERC721 implementation with native liquidity and fractionalization. While these two standards are not designed to be mixed, this implementation strives to do so in as robust a manner as possible while minimizing tradeoffs.

In it's current implementation, ERC404 effectively isolates ERC20 / ERC721 standard logic or introduces pathing where possible. Pathing could best be described as a lossy encoding scheme in which token amount data and ids occupy shared space under the assumption that negligible token transfers occupying id space do not or do not need to occur.

This standard is entirely experimental and unaudited, while testing has been conducted in an effort to ensure execution is as accurate as possible. The nature of overlapping standards, however, does imply that integrating protocols will not fully understand their mixed function.

## ERC721 Notes

The ERC721 implementation here is a bit non-standard, where tokens are instead burned and minted repeatedly as per underlying / fractional transfers. This is a aspect of the concept's design is deliberate, with the goal of creating an NFT that has native fractionalization, liquidity and encourages some aspects of trading / engagement to farm unique trait sets.

## Licensing

This source code is unlicensed, and free for anyone to use as they please. Any effort to improve source or explore the concept further is encouraged!
