// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.3;

import {Base_Test, console2} from "./Base_Test.t.sol";
import {MathMasters} from "src/MathMasters.sol";
import {Harness} from "./Harness.sol";

contract MathMastersTest is Base_Test {
    function testMulWad() public {
        assertEq(MathMasters.mulWad(2.5e18, 0.5e18), 1.25e18);
        assertEq(MathMasters.mulWad(3e18, 1e18), 3e18);
        assertEq(MathMasters.mulWad(369, 271), 0);
    }

    //@note tested with forge test --debug testMulRevert
    function testMulRevert() public {
        MathMasters.mulWad(type(uint256).max, type(uint256).max);
    }

    function testMulWadFuzz(uint256 x, uint256 y) public pure {
        // Ignore cases where x * y overflows.
        unchecked {
            if (x != 0 && (x * y) / x != y) return;
        }
        assert(MathMasters.mulWad(x, y) == (x * y) / 1e18);
    }

    function testMulWadUp() public {
        assertEq(MathMasters.mulWadUp(2.5e18, 0.5e18), 1.25e18);
        assertEq(MathMasters.mulWadUp(3e18, 1e18), 3e18);
        assertEq(MathMasters.mulWadUp(369, 271), 1);
    }

    function testMulWapUpUnit() public {
        uint256 x = 35489383352426383734;
        uint256 y = 77835437364547490833;
        uint256 result = MathMasters.mulWadUp(x, y);
        uint256 resultDown = MathMasters.mulWad(x, y);
        //15612949711073402678
        console2.log(result);
        //15612949711073402675
        console2.log(x * y / MathMasters.WAD + 1);
        console2.log((x * y - 1));
        console2.log((x * y - 1) / MathMasters.WAD);
        console2.log((x * y - 1) / MathMasters.WAD + 1);
        //15612949711073402674
        console2.log(resultDown);
    }

    function testMulWadUpFuzz(uint256 x, uint256 y) public {
        // We want to skip the case where x * y would overflow.
        // Since Solidity 0.8.0 checks for overflows by default,
        // we cannot just multiply x and y as this could revert.
        // Instead, we can ensure x or y is 0, or
        // that y is less than or equal to the maximum uint256 value divided by x
        if (x == 0 || y == 0 || y <= type(uint256).max / x) {
            uint256 result = MathMasters.mulWadUp(x, y);
            uint256 expected = x * y == 0 ? 0 : (x * y - 1) / 1e18 + 1;
            assertEq(result, expected);
        }
        // If the conditions for x and y are such that x * y would overflow,
        // this function will simply not perform the assertion.
        // In a testing context, you might want to handle this case differently,
        // depending on whether you want to consider such an overflow case as passing or failing.
    }
    // @note halmos --function check_testMulWadUpFuzz_halmos --solver-timeout-assertion 0

    function check_testMulWadUpFuzz_halmos(uint256 x, uint256 y) public pure {
        if (x == 0 || y == 0 || y <= type(uint256).max / x) {
            uint256 result = MathMasters.mulWadUp(x, y);
            uint256 expected = x * y == 0 ? 0 : (x * y - 1) / 1e18 + 1;
            assert(result == expected);
        }
    }

    function testSqrt() public {
        assertEq(MathMasters.sqrt(0), 0);
        assertEq(MathMasters.sqrt(1), 1);
        assertEq(MathMasters.sqrt(2704), 52);
        assertEq(MathMasters.sqrt(110889), 333);
        assertEq(MathMasters.sqrt(32239684), 5678);
        assertEq(MathMasters.sqrt(type(uint256).max), 340282366920938463463374607431768211455);
    }
    // halmos --function testSqrtFuzzUni --loop 1000 there is a path explosion problem here. Will never work

    function testSqrtFuzzUni(uint256 x) public pure {
        assert(MathMasters.sqrt(x) == uniSqrt(x));
    }

    function testSqrtFuzzSolmate(uint256 x) public pure {
        assert(MathMasters.sqrt(x) == solmateSqrt(x));
    }

    function testSqrtWithCertoraEdgeCase() public pure {
        uint256 x = 0xffff2b00000000;
        assert(MathMasters.sqrt(x) == solmateSqrt(x));
    }

    // This test passes maby by adding more runs it could find an issue. Halmos founds a bunch of examples though
    function testHarnessFuzz(uint256 x) public {
        Harness h = new Harness();
        assertEq(h.mathMastersTopHalf(x), h.solmateTopHalf(x));
    }

    function testHarnessSolmate() public {
        uint256 x = 0xffff2b00000000;
        Harness h = new Harness();
        assertEq(h.mathMastersTopHalf(x), h.solmateTopHalf(x));
    }

    // Both these fuzz tests do not catch any issues
    // 1. The harder way, with formal verifications
    // 2. The hint that should have tipped you off
    //@note
    // command to use the soldity compiler for symbolic execution :
    // solc --model-checker-engine chc --model-checker-targets overflow SmallSol.sol
    // For asserts (need to add asserts in the contract : ) solc --model-checker-engine chc --model-checker-targets asset SmallSol.sol
    // https://secure-contracts.com/
}
