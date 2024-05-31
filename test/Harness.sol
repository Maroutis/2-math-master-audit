// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MathMasters} from "../src/MathMasters.sol";

// wrapping this library in a harness. The certora prover cannot reason that this harness cannot affect the return value of the codebase. Certora is saying that wrapping in harness not catch all the bugs
contract Harness {
    function mulWadUp(uint256 x, uint256 y) external pure returns (uint256) {
        return MathMasters.mulWadUp(x, y);
    }

    function uniSqrt(uint256 y) external pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function mathMastersSqrt(uint256 x) external pure returns (uint256 z) {
        z = MathMasters.sqrt(x);
    }

    function solmateTopHalf(uint256 x) external pure returns (uint256 z) {
        assembly {
            let y := x

            z := 181
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }
            z := shr(18, mul(z, add(y, 65536)))
        }
    }

    function mathMastersTopHalf(uint256 x) external pure returns (uint256 z) {
        assembly {
            z := 181

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffffff, x)) // shift r left by 7 if x > 2**136 - 1
            r := or(r, shl(6, lt(0xffffffffffffffffff, shr(r, x)))) // 2**72 - 1
            r := or(r, shl(5, lt(0xffffffffff, shr(r, x)))) // 2**40 - 1
            // Correct: 16777215 0xffffff
            r := or(r, shl(4, lt(0xffffff, shr(r, x)))) // 16777002 is a weird number 2**24 - 1 = 16777215
            z := shl(shr(1, r), z)

            z := shr(18, mul(z, add(shr(r, x), 65536)))
        }
    }
}
