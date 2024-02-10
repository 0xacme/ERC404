# NOTICE

This repository has been deprecated, ongoing efforts on ERC404 have moved [here](https://github.com/Pandora-Labs-Org/erc404).

# ERC404

ERC404 is an experimental, mixed ERC20 / ERC721 implementation with native liquidity and fractionalization. While these two standards are not designed to be mixed, this implementation strives to do so in as robust a manner as possible while minimizing tradeoffs.

In it's current implementation, ERC404 effectively isolates ERC20 / ERC721 standard logic or introduces pathing where possible. Pathing could best be described as a lossy encoding scheme in which token amount data and ids occupy shared space under the assumption that negligible token transfers occupying id space do not or do not need to occur.

This standard is entirely experimental and unaudited, while testing has been conducted in an effort to ensure execution is as accurate as possible. The nature of overlapping standards, however, does imply that integrating protocols will not fully understand their mixed function.

## ERC721 Notes

The ERC721 implementation here is a bit non-standard, where tokens are instead burned and minted repeatedly as per underlying / fractional transfers. This is a aspect of the concept's design is deliberate, with the goal of creating an NFT that has native fractionalization, liquidity and encourages some aspects of trading / engagement to farm unique trait sets.

## Licensing

This software is released under the MIT License.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
