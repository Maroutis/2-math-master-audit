/*
* Verification of MulWadUp for MathMasters
*/


methods {
    function mathMastersSqrt(uint256) external returns uint256 envfree;
    function uniSqrt(uint256) external returns uint256 envfree;
    function mathMastersTopHalf(uint256) external returns uint256 envfree;
    function solmateTopHalf(uint256) external returns uint256 envfree;
}
    // this passes for optimistic_loop = true. But it unwinds the loop so it doesnt actually verify
    // Running this will will lead to path explosion problem
    // rule uniSqrtMatchesMathMastersSqrt(uint256 x) {
    //     assert(mathMastersSqrt(x) == uniSqrt(x));
    // }

    rule solmateTopHalfMatchesMathMastersTopHalf(uint256 x){
        // require(x != 0xffff2b00000000); Need to add all edges cases that do not revert the sqrt here
        assert(mathMastersTopHalf(x) == solmateTopHalf(x));
    }

    
