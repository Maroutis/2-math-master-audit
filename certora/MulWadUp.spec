/*
* Verification of MulWadUp for MathMasters
*/

methods {
    function mulWadUp(uint256 x, uint256 y) external returns uint256 envfree;
}

definition WAD() returns uint256 = 1000000000000000000; // the constant variable

rule check_testMulWadUpFuzz(uint256 x, uint256 y) {
    require(x == 0 || y == 0 || y <= assert_uint256(max_uint256/ x)); //max_uint256 = type(uint256).max
    uint256 result = mulWadUp(x, y);
    mathint expected = x * y == 0 ? 0 : (x * y - 1) / WAD() + 1;
    assert(result == assert_uint256(expected));
}
// max_uint256 is of type mathint and not uint256. The mathint type can represent an integer of any size and for this reason it can never overflow or underflow.

// invariant are similar to rules, except than unlike rules where there is a bunch of stuff, invariants have this one liner
invariant check_testMulWadUp()
    true == true;


invariant mulWadUpInvariant(uint256 x, uint256 y)

    mulWadUp(x, y) == assert_uint256(x * y == 0 ? 0 : (x * y - 1) / WAD() + 1) // this invariant should hold so long as this precondition/preserved block holds
    {
        preserved {
            require(x == 0 || y == 0 || y <= assert_uint256(max_uint256/ x));
        }
    }