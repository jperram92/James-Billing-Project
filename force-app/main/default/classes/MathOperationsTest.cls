/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 11-20-2024
 * @last modified by  : jamesperram@gmail.com
**/
@isTest
private class MathOperationsTest {
    @isTest
    static void testAddNumbers() {
        Integer a = 5;
        Integer b = 10;
        Integer result = MathOperations.addNumbers(a, b);
        System.assertEquals(15, result, 'The addNumbers method should return the sum of the inputs.');
    }

    @isTest
    static void testMultiplyNumbers() {
        Integer a = 10;
        Integer b = 200;
        Integer result = MathOperations.multiplyNumbers(a, b);
        System.assertEquals(2000, result, 'The multiplyNumbers method should return the product of the inputs.');
    }

    @isTest
    static void testDivideNumbers() {
        Decimal a = 10.20;
        Decimal b = 20.30;
        Decimal result = MathOperations.divideNumbers(a, b);
        System.assertEquals(0.5025, result.setScale(4), 'The divideNumbers method should return the quotient.');
    }

    @isTest
    static void testSubtractNumbers() {
        Integer a = 50;
        Integer b = 10;
        Integer result = MathOperations.subtractNumbers(a, b);
        System.assertEquals(40, result, 'The subtractNumbers method should return the difference.');
    }

    @isTest
    static void testSquareRoot() {
        Decimal a = 4;
        Decimal result = MathOperations.squareRoot(a);
        System.assertEquals(2, result, 'The squareRoot method should return the root.');
    }

    @isTest
    static void testSquareNumber() {
        Integer a = 2;
        Integer result = MathOperations.squareNumber(a);
        System.assertEquals(4, result, 'The squareNumber method should return the square.');
    }

    @isTest
    static void testPiCalculation() {
        Integer decimalPlaces = 6;
        Decimal result = MathOperations.getPi(decimalPlaces);
        System.assertEquals(3.141593, result, 'The getPi method should return Pi rounded to the given decimal places.');
    }

    @isTest
    static void testPowerMethod() {
        Decimal base = 3; 
        Integer exponent = 5;
        Decimal result = MathOperations.power(base, exponent);
        System.assertEquals(243, result, 'The power method should calculate the correct power.');
    }

    @isTest
    static void testModulusOperation() {
        Integer dividend = 4;
        Integer divisor = 2;
        Integer result = MathOperations.modulus(dividend, divisor);
        System.assertEquals(0, result, 'The modulus operation failed.');
    }

    @isTest
    static void testFactorialMethod() {
        Integer n = 4;
        Integer result = MathOperations.factorial(n);
        System.assertEquals(24, result, 'The factorial calculation failed.');
    }
}