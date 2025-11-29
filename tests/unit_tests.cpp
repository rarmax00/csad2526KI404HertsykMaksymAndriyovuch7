#include <gtest/gtest.h>
#include "math_operations.h"

// Tests for add with positive numbers
TEST(AdditionPositiveTests, SmallNumbers) {
    EXPECT_EQ(add(2, 3), 5);
    EXPECT_EQ(add(1, 1), 2);
}

TEST(AdditionPositiveTests, LargerNumbers) {
    EXPECT_EQ(add(100, 200), 300);
    EXPECT_EQ(add(12345, 67890), 80235);
}

// Tests involving zero
TEST(AdditionZeroTests, ZeroAndZero) {
    EXPECT_EQ(add(0, 0), 0);
}

TEST(AdditionZeroTests, ZeroAndNonZero) {
    EXPECT_EQ(add(0, 5), 5);
    EXPECT_EQ(add(-5, 0), -5);
}

// Tests with negative numbers
TEST(AdditionNegativeTests, BothNegative) {
    EXPECT_EQ(add(-2, -3), -5);
    EXPECT_EQ(add(-100, -200), -300);
}

TEST(AdditionNegativeTests, MixedSigns) {
    EXPECT_EQ(add(-10, 4), -6);
    EXPECT_EQ(add(7, -3), 4);
}

// Optional: a main so this test file can be built standalone (if you don't link gtest_main)
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
